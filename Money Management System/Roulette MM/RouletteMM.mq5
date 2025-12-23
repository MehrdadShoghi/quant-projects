//+------------------------------------------------------------------+
//|                                                   RouletteMM.mqh |
//|------------------------------------------------------------------|
//|  Author          : Mehrdad Shoghi                                |
//|  Version         : 1.04                                          |
//|  Platform        : MetaTrader 5 (MQL5, Library)                  |
//|------------------------------------------------------------------|
//|  Purpose                                                         |
//|  -------                                                         |
//|  This library encapsulates the "Roulette" money           |
//|  management system, designed for modular integration into        |
//|  Expert Advisors.                                                |
//|                                                                  |
//|  It separates position sizing logic from entry/exit logic,       |
//|  allowing for clean, reusable code across multiple projects.     |
//|                                                                  |
//|  Key Concepts:                                                   |
//|                                                                  |
//|    1) Cycle Targets:                                             |
//|       The goal is to win N units in a cycle. Once the target is  |
//|       reached, the lot size resets to the base level to bank     |
//|       profits.                                                   |
//|                                                                  |
//|    2) Flattening (Defensive Mode):                               |
//|       If a loss occurs, the system automatically drops trade     |
//|       size to a microscopic level (e.g., 0.01 lots). It stays    |
//|       flat until a win is secured, protecting the account        |
//|       during choppy or unfavorable market conditions.            |
//|                                                                  |
//|    3) State Persistence:                                         |
//|       Uses Terminal Global Variables to "remember" the cycle     |
//|       position. If MT5 crashes or the timeframe changes, the     |
//|       strategy picks up exactly where it left off.               |
//|                                                                  |
//|  Supported Modes (ENUM_MM_TYPE):                                 |
//|  -------------------------------                                 |
//|    - MM_CONSECUTIVE: Resets to 1 unit immediately after loss.    |
//|                      (High Risk / High Reward)                   |
//|    - MM_CUMULATIVE : Steps down risk gently after a loss.        |
//|                      (Balanced approach)                         |
//|    - MM_NEGATIVE   : Increases risk after loss.                  |
//|                      (Martingale variant for mean reversion)     |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Gemini AI User"
#property strict

//+------------------------------------------------------------------+
//| Enum: Money Management Strategies                                |
//+------------------------------------------------------------------+
enum ENUM_MM_TYPE
  {
   MM_CONSECUTIVE, // Positive Progression: Reset risk to 1.0 immediately after any loss.
   MM_CUMULATIVE,  // Positive Progression: Step down risk gently (1 unit) after a loss.
   MM_NEGATIVE     // Negative Progression: Increase risk after loss (Martingale variant).
  };

//+------------------------------------------------------------------+
//| Class: CRouletteMM                                               |
//| Purpose: Manages position sizing and trade result processing.    |
//+------------------------------------------------------------------+
class CRouletteMM
  {
private:
   //--- Settings (Initialized via Init method)
   bool              m_Enabled;          // Is MM active?
   ENUM_MM_TYPE      m_Type;             // Which strategy logic to use
   double            m_BaseLot;          // The standard starting lot size
   double            m_FlatteningLot;    // The defensive "tiny" lot size (e.g., 0.01)
   int               m_CycleTarget;      // How many units to reach before resetting (e.g., 6)
   bool              m_UseFlattening;    // Whether to use defensive mode after losses
   double            m_RiskRewardRatio;  // Used for calculating step-downs in Cumulative mode
   long              m_MagicNumber;      // ID to identify trades belonging to this instance
   string            m_Symbol;           // Symbol this instance is trading

   //--- State Variables (Dynamic)
   double            m_CurrentUnit;      // Current position in the cycle (1.0, 2.0, 3.0...)
   bool              m_IsFlattening;     // Are we currently in "Defensive Mode"?
   string            m_GlobalPrefix;     // Unique string for saving state to Global Variables

   //--- Helper Methods
   void              SaveState();        // Save variables to MT5 Global Variables
   void              LoadState();        // Load variables from MT5 Global Variables

public:
                     CRouletteMM();      // Constructor
                    ~CRouletteMM();      // Destructor

   //--- Setup
   void              Init(long magic, string sym, bool enabled, ENUM_MM_TYPE type, 
                          double baseLot, double flatLot, int target, bool useFlat, double rrr);

   //--- Main Logic
   double            GetLotSize();       // Returns the lot size for the *next* trade
   void              OnDeal(ulong ticket); // Processes a closed trade (Win/Loss logic)
   void              Reset();            // Manually resets the cycle to start
  };

//+------------------------------------------------------------------+
//| Constructor: Initialize default state                            |
//+------------------------------------------------------------------+
CRouletteMM::CRouletteMM()
  {
   m_CurrentUnit = 1.0;
   m_IsFlattening = false;
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRouletteMM::~CRouletteMM()
  {
  }

//+------------------------------------------------------------------+
//| Init: Configures the MM engine with user inputs                  |
//+------------------------------------------------------------------+
void CRouletteMM::Init(long magic, string sym, bool enabled, ENUM_MM_TYPE type, 
                       double baseLot, double flatLot, int target, bool useFlat, double rrr)
  {
   m_MagicNumber     = magic;
   m_Symbol          = sym;
   m_Enabled         = enabled;
   m_Type            = type;
   m_BaseLot         = baseLot;
   m_FlatteningLot   = flatLot;
   m_CycleTarget     = target;
   m_UseFlattening   = useFlat;
   m_RiskRewardRatio = rrr;
   
   // Generate a unique key so this specific chart/EA doesn't conflict with others.
   // Key format: RMM_MagicNumber_Symbol (e.g., "RMM_123456_EURUSD")
   m_GlobalPrefix    = "RMM_" + (string)m_MagicNumber + "_" + m_Symbol;
   
   // Attempt to resume previous session state if MM is enabled
   if(m_Enabled) LoadState();
  }

//+------------------------------------------------------------------+
//| GetLotSize: Calculates the required volume for the next trade    |
//+------------------------------------------------------------------+
double CRouletteMM::GetLotSize()
  {
   // 1. If MM is disabled, just return the fixed base lot.
   if(!m_Enabled) return m_BaseLot;

   double lot = 0;

   // 2. Logic for Negative Progression (Martingale style)
   //    Here, we increase lot size based on units.
   if(m_Type == MM_NEGATIVE)
     {
      lot = m_BaseLot * m_CurrentUnit;
     }
   // 3. Logic for Positive Progression (Compounding winners)
   else
     {
      // If we are in "Flattening" mode (recovering from a loss), use the tiny lot.
      if(m_UseFlattening && m_IsFlattening)
         lot = m_FlatteningLot; 
      else
         // Otherwise, calculate size: BaseLot + (BaseLot * Current Cycle Step)
         // Example: Base 0.1, Unit 3 -> 0.01 + (0.1 * 3) = 0.31 (approx logic)
         lot = m_FlatteningLot + (m_BaseLot * m_CurrentUnit); 
     }

   // 4. Normalize to Broker Limits (Step, Min, Max)
   //    This prevents errors like "Invalid Volume" from the server.
   double step = SymbolInfoDouble(m_Symbol, SYMBOL_VOLUME_STEP);
   double min  = SymbolInfoDouble(m_Symbol, SYMBOL_VOLUME_MIN);
   double max  = SymbolInfoDouble(m_Symbol, SYMBOL_VOLUME_MAX);
   
   lot = MathMax(min, MathMin(max, lot));
   
   // Round down to the nearest step to ensure validity
   return MathFloor(lot / step) * step;
  }

//+------------------------------------------------------------------+
//| OnDeal: Updates the progression based on trade results           |
//| Note: Call this inside OnTradeTransaction when a deal is added.  |
//+------------------------------------------------------------------+
void CRouletteMM::OnDeal(ulong ticket)
  {
   if(!m_Enabled) return;

   // Security check: Ensure this deal belongs to this EA instance
   if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != m_MagicNumber) return;
   if(HistoryDealGetString(ticket, DEAL_SYMBOL) != m_Symbol) return;

   double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
   
   // ===========================
   //       WIN SCENARIO
   // ===========================
   if(profit > 0)
     {
      if(m_Type == MM_NEGATIVE)
        {
         // Negative MM: A win recovers losses, so we decrease risk.
         m_CurrentUnit = MathMax(1.0, m_CurrentUnit - 1.0);
        }
      else
        {
         // Positive MM: We are compounding winnings.
         if(m_IsFlattening)
           {
            // We just won a "Flattening" trade. Crisis averted.
            // Exit defensive mode and reset to Unit 1.
            m_IsFlattening = false; 
            m_CurrentUnit = 1.0; 
           }
         else
           {
            // We won a normal trade. Increase the unit for the next trade.
            m_CurrentUnit += 1.0;
            
            // Check if we hit the Cycle Target (e.g., 6 wins).
            // If yes, bank the profits and reset to 1.0.
            if(m_CurrentUnit > m_CycleTarget) m_CurrentUnit = 1.0; 
           }
        }
     }
   // ===========================
   //       LOSS SCENARIO
   // ===========================
   else if(profit < 0)
     {
      if(m_Type == MM_NEGATIVE)
        {
         // Negative MM: A loss means we must increase risk to recover next time.
         m_CurrentUnit += 1.0;
         if(m_CurrentUnit > m_CycleTarget) m_CurrentUnit = 1.0; // Safety cap
        }
      else
        {
         // Positive MM: We lost capital.
         // 1. Activate "Flattening" (Defensive Mode) to protect remaining equity.
         if(m_UseFlattening) m_IsFlattening = true;
         
         // 2. Adjust the Unit based on the specific Positive logic.
         if(m_Type == MM_CONSECUTIVE)
           {
            // Strict Mode: Any loss resets us back to start.
            m_CurrentUnit = 1.0; 
           }
         else if(m_Type == MM_CUMULATIVE)
           {
            // Gentle Mode: Step down slightly instead of full reset.
            // We calculate step size based on Risk:Reward Ratio.
            double stepDown = (m_RiskRewardRatio > 0) ? MathMax(0.5, 1.0 / m_RiskRewardRatio) : 1.0;
            m_CurrentUnit = MathMax(1.0, m_CurrentUnit - stepDown);
           }
        }
     }
     
   // Save the new state immediately so we don't lose progress if MT5 closes.
   SaveState();
  }

//+------------------------------------------------------------------+
//| SaveState: Persist data to Global Variables (F3 Menu)            |
//+------------------------------------------------------------------+
void CRouletteMM::SaveState()
  {
   // Example Variable Name: "RMM_123456_EURUSD_Unit"
   GlobalVariableSet(m_GlobalPrefix + "_Unit", m_CurrentUnit);
   GlobalVariableSet(m_GlobalPrefix + "_Flat", (double)m_IsFlattening);
  }

//+------------------------------------------------------------------+
//| LoadState: Retrieve data from Global Variables                   |
//+------------------------------------------------------------------+
void CRouletteMM::LoadState()
  {
   // Check if the variable exists (e.g., from a previous session)
   if(GlobalVariableCheck(m_GlobalPrefix + "_Unit"))
      m_CurrentUnit = GlobalVariableGet(m_GlobalPrefix + "_Unit");
   else 
      m_CurrentUnit = 1.0; // Default start
   
   if(GlobalVariableCheck(m_GlobalPrefix + "_Flat"))
      m_IsFlattening = (bool)GlobalVariableGet(m_GlobalPrefix + "_Flat");
   else 
      m_IsFlattening = false;
  }

//+------------------------------------------------------------------+
//| Reset: Manual hard reset of the system                           |
//+------------------------------------------------------------------+
void CRouletteMM::Reset()
  {
   m_CurrentUnit = 1.0;
   m_IsFlattening = false;
   SaveState();
  }