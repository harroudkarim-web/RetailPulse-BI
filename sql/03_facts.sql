USE RetailPulseDW;
GO

-- =============================================
-- RETAILPULSE - FACT TABLES
-- =============================================


-- =============================================
-- FACT SALES
-- =============================================

CREATE TABLE dbo.FactSales_New (
    sales_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    sale_date DATE,
    quantity INT,
    unit_price DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    sales_channel VARCHAR(50),

    FOREIGN KEY (customer_id)
        REFERENCES dbo.DimCustomer_New(customer_id),

    FOREIGN KEY (product_id)
        REFERENCES dbo.DimProduct_New(product_id)
);
GO


-- Clean mixed date formats, remove duplicates
-- and exclude sales without a valid price.

WITH CleanSales AS (
    SELECT
        sales_id,
        customer_id,
        product_id,

        COALESCE(
            TRY_CONVERT(DATE, sale_date, 23),
            TRY_CONVERT(DATE, sale_date, 103)
        ) AS sale_date,

        quantity,
        unit_price,
        unit_cost,
        TRIM(sales_channel) AS sales_channel,

        ROW_NUMBER() OVER (
            PARTITION BY sales_id
            ORDER BY sales_id
        ) AS rn

    FROM staging.sales
)

INSERT INTO dbo.FactSales_New
SELECT
    sales_id,
    customer_id,
    product_id,
    sale_date,
    quantity,
    unit_price,
    unit_cost,
    sales_channel
FROM CleanSales
WHERE rn = 1
  AND unit_price IS NOT NULL
  AND sale_date IS NOT NULL;
GO


-- =============================================
-- FACT RETURNS
-- =============================================

CREATE TABLE dbo.FactReturns_New (
    return_id INT PRIMARY KEY,
    sales_id INT,
    return_date DATE,
    return_quantity INT,
    return_reason VARCHAR(100),

    FOREIGN KEY (sales_id)
        REFERENCES dbo.FactSales_New(sales_id)
);
GO


WITH CleanReturns AS (
    SELECT
        return_id,
        sales_id,
        return_date,
        return_quantity,
        TRIM(return_reason) AS return_reason,

        ROW_NUMBER() OVER (
            PARTITION BY return_id
            ORDER BY return_id
        ) AS rn

    FROM staging.returns
)

INSERT INTO dbo.FactReturns_New
SELECT
    r.return_id,
    r.sales_id,
    r.return_date,
    r.return_quantity,
    r.return_reason
FROM CleanReturns r

INNER JOIN dbo.FactSales_New s
    ON r.sales_id = s.sales_id

WHERE r.rn = 1;
GO

-- =============================================
-- DIM DATE
-- =============================================

CREATE TABLE dbo.DimDate_New (
    date_id INT PRIMARY KEY,
    date DATE UNIQUE,
    year INT,
    quarter INT,
    month_number INT,
    month_name VARCHAR(20),
    day INT
);
GO

DECLARE @StartDate DATE =
    (SELECT MIN(sale_date) FROM dbo.FactSales_New);

DECLARE @EndDate DATE =
    (SELECT MAX(sale_date) FROM dbo.FactSales_New);

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO dbo.DimDate_New
    VALUES (
        YEAR(@StartDate) * 10000
        + MONTH(@StartDate) * 100
        + DAY(@StartDate),

        @StartDate,
        YEAR(@StartDate),
        DATEPART(QUARTER, @StartDate),
        MONTH(@StartDate),
        DATENAME(MONTH, @StartDate),
        DAY(@StartDate)
    );

    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;
GO

-- =============================================
-- DATE KEY
-- =============================================

ALTER TABLE dbo.FactSales_New
ADD date_id INT;
GO

UPDATE dbo.FactSales_New
SET date_id =
    YEAR(sale_date) * 10000
    + MONTH(sale_date) * 100
    + DAY(sale_date);
GO

ALTER TABLE dbo.FactSales_New
ADD CONSTRAINT FK_FactSales_Date
FOREIGN KEY (date_id)
REFERENCES dbo.DimDate_New(date_id);
GO