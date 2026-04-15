-- Which customers generate the most long-term value?
SELECT c.customer_id, c.customer_name,
       SUM(f.amount) AS lifetime_value
FROM fact_transactions f
JOIN dim_customers c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY lifetime_value DESC;

-- How many customers are returning vs one-time?
SELECT 
  CASE 
    WHEN txn_count = 1 THEN 'One-time'
    ELSE 'Repeat'
  END AS customer_type,
  COUNT(*) AS total_customers
FROM (
    SELECT customer_id, COUNT(*) AS txn_count
    FROM fact_transactions
    GROUP BY customer_id
) t
GROUP BY customer_type;

-- How many active users each month?
SELECT d.year, d.month,
       COUNT(DISTINCT f.customer_id) AS active_customers
FROM fact_transactions f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

-- How much does a user spend per transaction?
SELECT 
  ROUND(AVG(amount), 2) AS avg_transaction_value
FROM fact_transactions;

-- Which cities generate most revenue?
SELECT c.city, SUM(f.amount) AS revenue
FROM fact_transactions f
JOIN dim_customers c ON f.customer_id = c.customer_id
GROUP BY c.city
ORDER BY revenue DESC
LIMIT 10;

-- Which category contributes most?
SELECT 
  m.merchant_category,
  SUM(f.amount) AS revenue,
  ROUND(SUM(f.amount) * 100 / 
        (SELECT SUM(amount) FROM fact_transactions), 2) AS percentage
FROM fact_transactions f
JOIN dim_merchants m ON f.merchant_id = m.merchant_id
GROUP BY m.merchant_category;

-- Where are failures happening?
SELECT payment_mode,
       COUNT(*) AS failed_count
FROM fact_transactions
WHERE status = 'Failed'
GROUP BY payment_mode;

-- Classify customers into High / Medium / Low
SELECT customer_id,
       SUM(amount) AS total_spent,
       CASE 
         WHEN SUM(amount) > 50000 THEN 'High'
         WHEN SUM(amount) > 20000 THEN 'Medium'
         ELSE 'Low'
       END AS segment
FROM fact_transactions
GROUP BY customer_id;

-- Smooth trend for business reporting
SELECT d.year, d.month,
       SUM(f.amount) AS revenue,
       AVG(SUM(f.amount)) OVER (
           ORDER BY d.year, d.month 
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS rolling_avg
FROM fact_transactions f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month;

-- Did customers come back next month?
SELECT 
  COUNT(DISTINCT f1.customer_id) AS retained_customers
FROM fact_transactions f1
JOIN fact_transactions f2 
  ON f1.customer_id = f2.customer_id
JOIN dim_date d1 ON f1.date_id = d1.date_id
JOIN dim_date d2 ON f2.date_id = d2.date_id
WHERE d2.month = d1.month + 1;

-- Top Merchant per Category
SELECT merchant_category, merchant_name, revenue
FROM (
    SELECT m.merchant_category, m.merchant_name,
           SUM(f.amount) AS revenue,
           RANK() OVER (PARTITION BY m.merchant_category ORDER BY SUM(f.amount) DESC) rnk
    FROM fact_transactions f
    JOIN dim_merchants m ON f.merchant_id = m.merchant_id
    GROUP BY m.merchant_category, m.merchant_name
) t
WHERE rnk = 1;

-- High amount transactions
SELECT *
FROM fact_transactions
WHERE amount > 9000;

-- Revenue Growth %
SELECT year,
       revenue,
       LAG(revenue) OVER (ORDER BY year) AS prev_year,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY year)) 
             / LAG(revenue) OVER (ORDER BY year) * 100, 2) AS growth_pct
FROM (
    SELECT d.year, SUM(f.amount) AS revenue
    FROM fact_transactions f
    JOIN dim_date d ON f.date_id = d.date_id
    GROUP BY d.year
) t;


-- Most Profitable Customers
SELECT customer_id,
       SUM(net_amount) AS profit
FROM fact_transactions
GROUP BY customer_id
ORDER BY profit DESC
LIMIT 10;
