{{
    config(
        schema='silver',
        materialized='table',
        cluster_by=['SalesOrderID']
    )
}}



SELECT 
    CAST(SalesOrderID AS INT)                              AS SalesOrderID,
    CASE
        WHEN REGEXP_CONTAINS(OrderDate, r'^\d{4}-\d{2}$') THEN PARSE_DATE('%Y-%m-%d', CONCAT(OrderDate, '-01')) 
        ELSE PARSE_DATE('%Y-%m-%d', OrderDate) 
    END                                                    AS OrderDate,                                                
    PARSE_DATE('%Y-%m-%d', ShipDate)                       AS ShipDate,
    CAST(OnlineOrderFlag AS BOOL)                          AS OnlineOrderFlag,
    AccountNumber,
    CAST(CustomerID AS INT)                                AS CustomerID,
    CAST(NULLIF(SalesPersonID, '') AS INT)                 AS SalesPersonID,
    CAST(Freight AS FLOAT64)                               AS Freight,
    _internal_sequence                                     AS _sequence,
    CURRENT_TIMESTAMP()                                    AS _internal_sequence
FROM {{ ref('raw_sales_order_header') }}


    