{{
    config(
        schema='datamart',
        materialized='view'
    )
}}

---Which color generated the highest revenue each year?

WITH year_color_revenue_cte AS (
SELECT
    EXTRACT(YEAR FROM OrderDate)  AS Year,
    p.Color,
    SUM(o.TotalLineExtendedPrice) AS Revenue
FROM {{ ref('publish_orders') }} o
LEFT JOIN {{ ref('publish_products') }} p
    ON o.ProductID = p.ProductID
GROUP BY ALL
) 


SELECT *
FROM year_color_revenue_cte
QUALIFY RANK() OVER (PARTITION BY Year ORDER BY Revenue DESC) = 1
