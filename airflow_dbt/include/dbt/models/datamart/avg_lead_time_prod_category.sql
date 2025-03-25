{{
    config(
        schema='datamart',
        materialized='view'
    )
}}

---What is the average LeadTimeInBusinessDays by ProductCategoryName?
SELECT
    IF(ProductCategoryName = '', 'Unknown', ProductCategoryName) AS ProductCategoryName,
    AVG(LeadTimeInBusinessDays)                                  AS AverageLeadTime
FROM {{ ref('publish_orders') }} o 
LEFT JOIN {{ ref('publish_products') }} p 
    ON o.ProductID = p.ProductID
GROUP BY 1