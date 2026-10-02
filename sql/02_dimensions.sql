USE RetailPulseDW;
GO

-- =============================================
-- RETAILPULSE - DIMENSION TABLES
-- =============================================


-- =============================================
-- DIM CUSTOMER
-- =============================================

CREATE TABLE dbo.DimCustomer_New (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    country VARCHAR(50),
    segment VARCHAR(50),
    signup_date DATE
);
GO

WITH CleanCustomers AS (
    SELECT
        customer_id,

        COALESCE(
            NULLIF(TRIM(customer_name), ''),
            'Unknown Customer'
        ) AS customer_name,

        CASE UPPER(TRIM(country))
            WHEN 'BE' THEN 'Belgium'
            WHEN 'BELGIUM' THEN 'Belgium'
            WHEN 'FR' THEN 'France'
            WHEN 'FRANCE' THEN 'France'
            WHEN 'DE' THEN 'Germany'
            WHEN 'GERMANY' THEN 'Germany'
            WHEN 'LU' THEN 'Luxembourg'
            WHEN 'LUXEMBOURG' THEN 'Luxembourg'
            WHEN 'NL' THEN 'Netherlands'
            WHEN 'NETHERLANDS' THEN 'Netherlands'
            ELSE TRIM(country)
        END AS country,

        COALESCE(
            NULLIF(TRIM(segment), ''),
            'Unknown'
        ) AS segment,

        signup_date,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY customer_id
        ) AS rn

    FROM staging.customers
)

INSERT INTO dbo.DimCustomer_New
(
    customer_id,
    customer_name,
    country,
    segment,
    signup_date
)
SELECT
    customer_id,
    customer_name,
    country,
    segment,
    signup_date
FROM CleanCustomers
WHERE rn = 1;
GO


-- =============================================
-- DIM PRODUCT
-- =============================================

CREATE TABLE dbo.DimProduct_New (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    standard_cost DECIMAL(10,2),
    list_price DECIMAL(10,2)
);
GO

INSERT INTO dbo.DimProduct_New
SELECT
    product_id,
    TRIM(product_name),
    TRIM(category),
    standard_cost,
    list_price
FROM staging.products;
GO

