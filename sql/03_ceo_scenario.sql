USE marketplace_bozorboz;
GO

/* =========================================================
   BOZORBOZ MARKETPLACE
   03 - CEO SCENARIO ANALYSIS
   =========================================================

   Scenario:
   Exclude orders that contain at least one of the following:
   1. Electronics category
   2. Tezkor courier
   3. Banner acquisition source

   Purpose:
   Estimate the impact of removing these segments
   from the current business mix.

   IMPORTANT:
   This is an order-level scenario.
   An order is excluded entirely if it matches
   ANY of the three conditions above.
   ========================================================= */


/* =========================================================
   1. CURRENT BUSINESS BASELINE
   ========================================================= */

SELECT
    COUNT(DISTINCT o.order_id) AS Total_Orders,

    SUM(
        oi.quantity * oi.unit_price
        - oi.discount_amount
    ) AS GMV,

    SUM(oi.commission_amount) AS Commission,

    SUM(
        oi.commission_amount
    )
    /
    NULLIF(
        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ),
        0
    ) AS Take_Rate

FROM fact_order o
INNER JOIN fact_order_item oi
    ON o.order_id = oi.order_id;
GO


/* =========================================================
   2. IDENTIFY ORDERS INCLUDED IN THE SCENARIO
   ========================================================= */

WITH ScenarioOrders AS
(
    SELECT DISTINCT
        o.order_id
    FROM fact_order o
    INNER JOIN fact_order_item oi
        ON o.order_id = oi.order_id
    INNER JOIN dim_product p
        ON oi.product_id = p.product_id
    INNER JOIN fact_delivery d
        ON o.order_id = d.order_id
    INNER JOIN dim_customer c
        ON o.customer_id = c.customer_id

    WHERE
        p.category = N'Elektronika'
        OR d.courier_id =
        (
            SELECT courier_id
            FROM dim_courier
            WHERE courier_name = N'Tezkor'
        )
        OR c.acquisition_source = N'Banner'
)

SELECT
    COUNT(*) AS Orders_Excluded
FROM ScenarioOrders;
GO


/* =========================================================
   3. CURRENT GMV VS SCENARIO GMV
   ========================================================= */

WITH ScenarioOrders AS
(
    SELECT DISTINCT
        o.order_id
    FROM fact_order o
    INNER JOIN fact_order_item oi
        ON o.order_id = oi.order_id
    INNER JOIN dim_product p
        ON oi.product_id = p.product_id
    INNER JOIN fact_delivery d
        ON o.order_id = d.order_id
    INNER JOIN dim_customer c
        ON o.customer_id = c.customer_id

    WHERE
        p.category = N'Elektronika'
        OR d.courier_id =
        (
            SELECT courier_id
            FROM dim_courier
            WHERE courier_name = N'Tezkor'
        )
        OR c.acquisition_source = N'Banner'
)

SELECT
    'Current' AS Scenario,
    SUM(
        oi.quantity * oi.unit_price
        - oi.discount_amount
    ) AS GMV
FROM fact_order_item oi

UNION ALL

SELECT
    'Scenario' AS Scenario,
    SUM(
        oi.quantity * oi.unit_price
        - oi.discount_amount
    ) AS GMV
FROM fact_order_item oi
WHERE oi.order_id NOT IN
(
    SELECT order_id
    FROM ScenarioOrders
);
GO


/* =========================================================
   4. GMV IMPACT
   ========================================================= */

WITH ScenarioOrders AS
(
    SELECT DISTINCT
        o.order_id
    FROM fact_order o
    INNER JOIN fact_order_item oi
        ON o.order_id = oi.order_id
    INNER JOIN dim_product p
        ON oi.product_id = p.product_id
    INNER JOIN fact_delivery d
        ON o.order_id = d.order_id
    INNER JOIN dim_customer c
        ON o.customer_id = c.customer_id

    WHERE
        p.category = N'Elektronika'
        OR d.courier_id =
        (
            SELECT courier_id
            FROM dim_courier
            WHERE courier_name = N'Tezkor'
        )
        OR c.acquisition_source = N'Banner'
),

CurrentGMV AS
(
    SELECT
        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) AS GMV
    FROM fact_order_item oi
),

ScenarioGMV AS
(
    SELECT
        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) AS GMV
    FROM fact_order_item oi
    WHERE oi.order_id NOT IN
    (
        SELECT order_id
        FROM ScenarioOrders
    )
)

SELECT
    CurrentGMV.GMV AS Current_GMV,
    ScenarioGMV.GMV AS Scenario_GMV,

    CurrentGMV.GMV - ScenarioGMV.GMV
        AS GMV_Lost,

    CAST(
        100.0 *
        (ScenarioGMV.GMV - CurrentGMV.GMV)
        / NULLIF(CurrentGMV.GMV, 0)
        AS DECIMAL(10,2)
    ) AS GMV_Change_Percent

FROM CurrentGMV
CROSS JOIN ScenarioGMV;
GO


/* =========================================================
   5. COMMISSION IMPACT
   ========================================================= */

WITH ScenarioOrders AS
(
    SELECT DISTINCT
        o.order_id
    FROM fact_order o
    INNER JOIN fact_order_item oi
        ON o.order_id = oi.order_id
    INNER JOIN dim_product p
        ON oi.product_id = p.product_id
    INNER JOIN fact_delivery d
        ON o.order_id = d.order_id
    INNER JOIN dim_customer c
        ON o.customer_id = c.customer_id

    WHERE
        p.category = N'Elektronika'
        OR d.courier_id =
        (
            SELECT courier_id
            FROM dim_courier
            WHERE courier_name = N'Tezkor'
        )
        OR c.acquisition_source = N'Banner'
)

SELECT
    'Current' AS Scenario,
    SUM(oi.commission_amount) AS Commission
FROM fact_order_item oi

UNION ALL

SELECT
    'Scenario' AS Scenario,
    SUM(oi.commission_amount) AS Commission
FROM fact_order_item oi
WHERE oi.order_id NOT IN
(
    SELECT order_id
    FROM ScenarioOrders
);
GO


/* =========================================================
   6. ORDER VOLUME IMPACT
   ========================================================= */

WITH ScenarioOrders AS
(
    SELECT DISTINCT
        o.order_id
    FROM fact_order o
    INNER JOIN fact_order_item oi
        ON o.order_id = oi.order_id
    INNER JOIN dim_product p
        ON oi.product_id = p.product_id
    INNER JOIN fact_delivery d
        ON o.order_id = d.order_id
    INNER JOIN dim_customer c
        ON o.customer_id = c.customer_id

    WHERE
        p.category = N'Elektronika'
        OR d.courier_id =
        (
            SELECT courier_id
            FROM dim_courier
            WHERE courier_name = N'Tezkor'
        )
        OR c.acquisition_source = N'Banner'
)

SELECT
    COUNT(DISTINCT o.order_id) AS Current_Orders,

    COUNT(
        DISTINCT
        CASE
            WHEN o.order_id NOT IN
            (
                SELECT order_id
                FROM ScenarioOrders
            )
            THEN o.order_id
        END
    ) AS Scenario_Orders

FROM fact_order o;
GO


/* =========================================================
   7. SCENARIO SUMMARY
   ========================================================= */

WITH ScenarioOrders AS
(
    SELECT DISTINCT
        o.order_id
    FROM fact_order o
    INNER JOIN fact_order_item oi
        ON o.order_id = oi.order_id
    INNER JOIN dim_product p
        ON oi.product_id = p.product_id
    INNER JOIN fact_delivery d
        ON o.order_id = d.order_id
    INNER JOIN dim_customer c
        ON o.customer_id = c.customer_id

    WHERE
        p.category = N'Elektronika'
        OR d.courier_id =
        (
            SELECT courier_id
            FROM dim_courier
            WHERE courier_name = N'Tezkor'
        )
        OR c.acquisition_source = N'Banner'
),

CurrentMetrics AS
(
    SELECT
        COUNT(DISTINCT o.order_id) AS Orders,
        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) AS GMV,
        SUM(oi.commission_amount) AS Commission
    FROM fact_order o
    INNER JOIN fact_order_item oi
        ON o.order_id = oi.order_id
),

ScenarioMetrics AS
(
    SELECT
        COUNT(DISTINCT o.order_id) AS Orders,
        SUM(
            oi.quantity * oi.unit_price
            - oi.discount_amount
        ) AS GMV,
        SUM(oi.commission_amount) AS Commission
    FROM fact_order o
    INNER JOIN fact_order_item oi
        ON o.order_id = oi.order_id
    WHERE o.order_id NOT IN
    (
        SELECT order_id
        FROM ScenarioOrders
    )
)

SELECT
    CurrentMetrics.Orders AS Current_Orders,
    ScenarioMetrics.Orders AS Scenario_Orders,

    CurrentMetrics.GMV AS Current_GMV,
    ScenarioMetrics.GMV AS Scenario_GMV,

    CurrentMetrics.Commission AS Current_Commission,
    ScenarioMetrics.Commission AS Scenario_Commission,

    CurrentMetrics.GMV
        - ScenarioMetrics.GMV AS GMV_Lost,

    CurrentMetrics.Commission
        - ScenarioMetrics.Commission AS Commission_Lost

FROM CurrentMetrics
CROSS JOIN ScenarioMetrics;
GO


/* =========================================================
   END OF CEO SCENARIO ANALYSIS
   ========================================================= */
