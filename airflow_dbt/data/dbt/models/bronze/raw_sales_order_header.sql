{{
    config(
        schema='bronze',
        materialized='table',
        cluster_by=['SalesOrderID']
    )
}}



SELECT 
    SalesOrderID,
    OrderDate,
    ShipDate,
    OnlineOrderFlag,
    AccountNumber,
    CustomerID,
    SalesPersonID,
    Freight,
    CURRENT_TIMESTAMP() AS _internal_sequence
FROM {{ source('EXT_S3_FILES', 'src_sales_order_header') }}


    