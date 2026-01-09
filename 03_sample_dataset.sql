USE customer_profitability;
GO

-- 1. dim_customer
INSERT INTO dim_customer (customer_id, customer_name, segment, city, country, valid_from, valid_to, is_current)
VALUES
('C001', 'Alice Retail',  'Regular', 'Mumbai',   'India', '2025-01-01', NULL, 1),
('C002', 'Bravo Stores',  'Premium', 'Delhi',    'India', '2025-01-01', NULL, 1),
('C003', 'Charlie Online','SME',     'Bangalore','India', '2025-01-01', NULL, 1);
GO

-- 2. dim_date  (just a few days)
INSERT INTO dim_date (date_key, full_date, [year], [month], [day])
VALUES
(20250101, '2025-01-01', 2025, 1, 1),
(20250102, '2025-01-02', 2025, 1, 2),
(20250103, '2025-01-03', 2025, 1, 3),
(20250104, '2025-01-04', 2025, 1, 4),
(20250105, '2025-01-05', 2025, 1, 5);
GO

-- 3. dim_product
INSERT INTO dim_product (product_id, product_name, category)
VALUES
('P001', 'Basic Plan',   'Subscription'),
('P002', 'Pro Plan',     'Subscription'),
('P003', 'One-time Addon','Addon');
GO

-- 4. fact_customer_profitability
-- use existing surrogate keys from the dimension tables
INSERT INTO fact_customer_profitability (customer_key, product_key, date_key, revenue_amount, cost_amount)
VALUES
(1, 1, 20250101, 1000.00, 600.00),  -- Alice, Basic Plan
(1, 2, 20250102, 1500.00, 700.00),
(2, 2, 20250102, 2000.00, 900.00),  -- Bravo, Pro Plan
(2, 3, 20250103,  500.00, 200.00),
(3, 1, 20250104, 1200.00, 800.00),  -- Charlie, Basic
(3, 2, 20250105, 1800.00, 900.00);
GO