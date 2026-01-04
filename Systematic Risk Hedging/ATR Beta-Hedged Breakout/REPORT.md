# Intraday Range Breakout with ATR-Scaled Beta Hedging

![Platform](https://img.shields.io/badge/Platform-MetaTrader%205-blue)
![Language](https://img.shields.io/badge/Language-MQL5-green)
![Version](https://img.shields.io/badge/Version-1.00-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**A volatility-aware intraday breakout strategy with adaptive index hedging.**

---

## 📑 Table of Contents
- [Overview](#-overview)
- [Theory & Logic](#-theory--logic)
- [Performance Comparison](#-performance-comparison)
- [Key Features](#-key-features)
- [Hedge Logic Matrix](#-hedge-logic-matrix)
- [Technical Logic](#-technical-logic)
- [Math & Calculations](#-math--calculations)
- [Installation](#-installation)
- [Disclaimer](#-disclaimer)

---

## 📈 Overview

**RangeBetaHedge** is a quantitative system designed to extract momentum alpha from intraday price discovery ranges while actively mitigating systemic market risk.

Unlike standard breakout strategies that leave equity exposed to index shocks, this system introduces a controlled, **ATR-scaled beta hedging framework**. It dynamically hedges the main position using a correlated instrument (e.g., SPX500) only when volatility conditions necessitate protection.

---

## 📘 Theory & Logic

The core hypothesis rests on two market mechanics:

1. **Price Discovery:** Markets frequently establish ranges during defined intraday windows. A confirmed breakout beyond this range ($High$ or $Low$), when aligned with higher-timeframe structure, represents a tradable momentum regime.
2. **Systemic Shock Mitigation:** Intraday breakouts are vulnerable to broader market sentiment shifts.

To solve the "false breakout" problem caused by index correlation, this system applies **Adaptive Hedging**:
* **Correlation Filter:** A hedge is only opened if the main symbol and hedge symbol move in the same direction, preventing hedging during divergence.
* **Beta Neutrality:** The hedge size is not arbitrary; it is calculated using Volatility (ATR) and Contract Value to achieve economic neutrality.

---

## 📊 Performance Comparison

Two configurations were evaluated over the 2024–2025 period using 99% quality data. The **Hedged** approach demonstrates superior risk-adjusted returns compared to the **Unhedged** baseline.

### Key Metrics

| Metric | Unhedged Baseline | **Hedged System** |
| :--- | :--- | :--- |
| **Net Profit** | $5,618.95 | **$7,320.93** |
| **Profit Factor** | 1.25 | **1.31** |
| **Max Drawdown** | 8.25% | **6.35%** |
| **Recovery Factor** | 4.43 | **6.90** |
| **Sharpe Ratio** | 3.71 | **4.73** |

### Equity Curve Behavior
* **Unhedged:** Shows clear growth but suffers deeper drawdowns during periods of high index volatility.
* **Hedged:** Results in a smoother curve with faster recovery and reduced equity compression during market shocks.

---

## ✨ Key Features

* **🛡️ Dynamic Beta Hedging:** Automatically calculates hedge size based on volatility ratios ($\beta$) to ensure true economic offset.
* **⏱️ No Look-Ahead Bias:** Ranges are finalized only after the full window completes. No intrabar execution or repainting.
* **🧩 Lifecycle Control:** The hedge is slave to the main position. It opens only when conditions are met and closes immediately when the main position exits.
* **📉 Risk Normalization:** Uses Percent-based Stop Loss and RRR-based Take Profit to standardize risk across different asset classes.

---

## 🧩 Hedge Logic Matrix

The hedging engine uses a specific set of logic to avoid over-hedging or hedging during noise.

| Condition | Logic | Purpose |
| :--- | :--- | :--- |
| **Activation** | $|R_{hedge}| \le \text{LagFactor} \times |R_{main}|$ | Ensures hedge move lags the main move; prevents hedging noise. |
| **Direction** | Main & Hedge must match direction | Prevents hedging during market divergence. |
| **Sizing** | Clamped Beta ($0.5 \le \beta \le 5.0$) | Prevents outlier volatility from creating massive hedge positions. |
| **Exit** | Main Trade Closure | Prevents orphan exposure; hedge dies when main trade dies. |

---

## 🧮 Technical Logic

The system operates on a strict state-machine architecture to ensure deterministic behavior.

### 1. Intraday Range Construction
The system builds the range using M1 data between `RangeStartHour` and `RangeDurationMin`.
$$RangeHigh = \max(High_{M1})$$
$$RangeLow = \min(Low_{M1})$$

### 2. Breakout Confirmation
Signal is generated on the Confirmation Timeframe (e.g., H1).
* **Buy:** If $Close_{t-1} > RangeHigh$
* **Sell:** If $Close_{t-1} < RangeLow$

### 3. Risk Management
* **Stop Loss:** $SL_{distance} = P_{entry} \times \frac{SL_{\%}}{100}$
* **Take Profit:** $TP_{distance} = SL_{distance} \times RRR$

---

## 💻 Math & Calculations

The core innovation is the **ATR-Scaled Beta** calculation, used to determine the exact lot size for the hedge instrument.

### Beta ($\beta$) Formula
To achieve economic neutrality, we balance Volatility and Contract Value:

$$\beta = \frac{ATR_{main} \times VPP_{main}}{ATR_{hedge} \times VPP_{hedge}}$$

* **ATR:** Average True Range
* **VPP:** Value Per Point (Contract Size)

### Smoothed Update
To avoid jitter in sizing, the Beta is smoothed over time:
$$\beta_t = (1-\alpha)\beta_{t-1} + \alpha \beta_{raw}$$

### Final Hedge Sizing
$$\text{HedgeLots} = \text{MainLots} \times \beta$$

---

## 📥 Installation

1. Download the `.mq5` source files.
2. Open your **MetaTrader 5** terminal.
3. Go to **File** -> **Open Data Folder**.
4. Navigate to `MQL5` -> `Experts`.
5. Paste the file into this folder.
6. Compile and attach to your chart (ensure the Hedge Symbol, e.g., SPX500, is in your Market Watch).

---

## ⚠️ Disclaimer

**Risk Warning:** Trading financial markets involves significant risk of loss. This tool is provided for educational and analytical purposes only. Past performance of any trading system or methodology is not necessarily indicative of future results. The hedging techniques described increase margin utilization and require careful capital management. The author accepts no liability for any loss or damage.

---

**Author:** Mehrdad Shoghi
**Copyright:** © 2026
