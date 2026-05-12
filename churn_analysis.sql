CREATE OR REPLACE VIEW churn_analysis AS

WITH active_users AS (

    SELECT
        DATE_FORMAT(subscription_period_start, '%Y-%m-01') AS month_date,
        COUNT(DISTINCT student_id) AS active_users

    FROM subscriptions

    WHERE subscription_type IN (0,2,3)

    GROUP BY month_date
),

canceled_users AS (

    SELECT
        DATE_FORMAT(cancelled_date, '%Y-%m-01') AS month_date,
        COUNT(DISTINCT student_id) AS canceled_users

    FROM subscriptions

    WHERE cancelled_date IS NOT NULL
      AND subscription_type IN (0,2,3)

    GROUP BY month_date
),

passive_users AS (

    SELECT
        DATE_FORMAT(end_date, '%Y-%m-01') AS month_date,
        COUNT(DISTINCT student_id) AS passive_users

    FROM subscriptions

    WHERE end_date IS NOT NULL
      AND cancelled_date IS NULL
      AND subscription_type IN (0,2,3)

    GROUP BY month_date
)

SELECT

    STR_TO_DATE(a.month_date,'%Y-%m-%d') AS month_date,

    a.active_users,

    COALESCE(c.canceled_users,0) AS canceled_users,

    COALESCE(p.passive_users,0) AS passive_users,

    (
        COALESCE(c.canceled_users,0)
        + COALESCE(p.passive_users,0)
    ) AS total_churned_users,

    (
    (
        COALESCE(c.canceled_users,0)
        + COALESCE(p.passive_users,0)
    ) * 1.0
    /
    NULLIF(a.active_users,0)
) / 100 AS churn_rate,

   (
    COALESCE(c.canceled_users,0) * 1.0
    /
    NULLIF(a.active_users,0)
) / 100 AS active_churn_rate,

(
    COALESCE(p.passive_users,0) * 1.0
    /
    NULLIF(a.active_users,0)
) / 100 AS passive_churn_rate

FROM active_users a

LEFT JOIN canceled_users c
    ON a.month_date = c.month_date

LEFT JOIN passive_users p
    ON a.month_date = p.month_date

ORDER BY month_date;