--Revenue Analysis
/*Total revenue over time
Monthly sales trends
Revenue by product category
Revenue by seller
Average order value (AOV)
Installment payment behavior
Freight cost analysis
Revenue contribution by state/city*/

--Total Orders
SELECT
    COUNT(*)
FROM olist_orders_dataset;

--2016 orders
SELECT
    COUNT(*)
FROM olist_orders_dataset
WHERE EXTRACT(YEAR FROM order_purchase_timestamp) = 2016;

--2017 orders
SELECT
    COUNT(*)
FROM olist_orders_dataset
WHERE EXTRACT(YEAR FROM order_purchase_timestamp) = 2017;

--2018 orders
SELECT
    COUNT(*)
FROM olist_orders_dataset
WHERE EXTRACT(YEAR FROM order_purchase_timestamp) = 2018;

--Total Sellers
SELECT
    COUNT(*)
FROM olist_sellers_dataset;

--Total Customers
SELECT
    COUNT(DISTINCT customer_unique_id)
FROM olist_customers_dataset;

--Total Revenue
SELECT
    SUM(payment_value)
FROM olist_order_payments_dataset;

--Previous year growth
WITH YearlyRevenue AS (
    SELECT
        EXTRACT(YEAR FROM od.order_purchase_timestamp) AS year,
        SUM(pd.payment_value) AS revenue
    FROM olist_order_payments_dataset pd
    INNER JOIN olist_orders_dataset od ON pd.order_id = od.order_id
    GROUP BY 1
)
SELECT 
    year,
    revenue,
    LAG(revenue) OVER (ORDER BY year) AS prev_year_revenue,
    ROUND(
        ((revenue - LAG(revenue) OVER (ORDER BY year)) / LAG(revenue) OVER (ORDER BY year)) * 100, 
    2) AS yoy_growth_percentage
FROM YearlyRevenue
ORDER BY year DESC;

--2016 Revenue
SELECT
    SUM(payment_value) AS revenue_2016
FROM olist_order_payments_dataset pd
INNER JOIN olist_orders_dataset od
    ON pd.order_id = od.order_id
WHERE EXTRACT(YEAR FROM od.order_purchase_timestamp) = 2016;

--2017 Revenue
SELECT
    SUM(payment_value) AS revenue_2016
FROM olist_order_payments_dataset pd
INNER JOIN olist_orders_dataset od
    ON pd.order_id = od.order_id
WHERE EXTRACT(YEAR FROM od.order_purchase_timestamp) = 2017;

--2018 Revenue
SELECT
    SUM(payment_value) AS revenue_2016
FROM olist_order_payments_dataset pd
INNER JOIN olist_orders_dataset od
    ON pd.order_id = od.order_id
WHERE EXTRACT(YEAR FROM od.order_purchase_timestamp) = 2018;

--Unique Categories
SELECT
    COUNT(DISTINCT product_category_name)
FROM olist_products_dataset;

--Total revenue over time
SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    SUM(payment_value) AS total_revenue
FROM olist_order_payments_dataset pd
INNER JOIN olist_orders_dataset od
    ON pd.order_id = od.order_id
INNER JOIN olist_order_items_dataset oi
    ON od.order_id = oi.order_id
GROUP BY year
ORDER BY year DESC;

--Monthly sales trends
SELECT
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    SUM(payment_value) AS monthly_revenue
FROM olist_order_payments_dataset pd
LEFT JOIN olist_orders_dataset od
    ON pd.order_id = od.order_id
GROUP BY month
ORDER BY monthly_revenue DESC;

--Revenue by seller
SELECT 
    sd.seller_id,
    SUM(pd.payment_value) AS total_revenue
FROM olist_sellers_dataset sd
LEFT JOIN olist_order_items_dataset oi
    ON sd.seller_id = oi.seller_id
LEFT JOIN olist_order_payments_dataset pd
    ON oi.order_id = pd.order_id
GROUP BY sd.seller_id
ORDER BY total_revenue DESC
LIMIT 5;

--Quantity sold by Seller

SELECT 
    sd.seller_id,
    sd.seller_city,
    COUNT(oi.product_id) AS total_quantity_sold,
    ROUND(AVG(ord.review_score), 2) AS avg_review_score,
    SUM(pd.payment_value) AS total_revenue
FROM olist_sellers_dataset sd
LEFT JOIN olist_order_items_dataset oi
    ON sd.seller_id = oi.seller_id
LEFT JOIN olist_order_payments_dataset pd
    ON oi.order_id = pd.order_id
LEFT JOIN olist_order_reviews_dataset ord
    ON oi.order_id = ord.order_id
GROUP BY sd.seller_id, sd.seller_city
ORDER BY total_quantity_sold DESC
LIMIT 5;

--Average order value (AOV)
SELECT 
    SUM(pd.payment_value) / COUNT(DISTINCT pd.order_id) AS average_order_value
FROM olist_order_payments_dataset pd
INNER JOIN olist_orders_dataset od 
    ON pd.order_id = od.order_id;

--Average order value (2016)
SELECT 
    SUM(pd.payment_value) / COUNT(DISTINCT pd.order_id) AS average_order_value_2016
FROM olist_order_payments_dataset pd
INNER JOIN olist_orders_dataset od
    ON pd.order_id = od.order_id
WHERE EXTRACT(YEAR FROM od.order_purchase_timestamp) = 2016;

--Average order value (2017)
SELECT 
    SUM(pd.payment_value) / COUNT(DISTINCT pd.order_id) AS average_order_value_2017
FROM olist_order_payments_dataset pd
INNER JOIN olist_orders_dataset od
    ON pd.order_id = od.order_id
WHERE EXTRACT(YEAR FROM od.order_purchase_timestamp) = 2017;

--Average order value (2018)
SELECT 
    SUM(pd.payment_value) / COUNT(DISTINCT pd.order_id) AS average_order_value_2018
FROM olist_order_payments_dataset pd
INNER JOIN olist_orders_dataset od
    ON pd.order_id = od.order_id
WHERE EXTRACT(YEAR FROM od.order_purchase_timestamp) = 2018;

--Median order value
SELECT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY payment_value) AS median_order_value
FROM olist_order_payments_dataset;

--Max Price
SELECT 
    MAX(payment_value) AS max_order_value
FROM olist_order_payments_dataset;


--Installment payment behavior
SELECT
    pd.payment_installments,
    COUNT(*) AS num_orders,
    AVG(pd.payment_value) AS avg_payment_value
FROM olist_order_payments_dataset pd
GROUP BY pd.payment_installments
ORDER BY num_orders DESC;

--Freight cost analysis (total price paid to transport goods)
SELECT
    pct.product_category_name_english AS product_category,
    SUM(oi.freight_value) AS total_freight_cost
FROM olist_order_items_dataset oi
INNER JOIN olist_products_dataset pd
    ON oi.product_id = pd.product_id
JOIN product_category_name_translation pct
    ON pd.product_category_name = pct.product_category_name
WHERE freight_value > 0
GROUP BY pct.product_category_name_english
ORDER BY total_freight_cost DESC
LIMIT 10;

--Revenue contribution by state
SELECT
    cd.customer_state AS State,
    SUM(opd.payment_value) AS total_revenue
FROM olist_order_payments_dataset opd
LEFT JOIN olist_orders_dataset od
    ON opd.order_id = od.order_id
LEFT JOIN olist_customers_dataset cd
    ON od.customer_id = cd.customer_id
GROUP BY cd.customer_state
ORDER BY total_revenue DESC
LIMIT 10;



/*2. Geographic Analysis 🌍

VERY strong area in this dataset.

You can analyze:

Customer distribution by state
Seller concentration
Delivery performance by region
Revenue by geography
Top states/cities by sales
Freight cost by region*/

--Customer distribution by state
--TOP 10 states with the highest number of customers
SELECT
    customer_state,
    COUNT(*) AS num_customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY num_customers DESC;

--Seller concentration
SELECT
    seller_state,
    COUNT(*) AS num_sellers
FROM olist_sellers_dataset osd
GROUP BY seller_state
ORDER BY num_sellers DESC;

--Delivery performance by region
SELECT
    cd.customer_state AS State,
    AVG(EXTRACT(EPOCH FROM (od.order_delivered_customer_date - od.order_purchase_timestamp)) / 86400) AS avg_delivery_time_days
FROM olist_orders_dataset od
LEFT JOIN olist_customers_dataset cd    
    ON od.customer_id = cd.customer_id
WHERE od.order_delivered_customer_date IS NOT NULL
GROUP BY cd.customer_state
ORDER BY avg_delivery_time_days DESC
LIMIT 10;

--Revenue by geography
SELECT
    cd.customer_state AS State,
    SUM(opd.payment_value) AS total_revenue
FROM olist_order_payments_dataset opd
INNER JOIN olist_orders_dataset od
    ON opd.order_id = od.order_id
INNER JOIN olist_customers_dataset cd
    ON od.customer_id = cd.customer_id
GROUP BY cd.customer_state
ORDER BY total_revenue DESC
LIMIT 10;

--Top Cities by sales
SELECT
    cd.customer_city AS Cities,
    SUM(opd.payment_value) AS total_revenue
FROM olist_order_payments_dataset opd
INNER JOIN olist_orders_dataset od
    ON opd.order_id = od.order_id
INNER JOIN olist_customers_dataset cd
    ON od.customer_id = cd.customer_id
GROUP BY cd.customer_city
ORDER BY total_revenue DESC
LIMIT 10;

--Freight cost by region
SELECT
    ocd.customer_state AS State,
    SUM(oi.freight_value) AS total_freight_cost
FROM olist_order_items_dataset oi
INNER JOIN olist_orders_dataset od
    ON oi.order_id = od.order_id
INNER JOIN olist_customers_dataset ocd
    ON od.customer_id = ocd.customer_id
WHERE freight_value > 0
GROUP BY ocd.customer_state
ORDER BY total_freight_cost DESC
LIMIT 10;



/*3. Product Performance Analysis 📦

This is where business intelligence becomes interesting.

Questions:
Best-selling product categories
Highest revenue products
Most reviewed categories
High-return/low-rating products
Product size vs freight cost
Product demand trends*/

--Best-selling product categories and highest revenue products
SELECT
    pct.product_category_name_english AS product_category,
    COUNT(*) AS num_sales,
    SUM(opd.payment_value) AS total_revenue
FROM olist_order_payments_dataset opd
INNER JOIN olist_order_items_dataset oi
    ON opd.order_id = oi.order_id
INNER JOIN olist_products_dataset pd
    ON oi.product_id = pd.product_id
JOIN product_category_name_translation pct  
    ON pd.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english
ORDER BY SUM(opd.payment_value) DESC
LIMIT 10;

--Most reviewed categories and average review score by category
    SELECT
        pct.product_category_name_english AS product_category,
        COUNT(*) AS num_reviews,
        ROUND(AVG(ord.review_score), 1) AS avg_review_score
    FROM olist_order_reviews_dataset ord
    INNER JOIN olist_order_items_dataset oi
        ON ord.order_id = oi.order_id
    INNER JOIN olist_products_dataset pd
        ON oi.product_id = pd.product_id
    JOIN product_category_name_translation pct
        ON pd.product_category_name = pct.product_category_name
    GROUP BY pct.product_category_name_english
    ORDER BY COUNT(*) DESC
    LIMIT 10;

-- Low-rating products
SELECT
    pct.product_category_name_english AS product_category,
    COUNT(*) AS num_reviews,
    ROUND(AVG(ord.review_score), 1) AS avg_review_score
FROM olist_order_reviews_dataset ord
INNER JOIN olist_order_items_dataset oi
    ON ord.order_id = oi.order_id
INNER JOIN olist_products_dataset pd
    ON oi.product_id = pd.product_id
JOIN product_category_name_translation pct
    ON pd.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english, pd.product_id
HAVING AVG(ord.review_score) < 2.5
ORDER BY AVG(ord.review_score) ASC
LIMIT 10;

--Product size vs freight cost
SELECT
    pct.product_category_name_english AS product_category,
    ROUND(AVG(pd.product_weight_g), 2) AS avg_weight_g,
    ROUND(AVG(oid.freight_value), 2) AS avg_freight_cost
FROM olist_order_items_dataset oid
INNER JOIN olist_products_dataset pd
    ON oid.product_id = pd.product_id
JOIN product_category_name_translation pct
    ON pd.product_category_name = pct.product_category_name
WHERE freight_value > 0
GROUP BY pct.product_category_name_english
ORDER BY avg_freight_cost DESC
LIMIT 15;

--Product demand trends (monthly sales by category)
/*SELECT
    EXTRACT(MONTH FROM od.order_purchase_timestamp) AS month,
    pct.product_category_name_english AS product_category,
    SUM(op.payment_value) AS monthly_revenue
FROM olist_order_items_dataset oi
INNER JOIN olist_orders_dataset od
    ON oi.order_id = od.order_id
INNER JOIN olist_products_dataset pd
    ON oi.product_id = pd.product_id
INNER JOIN olist_order_payments_dataset op
    ON od.order_id = op.order_id
JOIN product_category_name_translation pct
    ON pd.product_category_name = pct.product_category_name
GROUP BY EXTRACT(MONTH FROM od.order_purchase_timestamp), pct.product_category_name_english
ORDER BY month, monthly_revenue DESC
LIMIT 15;*/


/*4. Customer Satisfaction Analysis ⭐

One of the strongest parts of the dataset.

Questions:
Average review score
Review score by category
Delivery delay vs review score
States with happiest customers
Does freight cost affect ratings?
Does delivery speed affect satisfaction?*/

--Average review score
SELECT
    ROUND(AVG(review_score), 1) AS average_review_score
FROM olist_order_reviews_dataset;

--Review score distribution
SELECT 
    review_score,
    COUNT(*) AS total_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage_of_total
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score DESC;

--Review score by category
SELECT
    pct.product_category_name_english AS product_category,
    ROUND(AVG(ord.review_score), 1) AS avg_review_score
FROM olist_order_reviews_dataset ord
INNER JOIN olist_order_items_dataset oi
    ON ord.order_id = oi.order_id
INNER JOIN olist_products_dataset pd
    ON oi.product_id = pd.product_id
JOIN product_category_name_translation pct
    ON pd.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english
ORDER BY avg_review_score DESC;

--Delivery delay vs review score
SELECT 
    ROUND(AVG(EXTRACT(EPOCH FROM (od.order_delivered_customer_date - od.order_purchase_timestamp)) / 86400), 2) AS avg_delivery_delay_days,
    ROUND(AVG(ord.review_score), 1) AS avg_review_score
FROM olist_order_reviews_dataset ord
INNER JOIN olist_order_items_dataset oi
    ON ord.order_id = oi.order_id
INNER JOIN olist_orders_dataset od
    ON oi.order_id = od.order_id
WHERE od.order_delivered_customer_date IS NOT NULL
GROUP BY od.order_id;

--States with happiest customers
SELECT
    cd.customer_state AS State,
    ROUND(AVG(ord.review_score), 2) AS avg_review_score
FROM olist_customers_dataset cd
INNER JOIN olist_orders_dataset od
    ON cd.customer_id = od.customer_id
INNER JOIN olist_order_reviews_dataset ord
    ON od.order_id = ord.order_id
GROUP BY State
ORDER BY avg_review_score DESC
LIMIT 10;

--Does freight cost affect ratings?
SELECT
    oid.freight_value AS freight_cost,
    ROUND(AVG(ord.review_score), 2) AS avg_review_score
FROM olist_order_items_dataset oid
INNER JOIN olist_orders_dataset od
    ON oid.order_id = od.order_id
INNER JOIN olist_order_reviews_dataset ord
    ON od.order_id = ord.order_id
WHERE freight_value > 0
GROUP BY oid.freight_value
ORDER BY avg_review_score DESC;

--Does delivery speed affect satisfaction?
SELECT 
    ROUND(AVG(EXTRACT(EPOCH FROM (od.order_delivered_customer_date - od.order_purchase_timestamp)) / 86400), 2) AS avg_delivery_delay_days,
    ROUND(AVG(ord.review_score), 1) AS avg_review_score
FROM olist_order_reviews_dataset ord
INNER JOIN olist_order_items_dataset oi
    ON ord.order_id = oi.order_id
INNER JOIN olist_orders_dataset od
    ON oi.order_id = od.order_id
WHERE od.order_delivered_customer_date IS NOT NULL
GROUP BY od.order_id
ORDER BY avg_delivery_delay_days ASC;

/*Questions:
Average delivery time
Late deliveries %
Delivery performance by seller
Shipping delay patterns
Estimated vs actual delivery
Freight cost efficiency*/

--Average delivery time
SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM (od.order_delivered_customer_date - od.order_purchase_timestamp)) / 86400), 2) AS avg_delivery_time_days
FROM olist_orders_dataset od
WHERE od.order_delivered_customer_date IS NOT NULL;

--Late deliveries %
SELECT
    ROUND((SUM(
        CASE 
            WHEN od.order_delivered_customer_date > od.order_estimated_delivery_date THEN 1 
            ELSE 0 
            END) 
            * 100.0) / COUNT(*), 2
        ) AS late_delivery_percentage
FROM olist_orders_dataset od
WHERE od.order_delivered_customer_date IS NOT NULL;

--Total Failure rate by seller
SELECT 
    ROUND(
        (SUM(CASE 
            WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 
            ELSE 0 
        END) * 100.0) / COUNT(*), 2
    ) AS total_platform_failure_rate
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL;

--Delivery performance by seller
SELECT
    sd.seller_id,
    ROUND(AVG(EXTRACT(EPOCH FROM (od.order_delivered_customer_date - od.order_purchase_timestamp)) / 86400), 2) AS avg_delivery_time_days
FROM olist_sellers_dataset sd
INNER JOIN olist_order_items_dataset oi
    ON sd.seller_id = oi.seller_id
INNER JOIN olist_orders_dataset od
    ON oi.order_id = od.order_id
WHERE od.order_delivered_customer_date IS NOT NULL
GROUP BY sd.seller_id
ORDER BY avg_delivery_time_days DESC
LIMIT 10;

--Shipping delay patterns along with total deliveries(monthly late deliveries)
SELECT
    EXTRACT(MONTH FROM od.order_purchase_timestamp) AS month,
    SUM(
        CASE 
            WHEN od.order_delivered_customer_date > od.order_estimated_delivery_date THEN 1 
            ELSE 0 
        END
    ) AS num_late_deliveries,
    COUNT(*) AS total_deliveries
FROM olist_orders_dataset od
WHERE od.order_delivered_customer_date IS NOT NULL 
GROUP BY month
ORDER BY month ASC;

--Estimated vs actual delivery
SELECT 
    od.order_id,
    od.order_estimated_delivery_date,
    od.order_delivered_customer_date,
    EXTRACT(EPOCH FROM (od.order_delivered_customer_date - od.order_estimated_delivery_date)) / 86400 AS delivery_delay_days
FROM olist_orders_dataset od
WHERE od.order_delivered_customer_date IS NOT NULL AND od.order_estimated_delivery_date IS NOT NULL
ORDER BY delivery_delay_days DESC
LIMIT 10;

--Freight cost efficiency (freight cost per kg)
SELECT
    pct.product_category_name_english AS product_category,
    ROUND(AVG(oi.freight_value / NULLIF(pd.product_weight_g, 0)), 4) AS avg_freight_cost_per_kg
FROM olist_order_items_dataset oi
INNER JOIN olist_products_dataset pd
    ON oi.product_id = pd.product_id
JOIN product_category_name_translation pct
    ON pd.product_category_name = pct.product_category_name
WHERE oi.freight_value > 0 AND pd.product_weight_g > 0
GROUP BY pct.product_category_name_english
ORDER BY avg_freight_cost_per_kg DESC
LIMIT 10;

--Freight cost with avg_size and product category
SELECT
    pct.product_category_name_english AS product_category,
    ROUND(AVG(pd.product_weight_g), 2) AS avg_weight_g,
    SUM(oi.freight_value) AS total_freight_cost
FROM olist_order_items_dataset oi
INNER JOIN olist_products_dataset pd
    ON oi.product_id = pd.product_id
JOIN product_category_name_translation pct
    ON pd.product_category_name = pct.product_category_name
WHERE oi.freight_value > 0 AND pd.product_weight_g > 0
GROUP BY pct.product_category_name_english
ORDER BY total_freight_cost DESC
LIMIT 10;


/*Top-performing sellers
Sellers with best ratings
Seller delivery efficiency
Revenue per seller
Seller retention/activity*/

--Total Sellers
SELECT
    COUNT(*)
FROM olist_sellers_dataset;

--Top-performing sellers by revenue
SELECT
    osd.seller_id,
    SUM(opd.payment_value) AS total_revenue
FROM olist_sellers_dataset osd
INNER JOIN olist_order_items_dataset oid
    ON osd.seller_id = oid.seller_id
INNER JOIN olist_order_payments_dataset opd
    ON oid.order_id = opd.order_id
GROUP BY osd.seller_id
ORDER BY total_revenue DESC
LIMIT 10;

--Sellers with best ratings
SELECT
    osd.seller_id,
    ROUND(AVG(prd.review_score), 10) AS avg_review_score
FROM olist_sellers_dataset osd
INNER JOIN olist_order_items_dataset oid
    ON osd.seller_id = oid.seller_id
INNER JOIN olist_order_reviews_dataset prd
    ON oid.order_id = prd.order_id
GROUP BY osd.seller_id
ORDER BY avg_review_score DESC;

--Seller delivery efficiency
SELECT
    osd.seller_id,
    ROUND(AVG(EXTRACT(EPOCH FROM (od.order_delivered_customer_date - od.order_purchase_timestamp)) / 86400), 2) AS avg_delivery_time_days
FROM olist_sellers_dataset osd
INNER JOIN olist_order_items_dataset oid
    ON osd.seller_id = oid.seller_id
INNER JOIN olist_orders_dataset od
    ON oid.order_id = od.order_id
WHERE od.order_delivered_customer_date IS NOT NULL
GROUP BY osd.seller_id
ORDER BY avg_delivery_time_days ASC
LIMIT 10;

/*Most common payment types
Installment behavior
High-value installment orders
Payment method by category/state*/

--Most common payment types where type is not not_defined
SELECT
    payment_type,
    COUNT(*) AS num_payments
FROM olist_order_payments_dataset
WHERE payment_type != 'not_defined'
GROUP BY payment_type
ORDER BY num_payments DESC;

--INSTALLMENT BEHAVIOR
SELECT
    CASE 
        WHEN payment_installments BETWEEN 2 AND 12 THEN '2-12 installments' 
        WHEN payment_installments > 12 THEN 'More than 12 installments'
        ELSE 'Single payment' 
    END AS installment_bracket,
    COUNT(*) AS num_orders,
    AVG(payment_value) AS avg_payment_value
FROM olist_order_payments_dataset
WHERE payment_value > 1000
GROUP BY installment_bracket
ORDER BY num_orders DESC;

--Payment method by category
SELECT
    pct.product_category_name_english AS product_category,
    payment_type,
    COUNT(*) AS num_payments
FROM olist_order_payments_dataset opd
INNER JOIN olist_order_items_dataset oi
    ON opd.order_id = oi.order_id
INNER JOIN olist_products_dataset pd
    ON oi.product_id = pd.product_id
JOIN product_category_name_translation pct
    ON pd.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english, payment_type
ORDER BY num_payments DESC;


--Customer distribution by geolocation (lat/lng)
SELECT
    og.geolocation_lat,
    og.geolocation_lng,
    COUNT(ocd.customer_unique_id) AS customer_count
FROM olist_customers_dataset ocd
INNER JOIN olist_geolocation_dataset og
    ON ocd.customer_zip_code_prefix = og.geolocation_zip_code_prefix
GROUP BY og.geolocation_lat, og.geolocation_lng
ORDER BY customer_count DESC;
