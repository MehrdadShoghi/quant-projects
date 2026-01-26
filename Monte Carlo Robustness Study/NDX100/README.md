# NDX100 Intraday Range Breakout: Monte Carlo Robustness Study

![Platform](https://img.shields.io/badge/Platform-MetaTrader%205-blue)
![Asset](https://img.shields.io/badge/Asset-NDX100-green)
![Method](https://img.shields.io/badge/Method-Monte%20Carlo-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**A quantitative evaluation of intraday strategy robustness using execution stress testing and distributional analysis.**

---

## 📑 Table of Contents
- [Overview](#-overview)
- [Strategy Snapshot](#-strategy-snapshot)
- [Research Methodology](#-research-methodology)
- [Monte Carlo Outcome Landscape](#-monte-carlo-outcome-landscape)
- [Key Findings](#-key-findings)
- [Limitations](#-limitations)
- [Repository Contents](#-repository-contents)
- [Research Disclaimer](#-research-disclaimer)

---

## 📈 Overview

This repository presents a quantitative robustness analysis of an intraday **NDX100** range breakout strategy, implemented in **MetaTrader 5 (MT5)**.

The project prioritizes **distributional behavior** over single-path optimization. A custom MT5 research EA was developed to simulate realistic execution degradation (slippage, delays, spread inflation) and export quant-grade metrics for stress testing. The goal is to separate structural edge from curve-fitted fragility.

---

## 📊 Strategy Snapshot

| Parameter | Value | Note |
| :--- | :--- | :--- |
| **Instrument** | NDX100 | Nasdaq-100 Index |
| **Timeframe** | H1 | 1-Hour Candles |
| **Range Window** | 15:00 – 16:00 (Server) | Corresponds to **08:00 – 09:00 New York** |
| **Entry Logic** | Breakout | Confirmation on **Closed Candle** beyond Range High/Low |
| **Risk Model** | 1% Risk | Dynamic Position Sizing |
| **Reward-to-Risk** | 2.0R | 1 Unit Risk : 2 Units Reward |
| **Frequency** | Max 1 Trade / Day | Pure regime sampling |

---

## 🔬 Research Methodology

The study follows a professional quantitative workflow to validate robustness:

1.  **Baseline Backtest:** Performance evaluation under ideal execution conditions (Monte Carlo disabled).
2.  **Monte Carlo Stress Testing:** Simulation of execution degradation factors:
    * Spread Inflation
    * Slippage (Positive & Negative)
    * Execution Delay (Latency)
    * Order Failure Probability
3.  **Outcome-Space Analysis:** Evaluating the strategy in **Profit vs. Drawdown** space rather than inspecting a single equity curve.
4.  **Robustness Classification:** Distinguishing between structural edge and fragile, execution-dependent performance.

*Note: All Monte Carlo scenarios use deterministic seeds to ensure full reproducibility.*

---

## 📉 Monte Carlo Outcome Landscape

*Each point represents a unique execution scenario plotted in Profit–Drawdown space.*

<img width="640" height="690" alt="image" src="https://github.com/user-attachments/assets/0282fbe3-f99b-4122-9e8c-0a9f9025b9b4" />

**Key Observation:** The dense green region indicates structurally profitable outcomes. While execution stress widens dispersion, it does not eliminate the core profitable region, suggesting the edge is structural rather than execution-dependent.

---

## ✨ Key Findings

* **Expectancy:** Positive expectancy confirmed under baseline conditions.
* **Persistence:** Profitability persists across a statistically significant subset of stressed scenarios.
* **Degradation Mode:** The primary failure mode under stress is **Drawdown Inflation**, not expectancy collapse.
* **Clustering:** Robust outcomes cluster tightly, indicating limited tail dependency.

---

## ⚠️ Limitations

* **Single Instrument:** Study is isolated to NDX100.
* **Session Bias:** Focused exclusively on the early New York session.
* **Regime Shift:** Structural market regime shifts are not modeled.
* **Not Live-Ready:** This is a research framework, not a production trading system.

*These limitations are acknowledged by design to preserve research integrity.*

---

## 📂 Repository Contents

* `EA/` – MT5 Research Expert Advisor (Strategy Logic + Monte Carlo Engine).
* `data/` – Exported Monte Carlo CSV results.
* `analysis/` – Aggregations and visualizations.
* `README.md` – Project overview.

---

## ⚠️ Research Disclaimer

**Educational Use Only:** This project is research-oriented and provided for analytical purposes only. It does not constitute investment advice or a recommendation to trade live capital. Past performance in a simulation is not indicative of future real-world results.
