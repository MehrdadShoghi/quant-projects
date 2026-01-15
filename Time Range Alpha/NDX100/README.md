# Time-of-Day Alpha in NDX100: Intraday Regime Analysis

![Platform](https://img.shields.io/badge/Platform-Tableau%20%7C%20MT5-blue)
![Asset](https://img.shields.io/badge/Asset-NDX100-green)
![Type](https://img.shields.io/badge/Type-Quantitative%20Research-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**A quantitative study isolating time as a market regime variable to decode intraday momentum and mean-reversion clusters.**

[**🔗 View Interactive Dashboard (Tableau Public)**](https://public.tableau.com/app/profile/mehrdad.shoghi/viz/NDX100/Sheet1?publish=yes)

---

## 📑 Table of Contents
- [Overview](#-overview)
- [Theory & Logic](#-theory--logic)
- [Market & Setup](#-market--setup)
- [Key Findings](#-key-findings)
- [Strategy Logic Matrix](#-strategy-logic-matrix)
- [Microstructure & Execution](#-microstructure--execution)
- [Visual Analysis](#-visual-analysis)
- [Disclaimer](#-disclaimer)

---

## 📈 Overview

**Time-of-Day Alpha** is a research framework designed to measure how identical intraday strategies perform across different temporal windows of the trading day.

Instead of optimizing indicators or entry triggers, this study isolates **Time** as the primary market regime variable. The central thesis is that the same strategy logic can be highly profitable or deeply unprofitable depending solely on the specific hour and minute it is deployed.

This project visualizes these "Alpha Clusters" for the **Nasdaq-100 (NDX100)**, differentiating between **Breakout** (Trend Following) and **Reversion** (False Breakout) regimes.

---

## 📘 Theory & Logic

The analysis rests on the concept of **Temporal Regimes**:

1.  **Time as a Filter:** Markets exhibit structural behaviors (volatility expansion, mean reversion, liquidity injection) at specific times of day (e.g., NY Open, European Close).
2.  **Regime Segregation:** Breakout strategies tend to work during high-volatility expansion, while Reversion strategies thrive during accumulation or low-volume chop.
3.  **Stability:** Profitable behavior appears as stable "Time Clusters" (e.g., 09:30–10:30) rather than isolated, random timestamps.

### The "When" vs. "How"
By keeping the strategy logic static and only varying the start time, we prove that **when you trade can matter as much as how you trade.**

---

## 📊 Market & Setup

The following parameters were locked to ensure a controlled testing environment (ceteris paribus).

| Parameter | Value | Note |
| :--- | :--- | :--- |
| **Instrument** | NDX100 (Nasdaq-100) | High beta, high volatility index. |
| **Timeframe** | M15 | Execution timeframe. |
| **Data Period** | 2024 – 2025 | Multi-year aggregate analysis. |
| **Risk Model** | Fixed Fractional (1%) | Constant risk per trade. |
| **Reward/Risk** | 2.0R | 1 Unit Risk : 2 Units Reward. |
| **Constraints** | 1 Trade Per Day | No over-trading; pure regime sampling. |
| **Force Exit** | 22:59 Server Time | No overnight hold risk. |

---

## 🧩 Strategy Logic Matrix

The entry engine uses a deterministic breakout/reversion model based on a fixed pre-market or intraday range. Both strategies utilize the same **Range High/Low** triggers but execute in opposite directions.

| Condition | Logic | Breakout Action | Reversion Action |
| :--- | :--- | :--- | :--- |
| **Range Definition** | Fixed Duration (1–60 min) | Establish Balance | Establish Balance |
| **Upside Trigger** | `Close[1] > RangeHigh` | **BUY** (Momentum) | **SELL** (False Break/Fade) |
| **Downside Trigger** | `Close[1] < RangeLow` | **SELL** (Momentum) | **BUY** (False Break/Fade) |
| **Stop Loss** | Opposite Range Extreme | Structural Failure point | Structural Failure point |
| **Take Profit** | $2 \times \text{StopDistance}$ | Positive Skew ($2R$) | Positive Skew ($2R$) |

---

## 🔬 Microstructure & Execution

The system operates on strict **M15 close-only** logic. The specific execution direction depends on the selected Strategy Mode (Breakout vs. Reversion).

### Entry Logic Pseudo-Code
The strategy validates the trigger only after the candle has sealed.

```cpp
enum ENUM_STRATEGY_TYPE { STRATEGY_BREAKOUT, STRATEGY_REVERSION };

void OnBarClose() {
   // 1. Define Range from Reference Window
   double rangeHigh = GetHigh(RangeStartTime, RangeDuration);
   double rangeLow  = GetLow(RangeStartTime, RangeDuration);
   double riskDist  = rangeHigh - rangeLow;

   // 2. Logic: Upside Trigger (Close > High)
   if (Close[1] > rangeHigh && !IsTradeToday) {
       if (StrategyMode == STRATEGY_BREAKOUT) {
           // Momentum: Buy strength
           OpenOrder(ORDER_BUY, SL=rangeLow, TP=rangeHigh + (riskDist*2)); 
       }
       else if (StrategyMode == STRATEGY_REVERSION) {
           // Fade: Sell the false breakout
           OpenOrder(ORDER_SELL, SL=rangeHigh + riskDist, TP=rangeHigh - (riskDist*2));
       }
   }

   // 3. Logic: Downside Trigger (Close < Low)
   else if (Close[1] < rangeLow && !IsTradeToday) {
       if (StrategyMode == STRATEGY_BREAKOUT) {
           // Momentum: Sell weakness
           OpenOrder(ORDER_SELL, SL=rangeHigh, TP=rangeLow - (riskDist*2));
       }
       else if (StrategyMode == STRATEGY_REVERSION) {
           // Fade: Buy the false breakdown
           OpenOrder(ORDER_BUY, SL=rangeLow - riskDist, TP=rangeLow + (riskDist*2));
       }
   }
}
```

---

## 📉 Visual Analysis

### 1. Time-of-Day Alpha Heatmap
*Visualizing expectancy clusters. Green zones indicate high-probability time windows.*

<img width="2380" height="1393" alt="image" src="https://github.com/user-attachments/assets/d45dfeab-ae6f-4826-85bc-a377262fac5a" />

### 2. Regime Comparison: Breakout vs. Reversion
*Contrasting performance curves showing how different regimes perform on the same data set.*

<img width="1345" height="825" alt="image" src="https://github.com/user-attachments/assets/aa4684d3-9aed-44ec-a8d2-ddf91514fb39" />

---

## ⚠️ Disclaimer

**Research Only:** This project is a time-filter discovery framework, not a complete "black box" trading system. The data provided is for educational and analytical purposes only. Past performance of any specific time cluster is not necessarily indicative of future results. Trading futures and CFDs involves significant risk of loss.

---

**Author:** Mehrdad Shoghi
**Detailed Report:** [docs/TECHNICAL_REPORT.md](docs/TECHNICAL_REPORT.md)
