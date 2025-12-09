//+------------------------------------------------------------------+
//|                               RegimeDetectionIndicator.mq5       |
//|------------------------------------------------------------------|
//|  Author      : Mehrdad Shoghi                                    |
//|  Version     : 3.08                                              |
//|  Platform    : MetaTrader 5 (MQL5, Indicator)                    |
//|------------------------------------------------------------------|
//|  Purpose                                                         |
//|  -------                                                         |
//|  This indicator performs *regime detection* using:               |
//|    1) A rolling linear regression SLOPE over the last N bars     |
//|    2) Realized volatility (stddev of log-returns)                |
//|    3) Auto-adaptive thresholds based on standard deviations      |
//|       (no hard-coded magic numbers)                              |
//|                                                                  |
//|  Trend regimes are classified using the sign & strength of the   |
//|  regression slope, while volatility regimes are derived from a   |
//|  z-score of realized volatility.                                 |
//|                                                                  |
//|  The final state is mapped into intuitive labels and colors:     |
//|                                                                  |
//|    - TREND_UP + HIGH_VOL    -> "EXPLOSIVE UP"    (Dark Green)    |
//|    - TREND_UP + NORMAL/LOW  -> "STEADY UP"       (Lime)          |
//|    - TREND_DOWN + HIGH_VOL  -> "CRASH / DUMP"    (Dark Red)      |
//|    - TREND_DOWN + NORMAL/LOW-> "SLOW BLEED"      (Light Coral)   |
//|    - TREND_MEAN             -> "SIDEWAYS"        (Gold)          |
//|                                                                  |
//|  The line in the subwindow and the main-chart background are     |
//|  always color-consistent with the detected regime.               |
//|                                                                  |
//|  Non-Repainting Behavior                                         |
//|  ------------------------                                        |
//|  This indicator is explicitly designed to be *bar-close stable*: |
//|   - During the open bar, Price, Slope, and Volatility are        |
//|     "latched" to the previous closed bar's values.               |
//|   - No regime, color, or line noise while the current bar is     |
//|     forming.                                                     |
//|                                                                  |
//|  In other words: the regime only truly updates on bar close.     |
//|  This makes it suitable for both visual analysis and strategy    |
//|  integration without intra-bar repainting.                       |
//+------------------------------------------------------------------+
#property copyright "Mehrdad Shoghi"
#property version   "3.08"
#property strict

#property indicator_separate_window
#property indicator_plots   1
#property indicator_buffers 4

//--- Plot 1: Trend Slope Line (Multi-Colored)
#property indicator_label1  "TrendSlope"
#property indicator_type1   DRAW_COLOR_LINE

// COLOR INDEX MAPPING:
// 0 = Gray       (Init / Unknown)
// 1 = DarkGreen  (EXPLOSIVE UP: strong uptrend + high vol)
// 2 = Lime       (STEADY UP: uptrend + normal/low vol)
// 3 = DarkRed    (CRASH / DUMP: strong downtrend + high vol)
// 4 = LightCoral (SLOW BLEED: downtrend + normal/low vol)
// 5 = Gold       (SIDEWAYS: mean-reverting regime)
#property indicator_color1  clrDarkGray, clrDarkGreen, clrLime, clrDarkRed, clrLightCoral, clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

//==================================================================
//  INPUTS
//==================================================================
input ENUM_APPLIED_PRICE InpPriceType       = PRICE_CLOSE; // Applied price
input int                InpLookback        = 30;          // Lookback for trend & vol

// Sensitivity in StdDevs / Z-Score (no fixed thresholds)
input double             InpTrendSensitivity= 1.5;         // Trend trigger (StdDevs)
input double             InpVolSensitivity  = 1.0;         // Vol trigger (Z-Score)

input bool               InpShowPanel       = true;        // Show top-left state panel
input bool               InpShadeBackground = true;        // Shade main chart background
input bool               InpShowRegLine     = true;        // Show black regression line on price chart
input bool               InpEnableAlerts    = true;        // Alerts on regime change

//==================================================================
//  BUFFERS
//==================================================================
double SlopeBuffer[];       // Plot data: regression slope
double SlopeColorIndex[];   // Plot color index
double VolBuffer[];         // Realized volatility (calc)
double PriceBuffer[];       // Applied price (calc)

//==================================================================
//  ENUMS & STATE
//==================================================================
enum TREND_REGIME { TREND_UNKNOWN=0, TREND_UP=1, TREND_DOWN=2, TREND_MEAN=3 };
enum VOL_REGIME   { VOL_UNKNOWN=0, VOL_NORMAL=1, VOL_HIGH=2, VOL_LOW=3 };

// Object names
string PanelName    = "RegimePanel_BarByBar";
string RectPrefixTr = "RegimeBG_Bar_";
string RegLineName  = "RegimeLine_Bar";

// Last regime state for alerts
int LastTrendRegime = -1;
int LastVolRegime   = -1;

//==================================================================
//  HELPER: Get applied price
//==================================================================
double GetAppliedPrice(const int index,
                       const double &open[],
                       const double &high[],
                       const double &low[],
                       const double &close[])
{
   switch(InpPriceType)
   {
      case PRICE_OPEN:      return(open[index]);
      case PRICE_HIGH:      return(high[index]);
      case PRICE_LOW:       return(low[index]);
      case PRICE_MEDIAN:    return(0.5 * (high[index] + low[index]));
      case PRICE_TYPICAL:   return((high[index] + low[index] + close[index]) / 3.0);
      case PRICE_WEIGHTED:  return((high[index] + low[index] + 2.0 * close[index]) / 4.0);
      case PRICE_CLOSE:
      default:              return(close[index]);
   }
}

//==================================================================
//  HELPER: Convert (trend, vol) → human-readable label
//==================================================================
string TrendRegimeText(int trend, int vol)
{
   if(trend == TREND_MEAN)
      return("SIDEWAYS (Gold)");

   if(trend == TREND_UP)
   {
      if(vol == VOL_HIGH) return("EXPLOSIVE UP (Dark Green)");
      return("STEADY UP (Light Green)");
   }

   if(trend == TREND_DOWN)
   {
      if(vol == VOL_HIGH) return("CRASH/DUMP (Dark Red)");
      return("SLOW BLEED (Light Red)");
   }

   return("UNKNOWN");
}

//==================================================================
//  PANEL & DRAWING HELPERS
//==================================================================
void UpdateRegimePanel(int trendRegime, int volRegime)
{
   if(!InpShowPanel)
      return;

   string txt = "State: " + TrendRegimeText(trendRegime, volRegime);

   if(ObjectFind(0, PanelName) < 0)
   {
      ObjectCreate(0, PanelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, PanelName, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
      ObjectSetInteger(0, PanelName, OBJPROP_XDISTANCE,  50);
      ObjectSetInteger(0, PanelName, OBJPROP_YDISTANCE,  50);
      ObjectSetInteger(0, PanelName, OBJPROP_FONTSIZE,   10);
      ObjectSetString (0, PanelName, OBJPROP_FONT,       "Arial");
   }

   ObjectSetString (0, PanelName, OBJPROP_TEXT,  txt);
   ObjectSetInteger(0, PanelName, OBJPROP_COLOR, clrBlack);
}

// Shade entire main-chart background between bar i-1 and i
void ShadeBackground(int i, color bgCol, const datetime &time[])
{
   if(!InpShadeBackground || i <= 0)
      return;

   string name = RectPrefixTr + IntegerToString(i);

   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);

   if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0,
                    time[i],   1.0e10,
                    time[i-1], -1.0e10))
      return;

   ObjectSetInteger(0, name, OBJPROP_COLOR, bgCol);
   ObjectSetInteger(0, name, OBJPROP_BACK,  true);
   ObjectSetInteger(0, name, OBJPROP_FILL,  true);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
}

// Draw black regression line on main price chart for the last N bars
void DrawRegressionLine(int i, const datetime &time[])
{
   if(!InpShowRegLine)
      return;

   int n = InpLookback;
   if(i < n)
      return;

   // We intentionally use PriceBuffer, which has already been "latched"
   // for the active bar to ensure bar-close-stable behavior.
   int startIdx = i - n + 1;

   double Sx  = 0.0;
   double Sy  = 0.0;
   double Sxx = 0.0;
   double Sxy = 0.0;

   for(int j = 0; j < n; j++)
   {
      double x = j;
      double y = PriceBuffer[startIdx + j];
      Sx  += x;
      Sy  += y;
      Sxx += x * x;
      Sxy += x * y;
   }

   double denom = (double)n * Sxx - Sx * Sx;
   if(denom == 0.0)
      return;

   // Regression line: y = m * x + b
   double m = ((double)n * Sxy - Sx * Sy) / denom;
   double b = (Sy - m * Sx) / (double)n;

   double priceStart = m * 0.0          + b;
   double priceEnd   = m * (double)(n-1)+ b;

   if(ObjectFind(0, RegLineName) < 0)
   {
      ObjectCreate(0, RegLineName, OBJ_TREND, 0, 0, 0);
      ObjectSetInteger(0, RegLineName, OBJPROP_COLOR,    clrBlack);
      ObjectSetInteger(0, RegLineName, OBJPROP_WIDTH,    3);
      ObjectSetInteger(0, RegLineName, OBJPROP_RAY_RIGHT,false);
   }

   ObjectSetInteger(0, RegLineName, OBJPROP_TIME,  0, time[startIdx]);
   ObjectSetDouble (0, RegLineName, OBJPROP_PRICE, 0, priceStart);
   ObjectSetInteger(0, RegLineName, OBJPROP_TIME,  1, time[i]);
   ObjectSetDouble (0, RegLineName, OBJPROP_PRICE, 1, priceEnd);
}

//==================================================================
//  OnInit
//==================================================================
int OnInit()
{
   // Buffers:
   // 0: SlopeBuffer       (plot data)
   // 1: SlopeColorIndex   (plot color index)
   // 2: VolBuffer         (calc)
   // 3: PriceBuffer       (calc)
   SetIndexBuffer(0, SlopeBuffer,       INDICATOR_DATA);
   SetIndexBuffer(1, SlopeColorIndex,   INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, VolBuffer,         INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, PriceBuffer,       INDICATOR_CALCULATIONS);

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Regime_Stable(" + IntegerToString(InpLookback) + ")");

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);

   // Zero line for slope
   IndicatorSetInteger(INDICATOR_LEVELS, 1);
   IndicatorSetDouble (INDICATOR_LEVELVALUE, 0, 0.0);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrGray);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, 0, STYLE_DOT);

   return(INIT_SUCCEEDED);
}

//==================================================================
//  OnCalculate  (core engine)
//==================================================================
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int n      = InpLookback;
   int minReq = n * 2 + 2;   // need enough bars for both slopes/vol and their rolling stats
   if(rates_total <= minReq)
      return(0);

   int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;
   if(start < 0) start = 0;

   //===============================================================
   // 1) PRICE SERIES (with non-repainting latch on last bar)
   //===============================================================
   for(int i = start; i < rates_total; i++)
   {
      PriceBuffer[i] = GetAppliedPrice(i, open, high, low, close);

      // FIX 1: LATCH PRICE ON ACTIVE BAR
      // For the last (currently forming) bar, we COPY the previous
      // closed bar's value. This prevents slope/vol from dancing
      // with every tick.
      if(i == rates_total - 1 && i > 0)
      {
         PriceBuffer[i] = PriceBuffer[i-1];
      }
   }

   //===============================================================
   // 2) TREND SLOPE (rolling regression over N bars)
   //    with non-repainting latch on last bar
   //===============================================================
   for(int i = MathMax(start, n); i < rates_total; i++)
   {
      // FIX 2: LATCH SLOPE ON ACTIVE BAR
      if(i == rates_total - 1 && i > 0)
      {
         SlopeBuffer[i] = SlopeBuffer[i-1];
         continue;
      }

      double Sx  = 0.0;
      double Sy  = 0.0;
      double Sxx = 0.0;
      double Sxy = 0.0;

      int first = i - n + 1;
      for(int j = 0; j < n; j++)
      {
         double x = j;
         double y = PriceBuffer[first + j];
         Sx  += x;
         Sy  += y;
         Sxx += x * x;
         Sxy += x * y;
      }

      double denom = (double)n * Sxx - Sx * Sx;
      SlopeBuffer[i] = (denom != 0.0) ? (((double)n * Sxy - Sx * Sy) / denom) : 0.0;
   }

   //===============================================================
   // 3) REALIZED VOLATILITY (std of log returns over N bars)
   //    with non-repainting latch on last bar
   //===============================================================
   for(int i = MathMax(start, n); i < rates_total; i++)
   {
      // FIX 3: LATCH VOL ON ACTIVE BAR
      if(i == rates_total - 1 && i > 0)
      {
         VolBuffer[i] = VolBuffer[i-1];
         continue;
      }

      double sumR  = 0.0;
      double sumR2 = 0.0;
      int    count = 0;

      int first = i - n + 1;
      for(int j = first; j < i; j++)
      {
         if(PriceBuffer[j] > 0.0 && PriceBuffer[j+1] > 0.0)
         {
            double r = MathLog(PriceBuffer[j+1] / PriceBuffer[j]);
            sumR  += r;
            sumR2 += r * r;
            count++;
         }
      }

      if(count > 1)
      {
         double meanR = sumR / (double)count;
         double varR  = (sumR2 / (double)count) - meanR * meanR;
         VolBuffer[i] = MathSqrt(MathMax(0.0, varR));
      }
      else
      {
         VolBuffer[i] = 0.0;
      }
   }

   //===============================================================
   // 4) AUTO REGIME DETECTION & COLORING
   //    (stddev of slope, z-score of vol)
   //===============================================================
   int calcStart = MathMax(start, n * 2);

   for(int i = calcStart; i < rates_total; i++)
   {
      //--- A. AUTO TREND (StdDev of slope)
      double slopeSum  = 0.0;
      double slopeSum2 = 0.0;

      for(int k = i - n + 1; k <= i; k++)
      {
         double s = SlopeBuffer[k];
         slopeSum  += s;
         slopeSum2 += s * s;
      }

      double slopeMean = slopeSum / (double)n;
      double slopeVar  = (slopeSum2 / (double)n) - slopeMean * slopeMean;
      double slopeStd  = MathSqrt(MathMax(0.0, slopeVar));

      double trendThreshold = slopeStd * InpTrendSensitivity;

      int trendRegime = TREND_MEAN;
      double sNow     = SlopeBuffer[i];

      if(trendThreshold > 0.0)
      {
         if(sNow >  trendThreshold)
            trendRegime = TREND_UP;
         else if(sNow < -trendThreshold)
            trendRegime = TREND_DOWN;
         else
            trendRegime = TREND_MEAN;
      }
      else
      {
         trendRegime = TREND_MEAN;
      }

      //--- B. AUTO VOLATILITY (Z-Score of realized vol)
      double volSum  = 0.0;
      double volSum2 = 0.0;

      for(int k = i - n + 1; k <= i; k++)
      {
         double v = VolBuffer[k];
         volSum  += v;
         volSum2 += v * v;
      }

      double volMean = volSum / (double)n;
      double volVar  = (volSum2 / (double)n) - volMean * volMean;
      double volStd  = MathSqrt(MathMax(0.0, volVar));

      int volRegime = VOL_NORMAL;
      if(volStd > 0.0)
      {
         double zScore = (VolBuffer[i] - volMean) / volStd;

         if(zScore >= InpVolSensitivity)
            volRegime = VOL_HIGH;
         else if(zScore <= -InpVolSensitivity)
            volRegime = VOL_LOW;
         else
            volRegime = VOL_NORMAL;
      }

      //--- C. COLOR LOGIC: map (trendRegime, volRegime) → color index + background
      int   cIdx       = 0;          // default: gray / unknown
      color finalColor = clrSilver;  // default bg (should rarely be seen)

      if(trendRegime == TREND_MEAN)
      {
         cIdx       = 5;            // Gold
         finalColor = clrGold;
      }
      else if(trendRegime == TREND_UP)
      {
         if(volRegime == VOL_HIGH)
         {
            cIdx       = 1;         // Dark Green (Explosive Up)
            finalColor = clrDarkGreen;
         }
         else
         {
            cIdx       = 2;         // Lime (Steady Up)
            finalColor = clrLime;
         }
      }
      else if(trendRegime == TREND_DOWN)
      {
         if(volRegime == VOL_HIGH)
         {
            cIdx       = 3;         // Dark Red (Crash)
            finalColor = clrDarkRed;
         }
         else
         {
            cIdx       = 4;         // Light Coral (Slow Bleed)
            finalColor = clrLightCoral;
         }
      }

      SlopeColorIndex[i] = cIdx;

      //--- D. Background shading on main chart
      ShadeBackground(i, finalColor, time);

      //--- E. Panel, regression line, and alerts on the newest bar only
      if(i == rates_total - 1)
      {
         UpdateRegimePanel(trendRegime, volRegime);
         DrawRegressionLine(i, time);

         int combinedNow  = trendRegime * 10 + volRegime;
         int combinedPrev = LastTrendRegime * 10 + LastVolRegime;

         if(InpEnableAlerts && combinedNow != combinedPrev && LastTrendRegime != -1)
         {
            string msg = "State: " + TrendRegimeText(trendRegime, volRegime);
            Alert(msg);
            Print(msg);
            LastTrendRegime = trendRegime;
            LastVolRegime   = volRegime;
         }
         else if(LastTrendRegime == -1)
         {
            LastTrendRegime = trendRegime;
            LastVolRegime   = volRegime;
         }
      }
   }

   return(rates_total);
}
//+------------------------------------------------------------------+

