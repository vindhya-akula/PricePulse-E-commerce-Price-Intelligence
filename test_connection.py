import requests
from bs4 import BeautifulSoup

url = "https://books.toscrape.com/"

response = requests.get(
    url,
    headers={"User-Agent": "PricePulse learning project"},
    timeout=15
)

print("Status code:", response.status_code)

response.raise_for_status()

response.encoding = response.apparent_encoding
soup = BeautifulSoup(response.text, "html.parser")

import unicodedata

title = "Noahâs"

print("Before:", title)
print("Unicode characters:", [
    f"{char!r}: U+{ord(char):04X}"
    for char in title
])

print("Page title:", soup.title.get_text(strip=True))

products = soup.select("article.product_pod")

print("Products found:", len(products))

if products:
    first_product = products[0]

    title = first_product.h3.a["title"]
    price = first_product.select_one(".price_color").get_text(strip=True)

    print("First product:", title)
    print("First product price:", price)
    