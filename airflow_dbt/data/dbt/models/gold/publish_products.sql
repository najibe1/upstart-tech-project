{{
    config(
        schema='gold',
        materialized='table',
        cluster_by=['ProductId', 'ProductCategoryName', 'ProductSubCategoryName']
    )
}}




SELECT 
    ProductId,
    ProductDesc,
    ProductNumber,
    MakeFlag,
    IF(Color = '', 'N/A', Color) AS Color,
    SafetyStockLevel,
    ReorderPoint,
    StandardCost,
    ListPrice,
    Size,
    SizeUnitMeasureCode,
    Weight,
    WeightUnitMeasureCode,
    CASE 
        WHEN ProductCategoryName = '' THEN 
            CASE 
                WHEN ProductSubCategoryName IN ('Gloves', 'Shorts', 'Socks', 'Tights', 'Vests') THEN 'Clothing'
                WHEN ProductSubCategoryName IN ('Locks', 'Lights', 'Headsets', 'Helmets', 'Pedals', 'Pumps') THEN 'Accessories' 
                WHEN ProductSubCategoryName LIKE '%Frames%' OR ProductSubCategoryName IN ('Wheels', 'Saddles') THEN 'Components' 
                ELSE ProductCategoryName
            END 
        ELSE ProductCategoryName
    END AS ProductCategoryName,
    ProductSubCategoryName
FROM {{ ref('store_products') }}



