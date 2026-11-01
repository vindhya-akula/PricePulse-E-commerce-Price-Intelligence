/* ============================================================
   PRICEPULSE - E-COMMERCE PRICE INTELLIGENCE
   Database: MySQL 8.0+
   Purpose: Schema creation, data validation and SQL analysis
   ============================================================ */

/* ------------------------------------------------------------
   1. DATABASE AND TABLE SETUP
   ------------------------------------------------------------ */
CREATE DATABASE IF NOT EXISTS pricepulse;
USE pricepulse;

CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(500) NOT NULL,
    price_gbp DECIMAL(10,2) NOT NULL,
    rating TINYINT NOT NULL,
    availability VARCHAR(100) NOT NULL,
    category VARCHAR(100) NOT NULL,
    product_url VARCHAR(500) NOT NULL,
    scraped_at DATETIME NOT NULL,
    UNIQUE KEY unique_product_url (product_url),
    CONSTRAINT chk_price CHECK (price_gbp > 0),
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;

/* ------------------------------------------------------------
   2. TABLE STRUCTURE AND INITIAL DATA VALIDATION
   ------------------------------------------------------------ */
SHOW TABLES;
DESCRIBE products;
SHOW CREATE TABLE products;

-- Total number of records
SELECT COUNT(*) AS total_records
FROM products;

-- Preview records
SELECT
    product_id,
    product_name,
    price_gbp,
    rating,
    availability,
    category,
    product_url,
    scraped_at
FROM products
LIMIT 10;

-- Check missing or blank product names
SELECT COUNT(*) AS missing_or_blank_names
FROM products
WHERE product_name IS NULL OR TRIM(product_name) = '';

-- Check missing or blank categories
SELECT COUNT(*) AS missing_or_blank_categories
FROM products
WHERE category IS NULL OR TRIM(category) = '';

-- Check invalid prices and ratings
SELECT
    SUM(CASE WHEN price_gbp <= 0 THEN 1 ELSE 0 END) AS invalid_prices,
    SUM(CASE WHEN rating NOT BETWEEN 1 AND 5 THEN 1 ELSE 0 END) AS invalid_ratings
FROM products;

-- Check uniqueness of product URLs
SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_url) AS unique_product_urls
FROM products;

-- Identify duplicate product URLs, if any
SELECT
    product_url,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_url
HAVING COUNT(*) > 1;

-- Check the scrape date range
SELECT
    MIN(scraped_at) AS earliest_scrape,
    MAX(scraped_at) AS latest_scrape
FROM products;


-- Find the highest-priced books
SELECT
    product_name,
    category,
    price_gbp,
    rating
FROM products
ORDER BY price_gbp DESC
LIMIT 10;

-- Find the lowest-priced books
SELECT
    product_name,
    category,
    price_gbp,
    rating
FROM products
ORDER BY price_gbp ASC
LIMIT 10;

/* ------------------------------------------------------------
   4. CATEGORY-LEVEL ANALYSIS
   ------------------------------------------------------------ */
-- Compare average, minimum and maximum prices by category
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(price_gbp), 2) AS average_price,
    MIN(price_gbp) AS lowest_price,
    MAX(price_gbp) AS highest_price
FROM products
GROUP BY category
ORDER BY average_price DESC;

-- Categories with at least five products
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(price_gbp), 2) AS average_price
FROM products
GROUP BY category
HAVING COUNT(*) >= 5
ORDER BY average_price DESC;

-- Top five categories by product count
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(price_gbp), 2) AS average_price
FROM products
GROUP BY category
ORDER BY product_count DESC
LIMIT 5;

-- Top five categories by average price (minimum ten products)
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(price_gbp), 2) AS average_price
FROM products
GROUP BY category
HAVING COUNT(*) >= 10
ORDER BY average_price DESC
LIMIT 5;

/* ------------------------------------------------------------
   5. PRODUCT AVAILABILITY ANALYSIS
   ------------------------------------------------------------ */
-- Distribution of products by availability
SELECT
    availability,
    COUNT(*) AS product_count,
    ROUND(
        COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM products), 0),
        2
    ) AS percentage
FROM products
GROUP BY availability
ORDER BY product_count DESC;

-- Verify distinct availability values
SELECT
    availability,
    COUNT(*) AS product_count
FROM products
GROUP BY availability
ORDER BY product_count DESC;

/* ------------------------------------------------------------
   6. RATING ANALYSIS
   ------------------------------------------------------------ */
-- Rating distribution
SELECT
    rating,
    COUNT(*) AS product_count,
    ROUND(
        COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM products), 0),
        2
    ) AS percentage
FROM products
GROUP BY rating
ORDER BY rating DESC;

-- Average rating by category (minimum five products)
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM products
GROUP BY category
HAVING COUNT(*) >= 5
ORDER BY average_rating DESC;

-- Top five categories by average rating (minimum ten products)
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM products
GROUP BY category
HAVING COUNT(*) >= 10
ORDER BY average_rating DESC
LIMIT 5;

-- Five categories with the lowest average rating (minimum ten products)
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM products
GROUP BY category
HAVING COUNT(*) >= 10
ORDER BY average_rating ASC
LIMIT 5;

-- Categories with average rating below 3 and at least 20 products
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM products
GROUP BY category
HAVING AVG(rating) < 3.0
   AND COUNT(*) >= 20
ORDER BY average_rating ASC;

-- Categories with average rating above 3.5 and at least ten products
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(price_gbp), 2) AS average_price
FROM products
GROUP BY category
HAVING AVG(rating) > 3.5
   AND COUNT(*) >= 10
ORDER BY average_rating DESC;

        WHEN price_gbp < 20 THEN 'Budget (< £20)'
        WHEN price_gbp < 40 THEN 'Mid-range (£20–39.99)'
        ELSE 'Premium (£40+)'
    END AS price_band,
    COUNT(*) AS product_count,
    ROUND(
        COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM products), 0),
        2
    ) AS percentage
FROM products
GROUP BY price_band
ORDER BY MIN(price_gbp);

-- Compare average book prices across rating levels
SELECT
    rating,
    COUNT(*) AS product_count,
    ROUND(AVG(price_gbp), 2) AS average_price
FROM products
GROUP BY rating
ORDER BY rating DESC;

/* ------------------------------------------------------------
   8. BEST-VALUE AND PREMIUM CATEGORY ANALYSIS
   ------------------------------------------------------------ */
-- Categories with average rating above 3.5 and at least ten products
SELECT
    category,
    ROUND(AVG(rating), 2) AS average_rating,
    COUNT(*) AS product_count,
    ROUND(AVG(price_gbp), 2) AS average_price
FROM products
GROUP BY category
HAVING AVG(rating) > 3.5
   AND COUNT(*) >= 10
ORDER BY average_rating DESC;

-- Best-rated expensive categories
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(price_gbp), 2) AS average_price
FROM products
GROUP BY category
HAVING COUNT(*) >= 10
   AND AVG(price_gbp) > 35
   AND AVG(rating) > 3.0
ORDER BY average_rating DESC;

-- Compare rating and price using a descriptive rating-per-pound metric
-- This is a custom descriptive ratio, not a standard measure of value.
SELECT
    category,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(price_gbp), 2) AS average_price,
    ROUND(AVG(rating) / NULLIF(AVG(price_gbp), 0), 4) AS rating_per_pound
FROM products
GROUP BY category
HAVING COUNT(*) >= 10
   AND AVG(rating) > 3.0
   AND AVG(price_gbp) > 35
ORDER BY rating_per_pound DESC;

-- Categories with the highest percentage of premium books (£40 or more)
SELECT
    category,
    COUNT(*) AS total_books,
    SUM(CASE WHEN price_gbp >= 40 THEN 1 ELSE 0 END) AS premium_books,
    ROUND(
        SUM(CASE WHEN price_gbp >= 40 THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS premium_percentage
FROM products
GROUP BY category
HAVING COUNT(*) >= 5
ORDER BY premium_percentage DESC;

-- Categories with the largest price variation
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(price_gbp), 2) AS average_price,
    ROUND(STDDEV_POP(price_gbp), 2) AS price_std_deviation,
    ROUND(MAX(price_gbp) - MIN(price_gbp), 2) AS price_range
FROM products
GROUP BY category
HAVING COUNT(*) >= 5
ORDER BY price_std_deviation DESC;

    SELECT
        category,
        product_name,
        rating,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY rating DESC, product_name ASC
        ) AS rating_rank
    FROM products
)
SELECT
    category,
    product_name,
    rating,
    rating_rank
FROM ranked_books
WHERE rating_rank <= 2
ORDER BY category, rating_rank;

-- Lowest-priced book with a rating of at least 4 in each category
WITH ranked_books AS (
    SELECT
        category,
        product_name,
        rating,
        price_gbp,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY price_gbp ASC, product_name ASC
        ) AS price_rank
    FROM products
    WHERE rating >= 4
)
SELECT
    category,
    product_name,
    rating,
    price_gbp,
    price_rank
FROM ranked_books
WHERE price_rank = 1
ORDER BY category;

-- Highest-priced book in each category whose average rating is above 3.0
WITH category_ratings AS (
    SELECT category
    FROM products
    GROUP BY category
    HAVING AVG(rating) > 3.0
),
ranked_books AS (
    SELECT
        p.category,
        p.product_name,
        p.price_gbp,
        ROW_NUMBER() OVER (
            PARTITION BY p.category
            ORDER BY p.price_gbp DESC, p.product_name ASC
        ) AS price_rank
    FROM products AS p
    INNER JOIN category_ratings AS c
        ON p.category = c.category
)
SELECT
    category,
    product_name,
    price_gbp
FROM ranked_books
WHERE price_rank = 1
ORDER BY category;

-- Cheapest book priced below £20 in each category whose average rating is below 3.0
WITH category_ratings AS (
    SELECT category
    FROM products
    GROUP BY category
    HAVING AVG(rating) < 3.0
),
ranked_books AS (
    SELECT
        p.category,
        p.product_name,
        p.price_gbp,
        ROW_NUMBER() OVER (
            PARTITION BY p.category
            ORDER BY p.price_gbp ASC, p.product_name ASC
        ) AS price_rank
    FROM products AS p
    INNER JOIN category_ratings AS c
        ON p.category = c.category
    WHERE p.price_gbp < 20
)
SELECT
    category,
    product_name,
    price_gbp
FROM ranked_books
WHERE price_rank = 1
ORDER BY category;

/* ------------------------------------------------------------
   10. DATA QUALITY INVESTIGATION
   ------------------------------------------------------------ */
-- Check for suspicious or unexpected category labels
SELECT
    category,
    COUNT(*) AS product_count
FROM products
GROUP BY category
ORDER BY product_count DESC;

-- Inspect records with suspicious category labels, if present
SELECT
    product_name,
    category,
    product_url
FROM products
WHERE LOWER(TRIM(category)) IN ('default', 'add a comment')
ORDER BY category, product_name
LIMIT 20;

-- Check table constraints and indexes
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'pricepulse'
  AND TABLE_NAME = 'products';

/* ------------------------------------------------------------
   11. FINAL PROJECT SUMMARY METRICS
   ------------------------------------------------------------ */
SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_url) AS unique_product_urls,
    COUNT(DISTINCT category) AS total_categories,
    ROUND(AVG(price_gbp), 2) AS average_price,
    MIN(price_gbp) AS minimum_price,
    MAX(price_gbp) AS maximum_price,
    ROUND(AVG(rating), 2) AS average_rating,
    MIN(scraped_at) AS earliest_scrape,
    MAX(scraped_at) AS latest_scrape
FROM products;

