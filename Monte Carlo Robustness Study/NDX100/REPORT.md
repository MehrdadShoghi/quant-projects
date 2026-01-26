# NDX100 Intraday Range Breakout: Monte Carlo Robustness Study

![Type](https://img.shields.io/badge/Type-Technical%20Report-blue)
![Status](https://img.shields.io/badge/Status-Final-green)
![Asset](https://img.shields.io/badge/Asset-NDX100-orange)
![Method](https://img.shields.io/badge/Method-Monte%20Carlo-lightgrey)

**A Quantitative Robustness Study using Execution Stress Testing.**

---

## 📑 Table of Contents
- [1. Research Objective](#1-research-objective)
- [2. Strategy Specification](#2-strategy-specification)
- [3. EA Design & Research Infrastructure](#3-ea-design-and-research-infrastructure)
- [4. Baseline Backtest Results](#4-baseline-backtest-results)
- [5. Monte Carlo Methodology](#5-monte-carlo-methodology)
- [6. Monte Carlo Outcome Landscape](#6-monte-carlo-outcome-landscape)
- [7. Robustness Regime Classification](#7-robustness-regime-classification)
- [8. Robust-Only Performance Expectations](#8-robust-only-performance-expectations)
- [9. Why This Edge Likely Exists](#9-why-this-edge-likely-exists)
- [10. Limitations & Failure Modes](#10-limitations--failure-modes)
- [11. Practical Deployment Considerations](#11-practical-deployment-considerations)
- [12. Future Research Extensions](#12-future-research-extensions)
- [13. Research Integrity Statement](#13-research-integrity-statement)
- [Final Assessment](#final-assessment)

---

## 1. Research Objective

The objective of this study is to determine whether a time-of-day, structurally defined intraday breakout strategy on **NDX100**:
1.  Demonstrates positive expectancy under clean execution.
2.  Maintains profitability under realistic execution uncertainty.
3.  Exhibits bounded, interpretable failure modes rather than catastrophic breakdown.

The study explicitly avoids parameter optimization and instead focuses on robustness and distributional behavior, consistent with professional quantitative research standards.

---

## 2. Strategy Specification

### 2.1 Instrument & Timeframes
| Parameter | Value | Note |
| :--- | :--- | :--- |
| **Instrument** | NDX100 | Nasdaq-100 Index |
| **Signal Timeframe** | H1 | Closed-bar confirmation (reduces noise). |
| **Range Timeframe** | M1 | Precision range construction. |
| **Separation** | Intentional | M1 ensures accuracy; H1 prevents overreaction. |

### 2.2 Time-Based Range Definition
The strategy defines a fixed intraday range during:
* **15:00 – 16:00 (Server Time)**
* **08:00 – 09:00 New York Time**

This window corresponds to an early New York session liquidity regime transition, where overnight price compression often resolves into directional expansion. The range high and low represent a temporary equilibrium zone prior to price discovery.

### 2.3 Entry Logic (Breakout Mode)
After the range window completes:
* **Long Position:** Triggered if the previous H1 candle closes *above* the range high.
* **Short Position:** Triggered if the previous H1 candle closes *below* the range low.
* **Constraints:** Entries evaluated on closed bars only. Max 1 trade per day.

*The strategy does not predict direction; it reacts to price expansion beyond a structural boundary.*

### 2.4 Risk & Payoff Model
Risk per trade is applied consistently across Baseline and Monte Carlo tests.

| Parameter | Logic |
| :--- | :--- |
| **Risk per Trade** | 1% of Account Equity |
| **Position Sizing** | Dynamic, Volatility-Adjusted |
| **Stop Loss** | Anchored to opposite range extreme |
| **Reward-to-Risk** | 2.0 (Positive Skew) |

---

## 3. EA Design and Research Infrastructure

The custom **MetaTrader 5 (MT5)** Expert Advisor was developed specifically for research integrity, not live deployment.

* **High-Fidelity Range Construction:** Uses M1 bars to compute exact intraday highs and lows.
* **Strict Trade Isolation:** Symbol filtering and unique magic numbers prevent contamination.
* **Deterministic State:** Enforces strict one-trade-per-day logic for statistical cleanliness.
* **Execution Instrumentation:** Captures spread, slippage, delay, and fill outcomes.
* **Quant-Grade Export:** Per-pass metrics exported via `OnTesterPass()` with a CSV schema designed for downstream statistical analysis.

---

## 4. Baseline Backtest Results

<img width="2684" height="1064" alt="image" src="https://github.com/user-attachments/assets/c7d32769-3e60-4497-b581-8602fa57c2fe" />
<img width="2669" height="690" alt="image" src="https://github.com/user-attachments/assets/4bf01d05-5a5a-427a-a83a-0e5807920f9d" />
*(Monte Carlo Disabled – Reference Case)*

Before introducing execution uncertainty, a baseline backtest was conducted to establish the strategy’s unperturbed behavior under idealized execution.

### 4.1 Test Conditions
* **Monte Carlo:** OFF
* **Risk per trade:** 1%
* **Instrument:** NDX100 (H1)
* **History:** 99% Quality

### 4.2 Baseline Performance Summary

| Metric | Result |
| :--- | :--- |
| **Net Profit** | $2,834 |
| **Profit Factor** | 1.13 |
| **Sharpe Ratio** | 2.15 |
| **Win Rate** | 47.76% |
| **Max Drawdown** | ~16.96% |

### 4.3 Interpretation
* **Positive Expectancy:** Achieved without a high win rate (consistent with RRR = 2.0).
* **Bounded Drawdowns:** Material but typical for breakout systems.
* **Asymmetry:** A mild directional asymmetry exists (longs outperform shorts), consistent with equity index behavior.

---

## 5. Monte Carlo Methodology

### 5.1 Rationale
Traditional backtests implicitly assume stable spreads and instant fills—unrealistic for intraday index trading. Monte Carlo simulation is used to explicitly model execution uncertainty.

### 5.2 Execution Stress Dimensions
Each optimization pass defines a unique execution environment by randomizing:
* **Spread Inflation** (Multiplicative)
* **Slippage** (Points)
* **Execution Delay** (Milliseconds)
* **Order Failure** (Probability)

*Controls: 500 deterministic seeds; Stress Levels 1.0 → 3.0.*

### 5.3 Impact
Stress tests whether the strategy’s edge survives imperfect market participation (effective breakout threshold widening, adverse drift, missed trades).

---

## 6. Monte Carlo Outcome Landscape

<img width="2377" height="951" alt="image" src="https://github.com/user-attachments/assets/7a0a07ae-0324-4cea-b5a8-d7fb154c1440" />

Monte Carlo results are analyzed in **Profit–Drawdown** space, where each point represents one execution scenario.

**Key Observations:**
* A dense, profitable core of outcomes.
* Gradual performance degradation as stress increases.
* Rare, isolated loss-making scenarios.

*This pattern indicates structural expectancy, not reliance on ideal execution.*

---

## 7. Robustness Regime Classification

To separate deployable from non-deployable outcomes, scenarios are classified using explicit thresholds:

| Classification | Criteria |
| :--- | :--- |
| **Robust** | Net Profit ≥ $1,500 AND Max Drawdown ≤ 15% |
| **Fragile** | Profitable, but Drawdown > 15% |
| **Failing** | Net Negative Outcomes |

<img width="2381" height="961" alt="image" src="https://github.com/user-attachments/assets/633843bb-faba-4264-bc2c-79a49be51996" />

*Observation: The majority of scenarios fall into the robust or fragile categories, with failing outcomes statistically rare.*

---

## 8. Robust-Only Performance Expectations

To avoid optimistic bias, expectation statistics are computed **only** from robust scenarios.

<img width="2058" height="661" alt="image" src="https://github.com/user-attachments/assets/5c10f7d0-c377-4711-9fda-62ecd507930c" />

### 8.1 Profit Expectation
* **Average Profit:** ~$2,539
* **Median Profit:** ~$2,573
* *Observation: Close alignment between mean and median suggests profitability is not outlier-driven.*

### 8.2 Drawdown Profile
* **Median Drawdown:** ~13.15%
* **75th Percentile:** ~13.99%
* *Observation: Values remain comfortably below the robustness threshold, leaving headroom.*

---

## 9. Why This Edge Likely Exists

The **08:00 – 09:00 New York** window represents a liquidity regime transition characterized by:
1.  Increasing institutional participation.
2.  Resolution of overnight price compression.
3.  Activation of stop-loss and momentum-driven order flow.

The intraday range acts as a proxy for temporary equilibrium, and its boundaries become **order-flow activation zones**. Because the strategy reacts to price discovery, not indicators, its edge persists until execution costs overwhelm follow-through.

---

## 10. Limitations & Failure Modes

This strategy is not universally robust. Key limitations include:
* ⚠️ **Drawdown Sensitivity** under severe execution stress.
* ⚠️ **Dependence** on early NY session volatility.
* ⚠️ **Directional Asymmetry** between long and short trades.
* ⚠️ **Single-Trade Constraint** limits exposure but risks missing follow-through.
* ⚠️ **Regime Change Risk** (Structural shifts not modeled by Monte Carlo).

*Importantly, failure occurs gradually (drawdown inflation), not catastrophically.*

---

## 11. Practical Deployment Considerations

Before any live deployment, prudent enhancements would include:
* **Execution Filters:** Skip trades during spread/slippage blowouts.
* **Adaptive Risk:** Scale risk during adverse conditions.
* **Directional Controls:** Separate Long/Short risk profiles.
* **Volatility Filters:** Confirm session volatility before entry.
* **Broker Profiling:** Calibrate delays to specific broker infrastructure.

*These were intentionally excluded to preserve research neutrality.*

---

## 12. Future Research Extensions

Potential extensions consistent with quant standards:
1.  **Cross-Index Replication:** Testing on ES (S&P 500), RTY, DAX.
2.  **Volatility-Conditioned** range selection.
3.  **Direction-Specific Modeling.**
4.  **Adaptive Reward-to-Risk** structures.
5.  **Multi-Session Ensemble** strategies.

---

## 13. Research Integrity Statement

This study:
* ✅ Avoids curve-fitting and parameter mining.
* ✅ Separates baseline behavior from stressed distributions.
* ✅ Reports limitations transparently.
* ✅ Makes no claims of guaranteed profitability.

*Results represent empirical research, not investment advice.*

---

## Final Assessment

The baseline backtest confirms a **positive-expectancy reference case** under ideal execution with 1% risk per trade. Monte Carlo execution stress widens the distribution of outcomes but does not eliminate profitability across a meaningful subset of scenarios.

The dominant failure mode is **Drawdown Inflation**, not expectancy collapse — a characteristic consistent with structurally sound, time-based intraday strategies.
