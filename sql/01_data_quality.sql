
USE marketplace_bozorboz;
GO

/* =========================================================
   BOZORBOZ MARKETPLACE
   01 - DATA QUALITY CHECKS
   Period: 2023-01-01 to 2026-06-30
   ========================================================= */


/* =========================================================
   1. ROW COUNT — ALL TABLES
   ========================================================= */

SELECT 'dim_campaign' AS table_name, COUNT(*) AS row_count
FROM dim_campaign
UNION ALL
SELECT 'dim_courier', COUNT(*) FROM dim_courier
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL
SELECT 'fact_delivery', COUNT(*) FROM fact_delivery
UNION ALL
SELECT 'fact_marketing_spend', COUNT(*) FROM fact_marketing_spend
UNION ALL
SELECT 'fact_order', COUNT(*) FROM fact_order
UNION ALL
SELECT 'fact_order_item', COUNT(*) FROM fact_order_item
UNION ALL
SELECT 'fact_return', COUNT(*) FROM fact_return
UNION ALL
SELECT 'fact_review', COUNT(*) FROM fact_review
UNION ALL
SELECT 'fact_seller_payout', COUNT(*) FROM fact_seller_payout
UNION ALL
SELECT 'fact_session_daily', COUNT(*) FROM fact_session_daily
ORDER BY table_name;
GO


/* =========================================================
   2. DATE RANGE
   ========================================================= */

SELECT
    MIN(full_date) AS Start_Date,
    MAX(full_date) AS End_Date,
    COUNT(*) AS Number_Of_Days
FROM dim_date;
GO


/* =========================================================
   3. DUPLICATE DIMENSION KEYS
   Expected result: no rows
   ========================================================= */

SELECT
    'dim_customer' AS table_name,
    customer_id AS key_value,
    COUNT(*) AS duplicate_count
FROM dim_customer
GROUP BY customer_id
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'dim_product',
    product_id,
    COUNT(*)
FROM dim_product
GROUP BY product_id
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'dim_seller',
    seller_id,
    COUNT(*)
FROM dim_seller
GROUP BY seller_id
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'dim_courier',
    courier_id,
    COUNT(*)
FROM dim_courier
GROUP BY courier_id
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'dim_campaign',
    campaign_id,
    COUNT(*)
FROM dim_campaign
GROUP BY campaign_id
HAVING COUNT(*) > 1;
GO


/* =========================================================
   4. ORDER → ORDER ITEM MATCHING
   Every order should have order items.
   ========================================================= */

SELECT
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    COUNT(DISTINCT oi.order_id) AS Orders_With_Items,
    COUNT(DISTINCT o.order_id)
        - COUNT(DISTINCT oi.order_id) AS Orders_Without_Items
FROM fact_order o
LEFT JOIN fact_order_item oi
    ON o.order_id = oi.order_id;
GO


/* =========================================================
   5. ORDER → DELIVERY MATCHING
   ========================================================= */

SELECT
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    COUNT(DISTINCT d.order_id) AS Orders_With_Delivery,
    COUNT(DISTINCT o.order_id)
        - COUNT(DISTINCT d.order_id) AS Orders_Without_Delivery
FROM fact_order o
LEFT JOIN fact_delivery d
    ON o.order_id = d.order_id;
GO


/* =========================================================
   6. ORDER ITEM → PRODUCT ORPHANS
   Expected result: 0
   ========================================================= */

SELECT COUNT(*) AS Orphan_Order_Items
FROM fact_order_item oi
LEFT JOIN dim_product p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
GO


/* =========================================================
   7. ORDER → CUSTOMER ORPHANS
   Expected result: 0
   ========================================================= */

SELECT COUNT(*) AS Orphan_Orders_Customers
FROM fact_order o
LEFT JOIN dim_customer c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
GO


/* =========================================================
   8. ORDER ITEM → SELLER ORPHANS
   Expected result: 0
   ========================================================= */

SELECT COUNT(*) AS Orphan_Order_Items_Sellers
FROM fact_order_item oi
LEFT JOIN dim_seller s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;
GO


/* =========================================================
   9. DELIVERY → COURIER ORPHANS
   Expected result: 0
   ========================================================= */

SELECT COUNT(*) AS Orphan_Deliveries_Couriers
FROM fact_delivery d
LEFT JOIN dim_courier c
    ON d.courier_id = c.courier_id
WHERE c.courier_id IS NULL;
GO


/* =========================================================
   10. ORDER → DATE ORPHANS
   Expected result: 0
   ========================================================= */

SELECT COUNT(*) AS Orphan_Orders_Dates
FROM fact_order o
LEFT JOIN dim_date d
    ON o.order_date_id = d.date_id
WHERE d.date_id IS NULL;
GO


/* =========================================================
   11. NEGATIVE QUANTITIES
   ========================================================= */

SELECT
    COUNT(*) AS Negative_Quantity_Rows,
    MIN(quantity) AS Minimum_Quantity
FROM fact_order_item
WHERE quantity < 0;
GO


/* =========================================================
   12. ZERO OR NEGATIVE PRICES
   ========================================================= */

SELECT
    COUNT(*) AS Zero_Or_Negative_Price_Rows,
    MIN(unit_price) AS Minimum_Unit_Price
FROM fact_order_item
WHERE unit_price <= 0;
GO


/* =========================================================
   13. NEGATIVE / POSITIVE ORDER VALUES
   ========================================================= */

SELECT
    COUNT(*) AS Total_Orders,
    SUM(CASE WHEN gmv < 0 THEN 1 ELSE 0 END) AS Negative_GMV_Orders,
    SUM(CASE WHEN gmv = 0 THEN 1 ELSE 0 END) AS Zero_GMV_Orders,
    MIN(gmv) AS Minimum_GMV,
    MAX(gmv) AS Maximum_GMV
FROM fact_order;
GO


/* =========================================================
   14. ORDER STATUS DISTRIBUTION
   ========================================================= */

SELECT
    order_status,
    COUNT(*) AS Orders,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
        AS DECIMAL(10,2)
    ) AS Share_Percent
FROM fact_order
GROUP BY order_status
ORDER BY Orders DESC;
GO


/* =========================================================
   15. DELIVERED ORDER ITEMS
   ========================================================= */

SELECT
    COUNT(*) AS Delivered_Order_Items
FROM fact_order_item oi
INNER JOIN fact_order o
    ON oi.order_id = o.order_id
WHERE o.order_status = N'Yetkazildi';
GO


/* =========================================================
   16. RETURN RATE
   Returned Items / Delivered Items
   ========================================================= */

SELECT
    COUNT(DISTINCT r.return_id) AS Returned_Items,
    COUNT(DISTINCT oi.order_item_id) AS Delivered_Items,
    CAST(
        100.0 * COUNT(DISTINCT r.return_id)
        / NULLIF(COUNT(DISTINCT oi.order_item_id), 0)
        AS DECIMAL(10,2)
    ) AS Return_Rate_Percent
FROM fact_return r
INNER JOIN fact_order_item oi
    ON r.order_item_id = oi.order_item_id
INNER JOIN fact_order o
    ON oi.order_id = o.order_id
WHERE o.order_status = N'Yetkazildi';
GO


/* =========================================================
   17. WEEKEND COVERAGE
   Weekends must NOT be filtered from the dataset.
   ========================================================= */

SELECT
    SUM(
        CASE
            WHEN DATEPART(WEEKDAY, full_date) IN (1, 7)
            THEN 1 ELSE 0
        END
    ) AS Weekend_Days,
    SUM(
        CASE
            WHEN DATEPART(WEEKDAY, full_date) NOT IN (1, 7)
            THEN 1 ELSE 0
        END
    ) AS Weekdays
FROM dim_date;
GO


/* =========================================================
   18. DELIVERY RECORD COUNT
   Order and delivery should match 1-to-1.
   ========================================================= */

SELECT
    COUNT(DISTINCT order_id) AS Delivery_Orders,
    COUNT(*) AS Delivery_Rows
FROM fact_delivery;
GO


/* =========================================================
   19. DUPLICATE DELIVERY ORDERS
   Expected result: no rows
   ========================================================= */

SELECT
    order_id,
    COUNT(*) AS Delivery_Row_Count
FROM fact_delivery
GROUP BY order_id
HAVING COUNT(*) > 1;
GO


/* =========================================================
   20. FINAL DATA QUALITY SUMMARY
   ========================================================= */

SELECT
    (SELECT COUNT(*) FROM dim_campaign) AS Campaigns,
    (SELECT COUNT(*) FROM dim_courier) AS Couriers,
    (SELECT COUNT(*) FROM dim_customer) AS Customers,
    (SELECT COUNT(*) FROM dim_date) AS Dates,
    (SELECT COUNT(*) FROM dim_product) AS Products,
    (SELECT COUNT(*) FROM dim_seller) AS Sellers,
    (SELECT COUNT(*) FROM fact_order) AS Orders,
    (SELECT COUNT(*) FROM fact_order_item) AS Order_Items,
    (SELECT COUNT(*) FROM fact_delivery) AS Deliveries,
    (SELECT COUNT(*) FROM fact_return) AS Returns,
    (SELECT COUNT(*) FROM fact_review) AS Reviews,
    (SELECT COUNT(*) FROM fact_marketing_spend) AS Marketing_Spend_Rows,
    (SELECT COUNT(*) FROM fact_session_daily) AS Session_Rows,
    (SELECT COUNT(*) FROM fact_seller_payout) AS Seller_Payout_Rows;
GO


/* =========================================================
   END OF DATA QUALITY CHECKS
   ========================================================= */
