
from pathlib import Path
import pandas as pd

# Locate the existing CSV
BASE_DIR = Path(__file__).resolve().parent
CSV_PATH = BASE_DIR / "data" / "raw" / "books.csv"
BACKUP_PATH = BASE_DIR / "data" / "raw" / "books_backup.csv"

# Read the CSV
df = pd.read_csv(CSV_PATH, encoding="utf-8-sig")

# Keep a backup before making changes
if not BACKUP_PATH.exists():
    df.to_csv(BACKUP_PATH, index=False, encoding="utf-8-sig")
    print("Backup created:", BACKUP_PATH)

# Repair the known corrupted apostrophe sequence
columns_to_fix = ["product_name", "category", "availability"]

for column in columns_to_fix:
    if column in df.columns:
        df[column] = df[column].apply(
            lambda value: value.replace("â\u0080\u0099", "’")
            if isinstance(value, str) else value
        )

# Save the repaired CSV
df.to_csv(CSV_PATH, index=False, encoding="utf-8-sig")

print("CSV repair completed!")
print("Total rows:", len(df))
print("Remaining corrupted apostrophe sequences:",
      sum(
          df[column].astype(str).str.contains(
              "â\u0080\u0099", regex=False
          ).sum()
          for column in columns_to_fix if column in df.columns
      ))

# Preview repaired names
print(df[df["product_name"].str.contains(
    "Noah", case=False, na=False
)]["product_name"].to_string(index=False))
