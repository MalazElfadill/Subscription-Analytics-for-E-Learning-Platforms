CREATE OR REPLACE VIEW upgrade_analysis AS

SELECT

    s1.student_id,

    DATE(s1.subscription_period_start) AS old_purchase_date,

    DATE(s2.subscription_period_start) AS upgrade_date,

    CASE
        WHEN s1.subscription_type = 0 THEN 'Monthly'
        WHEN s1.subscription_type = 2 THEN 'Annual'
        WHEN s1.subscription_type = 3 THEN 'Lifetime'
    END AS old_plan,

    CASE
        WHEN s2.subscription_type = 0 THEN 'Monthly'
        WHEN s2.subscription_type = 2 THEN 'Annual'
        WHEN s2.subscription_type = 3 THEN 'Lifetime'
    END AS new_plan,

    p1.price AS old_price,

    p2.price AS new_price,

    (
        p2.price - p1.price
    ) AS price_increase

FROM subscriptions s1

JOIN subscriptions s2
    ON s1.student_id = s2.student_id
    AND s2.subscription_period_start > s1.subscription_period_start

LEFT JOIN purchases p1
    ON s1.student_id = p1.student_id
    AND DATE(s1.subscription_period_start) = DATE(p1.purchase_date)

LEFT JOIN purchases p2
    ON s2.student_id = p2.student_id
    AND DATE(s2.subscription_period_start) = DATE(p2.purchase_date)

WHERE s1.subscription_type <> s2.subscription_type;