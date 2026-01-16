# Time-of-Day Alpha in EURUSD

![Type](https://img.shields.io/badge/Type-Technical%20Report-blue)
![Status](https://img.shields.io/badge/Status-Final-green)
![Asset](https://img.shields.io/badge/Asset-EURUSD-orange)
![Method](https://img.shields.io/badge/Method-Regime%20Analysis-lightgrey)

**A Regime-Based Study of Breakout and Reversion Behavior in FX Markets.**

[**🔗 View Interactive Dashboard (Tableau Public)**](https://public.tableau.com/app/profile/mehrdad.shoghi/viz/NDX100/Sheet1?publish=yes)

---

## 📑 Table of Contents
- [1. Objective](#1-objective)
- [2. Instrument & Time Handling](#2-instrument--time-handling)
- [3. Strategy Architecture](#3-strategy-architecture)
- [4. Visualization Methodology](#4-visualization-methodology)
- [5. Empirical Results](#5-empirical-results-visual-evidence)
- [6. Interpretation](#6-interpretation)
- [7. Practical Application](#7-practical-application)
- [8. Limitations](#8-limitations)
- [9. Future Work](#9-future-work)
- [10. Conclusion](#10-conclusion)
- [Disclaimer](#-disclaimer)

---

## 1. Objective

The objective of this study is to evaluate whether **Time-of-Day** acts as a meaningful and repeatable explanatory variable for intraday strategy performance in **EURUSD**.

All trading logic, execution rules, and risk management parameters are held constant (*ceteris paribus*) while time-related dimensions (hour, minute, and range duration) are systematically varied.

**Goal:** To identify intraday behavioral regimes in FX markets, not to generate or promote specific trade signals.

---

## 2. Instrument & Time Handling

This alignment preserves consistent intraday market structure across all tests.

| Parameter | Specification |
| :--- | :--- |
| **Instrument** | EURUSD |
| **Timeframe** | M15 (15-Minute Candles) |
| **Time Reference** | Broker Server Time (Aligned to New York) |
| **DST Handling** | Automatic Daylight Saving Adjustment |
| **Periods Analyzed** | Multi-Year Aggregate, 2024, 2025 |

*Note: Unlike equity indices, EURUSD trades nearly 24 hours per day; therefore, time-of-day effects are driven by session transitions, liquidity cycles, and order-flow concentration rather than centralized exchange opens.*

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
| **Reversion** | Close > High | **Short** (Fade / False Break) |
| **Reversion** | Close < Low | **Long** (Fade / False Break) |

### 3.4 Risk Definition & Exit Rules
Risk is market-structure-anchored, non-discretionary, and identical across all configurations.

* **Max Trades:** 1 per day.
* **Sizing:** Fixed fractional risk (1%).
* **Stop Loss:** Placed at the opposite side of the defined range.
* **Take Profit:** Fixed at **2R** (Based on stop distance).
* **Forced Exit:** All positions closed at **22:59** Server Time.
* *Constraint:* This removes overnight exposure and isolates pure intraday regime behavior.

---

## 4. Visualization Methodology

Each configuration is visualized using a **Time-of-Day Heatmap**:

* **Y-Axis:** Range Start Hour
* **X-Axis:** Range Start Minute (5-minute increments)
* **Color Scale:** Total Profit (USD)
* **Cell Label:** Win Rate (%)

*This visualization highlights persistent temporal regimes rather than isolated statistical outliers.*

---

## 5. Empirical Results (Visual Evidence)

### 5.1 Breakout — Multi-Year Overview
*Breakout performance in EURUSD is highly time-dependent and concentrates into limited volatility expansion windows.*
> *(Insert EURUSD Breakout – Multi-Year Heatmap)*

### 5.2 Reversion — Multi-Year Overview
*Reversion behavior dominates a broader portion of the trading day, reflecting EURUSD’s mean-reverting microstructure.*
> *(Insert EURUSD Reversion – Multi-Year Heatmap)*

### 5.3 Structural Contrast: Breakout vs Reversion
*No strategy dominates across all sessions; effectiveness is regime-dependent and time-conditional.*
> *(Insert Breakout vs Reversion Comparison)*

### 5.4 Year-Specific Validation (2024)
*Validation of regime stability in the 2024 FX environment.*
> *(Insert EURUSD 2024 Heatmap)*

### 5.5 Year-Specific Validation (2025)
*Despite changes in volatility and macro conditions, intraday regimes persist across years.*
> *(Insert EURUSD 2025 Heatmap)*

---

## 6. Interpretation

Across all configurations:
1.  **Time-of-Day** acts as a first-order variable in EURUSD.
2.  **Strategy Effectiveness** is strongly regime-dependent.
3.  **Robust Edges** appear as multi-cell clusters, not isolated timestamps.
4.  **Range Duration** materially interacts with FX session structure.

*Comparison:* Compared to equity indices, EURUSD exhibits stronger mean-reversion regimes and more selective breakout windows.

---

## 7. Practical Application

This study intentionally avoids prescribing specific trading hours. Instead, it provides a framework to:
1.  **Identify** robust FX time clusters.
2.  **Validate** behavior across adjacent minutes and multiple years.
3.  **Re-evaluate** time filters as liquidity and volatility regimes evolve.

*The objective is regime identification, not signal publication.*

---

## 8. Limitations

* ⚠️ Results are specific to EURUSD and M15.
* ⚠️ FX market structure can evolve with macro and monetary conditions.
* ⚠️ Time-based edges require periodic revalidation.
* ⚠️ No claim of future profitability is made.

---

## 9. Future Work

This project is part of a broader cross-asset time-alpha framework. Planned extensions include:

### 9.1 Cross-Asset Comparison
Direct comparison between **Index-based markets (NDX100)** and **FX markets (EURUSD)** to isolate structural vs. asset-specific time behavior.

### 9.2 Strategy Robustness Across FX Pairs
Applying the same framework to other major FX pairs, different volatility regimes, and alternative execution constraints.

### 9.3 Regime Stability & Revalidation
Ongoing research will focus on monitoring regime drift, periodic time-filter recalibration, and stress-testing under macro regime shifts.

### 9.4 Framework Generalization
Extending the methodology to additional instruments and timeframes while preserving:
**Fixed Logic · Transparent Assumptions · Non-Discretionary Rules**

---

## 10. Conclusion

This study demonstrates that **Time-of-Day is a tradable market dimension in FX markets.**

Many EURUSD strategies fail not due to flawed logic, but because they are deployed in unfavorable intraday regimes. Time-based filtering provides a structurally simple and robust way to improve expectancy without increasing complexity.

---

## ⚠️ Disclaimer

**Research Only:** This project is a time-filter discovery framework, not a complete automated trading system. Results are for analytical and educational purposes only. FX trading involves significant risk, and past performance of specific time clusters does not guarantee future results.

---

**Author:** Mehrdad Shoghi
**Detailed Report:** [docs/TECHNICAL_REPORT_EURUSD.md](docs/TECHNICAL_REPORT_EURUSD.md)
