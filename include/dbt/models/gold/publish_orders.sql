{{
    config(
        schema='gold',
        materialized='table',
        cluster_by=['SalesOrderID', 'LeadTimeInBusinessDays']
    )
}}


WITH cte_lead_time AS (
    SELECT 
        SalesOrderID,
        OrderDate,
        ShipDate,
        ---generate date array between OrderDate and ShipDate and count only business days (excluding Saturdays and Sundays)
        SUM(CASE 
                WHEN EXTRACT(DAYOFWEEK FROM DATE_ADD(OrderDate, INTERVAL offset DAY)) NOT IN (1, 7) 
                THEN 1 
                ELSE 0 
            END) AS LeadTimeInBusinessDays
    FROM {{ ref('store_sales_order_header') }},
        UNNEST(GENERATE_ARRAY(0, DATE_DIFF(ShipDate, OrderDate, DAY))) AS offset
    GROUP BY ALL
)

SELECT
    d.* EXCEPT(_sequence, _internal_sequence),
    h.* EXCEPT(SalesOrderID, Freight, _sequence, _internal_sequence), 
    Freight                                    AS TotalOrderFreight,
    OrderQty * (UnitPrice - UnitPriceDiscount) AS TotalLineExtendedPrice,
    c.LeadTimeInBusinessDays
FROM {{ ref('store_sales_order_detail') }} d
LEFT JOIN {{ ref('store_sales_order_header') }} h
    ON d.SalesOrderID = h.SalesOrderID
LEFT JOIN cte_lead_time c
    ON d.SalesOrderID = c.SalesOrderID