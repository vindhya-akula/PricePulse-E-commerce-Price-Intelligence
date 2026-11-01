# PricePulse — E-commerce Price Intelligence

A data analytics project that collects, processes, and analyzes book catalog data to explore pricing patterns, ratings, and category-level trends.

## Project Overview

PricePulse is an end-to-end data analytics project built using Python, web scraping, MySQL, SQL, and Power BI. It extracts book information from Books to Scrape, stores the collected data, performs exploratory SQL analysis, and presents the findings through an interactive Power BI dashboard.

## Project Objective

- Collect book catalog data through web scraping.
- Clean, validate, and store the extracted data.
- Analyze book prices, ratings, price bands, and categories using SQL.
- Build an interactive dashboard to communicate meaningful insights.

## Tools and Technologies

- **Python:** Data collection and data processing
- **Requests:** Sending HTTP requests
- **BeautifulSoup:** HTML parsing and web scraping
- **Pandas:** Data cleaning and validation
- **MySQL:** Data storage
- **SQL:** Data analysis and querying
- **Power BI:** Interactive dashboard and visualization
- **Git and GitHub:** Version control and project hosting

## Dataset

**Source:** [Books to Scrape](https://books.toscrape.com/)

The dataset contains 1,000 book listings with information such as:

- Product name
- Price (GBP)
- Rating
- Availability
- Category
- Product URL
- Scraped timestamp

## Key Analysis and Findings

- Analyzed 1,000 book listings across 50 categories.
- Compared book distribution across Budget, Mid-range, and Premium price bands.
- Examined the relationship between book prices and ratings.
- Identified categories with the highest average prices and ratings.
- Found that Premium listings account for 40.3% of the catalog.
- Observed that average ratings across price bands are relatively similar, ranging from 2.85 to 2.98.

## Power BI Dashboard

The interactive dashboard provides:

- Total Books
- Average Book Price
- Average Rating
- Highest Book Price
- Book Distribution by Price Band
- Average Price by Rating
- Average Rating by Price Band
- Book Distribution by Rating
- Top 10 Categories by Number of Books
- Top 10 Categories by Average Price
- Top 10 Categories by Average Rating

## Project Structure

```text
PricePulse/
├── data/
│   └── raw/
│       └── books.csv
├── scraper/
│   ├── scraper.py
│   ├── fix_encoding.py
│   └── load_to_mysql.py
├── sql/
│   └── pricepulsequeries.sql
├── powerbi/
│   └── PricePulse_Dashboard.pbix
├── Screenshots/
│   ├── Homepage.png
│   └── PricePulse_Overview.png
├── test_connection.py
├── update_mysql_name.py
├── requirements.txt
├── .gitignore
└── README.md
```

## How to Run the Project

### 1. Clone the repository

```bash
git clone https://github.com/vindhya-akula/PricePulse-E-commerce-Price-Intelligence
cd PricePulse
```

### 2. Create and activate a virtual environment

```bash
python -m venv venv
venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Run the web scraper

```bash
python scraper/scraper.py
```

### 5. Configure MySQL

Create a MySQL database named `pricepulse`, configure your local database connection, and run the data-loading script.

```bash
python scraper/load_to_mysql.py
```

### 6. Perform SQL analysis

Open the SQL queries in the `sql` folder using MySQL Workbench.

### 7. Explore the dashboard

Open the Power BI `.pbix` file in Power BI Desktop. Configure the MySQL connection if required.

## Disclaimer

Books to Scrape is a demonstration website intended for web scraping practice. The dataset represents sample catalog listings and does not contain actual sales, customer transactions, or real-world purchasing behavior.

## Author

Created as a hands-on Data Analytics portfolio project using Python, SQL, MySQL, and Power BI. 