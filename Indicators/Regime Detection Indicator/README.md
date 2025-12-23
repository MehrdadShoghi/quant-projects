# Regime Detection Indicator (MQL5)

**Version:** 3.08  
**Author:** Mehrdad Shoghi  
**Platform:** MetaTrader 5 (MT5)

![Indicator Screenshot](https://via.placeholder.com/800x400?text=Place+Your+Screenshot+Here)
*(Add a screenshot of the indicator in action here)*

## 📈 Overview

The **Regime Detection Indicator** is a sophisticated market classification tool designed for algorithmic and manual trading on MetaTrader 5.

Unlike standard oscillators that rely on fixed overbought/oversold levels, this indicator uses **Adaptive Statistics** (Linear Regression Slope + Realized Volatility) to classify the market into 5 distinct "Regimes." It effectively filters out noise during sideways markets and identifies high-probability breakout or crash scenarios.

## ✨ Key Features

* **🚫 Non-Repainting (Bar-Close Stable):** Explicitly designed for reliability. The indicator "latches" values to the previous closed bar while the current bar is forming. It does not flicker or change colors mid-candle.
* **🧠 Auto-Adaptive Thresholds:** Uses Standard Deviations and Z-Scores instead of fixed values. It automatically adjusts to the volatility of any asset (Crypto, Indices, Forex, Commodities).
* **🎨 Visual Regime Map:** Colors the subwindow line and (optionally) the main chart background to reflect the current market state.
* **📊 On-Chart Diagnostics:** Draws the active Linear Regression line and displays a real-time status panel.
* **🔔 Alerts:** Built-in popup and log alerts when the market regime shifts.

## 🧩 How It Works

The indicator calculates a 2D Matrix of market states based on two rolling metrics over `N` bars:

1.  **Trend Strength:** Calculated via the Slope of a Linear Regression.
2.  **Volatility:** Calculated via the Standard Deviation of Log-Returns.

### The Regime Matrix

| Trend Direction | Volatility | **Regime Name** | **Color** | **Market Behavior** |
| :--- | :--- | :--- | :--- | :--- |
| **UP** | **HIGH** | **EXPLOSIVE UP** | `Dark Green` | Strong momentum, short squeezes, FOMO rallies. |
| **UP** | NORMAL | **STEADY UP** | `Lime` | Healthy, sustainable uptrend. Ideal for trend following. |
| **DOWN** | **HIGH** | **CRASH / DUMP** | `Dark Red` | Panic selling, news events, strong breakdown. |
| **DOWN** | NORMAL | **SLOW BLEED** | `Light Coral` | Grinding bear market or correction. |
| **FLAT** | (ANY) | **SIDEWAYS** | `Gold` | Mean-reverting, choppy, or accumulation/distribution. |

## ⚙️ Inputs & Parameters

| Parameter | Default | Description |
| :--- | :--- | :--- |
| `InpPriceType` | Close | The price data to analyze (Close, High, Low, Median, etc.). |
| `InpLookback` | 30 | The rolling window size (in bars) for regression and volatility calculations. |
| `InpTrendSensitivity`| 1.5 | Trend trigger threshold in **Standard Deviations**. |
| `InpVolSensitivity` | 1.0 | Volatility trigger threshold in **Z-Score**. |
| `InpShadeBackground`| true | Enables coloring the main chart background based on the regime. |
| `InpShowRegLine` | true | Draws the black Linear Regression line on the price chart. |

## 💻 Integration for EA Developers

This indicator is "iCustom-friendly." You can call it from an Expert Advisor using `iCustom`.

**Buffer Mapping:**

* **Buffer 0 (DATA):** The Regression Slope Value.
* **Buffer 1 (COLOR):** The Color Index (0=Gray, 1=DarkGreen, 2=Lime, 3=DarkRed, 4=LightCoral, 5=Gold).
* **Buffer 2 (CALC):** The Realized Volatility value.

**Example Code:**
```cpp
// Check if Regime is SIDEWAYS (Gold) to filter trades
double slopeVal = iCustom(..., 0, shift);
double colorIdx = iCustom(..., 1, shift);

if (colorIdx == 5) {
   // Market is chopping/sideways. Avoid Trend Strategies.
}
