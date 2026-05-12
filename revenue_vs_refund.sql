CREATE OR REPLACE VIEW revenue_vs_refund AS
WITH first_purchase AS (
    SELECT
        student_id,
        MIN(purchase_date) AS first_purchase_date
    FROM purchases
    GROUP BY student_id
)
SELECT
    p.purchase_id,
    p.student_id,
    s.student_country,
	DATE_FORMAT(p.purchase_date,'%Y-%m-01') AS month_date,

    DATE_FORMAT(p.purchase_date,'%Y-%m-01') AS purchase_date,
   DATE_FORMAT (p.refunded_date,'%Y-%m-01') AS refunded_date,

    p.price,

    CASE
        WHEN p.refunded_date IS NULL THEN 'Revenue'
        ELSE 'Refund'
    END AS transaction_type,

    CASE
        WHEN sub.subscription_type = 0 THEN 'Monthly'
        WHEN sub.subscription_type = 2 THEN 'Annual'
        WHEN sub.subscription_type = 3 THEN 'Lifetime'
        ELSE 'Unknown'
    END AS subscription_type,

    CASE
        WHEN p.refunded_date IS NULL THEN p.price
        ELSE 0
    END AS revenue,

    CASE
        WHEN p.refunded_date IS NOT NULL THEN p.price
        ELSE 0
    END AS refunds,

    CASE
        WHEN p.refunded_date IS NULL THEN p.price
        ELSE -p.price
    END AS net_revenue,
    CASE
        WHEN p.refunded_date = fp.first_purchase_date
        THEN 'New'
        ELSE 'Recurring'
    END AS customer_type

FROM purchases p

LEFT JOIN students s
    ON p.student_id = s.student_id

LEFT JOIN subscriptions sub
    ON p.subscription_id = sub.subscription_id
    
LEFT JOIN first_purchase fp
    ON p.student_id = fp.student_id;