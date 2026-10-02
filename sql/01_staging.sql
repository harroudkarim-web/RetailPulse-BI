USE RetailPulseDW;
GO

-- =============================================
-- RETAILPULSE - STAGING LAYER
-- Raw data ingestion
-- =============================================

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = 'staging'
)
BEGIN
    EXEC('CREATE SCHEMA staging');
END;
GO

CREATE TABLE staging.customers (
    customer_id INT,
    customer_name VARCHAR(100),
    country VARCHAR(50),
    segment VARCHAR(50),
    signup_date DATE
);

CREATE TABLE staging.products (
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    standard_cost DECIMAL(10,2),
    list_price DECIMAL(10,2)
);

CREATE TABLE staging.sales (
    sales_id INT,
    customer_id INT,
    product_id INT,
    sale_date VARCHAR(20), -- Raw because source contains mixed date formats
    quantity INT,
    unit_price DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    sales_channel VARCHAR(50)
);

CREATE TABLE staging.returns (
    return_id INT,
    sales_id INT,
    return_date DATE,
    return_quantity INT,
    return_reason VARCHAR(100)
);