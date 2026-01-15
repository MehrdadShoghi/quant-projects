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
- [5. Core Results](#5-core-results-with-visual-evidence)
- [6. Interpretation](#6-interpretation)
- [7. How to Use This Framework](#7-how-to-use-this-framework-guidance-not-signals)
- [8. Limitations](#8-limitations)
- [9. Conclusion](#9-conclusion)
- [Disclaimer](#-disclaimer)

---

## 1. Objective

The objective of this study is to examine whether **Time-of-Day** acts as a meaningful and repeatable explanatory variable for intraday strategy performance in the **NDX100**.

Rather than optimizing indicators or entries, all strategy logic is held constant while time-related dimensions (hour, minute, and range duration) are systematically varied.

**Goal:** To identify intraday behavioral regimes, not to generate trade signals.

---

## 2. Instrument & Time Handling

All tests were conducted under strict session alignment conditions.

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
Trades are considered strictly under these conditions to ensure no look-ahead bias or intrabar assumptions:
* ✅ A full M15 candle close.
* ✅ The close occurs strictly above or below the locked range.
* ✅ No overlap exists between range construction and entry candles.

### 3.3 Strategy Variants
Two distinct behaviors are tested using the exact same trigger levels.

| Variant | Logic | Action |
| :--- | :--- | :--- |
| **Breakout** | Close > High | **Long** (Trend Follow) |
| **Breakout** | Close < Low | **Short** (Trend Follow) |
| **Reversion** | Close > High | **Short** (Fade/False Break) |
| **Reversion** | Close < Low | **Long** (Fade/False Break) |

### 3.4 Risk Definition & Exit Rules
* **Max Trades:** 1 per day.
* **Sizing:** Fixed fractional risk (1%).
* **Stop Loss:** Placed at the opposite side of the defined range.
* **Take Profit:** Fixed at **2R** (Based on stop distance).
* **Forced Exit:** All positions closed at **22:59** Server Time.

---

## 4. Visualization Methodology

Each configuration is visualized using a **Time-of-Day Heatmap** to identify clusters.

* **Y-Axis:** Range Start Hour
* **X-Axis:** Range Start Minute (5-minute increments)
* **Color:** Total Profit (USD)
* **Label:** Win Rate (%)

---

## 5. Core Results (With Visual Evidence)

### 5.1 Breakout – Multi-Year Overview
*This heatmap shows how breakout performance varies across the trading day when all years are aggregated.*
> **Observation:** Performance concentrates into distinct **time clusters**, rather than isolated timestamps.

### 5.2 Reversion – Multi-Year Overview
*Reversion logic produces a materially different intraday profile.*
> **Observation:** Mean-reverting behavior dominates in completely different regimes than breakout behavior.

### 5.3 Breakout vs Reversion (Structural Contrast)
*Direct comparison highlights regime dependency rather than strategy superiority.*

### 5.4 Year-Specific Validation (2024 / 2025)
*To reduce overfitting risk, results are reviewed on individual years.*
> **Observation:** While absolute performance varies, the **time-based regimes persist** across years.

---

## 6. Interpretation

Key conclusions drawn from the visuals:
1.  **Time-of-Day** is a first-order variable.
2.  **Strategy Effectiveness** is strictly regime-dependent.
3.  **Robust Edges** appear as clusters, not single cells.
4.  **Range Duration** interacts strongly with time; they must be evaluated together.

---

## 7. How to Use This Framework (Guidance, Not Signals)

This study intentionally avoids prescribing specific trading hours. Instead, practitioners should:

1.  **Identify** robust clusters across adjacent minutes.
2.  **Validate** behavior across multiple years.
3.  **Re-evaluate** time filters periodically as regimes evolve.

*This framework is designed for regime identification, not signal generation.*

---

## 8. Limitations

* ⚠️ Results are specific to NDX100 and M15.
* ⚠️ Intraday regimes may evolve.
* ⚠️ Time windows require ongoing validation.
* ⚠️ No claim of future profitability is made.

---

## 9. Conclusion

This study demonstrates that **Time-of-Day is a tradable market dimension.**

Many strategies fail not due to poor logic, but because they are deployed in unfavorable intraday regimes. Time-based filtering offers a structurally simple and robust improvement without increasing complexity.

---

## ⚠️ Disclaimer

**Research Only:** This project is a time-filter discovery framework, not a complete "black box" trading system. The data provided is for educational and analytical purposes only. Past performance of any specific time cluster is not necessarily indicative of future results. Trading futures and CFDs involves significant risk of loss.

---

**Author:** Mehrdad Shoghi
**Detailed Report:** [docs/TECHNICAL_REPORT.md](docs/TECHNICAL_REPORT.md)
