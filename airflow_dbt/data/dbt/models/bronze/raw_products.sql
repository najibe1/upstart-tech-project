{{
    config(
        schema='bronze',
        materialized='table',
        cluster_by=['ProductId']
    )
}}




--prioritazing ProductCategoryName with description instead with no description to dedupe
WITH dedupe_data AS (
    SELECT 
        ProductID,
        ProductDesc,
        ProductNumber,
        MakeFlag,
        Color,
        SafetyStockLevel,
        ReorderPoint,
        StandardCost,
        ListPrice,
        Size,
        SizeUnitMeasureCode,
        Weight,
        WeightUnitMeasureCode,
        ProductCategoryName,
        ProductSubCategoryName,
        CURRENT_TIMESTAMP() AS _internal_sequence
    FROM {{ source('EXT_S3_FILES', 'src_products') }}
        QUALIFY ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY 
             CASE
                 WHEN ProductCategoryName IS NOT NULL THEN 1
                 ELSE 2
             END ASC) = 1

)

SELECT *
FROM dedupe_data
