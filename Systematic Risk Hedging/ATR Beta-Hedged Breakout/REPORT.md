# Intraday Range Breakout with Surgical Beta-Hedging

![Platform](https://img.shields.io/badge/Platform-MetaTrader%205-blue)
![Language](https://img.shields.io/badge/Language-MQL5-green)
![Version](https://img.shields.io/badge/Version-2.00-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**A volatility-aware breakout strategy utilizing "Surgical Hedging" to solve hedging drag.**

---

## 📑 Table of Contents
- [Overview](#-overview)
- [Theory & Logic](#-theory--logic)
- [Quantitative Analysis](#-quantitative-analysis)
- [Performance Comparison](#-performance-comparison)
- [Key Features](#-key-features)
- [Hedge Logic Matrix](#-hedge-logic-matrix)
- [Microstructure & Technical Logic](#-microstructure--technical-logic)
- [Math & Calculations](#-math--calculations)
- [Configuration](#-configuration)
- [Installation](#-installation)
- [Disclaimer](#-disclaimer)

---

## 📈 Overview

**RangeBetaHedge** is a quantitative system designed to extract momentum alpha from intraday price discovery ranges while actively mitigating systemic market risk.

Traders often view hedging as a necessary cost, believing that while it reduces risk, it inevitably reduces profit (known as **"Hedging Drag"**). This project solves that problem for a **Nasdaq-100 (US100)** breakout strategy by introducing a **"Surgical Hedge"** using the **S&P 500 (SPX500)**.

Unlike standard static hedges, this system is **event-driven**: it remains dormant 90% of the time and only activates when specific statistical "decoupling" events occur.

---

## 📘 Theory & Logic

The core hypothesis rests on two market mechanics:

1.  **Price Discovery (The Offense):** Markets frequently establish ranges during defined intraday windows. A confirmed breakout beyond this range, when aligned with higher-timeframe structure, represents a tradable momentum regime.
2.  **Surgical Beta-Hedging (The Defense):** Standard hedging uses fixed lots, which is mathematically incorrect due to varying volatility. We calculate a **Dynamic Beta** using ATR to ensure the hedge matches the dollar volatility of the main position.

### The "Free Lunch" Result
By moving from static to dynamic hedging, the system achieved a rare result in Modern Portfolio Theory—reducing risk while increasing returns:
* **Net Profit:** Increased by **+32.18%** (From $5,537.70 to $7,319.92)
* **Equity Drawdown:** Reduced by **-23.40%** (From 8.29% to 6.35%)
* **Recovery Factor:** Improved by **+57.89%** (From 4.37 to 6.90)
* **Sharpe Ratio:** Increased by **+28.93%** (From 3.63 to 4.68)
---

## 📊 Quantitative Analysis

The following table details exactly how the "Surgical Hedge" improved performance metrics compared to the unhedged baseline over 11,500 bars of historical data.

| Metric | Unhedged (Baseline) | Surgical Hedge (Optimized) | Value Change | % Impact |
| :--- | :--- | :--- | :--- | :--- |
| **Total Net Profit** | $5,537.70 | **$7,319.92** | +$1,782.22 | **+32.18%** |
| **Max Drawdown** | 8.29% | **6.35%** | -1.94% | **-23.40%** |
| **Sharpe Ratio** | 3.63 | **4.68** | +1.05 | **+28.93%** |
| **Recovery Factor** | 4.37 | **6.90** | +2.53 | **+57.89%** |
| **Total Trades** | 482 | **530** | +48 Hedges | **+9.96%** |

**Critical Insight:** The hedge only triggered 48 times out of 530 trades (a **9.06% activation rate**). The algorithm stays dormant during normal correlation, saving spread costs.

---

## 📉 Performance Comparison

#### 1. Unhedged Baseline
*Standard breakout logic without correlation protection. Note the deeper drawdowns.*

![Setting](https://github.com/user-attachments/assets/b0a1ac30-3ff5-44ad-b433-6c6f8262c945)

![Balance-Equity](https://github.com/user-attachments/assets/8bd12c0f-26af-4d4a-999b-effec8adc001)

![BacktestReport](https://github.com/user-attachments/assets/660a64a3-d7bd-49eb-98a4-2d17d240c4ac)

#### 2. Optimized: Surgical Beta-Hedge
*Smoother equity curve with higher net profit and faster recovery.*

![Setting_Hedge](https://github.com/user-attachments/assets/ea0b1144-55fa-4f92-ba63-1cccee12deef)

![Balance-Equity_Hedge](https://github.com/user-attachments/assets/510d4e18-ee2f-4a41-8e7a-dd1ccc101a01)

![BacktestReport_Hedge](https://github.com/user-attachments/assets/a40adb1a-2c91-4fa4-a074-de85c1ba578e)

---

## ✨ Key Features

* **🛡️ Event-Driven Hedging:** The "Surgical Filter" only activates the hedge when correlation breaks down.
* **💾 Microstructure Precision:** Uses M1 data for range calculation regardless of the chart timeframe to prevent look-ahead bias.
* **🧠 Dynamic Beta Sizing:** Automatically adjusts hedge size based on volatility ratios ($\beta$) to ensure true economic offset.
* **⏱️ No Repainting:** Ranges are finalized only after the full window completes.
* **📉 Risk Normalization:** Uses Percent-based Stop Loss and RRR-based Take Profit.

---

## 🧩 Hedge Logic Matrix

The hedging engine uses a specific set of logic to avoid over-hedging or hedging during noise.

| Condition | Logic | Purpose |
| :--- | :--- | :--- |
| **Activation** | $\vert R_{hedge} \vert \le \text{LagFactor} \times \vert R_{main} \vert$ | **The Surgical Filter.** Ensures hedge move lags the main move (a decoupling event). |
| **Direction** | Main & Hedge must match | Prevents hedging during market divergence. |
| **Sizing** | Clamped Beta ($0.5 \le \beta \le 5.0$) | Prevents outlier volatility from creating massive hedge positions. |
| **Exit** | Main Trade Closure | Prevents orphan exposure; hedge dies when main trade dies. |

---

## 🔬 Microstructure & Technical Logic

The system operates on a strict state-machine architecture to ensure deterministic behavior.

### 1. Intraday Range Construction (M1 Precision)
The EA iterates through **M1 (1-minute)** data to find the absolute High/Low, ensuring maximum precision and preventing false breakouts caused by data gaps on higher timeframes.

```cpp
void BuildRangeFromM1Window() {
   // Define start/end time
   datetime rangeStart = TodayAt(RangeStartHour, RangeStartMinute);
   datetime rangeEnd   = rangeStart + RangeDurationMin * 60;

   // Use M1 data for precision
   double highs[], lows[];
   int hN = CopyHigh(MainSymbol, PERIOD_M1, rangeStart, rangeEnd, highs);
   int lN = CopyLow(MainSymbol, PERIOD_M1, rangeStart, rangeEnd, lows);

   // Loop to find absolute extrema
   double hi = -DBL_MAX; double lo = DBL_MAX;
   int n = MathMin(hN, lN);
   
   for(int i=0; i<n; i++) {
      if(highs[i] > hi) hi = highs[i];
      if(lows[i]  < lo) lo = lows[i];
   }
   rangeHigh = hi; rangeLow  = lo;
}
```

### 2. The Surgical Filter Implementation
The `InpLagFactor` (e.g., 0.30) is the trigger threshold. The logic dictates: *"Only open a hedge if the S&P 500 has moved less than 30% of what the Nasdaq has moved."*

```cpp
bool ShouldOpenHedgeFilter() {
   // Calculate % return
   double main_ret = (main_now[0] - main_old[0]) / main_old[0];
   double hed_ret  = (hed_now[0]  - hed_old[0])  / hed_old[0];

   // 1. Direction Logic: If opposite, do NOT hedge
   if(main_ret * hed_ret < 0) return false;

   // 2. Magnitude Logic (The Surgical Filter)
   double main_abs = MathAbs(main_ret);
   double hed_abs  = MathAbs(hed_ret);

   // Trigger: Is the Hedge asset lagging significantly?
   return (hed_abs <= InpLagFactor * main_abs);
}
```

---

## 🧮 Math & Calculations

The core innovation is the **ATR-Scaled Beta** calculation, used to determine the exact lot size for the hedge instrument.

### Beta ($\beta$) Formula
To achieve economic neutrality, we balance Volatility and Contract Value:

$$\beta = \frac{ATR_{main} \times VPP_{main}}{ATR_{hedge} \times VPP_{hedge}}$$

* **ATR:** Average True Range
* **VPP:** Value Per Point (Contract Size)

### Smoothed Update & Final Sizing
To avoid jitter, Beta is smoothed. The final lot size is derived from the main position:
$$\text{HedgeLots} = \text{MainLots} \times \beta$$

---

## ⚙️ Configuration

These inputs control the time window and the correlation thresholds.

```cpp
//--- Section 1: Time & Schedule
input group  "== Time & Schedule =="
input int    RangeStartHour       = 15;        // Start Hour (Server Time)
input int    RangeStartMinute     = 0;         // Start Minute
input int    RangeDurationMin     = 60;        // Duration of the "Box" in minutes

//--- Section 2: Hedging Strategy
input group  "== Hedging Strategy =="
input bool   InpEnableHedging     = true;      // Master switch
input string HedgeSymbol          = "SPX500";  // The correlated asset
input double InpLagFactor         = 0.30;      // Correlation sensitivity
```
![Setting_Hedge](https://github.com/user-attachments/assets/b3bb5979-e644-4801-bad9-29affa37cf7a)

---

## ⚠️ Disclaimer

**Risk Warning:** Trading financial markets involves significant risk of loss. This tool is provided for educational and analytical purposes only. Past performance of any trading system or methodology is not necessarily indicative of future results. The hedging techniques described increase margin utilization and require careful capital management. The author accepts no liability for any loss or damage.

---

**Author:** Mehrdad Shoghi
**Copyright:** © 2026
