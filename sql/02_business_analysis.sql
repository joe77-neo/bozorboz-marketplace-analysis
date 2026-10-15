USE marketplace_bozorboz;
GO

/* =========================================================
   BOZORBOZ MARKETPLACE ANALYSIS
   Business Analysis Queries
   Period: 2023-01-01 to 2026-06-30
   ========================================================= */


/* =========================================================
   1. OVERALL BUSINESS KPIs
   ========================================================= */

-- Total GMV
SELECT
    SUM(quantity * unit_price - discount_amount) AS GMV
FROM fact_order_item;
GO

-- Total Orders
SELECT
    COUNT(DISTINCT order_id) AS Orders
FROM fact_order;
GO

-- Delivered Orders
SELECT
    COUNT(DISTINCT order_id) AS Delivered_Orders
FROM fact_order
WHERE order_status = N'Yetkazildi';
GO

-- Return Rate
SELECT
    CAST(
        100.0 * COUNT(*) /
        NULLIF(
            (
                SELECT COUNT(*)
                FROM fact_order_item oi
                INNER JOIN fact_order o
                    ON oi.order_id = o.order_id
                WHERE o.order_status = N'Yetkazildi'
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS Return_Rate_Percent
FROM fact_return;
GO


/* =========================================================
   2. GMV BY CATEGORY
   ========================================================= */

SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS GMV,
    CAST(
        100.0 *
        SUM(oi.quantity * oi.unit_price - oi.discount_amount)
        / NULLIF(
            (SELECT SUM(quantity * unit_price - discount_amount)
             FROM fact_order_item),
            0
        )
        AS DECIMAL(10,2)
    ) AS GMV_Share_Percent
FROM fact_order_item oi
INNER JOIN dim_product p
    ON oi.product_id = p.product_id
GROUP BY
    p.category
ORDER BY
    GMV DESC;
GO


/* =========================================================
   3. COMMISSION BY CATEGORY
   ========================================================= */

SELECT
    p.category,
    SUM(oi.commission_amount) AS Commission
FROM fact_order_item oi
INNER JOIN dim_product p
    ON oi.product_id = p.product_id
GROUP BY
    p.category
ORDER BY
    Commission DESC;
GO


/* =========================================================
   4. REALISED TAKE RATE BY CATEGORY
   ========================================================= */

SELECT
    p.category,
    SUM(oi.commission_amount) AS Commission,
    SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS GMV,
    CAST(
        100.0 * SUM(oi.commission_amount)
        / NULLIF(
            SUM(oi.quantity * oi.unit_price - oi.discount_amount),
            0
        )
        AS DECIMAL(10,2)
    ) AS Realised_Take_Rate_Percent
FROM fact_order_item oi
INNER JOIN dim_product p
    ON oi.product_id = p.product_id
GROUP BY
    p.category
ORDER BY
    Realised_Take_Rate_Percent DESC;
GO


/* =========================================================
   5. RETURN RATE BY CATEGORY
   ========================================================= */

SELECT
    p.category,
    COUNT(DISTINCT r.return_id) AS Returned_Items,
    COUNT(DISTINCT oi.order_item_id) AS Delivered_Items,
    CAST(
        100.0 * COUNT(DISTINCT r.return_id)
        / NULLIF(COUNT(DISTINCT oi.order_item_id), 0)
        AS DECIMAL(10,2)
    ) AS Return_Rate_Percent
FROM fact_order_item oi
INNER JOIN fact_order o
    ON oi.order_id = o.order_id
INNER JOIN dim_product p
    ON oi.product_id = p.product_id
LEFT JOIN fact_return r
    ON oi.order_item_id = r.order_item_id
WHERE
    o.order_status = N'Yetkazildi'
GROUP BY
    p.category
ORDER BY
    Return_Rate_Percent DESC;
GO


/* =========================================================
   6. AVERAGE ORDER WEIGHT BY CATEGORY
   ========================================================= */

SELECT
    p.category,
    CAST(
        SUM(oi.quantity * p.weight_kg)
        / NULLIF(COUNT(DISTINCT oi.order_id), 0)
        AS DECIMAL(10,2)
    ) AS Avg_Order_Weight_KG
FROM fact_order_item oi
INNER JOIN fact_order o
    ON oi.order_id = o.order_id
INNER JOIN dim_product p
    ON oi.product_id = p.product_id
WHERE
    o.order_status = N'Yetkazildi'
GROUP BY
    p.category
ORDER BY
    Avg_Order_Weight_KG DESC;
GO


/* =========================================================
   7. PAYMENT METHOD & REFUSAL RATE
   ========================================================= */

SELECT
    payment_method,
    COUNT(*) AS Orders,
    SUM(
        CASE
            WHEN order_status = N'Rad etildi'
            THEN 1 ELSE 0
        END
    ) AS Refused_Orders,
    CAST(
        100.0 *
        SUM(
            CASE
                WHEN order_status = N'Rad etildi'
                THEN 1 ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS Refusal_Rate_Percent
FROM fact_order
GROUP BY
    payment_method
ORDER BY
    Refusal_Rate_Percent DESC;
GO


/* =========================================================
   8. REFUSAL RATE BY REGION
   ========================================================= */

SELECT
    c.region,
    COUNT(*) AS Orders,
    SUM(
        CASE
            WHEN o.order_status = N'Rad etildi'
            THEN 1 ELSE 0
        END
    ) AS Refused_Orders,
    CAST(
        100.0 *
        SUM(
            CASE
                WHEN o.order_status = N'Rad etildi'
                THEN 1 ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS Refusal_Rate_Percent
FROM fact_order o
INNER JOIN dim_customer c
    ON o.customer_id = c.customer_id
GROUP BY
    c.region
ORDER BY
    Refusal_Rate_Percent DESC;
GO


/* =========================================================
   9. COD SHARE BY REGION
   ========================================================= */

SELECT
    c.region,
    COUNT(*) AS Orders,
    SUM(
        CASE
            WHEN o.payment_method = N'Naqd (yetkazishda)'
            THEN 1 ELSE 0
        END
    ) AS COD_Orders,
    CAST(
        100.0 *
        SUM(
            CASE
                WHEN o.payment_method = N'Naqd (yetkazishda)'
                THEN 1 ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS COD_Share_Percent
FROM fact_order o
INNER JOIN dim_customer c
    ON o.customer_id = c.customer_id
GROUP BY
    c.region
ORDER BY
    COD_Share_Percent DESC;
GO


/* =========================================================
   10. WASTED DELIVERY COST
   Incomplete orders = Cancelled + Refused
   ========================================================= */

SELECT
    o.order_status,
    SUM(d.actual_delivery_cost) AS Wasted_Delivery_Cost
FROM fact_order o
INNER JOIN fact_delivery d
    ON o.order_id = d.order_id
WHERE
    o.order_status IN (N'Bekor qilindi', N'Rad etildi')
GROUP BY
    o.order_status
ORDER BY
    Wasted_Delivery_Cost DESC;
GO


/* =========================================================
   11. WASTED DELIVERY COST BY REGION
   ========================================================= */

SELECT
    c.region,
    SUM(d.actual_delivery_cost) AS Wasted_Delivery_Cost
FROM fact_order o
INNER JOIN fact_delivery d
    ON o.order_id = d.order_id
INNER JOIN dim_customer c
    ON o.customer_id = c.customer_id
WHERE
    o.order_status IN (N'Bekor qilindi', N'Rad etildi')
GROUP BY
    c.region
ORDER BY
    Wasted_Delivery_Cost DESC;
GO


/* =========================================================
   12. REFUSED COD GMV
   ========================================================= */

SELECT
    SUM(o.gmv) AS Refused_COD_GMV
FROM fact_order o
WHERE
    o.order_status = N'Rad etildi'
    AND o.payment_method = N'Naqd (yetkazishda)';
GO


/* =========================================================
   13. REFUSAL RATE BY ORDER VALUE
   ========================================================= */

SELECT
    CASE
        WHEN gmv < 500000 THEN N'<500K'
        WHEN gmv < 1000000 THEN N'500K-1M'
        WHEN gmv < 3000000 THEN N'1M-3M'
        WHEN gmv < 5000000 THEN N'3M-5M'
        WHEN gmv < 10000000 THEN N'5M-10M'
        ELSE N'10M+'
    END AS Order_Value_Band,

    COUNT(*) AS Orders,

    SUM(
        CASE
            WHEN order_status = N'Rad etildi'
            THEN 1 ELSE 0
        END
    ) AS Refused_Orders,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN order_status = N'Rad etildi'
                THEN 1 ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS Refusal_Rate_Percent

FROM fact_order
GROUP BY
    CASE
        WHEN gmv < 500000 THEN N'<500K'
        WHEN gmv < 1000000 THEN N'500K-1M'
        WHEN gmv < 3000000 THEN N'1M-3M'
        WHEN gmv < 5000000 THEN N'3M-5M'
        WHEN gmv < 10000000 THEN N'5M-10M'
        ELSE N'10M+'
    END
ORDER BY
    MIN(gmv);
GO


/* =========================================================
   14. COURIER PERFORMANCE
   ========================================================= */

SELECT
    c.courier_name,
    COUNT(DISTINCT d.order_id) AS Orders,
    CAST(
        100.0 * AVG(CAST(d.is_on_time AS FLOAT))
        AS DECIMAL(10,2)
    ) AS On_Time_Percent,
    CAST(
        100.0 * c.sla_on_time_target
        AS DECIMAL(10,2)
    ) AS SLA_Target_Percent,
    CAST(
        100.0 *
        (
            AVG(CAST(d.is_on_time AS FLOAT))
            - c.sla_on_time_target
        )
        AS DECIMAL(10,2)
    ) AS SLA_Gap_Percentage_Points,
    CAST(
        AVG(CAST(d.delivery_attempts AS FLOAT))
        AS DECIMAL(10,2)
    ) AS Avg_Attempts,
    CAST(
        SUM(d.actual_delivery_cost)
        / NULLIF(COUNT(DISTINCT d.order_id), 0)
        AS DECIMAL(10,0)
    ) AS Delivery_Cost_Per_Order
FROM fact_delivery d
INNER JOIN dim_courier c
    ON d.courier_id = c.courier_id
INNER JOIN fact_order o
    ON d.order_id = o.order_id
WHERE
    o.order_status = N'Yetkazildi'
GROUP BY
    c.courier_name,
    c.sla_on_time_target
ORDER BY
    On_Time_Percent ASC;
GO


/* =========================================================
   15. DAMAGE RETURN RATE BY COURIER
   ========================================================= */

SELECT
    c.courier_name,
    COUNT(DISTINCT d.order_id) AS Delivered_Orders,

    COUNT(
        DISTINCT CASE
            WHEN r.reason = N'Shikastlangan'
            THEN r.return_id
        END
    ) AS Damage_Returns,

    CAST(
        100.0 *
        COUNT(
            DISTINCT CASE
                WHEN r.reason = N'Shikastlangan'
                THEN r.return_id
            END
        )
        / NULLIF(COUNT(DISTINCT d.order_id), 0)
        AS DECIMAL(10,2)
    ) AS Damage_Return_Rate_Percent

FROM fact_delivery d
INNER JOIN dim_courier c
    ON d.courier_id = c.courier_id
INNER JOIN fact_order o
    ON d.order_id = o.order_id
LEFT JOIN fact_return r
    ON d.order_id = r.order_id
WHERE
    o.order_status = N'Yetkazildi'
GROUP BY
    c.courier_name
ORDER BY
    Damage_Return_Rate_Percent DESC;
GO


/* =========================================================
   16. SELLER QUALITY
   ========================================================= */

SELECT
    s.seller_name,
    SUM(
        oi.quantity * oi.unit_price - oi.discount_amount
    ) AS GMV,

    CAST(
        AVG(CAST(rv.rating AS FLOAT))
        AS DECIMAL(10,2)
    ) AS Average_Rating,

    CAST(
        100.0 *
        COUNT(
            DISTINCT CASE
                WHEN r.return_id IS NOT NULL
                THEN r.return_id
            END
        )
        / NULLIF(COUNT(DISTINCT oi.order_item_id), 0)
        AS DECIMAL(10,2)
    ) AS Return_Rate_Percent

FROM fact_order_item oi
INNER JOIN dim_seller s
    ON oi.seller_id = s.seller_id
INNER JOIN fact_order o
    ON oi.order_id = o.order_id
LEFT JOIN fact_review rv
    ON oi.order_item_id = rv.order_item_id
LEFT JOIN fact_return r
    ON oi.order_item_id = r.order_item_id
GROUP BY
    s.seller_name
ORDER BY
    GMV DESC;
GO


/* =========================================================
   17. MARKETING FUNNEL BY SOURCE
   ========================================================= */

SELECT
    source,
    SUM(sessions) AS Sessions,
    SUM(add_to_cart) AS Add_To_Cart,
    SUM(orders) AS Orders,

    CAST(
        100.0 * SUM(add_to_cart)
        / NULLIF(SUM(sessions), 0)
        AS DECIMAL(10,2)
    ) AS Session_To_Cart_Percent,

    CAST(
        100.0 * SUM(orders)
        / NULLIF(SUM(add_to_cart), 0)
        AS DECIMAL(10,2)
    ) AS Cart_To_Order_Percent,

    CAST(
        100.0 * SUM(orders)
        / NULLIF(SUM(sessions), 0)
        AS DECIMAL(10,2)
    ) AS Overall_Conversion_Percent

FROM fact_session_daily
GROUP BY
    source
ORDER BY
    Overall_Conversion_Percent DESC;
GO


/* =========================================================
   18. MARKETING SPEND BY SOURCE
   ========================================================= */

SELECT
    source,
    SUM(spend_amount) AS Marketing_Spend
FROM fact_marketing_spend
GROUP BY
    source
ORDER BY
    Marketing_Spend DESC;
GO


/* =========================================================
   19. CUSTOMER ACQUISITION
   ========================================================= */

WITH CustomerStats AS
(
    SELECT
        acquisition_source,
        customer_id
    FROM dim_customer
),
OrderStats AS
(
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS Orders,
        SUM(gmv) AS GMV
    FROM fact_order
    GROUP BY
        customer_id
)
SELECT
    cs.acquisition_source,
    COUNT(DISTINCT cs.customer_id) AS New_Buyers,
    COALESCE(SUM(os.Orders), 0) AS Orders,
    COALESCE(SUM(os.GMV), 0) AS GMV,

    CAST(
        COALESCE(SUM(os.Orders), 0) * 1.0
        / NULLIF(COUNT(DISTINCT cs.customer_id), 0)
        AS DECIMAL(10,2)
    ) AS Orders_Per_Buyer,

    CAST(
        COALESCE(SUM(os.GMV), 0) * 1.0
        / NULLIF(COUNT(DISTINCT cs.customer_id), 0)
        AS DECIMAL(18,2)
    ) AS GMV_Per_Buyer

FROM CustomerStats cs
LEFT JOIN OrderStats os
    ON cs.customer_id = os.customer_id
GROUP BY
    cs.acquisition_source
ORDER BY
    GMV DESC;
GO


/* =========================================================
   20. MARKETING CAC
   CAC = Marketing Spend / New Buyers
   ========================================================= */

WITH NewBuyers AS
(
    SELECT
        acquisition_source,
        COUNT(*) AS New_Buyers
    FROM dim_customer
    GROUP BY
        acquisition_source
),
Spend AS
(
    SELECT
        source,
        SUM(spend_amount) AS Marketing_Spend
    FROM fact_marketing_spend
    GROUP BY
        source
)
SELECT
    nb.acquisition_source,
    nb.New_Buyers,
    COALESCE(s.Marketing_Spend, 0) AS Marketing_Spend,

    CAST(
        COALESCE(s.Marketing_Spend, 0) * 1.0
        / NULLIF(nb.New_Buyers, 0)
        AS DECIMAL(18,2)
    ) AS CAC

FROM NewBuyers nb
LEFT JOIN Spend s
    ON nb.acquisition_source = s.source
ORDER BY
    CAC DESC;
GO


/* =========================================================
   21. CAMPAIGN PERFORMANCE
   ========================================================= */

SELECT
    c.campaign_name,
    COUNT(DISTINCT o.order_id) AS Orders,
    SUM(o.gmv) AS GMV,
    SUM(oi.discount_amount) AS Discount_Given,
    CAST(
        100.0 *
        SUM(
            CASE
                WHEN o.customer_id IN
                (
                    SELECT customer_id
                    FROM fact_order
                    GROUP BY customer_id
                    HAVING MIN(order_id) = o.order_id
                )
                THEN 1 ELSE 0
            END
        )
        / NULLIF(COUNT(DISTINCT o.order_id), 0)
        AS DECIMAL(10,2)
    ) AS First_Time_Buyer_Share

FROM fact_order o
INNER JOIN fact_order_item oi
    ON o.order_id = oi.order_id
INNER JOIN dim_campaign c
    ON o.campaign_id = c.campaign_id
GROUP BY
    c.campaign_name
ORDER BY
    GMV DESC;
GO


/* =========================================================
   22. DEVICE PERFORMANCE — LAST 12 MONTHS
   ========================================================= */

SELECT
    c.device,
    COUNT(DISTINCT o.customer_id) AS Active_Buyers
FROM fact_order o
INNER JOIN dim_customer c
    ON o.customer_id = c.customer_id
INNER JOIN dim_date d
    ON o.order_date_id = d.date_id
WHERE
    d.full_date BETWEEN '2025-07-01' AND '2026-06-30'
GROUP BY
    c.device
ORDER BY
    Active_Buyers DESC;
GO


/* =========================================================
   23. REGION PERFORMANCE — LAST 12 MONTHS
   ========================================================= */

SELECT
    c.region,
    COUNT(DISTINCT o.customer_id) AS Active_Buyers
FROM fact_order o
INNER JOIN dim_customer c
    ON o.customer_id = c.customer_id
INNER JOIN dim_date d
    ON o.order_date_id = d.date_id
WHERE
    d.full_date BETWEEN '2025-07-01' AND '2026-06-30'
GROUP BY
    c.region
ORDER BY
    Active_Buyers DESC;
GO


/* =========================================================
   END OF BUSINESS ANALYSIS
   ========================================================= */
