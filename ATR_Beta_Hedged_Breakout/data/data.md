# Data Contract (MT5 Export → Python)

## Source
MetaTrader 5 History Center export (broker historical data).

## Symbols
- Main: NDX100
- Hedge: SPX500

## Required Timeframe
- M1 (core logic uses M1 for range + ATR + lag filter)
- H1 optional (can be resampled)

## Time Zone
- Export time zone: server time (document broker UTC offset)

## Required Columns
- time (timestamp)
- open, high, low, close
- tick_volume (optional)
- spread (optional)

## Raw Naming
data/raw/{SYMBOL}_M1_SERVER_{START}_{END}.csv

