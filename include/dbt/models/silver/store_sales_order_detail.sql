{{
    config(
        schema='silver',
        materialized='table',
        cluster_by=['SalesOrderDetailID', 'SalesOrderID', 'ProductID'],
    )
}}




SELECT
    CAST(SalesOrderDetailID AS INT)    AS SalesOrderDetailID,
    CAST(SalesOrderID AS INT)          AS SalesOrderID,
    ABS(CAST(OrderQty AS INT))         AS OrderQty,
    CAST(ProductID AS INT)             AS ProductID,
    CAST(UnitPrice AS FLOAT64)         AS UnitPrice,
    CAST(UnitPriceDiscount AS FLOAT64) AS UnitPriceDiscount,
    _internal_sequence                 AS _sequence,
    CURRENT_TIMESTAMP()                AS _internal_sequence
FROM {{ ref('raw_sales_order_detail') }}