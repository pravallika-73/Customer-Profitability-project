-- 1. Create database
CREATE DATABASE customer_profitability;
GO

USE customer_profitability;
GO

-- 2. Dimension tables

-- 2.1 dim_customer (SCD-ready)
CREATE TABLE dim_customer (
    customer_key      INT IDENTITY(1,1) PRIMARY KEY,   -- surrogate key
    customer_id       NVARCHAR(50)  NOT NULL,          -- business id
    customer_name     NVARCHAR(200) NOT NULL,
    segment           NVARCHAR(50)  NULL,
    city              NVARCHAR(100) NULL,
    country           NVARCHAR(100) NULL,
    valid_from        DATE          NOT NULL,
    valid_to          DATE          NULL,
    is_current        BIT           NOT NULL
);
GO

-- 2.2 dim_date
CREATE TABLE dim_date (
    date_key     INT         NOT NULL PRIMARY KEY,   -- e.g. 20250101
    full_date    DATE        NOT NULL,
    [year]       INT         NOT NULL,
    [month]      TINYINT     NOT NULL,
    [day]        TINYINT     NOT NULL
);
GO

-- 2.3 dim_product
CREATE TABLE dim_product (
    product_key   INT IDENTITY(1,1) PRIMARY KEY,
    product_id    NVARCHAR(50)  NOT NULL,
    product_name  NVARCHAR(200) NOT NULL,
    category      NVARCHAR(100) NULL
);
GO

-- 2.4 dim_channel
CREATE TABLE dim_channel (
    channel_key  INT IDENTITY(1,1) PRIMARY KEY,
    channel_name NVARCHAR(50) NOT NULL  -- e.g. Online, Store, Partner
);
GO

-- 3. Fact table

CREATE TABLE fact_customer_profitability (
    fact_id            INT IDENTITY(1,1) PRIMARY KEY,
    customer_key       INT NOT NULL,
    product_key        INT NOT NULL,
    date_key           INT NOT NULL,
    revenue_amount     DECIMAL(18,2) NOT NULL,
    cost_amount        DECIMAL(18,2) NOT NULL,
    profit_amount      AS (revenue_amount - cost_amount) PERSISTED,
    profit_margin_pct  AS (
                            CASE 
                                WHEN revenue_amount = 0 THEN 0 
                                ELSE (revenue_amount - cost_amount) * 100.0 / revenue_amount 
                            END
                          ) PERSISTED,

    CONSTRAINT fk_fact_customer
        FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    CONSTRAINT fk_fact_product
        FOREIGN KEY (product_key)  REFERENCES dim_product(product_key),
    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_key)     REFERENCES dim_date(date_key)
);
GO

-- 3.1 Extra business columns on fact table
ALTER TABLE fact_customer_profitability
ADD channel_key      INT NULL,                 -- FK to dim_channel
    quantity_sold    INT NOT NULL DEFAULT 1,   -- units sold
    discount_amount  DECIMAL(18,2) NOT NULL DEFAULT 0;  -- discount value
GO

-- 3.2 Link to dim_channel
ALTER TABLE fact_customer_profitability
ADD CONSTRAINT fk_fact_channel
    FOREIGN KEY (channel_key) REFERENCES dim_channel(channel_key);
GO

-- 3.3 Enforce grain (optional, if grain is 1 row per customer-product-date-channel)
ALTER TABLE fact_customer_profitability
ADD CONSTRAINT uq_fact_customer_product_date_channel
UNIQUE (customer_key, product_key, date_key, channel_key);
GO

-- 4. Performance indexes

-- Helpful nonclustered indexes on FKs
CREATE INDEX ix_fact_customer   ON fact_customer_profitability (customer_key);
CREATE INDEX ix_fact_product    ON fact_customer_profitability (product_key);
CREATE INDEX ix_fact_date       ON fact_customer_profitability (date_key);
CREATE INDEX ix_fact_channel    ON fact_customer_profitability (channel_key);

-- Composite index for common filter pattern (date + customer)
CREATE INDEX ix_fact_date_customer
ON fact_customer_profitability (date_key, customer_key);
GO