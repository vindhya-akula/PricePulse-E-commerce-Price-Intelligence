# PricePulse – E-commerce Price Intelligence Dashboard

An end-to-end data analytics project that collects, processes, and analyzes e-commerce book catalog data to uncover pricing patterns, rating distributions, and category-level insights using Python, MySQL, SQL, and Power BI.

## Project Overview

**PricePulse** is a data analytics project designed to explore pricing trends and product characteristics across an online book catalog.

The project uses web scraping to collect book information from [Books to Scrape](https://books.toscrape.com/), processes and validates the extracted data using Python, stores structured records in MySQL, performs SQL-based exploratory analysis, and presents key findings through an interactive Power BI dashboard.

The project demonstrates an end-to-end analytics workflow, from raw data collection to business insights and visualization.

## Business Objectives

- Collect structured product information through web scraping.
- Clean, validate, and transform extracted data.
- Store structured product records in a MySQL database.
- Analyze pricing distributions, ratings, and category-level trends using SQL.
- Identify relationships and patterns between product prices and ratings.
- Develop an interactive Power BI dashboard to communicate analytical findings.

## Tools & Technologies

| Category | Technologies |
|---|---|
| Programming | Python |
| Web Scraping | Requests, BeautifulSoup |
| Data Processing | Pandas, NumPy |
| Database | MySQL |
| Querying | SQL |
| Visualization | Power BI |
| Version Control | Git, GitHub |
| Development Environment | VS Code |

## Dataset

**Source:** [Books to Scrape](https://books.toscrape.com/)

The project collected and analyzed **1,000 book listings** from the demonstration e-commerce website.

### Dataset Attributes

- Product Name
- Price (GBP)
- Rating
- Availability
- Category
- Product URL
- Scraped Timestamp

The dataset provides a foundation for analyzing catalog-level pricing patterns, rating distributions, and category-level differences.

## Analytical Workflow

The project follows a structured data analytics pipeline:

### 1. Data Collection
- Extracted book catalog information using Python, Requests, and BeautifulSoup.
- Collected product names, prices, ratings, availability, categories, and product URLs.
- Scraped all 1,000 available book listings.

### 2. Data Cleaning & Validation
- Processed scraped records using Pandas.
- Validated extracted fields and data types.
- Handled encoding issues and prepared structured data for database storage.

### 3. Data Storage
- Created a MySQL database to store the collected book catalog.
- Loaded processed records into structured database tables.
- Established database connectivity using Python.

### 4. SQL Analysis
Performed exploratory SQL analysis to investigate:

- Overall pricing distributions.
- Book distribution across price bands.
- Average ratings across different price ranges.
- Category-level pricing and rating patterns.
- Top-performing categories based on average price and rating.

### 5. Dashboard Development
- Connected the structured data to Power BI.
- Developed interactive visualizations, KPI cards, and charts.
- Designed dashboard elements to support product catalog analysis.

### 6. Business Insights
- Interpreted pricing and rating patterns.
- Compared product distributions across categories.
- Identified catalog-level trends to support data-driven analysis.

### 7. Explore the Power BI Dashboard

- Open `powerbi/Pricepulse_Dashboard.pbix` using Power BI Desktop.
- Configure the MySQL connection if required.
- Refresh the dataset.
- Explore the dashboard using interactive filters and visualizations.

## Key Analysis & Business Insights

The analysis of 1,000 book listings across 50 categories revealed the following findings:

- **Premium Listings:** Premium-priced books represented approximately 40.3% of the analyzed catalog.
- **Rating Distribution:** Average ratings across different price bands were relatively similar, ranging from 2.85 to 2.98.
- **Pricing Analysis:** Compared book prices across Budget, Mid-range, and Premium segments.
- **Category Analysis:** Examined category-level differences in average prices, ratings, and product counts.
- **Product Distribution:** Identified categories with the highest number of book listings.

These findings provide insights into catalog composition, pricing patterns, and rating distributions.

## Power BI Dashboard

The interactive Power BI dashboard presents the analyzed book catalog through KPI cards, charts, and visual comparisons.

### Dashboard Features

**Key Performance Indicators**
- Total Books
- Average Book Price
- Average Rating
- Highest Book Price

**Pricing Analysis**
- Book Distribution by Price Band
- Average Price by Rating
- Pricing comparisons across product segments

**Rating Analysis**
- Average Rating by Price Band
- Book Distribution by Rating

**Category Analysis**
- Top 10 Categories by Number of Books
- Top 10 Categories by Average Price
- Top 10 Categories by Average Rating

### Dashboard Preview

#### Homepage

![PricePulse Homepage](Screenshots/Homepage.png)

#### Dashboard Overview

![PricePulse Dashboard Overview](Screenshots/PricePulse%20Overview.png)

## Project Structure

```text
PricePulse-E-commerce-Price-Intelligence/
│
├── data/
│   └── raw/
│       └── books.csv
│
├── scraper/
│   ├── scraper.py
│   ├── fix_encoding.py
│   └── load_to_mysql.py
│
├── sql/
│   └── pricepulsequeries.sql
│
├── powerbi/
│   └── Pricepulse_Dashboard.pbix
│
├── Screenshots/
│   ├── Homepage.png
│   └── PricePulse Overview.png
│
├── test_connection.py
├── update_mysql_names.py
├── requirements.txt
├── .gitignore
└── README.md
```

**Note:** The raw dataset directory is excluded from GitHub through `.gitignore`. Running the scraper generates the dataset