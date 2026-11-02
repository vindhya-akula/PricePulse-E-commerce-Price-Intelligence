
from pathlib import Path
import getpass
import pandas as pd
import mysql.connector
import sys

# 1. Locate the CSV file
BASE_DIR = Path(__file__).resolve().parent.parent
CSV_PATH = BASE_DIR / "data" / "raw" / "books.csv"

if not CSV_PATH.exists():
    raise FileNotFoundError(
        f"Dataset not found: {CSV_PATH}. "
        "Run scraper.py first."
    )

def main():
    connection = None
    cursor = None

    try:
        # 2. Read and validate the CSV before changing MySQL
        df = pd.read_csv(CSV_PATH, encoding="utf-8-sig")

        print("CSV loaded successfully!")
        print("Total rows:", len(df))

        required_columns = [
            "product_name", "price_gbp", "rating",
            "availability", "category", "product_url", "scraped_at"
        ]

        if not all(column in df.columns for column in required_columns):
            raise ValueError("CSV is missing required columns.")

        if df.empty:
            raise ValueError("CSV is empty. MySQL was not changed.")

        if df["product_url"].isna().any():
            raise ValueError("CSV contains missing product URLs.")

        if df["product_url"].duplicated().any():
            raise ValueError("CSV contains duplicate product URLs.")

        if df["product_name"].isna().any() or df["category"].isna().any():
            raise ValueError("CSV contains missing product names or categories.")

        if not df["price_gbp"].gt(0).all():
            raise ValueError("CSV contains invalid prices.")

        if not df["rating"].between(1, 5).all():
            raise ValueError("CSV contains invalid ratings.")

        # 3. Convert timestamps to MySQL-compatible UTC datetimes
        df["scraped_at"] = pd.to_datetime(
            df["scraped_at"],
            utc=True,
            errors="coerce"
        )

        if df["scraped_at"].isna().any():
            raise ValueError("CSV contains invalid timestamps.")

        df["scraped_at"] = df["scraped_at"].dt.tz_localize(None)

        # 4. Convert rows into MySQL-compatible values
        rows = [
            (
                row.product_name,
                float(row.price_gbp),
                int(row.rating),
                row.availability,
                row.category,
                row.product_url,
                row.scraped_at.to_pydatetime()
            )
            for row in df[required_columns].itertuples(index=False)
        ]

        # 5. Get the MySQL password
        password = getpass.getpass("Enter your MySQL password: ")

        # 6. Connect to MySQL
        connection = mysql.connector.connect(
            host="localhost",
            user="root",
            password=password,
            database="pricepulse"
        )

        cursor = connection.cursor()
        print("Connected to MySQL successfully!")

        # 7. Start a transaction
        connection.start_transaction()

        # 8. Remove old records
        cursor.execute("DELETE FROM products")
        print("Old product records cleared inside the transaction.")

        # 9. Insert the latest CSV records
        sql = """
            INSERT INTO products
            (product_name, price_gbp, rating, availability,
             category, product_url, scraped_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        cursor.executemany(sql, rows)

        # 10. Verify the new row count before committing
        cursor.execute("SELECT COUNT(*) FROM products")
        count = cursor.fetchone()[0]

        if count != len(df):
            raise ValueError(
                f"Row count mismatch: CSV={len(df)}, MySQL={count}"
            )

        # 11. Commit only after successful insertion and verification
        connection.commit()

        print("\nData refreshed successfully!")
        print("CSV records:", len(df))
        print("MySQL records:", count)

    except Exception as error:
        if connection is not None and connection.is_connected():
            connection.rollback()
            print("Transaction rolled back.")

        print("An error occurred:", error)
        sys.exit(1)

    finally:
        if cursor is not None:
            cursor.close()

        if connection is not None and connection.is_connected():
            connection.close()
            print("MySQL connection closed.")


if __name__ == "__main__":
    main()
