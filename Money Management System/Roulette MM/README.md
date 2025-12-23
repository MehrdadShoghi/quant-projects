# 🎲 RouletteMM Library (MQL5)

![Platform](https://img.shields.io/badge/Platform-MetaTrader%205-blue)
![Language](https://img.shields.io/badge/Language-MQL5-green)
![Version](https://img.shields.io/badge/Version-1.00-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**A modular, object-oriented Money Management engine for Expert Advisors.**

---

## 📑 Table of Contents
- [Overview](#-overview)
- [Key Features](#-key-features)
- [Strategy Matrix (How to Read)](#-strategy-matrix-how-to-read)
- [Technical Logic](#-technical-logic)
- [Developer Integration](#-developer-integration)
- [Installation](#-installation)
- [Disclaimer](#-disclaimer)

---

## 📈 Overview

**RouletteMM** is a standalone C++ Class (`.mqh`) that encapsulates advanced cycle-based position sizing logic. It separates the *math* of money management from the *signals* of your trading strategy.

This allows developers to plug professional-grade "Casino Math" into any EA with just three lines of code.

---

## ✨ Key Features

* **🛡️ Flattening (Defense):** The system automatically drops trade size to a microscopic level (e.g., 0.01 lots) immediately after a loss. It stays flat until a win is secured, protecting the account during choppy markets.
* **💾 State Persistence:** Uses Terminal Global Variables to "remember" the cycle position. If you restart MT5 or recompile your EA, the strategy picks up exactly where it left off.
* **📦 Plug-and-Play:** Zero global variable clutter. The entire system is contained within the `CRouletteMM` class.
* **🧠 Adaptive Logic:** Supports three distinct mathematical models for different market conditions (Trending vs. Mean Reversion).

---

## 🧩 Strategy Matrix (How to Read)

The library supports three distinct modes via `ENUM_MM_TYPE`. Choose the one that fits your strategy's win rate:

| Mode | Behavior | Risk Profile | **Best For** |
| :--- | :--- | :--- | :--- |
| **MM_CONSECUTIVE** | **Positive Progression.** Resets to 1 unit immediately after *any* loss. Requires a winning streak to profit. | **Aggressive** | High Win-Rate Breakout EAs |
| **MM_CUMULATIVE** | **Balanced Progression.** After a loss, it steps down 1 unit (or less) rather than resetting fully. Retains progress during mixed results. | **Moderate** | Trend Following / Swing |
| **MM_NEGATIVE** | **Martingale Variant.** Increases risk after a loss to recover faster. Decreases risk after a win. | **High Risk** | Scalping / Mean Reversion |

---

## 🧮 Technical Logic

The engine operates on a **Cycle** principle defined by two key states:

1. **The Cycle (Offense):**
    * The system tries to complete a cycle of $N$ wins (defined by `CycleTarget`).
    * As wins accumulate, lot size increases: $Lot = Base + (Base \times Unit)$.
    * If the target is reached, the system banks the profit and resets to Unit 1.

2. **The Flattening (Defense):**
    * *Trigger:* Any loss occurs (in Positive modes).
    * *Action:* Lot size is forced to `FlatteningLot` (e.g., 0.01).
    * *Exit:* A win must occur at 0.01 to prove the market is safe. Only then does the cycle resume.

---

## 💻 Developer Integration

This library is designed for the `MQL5/Include` folder.

### 1. Initialize
```cpp
#include <RouletteMM.mqh>

// Global Instance
CRouletteMM mm;

int OnInit() {
   // Magic, Symbol, Enabled, Mode, Base, Flat, Target, UseFlat, RRR
   mm.Init(12345, _Symbol, true, MM_CONSECUTIVE, 0.1, 0.01, 6, true, 1.5);
   return(INIT_SUCCEEDED);
}
```

### 2. Get Lot Size
Call this before opening any trade:
```cpp
double lotSize = mm.GetLotSize();
trade.Buy(lotSize, ...);
```

### 3. Process Results
Call this inside `OnTradeTransaction` to update the math:
```cpp
void OnTradeTransaction(const MqlTradeTransaction& trans, ...) {
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD) {
      mm.OnDeal(trans.deal);
   }
}
```

---

## 📥 Installation

1. Download `RouletteMM.mqh`.
2. Open your **MetaTrader 5** terminal.
3. Go to **File** -> **Open Data Folder**.
4. Navigate to `MQL5` -> `Include`.
5. Paste the file into this folder.
6. In your EA, add `#include <RouletteMM.mqh>` at the top.

---

## ⚠️ Disclaimer

**Risk Warning:** Trading financial markets involves significant risk of loss. This tool is provided for educational and analytical purposes only. Past performance of any trading system or methodology is not necessarily indicative of future results. The "Flattening" and "Martingale" techniques described can still result in losses if market conditions are unfavorable. The author accepts no liability for any loss or damage.

---

**Author:** Gemini AI User  
**Copyright:** © 2025
