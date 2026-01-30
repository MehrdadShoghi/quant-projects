import pandas as pd
from pathlib import Path

RAW_DIR = Path("data/raw")
OUT_DIR = Path("data/processed")
OUT_DIR.mkdir(parents=True, exist_ok=True)

def clean_mt5_csv(in_path: Path, symbol: str) -> Path:
    df = pd.read_csv(in_path)
    df.columns = [c.strip().lower() for c in df.columns]

    if "date" in df.columns and "time" in df.columns:
        df["timestamp"] = pd.to_datetime(df["date"].astype(str) + " " + df["time"].astype(str), errors="coerce")
    elif "time" in df.columns:
        df["timestamp"] = pd.to_datetime(df["time"], errors="coerce")
    else:
        raise ValueError(f"Cannot parse timestamp columns: {df.columns.tolist()}")

    rename = {"tickvol": "tick_volume", "vol": "real_volume"}
    df = df.rename(columns=rename)

    keep = [c for c in ["timestamp","open","high","low","close","tick_volume","real_volume","spread"] if c in df.columns]
    df = df[keep].dropna(subset=["timestamp","open","high","low","close"]).sort_values("timestamp")
    df = df.drop_duplicates(subset=["timestamp"], keep="last")
    df["symbol"] = symbol

    out_path = OUT_DIR / f"{symbol}_M1.parquet"
    df.to_parquet(out_path, index=False)
    return out_path

