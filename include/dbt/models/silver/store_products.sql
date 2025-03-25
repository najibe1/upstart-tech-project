{{
    config(
        schema='silver',
        materialized='table',
        cluster_by=['ProductId']
    )
}}

SELECT 
    CAST(ProductId AS INT)                         AS ProductId,
    ProductDesc,
    ProductNumber,
    CAST(MakeFlag AS BOOL)                         AS MakeFlag,
    Color,
    CAST(SafetyStockLevel AS INT)                  AS SafetyStockLevel,
    CAST(ReorderPoint AS INT)                      AS ReorderPoint,
    CAST(StandardCost AS FLOAT64)                  AS StandardCost,     
    CAST(ListPrice AS FLOAT64)                     AS ListPrice,
    Size,
    SizeUnitMeasureCode,
    Weight,
    WeightUnitMeasureCode,
    ProductCategoryName,
    ProductSubCategoryName,
    _internal_sequence                             AS _sequence,
    CURRENT_TIMESTAMP()                            AS _internal_sequence
FROM {{ ref('raw_products')}} 