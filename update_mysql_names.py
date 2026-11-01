
from pathlib import Path
import getpass
import pandas as pd
import mysql.connector

BASE_DIR = Path(__file__).resolve().parent
CSV_PATH = BASE_DIR / "data" / "raw" / "books.csv"

# Read the repaired CSV
df = pd.read_csv(CSV_PATH, encoding="utf-8-sig")

password = getpass.getpass("Enter your MySQL password: ")

connection = None
cursor = None

try:
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password=password,
        database="pricepulse"
    )

    cursor = connection.cursor()

    # Update product names using their unique URLs
    sql = """
        UPDATE products
        SET product_name = %s
        WHERE product_url = %s
    """

    rows = list(
        df[["product_name", "product_url"]]
        .itertuples(index=False, name=None)
    )

    cursor.executemany(sql, rows)
    connection.commit()

    print("Product names synchronized with the repaired CSV!")

    cursor.execute("""
        SELECT product_id, product_name
        FROM products
        WHERE product_name LIKE '%Noah%'
    """)

    for row in cursor.fetchall():
        print(row)

    cursor.execute("SELECT COUNT(*) FROM products")
    print("Total products:", cursor.fetchone()[0])

except Exception as error:
    if connection is not None and connection.is_connected():
        connection.rollback()
    print("Error:", error)

finally:
    if cursor is not None:
        cursor.close()
    if connection is not None and connection.is_connected():
        connection.close()
