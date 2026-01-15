# Time-of-Day Alpha in NDX100

![Type](https://img.shields.io/badge/Type-Technical%20Report-blue)
![Status](https://img.shields.io/badge/Status-Final-green)
![Asset](https://img.shields.io/badge/Asset-NDX100-orange)
![Method](https://img.shields.io/badge/Method-Regime%20Analysis-lightgrey)

**A Regime-Based Study of Breakout and Reversion Behavior.**

[**🔗 View Interactive Dashboard (Tableau Public)**](https://public.tableau.com/app/profile/mehrdad.shoghi/viz/NDX100/Sheet1?publish=yes)

---

## 📑 Table of Contents
- [1. Objective](#1-objective)
- [2. Instrument & Time Handling](#2-instrument--time-handling)
- [3. Strategy Architecture](#3-strategy-architecture)
- [4. Visualization Methodology](#4-visualization-methodology)
- [5. Empirical Results](#5-empirical-results-visual-evidence)
- [6. Interpretation](#6-interpretation)
- [7. Practical Application](#7-how-this-framework-should-be-used)
- [8. Limitations](#8-limitations)
- [9. Future Work](#9-future-work)
- [10. Conclusion](#10-conclusion)
- [Disclaimer](#-disclaimer)

---

## 1. Objective

The objective of this study is to evaluate whether **Time-of-Day** acts as a meaningful and repeatable explanatory variable for intraday strategy performance in the **NDX100**.

All trading logic, execution rules, and risk management parameters are held constant (*ceteris paribus*) while time-related dimensions (hour, minute, and range duration) are systematically varied.

**Goal:** To identify intraday behavioral regimes, not to generate or promote specific trade signals.

---

## 2. Instrument & Time Handling

This alignment preserves consistent intraday market structure across all tests.

| Parameter | Specification |
| :--- | :--- |
| **Instrument** | NDX100 (Nasdaq-100) |
| **Timeframe** | M15 (15-Minute Candles) |
| **Time Reference** | Broker Server Time (Aligned to New York) |
| **DST Handling** | Automatic Daylight Saving Adjustment |
| **Periods Analyzed** | Multi-Year Aggregate, 2024, 2025 |

---

## 3. Strategy Architecture

*Fixed Logic Across All Tests*

### 3.1 Range Construction
A single intraday range is defined using one of the following durations. Once the range fully closes, its high and low are **fixed** and never updated.
* 1 Minute
* 15 Minutes
* 30 Minutes
* 60 Minutes

### 3.2 Entry Confirmation & Bias Control
Trades are evaluated strictly under these conditions to prevent look-ahead bias:
* ✅ A full M15 candle close.
* ✅ The close occurs strictly above or below the locked range.
* ✅ No overlap exists between range construction and entry candles.

### 3.3 Strategy Logic Matrix
Two distinct behaviors are tested using the exact same trigger levels.

| Variant | Logic | Action |
| :--- | :--- | :--- |
| **Breakout** | Close > High | **Long** (Trend Follow) |
| **Breakout** | Close < Low | **Short** (Trend Follow) |
| **Reversion** | Close > High | **Short** (Fade/False Break) |
| **Reversion** | Close < Low | **Long** (Fade/False Break) |

### 3.4 Risk Definition & Exit Rules
Risk is market-structure-anchored, non-discretionary, and identical across all configurations.

* **Max Trades:** 1 per day.
* **Sizing:** Fixed fractional risk (1%).
* **Stop Loss:** Placed at the opposite side of the defined range.
* **Take Profit:** Fixed at **2R** (Based on stop distance).
* **Forced Exit:** All positions closed at **22:59** Server Time.

---

## 4. Visualization Methodology

Each configuration is visualized using a **Time-of-Day Heatmap**:

* **Y-Axis:** Range Start Hour
* **X-Axis:** Range Start Minute (5-minute increments)
* **Color Scale:** Total Profit (USD)
* **Cell Label:** Win Rate (%)

---

## 5. Empirical Results (Visual Evidence)

### 5.1 Breakout — Multi-Year Overview
*Breakout performance concentrates into distinct time clusters, rather than isolated timestamps.*

![NDX100 Breakout – All Years (60m Range)](../images/ndx100/heatmap_breakout_60m_all.png)

### 5.2 Reversion — Multi-Year Overview
*Reversion behavior dominates in different intraday regimes than breakout behavior.*

![NDX100 Reversion – All Years (30m Range)](../images/ndx100/heatmap_reversion_30m_all.png)

### 5.3 Structural Contrast: Breakout vs Reversion
*No strategy dominates across all sessions; effectiveness is regime-dependent.*

![Breakout vs Reversion Comparison](../images/ndx100/breakout_vs_reversion.png)

### 5.4 Year-Specific Validation (2024)
*Validation of regime stability in the 2024 data set.*

![NDX100 Reversion – 2024](../images/ndx100/heatmap_reversion_30m_2024.png)

### 5.5 Year-Specific Validation (2025)
*While absolute performance varies, intraday regimes persist across years, supporting a behavioral explanation.*

![NDX100 Reversion – 2025](../images/ndx100/heatmap_reversion_30m_2025.png)

---

## 6. Interpretation

Across all configurations:
1.  **Time-of-Day** acts as a first-order variable.
2.  **Strategy Effectiveness** is conditional on intraday regime.
3.  **Robust Edges** appear as multi-cell clusters, not isolated points.
4.  **Range Duration** materially interacts with time-of-day behavior.

---

## 7. How This Framework Should Be Used

This study intentionally avoids prescribing specific trading hours. Instead, it provides a framework to:
1.  **Identify** robust time clusters.
2.  **Validate** behavior across adjacent minutes and multiple years.
3.  **Re-evaluate** time filters periodically as regimes evolve.

*The goal is regime identification, not signal publication.*

---

## 8. Limitations

* ⚠️ Results are specific to NDX100 and M15.
* ⚠️ Intraday regimes may evolve over time.
* ⚠️ Time filters require ongoing validation.
* ⚠️ No claim of future profitability is made.

---

## 9. Future Work

This project is designed as a general time-alpha framework, not a single-market study. Planned extensions include:

### 9.1 EURUSD Time-of-Day Analysis
The same methodology will be applied to EURUSD to evaluate:
* Time-of-day behavior in a 24-hour FX market.
* Differences between index-driven and FX-driven microstructure.
* Strategy–time alignment under lower session concentration.

### 9.2 Cross-Market Strategy Consistency
Future work will assess:
* Whether breakout and reversion dominance shifts by market.
* How range duration interacts with time in FX vs indices.
* Persistence of intraday regimes across asset classes.

### 9.3 Regime Stability and Revalidation
Time-based regimes are not static. Ongoing work will focus on:
* Periodic revalidation of time filters.
* Monitoring regime drift.
* Evaluating robustness under changing volatility conditions.

### 9.4 Framework Generalization
The long-term goal is to extend this framework to additional instruments, timeframes, and execution constraints while preserving **Fixed Logic**, **Transparent Assumptions**, and **Non-Discretionary Rules**.

---

## 10. Conclusion

This study demonstrates that **Time-of-Day is a tradable market dimension.**

Many strategies fail not because of flawed logic, but because they are deployed in unfavorable intraday regimes. Time-based filtering offers a structurally simple and robust way to improve expectancy without increasing complexity.

---

## ⚠️ Disclaimer

**Research Only:** This project is a time-filter discovery framework, not a complete "black box" trading system. The data provided is for educational and analytical purposes only. Past performance of any specific time cluster is not necessarily indicative of future results. Trading futures and CFDs involves significant risk of loss.

---

**Author:** Mehrdad Shoghi
**Detailed Report:** [docs/TECHNICAL_REPORT.md](docs/TECHNICAL_REPORT.md)
