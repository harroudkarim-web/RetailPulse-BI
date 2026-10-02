-- =============================================
-- ANALYSE 4 : PERFORMANCE MENSUELLE
-- =============================================

SELECT
    d.year,
    d.month_number,
    d.month_name,

    ROUND(SUM(f.quantity * f.unit_price), 2) AS Revenue,

    ROUND(
        SUM(f.quantity * (f.unit_price - f.unit_cost)),
        2
    ) AS Profit,

    ROUND(
        SUM(f.quantity * (f.unit_price - f.unit_cost)) * 100.0
        / NULLIF(SUM(f.quantity * f.unit_price), 0),
        2
    ) AS MarginPercent

FROM dbo.FactSales_New f

JOIN dbo.DimDate_New d
    ON f.date_id = d.date_id

GROUP BY
    d.year,
    d.month_number,
    d.month_name

ORDER BY
    d.year,
    d.month_number;

SELECT
    p.product_name,
    SUM(f.quantity) AS UnitsSold,
    COALESCE(SUM(r.return_quantity), 0) AS UnitsReturned,

    ROUND(
        COALESCE(SUM(r.return_quantity), 0) * 100.0
        / NULLIF(SUM(f.quantity), 0),
        2
    ) AS ReturnRatePercent

FROM dbo.FactSales_New f

JOIN dbo.DimProduct_New p
    ON f.product_id = p.product_id

LEFT JOIN dbo.FactReturns_New r
    ON f.sales_id = r.sales_id

GROUP BY p.product_name

ORDER BY ReturnRatePercent DESC;

-- =============================================
-- ANALYSE 3 : TOP CLIENTS
-- =============================================

SELECT TOP 10
    c.customer_id,
    c.customer_name,
    c.country,
    c.segment,

    ROUND(
        SUM(f.quantity * f.unit_price),
        2
    ) AS Revenue,

    ROUND(
        SUM(f.quantity * (f.unit_price - f.unit_cost)),
        2
    ) AS Profit

FROM dbo.FactSales_New f

JOIN dbo.DimCustomer_New c
    ON f.customer_id = c.customer_id

GROUP BY
    c.customer_id,
    c.customer_name,
    c.country,
    c.segment

ORDER BY Revenue DESC;

-- =============================================
-- ANALYSE 4 : PERFORMANCE PAR CANAL
-- =============================================

SELECT
    sales_channel,

    ROUND(SUM(quantity * unit_price), 2) AS Revenue,

    ROUND(
        SUM(quantity * (unit_price - unit_cost)),
        2
    ) AS Profit,

    ROUND(
        SUM(quantity * (unit_price - unit_cost)) * 100.0
        / NULLIF(SUM(quantity * unit_price), 0),
        2
    ) AS MarginPercent

FROM dbo.FactSales_New

GROUP BY sales_channel

ORDER BY Revenue DESC;

-- =============================================
-- ANALYSE 5 : FORT CA / FAIBLE MARGE
-- =============================================

WITH ProductPerformance AS (
    SELECT
        p.product_name,
        p.category,

        SUM(f.quantity * f.unit_price) AS Revenue,

        SUM(f.quantity * (f.unit_price - f.unit_cost)) AS Profit,

        SUM(f.quantity * (f.unit_price - f.unit_cost)) * 100.0
        / NULLIF(SUM(f.quantity * f.unit_price), 0) AS MarginPercent

    FROM dbo.FactSales_New f

    JOIN dbo.DimProduct_New p
        ON f.product_id = p.product_id

    GROUP BY
        p.product_name,
        p.category
)

SELECT
    product_name,
    category,
    ROUND(Revenue, 2) AS Revenue,
    ROUND(Profit, 2) AS Profit,
    ROUND(MarginPercent, 2) AS MarginPercent

FROM ProductPerformance

WHERE Revenue > (
    SELECT AVG(Revenue)
    FROM ProductPerformance
)

AND MarginPercent < (
    SELECT AVG(MarginPercent)
    FROM ProductPerformance
)

ORDER BY Revenue DESC;

-- =============================================
-- ANALYSE 6 : EVOLUTION MENSUELLE
-- =============================================

SELECT
    d.year,
    d.month_number,
    d.month_name,

    ROUND(SUM(f.quantity * f.unit_price), 2) AS Revenue,

    ROUND(
        SUM(f.quantity * (f.unit_price - f.unit_cost)),
        2
    ) AS Profit,

    ROUND(
        SUM(f.quantity * (f.unit_price - f.unit_cost)) * 100.0
        / NULLIF(SUM(f.quantity * f.unit_price), 0),
        2
    ) AS MarginPercent

FROM dbo.FactSales_New f

JOIN dbo.DimDate_New d
    ON f.date_id = d.date_id

GROUP BY
    d.year,
    d.month_number,
    d.month_name

ORDER BY
    d.year,
    d.month_number;