# Time-of-Day Alpha in EURUSD: Intraday Regime Analysis

![Platform](https://img.shields.io/badge/Platform-Tableau%20%7C%20MT5-blue)
![Asset](https://img.shields.io/badge/Asset-EURUSD-green)
![Type](https://img.shields.io/badge/Type-Quantitative%20Research-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**A quantitative study isolating time as a market regime variable to decode intraday momentum and mean-reversion behavior in FX.**

[**🔗 View Interactive Dashboard (Tableau Public)**]([https://public.tableau.com/app/profile/mehrdad.shoghi/viz/NDX100/Sheet1?publish=yes](https://public.tableau.com/app/profile/mehrdad.shoghi/viz/EURUSD_17673419580200/Sheet1?publish=yes))

---

## 📑 Table of Contents
- [Overview](#-overview)
- [Theory & Logic](#-theory--logic)
- [Market & Setup](#-market--setup)
- [Strategy Logic Matrix](#-strategy-logic-matrix)
- [Microstructure & Execution](#-microstructure--execution)
- [Visual Analysis](#-visual-analysis)
- [Disclaimer](#-disclaimer)

---

## 📈 Overview

**Time-of-Day Alpha** is a quantitative research framework designed to measure how identical intraday strategies behave across different temporal windows of the trading day.

Rather than optimizing indicators, patterns, or signal sensitivity, this study isolates **Time** as the dominant market regime variable. The core hypothesis is that the same entry and risk logic can shift from profitable to unprofitable purely based on when it is executed.

This project maps intraday **Alpha Clusters** for **EURUSD**, separating Breakout (trend continuation) behavior from Reversion (false breakout / mean reversion) behavior.

---

## 📘 Theory & Logic

The analysis is built on the concept of **Temporal Market Regimes**:

1.  **Time as Structure:** FX markets exhibit predictable liquidity, volatility, and order-flow transitions tied to session opens, overlaps, and closes.
2.  **Regime Separation:**
    * **Breakout** strategies perform best during liquidity expansion and directional commitment.
    * **Reversion** strategies dominate during compression, range rotation, and post-impulse digestion.
3.  **Cluster Stability:** Robust edges appear as time clusters (e.g., specific hours/minutes) rather than isolated timestamps.

### The "When" vs. "How"
By holding strategy logic constant and shifting only the range start time, this study demonstrates that **timing alone can define edge** — often more strongly than entry mechanics.

---

## 📊 Market & Setup

All parameters were fixed to ensure a clean, controlled comparison across time windows.

| Parameter | Value | Note |
| :--- | :--- | :--- |
| **Instrument** | EURUSD | Most liquid FX pair globally. |
| **Timeframe** | M15 | Execution timeframe. |
| **Data Period** | 2024 – 2025 | Multi-year aggregated sample. |
| **Risk Model** | Fixed Fractional (1%) | Constant risk per trade. |
| **Reward/Risk** | 2.0R | Positive expectancy skew. |
| **Constraints** | 1 Trade Per Day | Pure regime sampling. |
| **Force Exit** | 22:59 Server Time | No overnight FX exposure. |

---

## 🧩 Strategy Logic Matrix

Both strategies are driven by the same range-based reference structure and differ only in execution intent.

| Condition | Logic | Breakout Action | Reversion Action |
| :--- | :--- | :--- | :--- |
| **Range Definition** | Fixed Duration (1–60 min) | Establish Balance | Establish Balance |
| **Upside Trigger** | `Close[1] > RangeHigh` | **BUY** (Momentum) | **SELL** (False Break) |
| **Downside Trigger** | `Close[1] < RangeLow` | **SELL** (Momentum) | **BUY** (False Break) |
| **Stop Loss** | Opposite Range Extreme | Structural Invalidation | Structural Invalidation |
| **Take Profit** | $2 \times \text{StopDistance}$ | Positive Skew ($2R$) | Positive Skew ($2R$) |

---

## 🔬 Microstructure & Execution

Execution is strictly close-based on M15 candles, preventing intrabar noise and look-ahead bias. The same logic engine supports both regimes, with direction controlled by a single strategy mode switch.

### Entry Logic Pseudo-Code

```cpp
enum ENUM_STRATEGY_TYPE { STRATEGY_BREAKOUT, STRATEGY_REVERSION };

void OnBarClose() {
   // 1. Define Range from Reference Window
   double rangeHigh = GetHigh(RangeStartTime, RangeDuration);
   double rangeLow  = GetLow(RangeStartTime, RangeDuration);
   double riskDist  = rangeHigh - rangeLow;

   // 2. Upside Trigger
   if (Close[1] > rangeHigh && !IsTradeToday) {
       if (StrategyMode == STRATEGY_BREAKOUT) {
           // Momentum
           OpenOrder(ORDER_BUY, SL=rangeLow, TP=rangeHigh + (riskDist*2));
       }
       else if (StrategyMode == STRATEGY_REVERSION) {
           // Fade / False Break
           OpenOrder(ORDER_SELL, SL=rangeHigh + riskDist, TP=rangeHigh - (riskDist*2));
       }
   }

   // 3. Downside Trigger
   else if (Close[1] < rangeLow && !IsTradeToday) {
       if (StrategyMode == STRATEGY_BREAKOUT) {
           // Momentum
           OpenOrder(ORDER_SELL, SL=rangeHigh, TP=rangeLow - (riskDist*2));
       }
       else if (StrategyMode == STRATEGY_REVERSION) {
           // Fade / False Break
           OpenOrder(ORDER_BUY, SL=rangeLow - riskDist, TP=rangeLow + (riskDist*2));
       }
   }
}
```

---

## 📉 Visual Analysis

### 1. Time-of-Day Alpha Heatmap
*Highlighting expectancy clusters across hours and minutes. Green zones represent statistically favorable temporal regimes.*

*(See Tableau dashboard for interactive exploration.)*

### 2. Breakout vs. Reversion Regime Comparison
*Direct comparison showing how EURUSD alternates between momentum-dominant and mean-reverting behavior depending on time of day.*

---

## ⚠️ Disclaimer

**Research Only:** This project is a time-filter discovery framework, not a complete automated trading system. Results are intended for analytical and educational purposes only. FX trading involves substantial risk, and historical performance of specific time windows does not guarantee future outcomes.

---

**Author:** Mehrdad Shoghi
**Detailed Report:** [docs/TECHNICAL_REPORT.md](docs/TECHNICAL_REPORT.md)
