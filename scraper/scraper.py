
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urljoin

import pandas as pd
import requests
from bs4 import BeautifulSoup


# Configuration
BASE_URL = "https://books.toscrape.com/"
OUTPUT_DIR = Path("data/raw")
OUTPUT_FILE = OUTPUT_DIR / "books.csv"

HEADERS = {
    "User-Agent": "PricePulse learning project"
}

RATING_MAP = {
    "One": 1,
    "Two": 2,
    "Three": 3,
    "Four": 4,
    "Five": 5,
}


def scrape_books():
    session = requests.Session()
    session.headers.update(HEADERS)

    records = []
    visited_pages = set()

    try:
        # Step 1: Get category links from the homepage
        response = session.get(BASE_URL, timeout=15)
        response.raise_for_status()

        soup = BeautifulSoup(response.content, "html.parser")

        
        category_links = soup.select(
                "div.side_categories ul li ul li a"
            )


        if not category_links:
            print("No categories found. Check the website structure.")
            return records

        print("Total categories found:", len(category_links))

        # Step 2: Visit each category
        for link in category_links:
            category = link.get_text(strip=True)
            url = urljoin(BASE_URL, link["href"])

            print(f"\nScraping category: {category}")

            while url:
                if url in visited_pages:
                    print("Page already visited. Stopping this category.")
                    break

                visited_pages.add(url)
                print("Scraping page:", url)

                try:
                    response = session.get(url, timeout=15)
                    response.raise_for_status()

                except requests.RequestException as error:
                    print("Request failed:", error)
                    break

                soup = BeautifulSoup(
                    response.content, "html.parser"
                )

                products = soup.select("article.product_pod")

                if not products:
                    print("No products found on this page.")
                    break

                # Step 3: Extract products from the current page
                for product in products:
                    try:
                        # Product name
                        title_element = product.select_one("h3 a")

                        if title_element is None:
                            print("Skipping product: title not found.")
                            continue

                        title = title_element.get("title")

                        if not title:
                            title = title_element.get_text(strip=True)

                        # Price
                        price_element = product.select_one(".price_color")

                        if price_element is None:
                            print(f"Skipping {title}: price not found.")
                            continue

                        price_text = price_element.get_text(strip=True)

                        price = float(
                            price_text.replace("£", "").replace("Â", "")
                        )

                        # Rating
                        rating_element = product.select_one("p.star-rating")

                        rating = None

                        if rating_element is not None:
                            rating_class = rating_element.get("class", [])

                            rating_word = next(
                                (
                                    word for word in rating_class
                                    if word in RATING_MAP
                                ),
                                None
                            )

                            rating = RATING_MAP.get(rating_word)

                        # Availability
                        availability_element = product.select_one(
                            "p.availability"
                        )

                        if availability_element is not None:
                            availability = availability_element.get_text(
                                " ", strip=True
                            )
                        else:
                            availability = "Unknown"

                        # Product URL
                        relative_url = title_element.get("href")

                        if not relative_url:
                            print(f"Skipping {title}: URL not found.")
                            continue

                        product_url = urljoin(url, relative_url)

                        # Save product record
                        records.append({
                            "product_name": title,
                            "price_gbp": price,
                            "rating": rating,
                            "availability": availability,
                            "category": category,
                            "product_url": product_url,
                            "scraped_at": datetime.now(
                                timezone.utc
                            ).isoformat()
                        })

                    except (AttributeError, KeyError, TypeError, ValueError) as error:
                        print("Skipping a malformed product:", error)

                # Step 4: Follow the next page AFTER processing products
                next_link = soup.select_one("li.next a")

                if next_link:
                    url = urljoin(url, next_link["href"])
                    time.sleep(1)
                else:
                    url = None

    finally:
        session.close()

    return records


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    records = scrape_books()

    if not records:
        print("No records collected. CSV was not created.")
        return

    df = pd.DataFrame(records)

    # Save CSV
    df.to_csv(
        OUTPUT_FILE,
        index=False,
        encoding="utf-8-sig"
    )

    print("\nScraping complete!")
    print("Total records:", len(df))
    print("Columns:", list(df.columns))
    print("Saved to:", OUTPUT_FILE.resolve())

    print("\nFirst five records:")
    print(df.head())

    # Data quality checks
    print("\nData quality checks:")
    print("Total rows:", len(df))
    print("Missing values:\n", df.isnull().sum())
    print(
        "Duplicate product URLs:",
        df["product_url"].duplicated().sum()
    )
    print("Unique categories:", df["category"].nunique())

    # Price validation
    print("\nPrice validation:")
    print("Minimum price:", df["price_gbp"].min())
    print("Maximum price:", df["price_gbp"].max())
    print("Invalid prices:", (df["price_gbp"] <= 0).sum())

    # Rating validation
    print("\nRating validation:")
    print("Rating values:", sorted(df["rating"].dropna().unique()))
    print(
        "Missing ratings:",
        df["rating"].isnull().sum()
    )
    print(
        "Invalid ratings:",
        (~df["rating"].between(1, 5)).sum()
    )

    # Availability analysis
    print("\nAvailability distribution:")
    print(df["availability"].value_counts(dropna=False))

    # Category preview
    print("\nSample categories:")
    print(sorted(df["category"].unique())[:10])


if __name__ == "__main__":
    main()

    
