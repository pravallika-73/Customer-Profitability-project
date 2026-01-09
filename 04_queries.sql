USE customer_profitability;
GO

-- 1. Total profit per customer
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    SUM(f.revenue_amount)        AS total_revenue,
    SUM(f.cost_amount)           AS total_cost,
    SUM(f.profit_amount)         AS total_profit,
    AVG(f.profit_margin_pct)     AS avg_profit_margin_pct
FROM fact_customer_profitability AS f
JOIN dim_customer AS c
    ON f.customer_key = c.customer_key
JOIN dim_date AS d
    ON f.date_key = d.date_key
GROUP BY
    c.customer_id,
    c.customer_name,
    c.segment
ORDER BY
    total_profit DESC;

    
-- 2. Top 5 customers by profit for year 2025
SELECT TOP (5)
    c.customer_id,
    c.customer_name,
    SUM(f.profit_amount) AS total_profit
FROM fact_customer_profitability AS f
JOIN dim_customer AS c
    ON f.customer_key = c.customer_key
JOIN dim_date AS d
    ON f.date_key = d.date_key
WHERE d.[year] = 2025
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY
    total_profit DESC;


-- 3. Profit by customer segment
SELECT
    c.segment,
    SUM(f.revenue_amount)    AS total_revenue,
    SUM(f.cost_amount)       AS total_cost,
    SUM(f.profit_amount)     AS total_profit,
    AVG(f.profit_margin_pct) AS avg_profit_margin_pct
FROM fact_customer_profitability AS f
JOIN dim_customer AS c
    ON f.customer_key = c.customer_key
GROUP BY
    c.segment
ORDER BY
    total_profit DESC;