{{
    config(
        schema='bronze',
        materialized='table',
        cluster_by=['SalesOrderDetailID']
    )
}}


SELECT
    SalesOrderID,
    SalesOrderDetailID,
    OrderQty,
    ProductID,
    UnitPrice,
    UnitPriceDiscount,
    CURRENT_TIMESTAMP() AS _internal_sequence
FROM {{ source('EXT_S3_FILES', 'src_sales_order_detail') }}
    