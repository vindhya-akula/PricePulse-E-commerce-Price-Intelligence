
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
UNIQUE KEY unique_product_url (product_url)
);

USE pricepulse;

SHOW TABLES;

DESCRIBE products;

SELECT COUNT(*) AS total_records
FROM products;

SELECT product_id, product_name, product_url
FROM products
WHERE product_url LIKE '%its-only-the-himalayas_981%';

SELECT COUNT(*) AS missing_names
FROM products
WHERE product_name IS NULL OR product_name = '';

SELECT product_id, product_name, price_gbp, rating, category
FROM products
LIMIT 5;

SELECT product_id, product_name
FROM products
WHERE product_name LIKE '%Noah%';

#Analyze overall product prices
SELECT
	COUNT(*) AS total_products,
	ROUND(AVG(price_gbp), 2) AS average_price,
	MIN(price_gbp) AS lowest_price,
	MAX(price_gbp) AS highest_price
FROM products;

#Find which categories have the highest average prices
SELECT
	category,
    COUNT(*) AS product_count,
    ROUND(AVG(price_gbp), 2) AS average_price,
    MIN(price_gbp) AS lowest_price,
    MAX(price_gbp) AS highest_price
FROM products
GROUP BY category
ORDER BY average_price DESC;

# Improvement in the analysis
SELECT 
	category,
    COUNT(*) AS product_count,
    ROUND(AVG(price_gbp), 2) AS average_price
FROM products
GROUP BY category
HAVING COUNT(*) >= 5
ORDER BY average_price DESC;

# Analyze product availability
SELECT 
	availability,
    COUNT(*) AS product_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM products),2) AS percenatge
    FROM products
    GROUP BY availability
    ORDER BY product_count DESC;
    
#Check the scraped values
SELECT 
	availability,
    COUNT(*) AS product_count
FROM products
GROUP BY availability;

USE pricepulse;

SELECT 
	COUNT(*) AS total_products,
    COUNT(DISTINCT product_url) AS unique_urls
FROM products;

#Rating Distribution
SELECT 
	rating, 
    COUNT(*) AS product_count,
    ROUND(
		COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM products),
        2
        ) AS percentage
	FROM products
    GROUP BY rating
    ORDER BY rating DESC;

#the average rating for each category and identify categories with the highest average rating.
SELECT
	category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM products
GROUP BY category
HAVING COUNT(*) >= 5
ORDER BY average_rating DESC;

# Find expensive books
SELECT 
	product_name, 
    category,
    price_gbp,
    rating
FROM products
ORDER BY price_gbp DESC
LIMIT 10;

# Investiagte price versus rating
SELECT
	rating,
    COUNT(*) AS product_count,
    ROUND(AVG(price_gbp), 2) AS average_price,
    MIN(price_gbp) AS lowest_price,
    MAX(price_gbp) AS highest_price
FROM products
GROUP BY rating
ORDER BY rating DESC;

#identify price bands
SELECT
	CASE
		WHEN price_gbp < 20 THEN 'Budget (£10–19.99)'
        WHEN price_gbp < 40 THEN 'Mid-range (£10–39.99)'
        ELSE 'Premium (£40–59.99)'
	END AS price_band,
    COUNT(*) AS product_count,
    ROUND(AVG(price_gbp), 2) AS average_price
FROM products
GROUP BY price_band
ORDER BY MIN(price_gbp);

# percentage of products in each price band
SELECT
	CASE
		WHEN price_gbp < 20 THEN 'Budget (£10–19.99)'
        WHEN price_gbp < 40 THEN 'Mid-range (£10–39.99)'
        ELSE 'Premium (£40–59.99)'
	END AS price_band,
    COUNT(*) AS product_count,
    ROUND( 
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM products), 2) AS percentage
FROM products
GROUP BY price_band 
ORDER BY MIN(price_gbp);

# higher-priced products also have higher ratings
SELECT
	CASE
		WHEN price_gbp < 20 THEN 'Budget (£10–19.99)'
		WHEN price_gbp < 40 THEN 'Mid-range (£10–39.99)'
		ELSE 'Premium (£40–59.99)'
	END AS price_band,
    ROUND(AVG(rating), 2) AS average_rating
FROM products
GROUP BY price_band
ORDER BY
	CASE
		WHEN price_band = 'Budget (£10–19.99)' THEN 1
		WHEN price_band = 'Mid-range (£10–39.99)' THEN 2
		ELSE 3
	END;
# also use ORDER BY MIN(price_gbp) in your original query, which sorts by the actual minimum price within each band.
    
# Find the best-value category--Which book categories have an avg rating above 3.5 and at least 10 products?
SELECT
	category, 
	ROUND(AVG(rating), 2) AS average_rating,
	COUNT(*) AS product_count
FROM products
GROUP BY category
HAVING ROUND(AVG(rating), 2) > 3.5 
	AND COUNT(*) >= 10
ORDER BY average_rating DESC;
    
# Find the Top 5 categories by avg rating
SELECT 
	category,
    ROUND(AVG(rating), 2) AS average_rating,
    COUNT(*) AS product_count
FROM products
GROUP BY category
HAVING COUNT(*) >= 10
ORDER BY average_rating DESC
LIMIT 5;

# Compare the highest-rated and lowest-rated categories, Write a query to find 
#the five categories with the lowest average rating, 
# considering only categories with at least 10 products.

SELECT 
	category, 
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM products
GROUP BY category
HAVING COUNT(*) >= 10
ORDER BY average_rating ASC
LIMIT 5;

# another way
SELECT 
	category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM products
    GROUP BY category
	HAVING ROUND(AVG(rating), 2) < 3.0
	AND COUNT(*) >= 20
	ORDER BY average_rating ASC;
    
 /*  top 5 categories with the highest product counts, showing:
- category
- product_count
- average_rating
*/
SELECT
	category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM products
GROUP BY category
ORDER BY product_count DESC
LIMIT 5;

/* Challenge: Find the top 5 categories with the highest average 
book price, considering only categories with at least 10 products.
*/
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

# Find the best-rated expensive categories
SELECT
	category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(price_gbp), 2) AS average_price
FROM products
GROUP BY category
HAVING COUNT(*) >= 10 
	AND average_price > 35
	AND average_rating > 3.0
ORDER BY average_rating DESC;

# Compare price and rating together
SELECT
	category,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(price_gbp), 2) AS average_price,
    ROUND(AVG(rating) / AVG(price_gbp), 4) AS rating_per_pound
FROM products
GROUP BY category
HAVING COUNT(*) >= 10
	AND AVG(rating) > 3.0
    AND AVG(price_gbp) > 35
ORDER BY rating_per_pound DESC;

# Find the top 3 most expensive books within each category.
WITH ranked_books AS (
    SELECT
        category,
        product_name,
        price_gbp,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY price_gbp DESC
        ) AS price_rank
    FROM products
)
SELECT
    category,
    product_name,
    price_gbp,
    price_rank
FROM ranked_books
WHERE price_rank <= 3
ORDER BY category, price_rank;

#Find the second-most expensive book in each category,
With ranked_books AS(
SELECT
	category,
    product_name,
    price_gbp,
    ROW_NUMBER() OVER(
		PARTITION BY category ORDER BY price_gbp DESC
        ) AS price_rank
	FROM products
)
SELECT 
	category,
    product_name,
    price_gbp,
    price_rank
FROM ranked_books
WHERE price_rank = 2
ORDER BY category, price_rank;

/* find the highest-priced book in each 
category whose price is above the overall average book price.
*/
With ranked_books AS(
		SELECT 
			category,
            product_name,
            price_gbp,
            ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY price_gbp DESC
		) AS price_rank
	FROM products
    WHERE price_gbp > (
		SELECT AVG(price_gbp)
        FROM products
	)
)
SELECT 
	category,
    product_name,
    price_gbp,
    price_rank
FROM ranked_books
WHERE price_rank = 1
ORDER BY category;
            

# Find the two highest-rated books in each category
WITH rating_book AS(
SELECT 
	category, 
    product_name,
    rating,
    ROW_NUMBER() OVER(
    PARTITION BY category
    ORDER BY rating DESC
    ) AS rating_rank
FROM products
)
SELECT
	category,
    product_name,
    rating,
    rating_rank
FROM rating_book
WHERE rating_rank < 3
ORDER BY category, rating_rank;

# 
WITH ranked_books AS (
	SELECT
		category,
        product_name,
        rating,
        price_gbp,
        ROW_NUMBER() OVER (
			PARTITION BY category
            ORDER BY price_gbp ASC
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

/* Find the highest_price book in each category 
whose average rating is above 3.0
*/
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
        ROW_NUMBER() OVER( 
			PARTITION BY p.category
            ORDER BY p.price_gbp
		) AS price_rank
	FROM products p
    JOIN category_ratings c
		ON p.category = c.category
)
SELECT
	category,
    product_name,
    price_gbp
FROM ranked_books
WHERE price_rank = 1
ORDER BY category;

USE pricepulse;

/* Which is the cheapest book priced below £20 in each category 
whose average rating is below 3.0?
*/
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
        ROW_NUMBER() OVER(
			PARTITION BY p.category
            ORDER BY p.price_gbp ASC
		) AS price_rank
	FROM products p
    JOIN category_ratings c
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

/* Which categories have a good average 
rating and enough books to make the result meaningful?
*/
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

#

SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(price_gbp), 2) AS average_price
FROM products
GROUP BY category
ORDER BY product_count DESC;

#Investigation on suspicious thing
SELECT
    product_name,
    category,
    product_url
FROM products
WHERE category IN ('Default', 'Add a comment')
ORDER BY category, product_name
LIMIT 20;

#
SELECT 
	COUNT(*) AS total_products,
    COUNT(DISTINCT product_url) AS unique_product_urls,
    MIN(scraped_at) AS earliest_scrape,
    MAX(scraped_at) AS latest_scrape
FROM products;


SHOW CREATE TABLE products;

SELECT
	TABLE_NAME,
	COLUMN_NAME,
    CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA = 'pricepulse'
	AND REFERENCED_TABLE_NAME = 'products';
    
USE pricepulse;

SELECT 
	COUNT(*) AS total_products,
    COUNT(DISTINCT product_url) AS unique_urls,
    ROUND(AVG(price_gbp), 2) AS average_price,
    MIN(price_gbp) AS minimum_price,
    MAX(price_gbp) AS maximum_price,
    COUNT(DISTINCT category) AS total_categories
FROM products;


    
    




