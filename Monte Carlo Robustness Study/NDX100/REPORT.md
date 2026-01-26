# NDX100 Intraday Range Breakout: Monte Carlo Robustness Study

![Platform](https://img.shields.io/badge/Platform-MetaTrader%205-blue)
![Asset](https://img.shields.io/badge/Asset-NDX100-green)
![Method](https://img.shields.io/badge/Method-Monte%20Carlo-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**A quantitative execution stress test evaluating the distributional robustness of a structural intraday breakout strategy.**

---

## 📑 Table of Contents
- [1. Research Objective](#1-research-objective)
- [2. Strategy Specification](#2-strategy-specification)
- [3. Research Infrastructure](#3-research-infrastructure)
- [4. Baseline Backtest Results](#4-baseline-backtest-results)
- [5. Monte Carlo Methodology](#5-monte-carlo-methodology)
- [6. Robustness Analysis](#6-robustness-analysis)
- [7. Microstructure Theory](#7-microstructure-theory)
- [8. Limitations & Future Work](#8-limitations--future-work)
- [Disclaimer](#-disclaimer)

---

## 1. Research Objective

The objective of this study is to determine whether a time-of-day, structurally defined intraday breakout strategy on **NDX100** demonstrates **Robustness**—defined as the ability to maintain positive expectancy under realistic execution uncertainty.

This study explicitly avoids parameter optimization, focusing instead on distributional behavior. The workflow follows a professional quantitative sequence:
1.  **Baseline:** Establish behavior under ideal execution.
2.  **Stress:** Apply Monte Carlo degradation (spread, slippage, delay).
3.  **Analyze:** Evaluate the distribution of outcomes rather than a single equity curve.

---

## 2. Strategy Specification

### 2.1 Core Parameters

| Parameter | Value | Note |
| :--- | :--- | :--- |
| **Instrument** | NDX100 | Nasdaq-100 Index |
| **Signal Timeframe** | H1 | Decision Logic (Closed Bar) |
| **Range Timeframe** | M1 | Precision Range Construction |
| **Range Window** | 15:00 – 16:00 (Server) | **08:00 – 09:00 New York** |
| **Frequency** | Max 1 Trade / Day | Pure regime sampling |

### 2.2 Logic Matrix

| Component | Logic | Purpose |
| :--- | :--- | :--- |
| **Range Definition** | High/Low of 15:00–16:00 | Captures Pre-NY Open equilibrium. |
| **Entry Trigger** | H1 Close > High (Long)<br>H1 Close < Low (Short) | Confirms directional expansion. |
| **Risk Model** | 1% of Equity | Volatility-normalized exposure. |
| **Stop Loss** | Opposite Range Extreme | Anchored to market structure. |
| **Take Profit** | $2.0 \times \text{Risk}$ | Positive Skew ($2R$). |

---

## 3. Research Infrastructure

The **MetaTrader 5 (MT5)** Expert Advisor was designed as a data-collection engine, not a production trading system.

* **High-Fidelity Construction:** Uses M1 bars for exact range boundaries, preventing tick-noise errors.
* **Deterministic State:** Strict isolation of daily trade logic to ensure statistical cleanliness.
* **Instrumentation:** Captures spread, slippage, and fill metrics per pass.
* **Quant-Grade Export:** Outputs CSV data via `OnTesterPass()` for downstream statistical analysis.

---

## 4. Baseline Backtest Results

*Reference Case: Ideal Execution (Monte Carlo OFF)*

Before applying stress, a baseline was established to confirm the strategy's unperturbed edge.

| Metric | Result |
| :--- | :--- |
| **Net Profit** | $2,834 |
| **Profit Factor** | 1.13 |
| **Sharpe Ratio** | 2.15 |
| **Win Rate** | 47.76% |
| **Max Drawdown** | ~16.96% |

> **Interpretation:** The strategy achieves positive expectancy without a high win rate, consistent with a $2R$ model. Performance is not driven by outliers, though a mild directional asymmetry (Long bias) exists.

---

## 5. Monte Carlo Methodology

Traditional backtests assume instant, perfect fills. This study simulates the reality of intraday index trading by randomizing execution variables across **500 deterministic seeds**.

### 5.1 Stress Dimensions
* **Spread Inflation:** Multiplicative widening of the bid/ask spread.
* **Slippage:** Random positive/negative price slippage on entry/exit.
* **Latency:** Execution delays (milliseconds) leading to price drift.
* **Order Failure:** Probabilistic rejection of orders.

### 5.2 Outcome Landscape
Results are analyzed in **Profit–Drawdown** space.
* **Core:** A dense, profitable region representing structural edge.
* **Degradation:** Performance degrades gradually as stress increases.
* **Failure Mode:** The primary failure mode is **Drawdown Inflation**, not the collapse of expectancy.

---

## 6. Robustness Analysis

Scenarios are classified into distinct regimes to separate deployable performance from fragility.

| Classification | Criteria | Observation |
| :--- | :--- | :--- |
| **Robust** | Profit $\ge$ $1,500 <br> DD $\le$ 15% | The majority of scenarios fall here. |
| **Fragile** | Profitable <br> DD $>$ 15% | Edge exists, but risk exceeds tolerance. |
| **Failing** | Net Negative | Statistically rare outcomes. |

### Robust-Only Expectations
* **Median Profit:** ~$2,573
* **Median Drawdown:** ~13.15%

---

## 7. Microstructure Theory

Why does the edge exist?

The **08:00–09:00 New York** window represents a critical liquidity regime transition.
1.  **Compression:** Overnight price action often compresses prior to the US Open.
2.  **Activation:** The range boundaries act as activation zones for institutional order flow and stop runs.
3.  **Expansion:** The strategy captures the resolution of this equilibrium into directional momentum.

---

## 8. Limitations & Future Work

### Limitations
* **Drawdown Sensitivity:** Vulnerable under severe execution stress.
* **Single Asset:** Validated only on NDX100.
* **Session Bias:** Dependent on early New York volatility.
* **Regime Risk:** Structural market shifts are not modeled.

### Future Extensions
* **Cross-Index Replication:** Testing on ES (S&P 500) and DAX.
* **Adaptive Risk:** Scaling risk based on volatility regimes.
* **Execution Filters:** Dynamic logic to avoid trading during spread blowouts.

---

## ⚠️ Disclaimer

**Research Only:** This project is a quantitative research framework, not a complete automated trading system. The results presented are for educational and analytical purposes only. Past performance—whether baseline or simulated—does not guarantee future results. Trading futures and CFDs involves significant risk of loss.
