from __future__ import annotations
from pathlib import Path
import pandas as pd

MT5_TS_FORMAT = "%Y.%m.%d %H:%M"

def _clean_cell(x: str) -> str:
    x = x.strip()
    # MT5 sometimes double-quotes fields like ""2024.01.03 01:00""
    x = x.strip('"').strip('"')
    return x

def load_mt5_m1_csv(path: str | Path) -> pd.DataFrame:
    """
    Robust loader for MT5DataBridge M1 CSV exported from Strategy Tester.

    Handles:
    - UTF-16 encoding
    - quoted header: "timestamp,open,high,..."
    - quoted fields like ""2024.01.03 01:00""
    - occasional malformed lines (skips safely)

    Expected columns:
    timestamp,open,high,low,close,tick_volume,spread
    """
    path = Path(path)

    with open(path, "r", encoding="utf-16") as f:
        lines = [ln.strip() for ln in f if ln.strip()]

    if not lines:
        raise ValueError(f"Empty file: {path}")

    header = lines[0].strip().strip('"')
    cols = [c.strip() for c in header.split(",")]

    required = ["timestamp", "open", "high", "low", "close", "tick_volume", "spread"]
    if cols != required:
        # still allow if order matches but maybe spaces; otherwise fail loud
        missing = [c for c in required if c not in cols]
        if missing:
            raise ValueError(f"Bad header in {path.name}. Found: {cols}")

    rows = []
    for ln in lines[1:]:
        parts = [_clean_cell(x) for x in ln.split(",")]
        if len(parts) != len(cols):
            continue
        rows.append(parts)

    df = pd.DataFrame(rows, columns=cols)

    df["timestamp"] = pd.to_datetime(df["timestamp"], format=MT5_TS_FORMAT, errors="raise")
    for c in ["open", "high", "low", "close", "tick_volume", "spread"]:
        df[c] = pd.to_numeric(df[c], errors="coerce")

    df = (
        df.dropna(subset=["timestamp", "open", "high", "low", "close"])
          .sort_values("timestamp")
          .drop_duplicates("timestamp", keep="last")
          .reset_index(drop=True)
    )

    return df
