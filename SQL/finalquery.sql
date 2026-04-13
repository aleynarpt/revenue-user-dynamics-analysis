WITH user_month_revenue AS (
    -- 1. User-month revenue
    SELECT
        gp.user_id,
        gp.game_name,
        DATE_TRUNC('month', gp.payment_date)::date AS month,
        SUM(gp.revenue_amount_usd) AS revenue
    FROM project.games_payments gp
    GROUP BY 1,2,3
),
user_month_enriched AS (
    -- 2. User info + previous/next month and revenue
    SELECT
        umr.*,
        gpu.language,
        gpu.age,
        LAG(umr.month) OVER (
            PARTITION BY umr.user_id, umr.game_name
            ORDER BY umr.month
        ) AS prev_month,
        LEAD(umr.month) OVER (
            PARTITION BY umr.user_id, umr.game_name
            ORDER BY umr.month
        ) AS next_month,
        LAG(umr.revenue) OVER (
            PARTITION BY umr.user_id, umr.game_name
            ORDER BY umr.month
        ) AS prev_revenue,
        LEAD(umr.revenue) OVER (
            PARTITION BY umr.user_id, umr.game_name
            ORDER BY umr.month
        ) AS next_revenue
    FROM user_month_revenue umr
    LEFT JOIN project.games_paid_users gpu
        ON umr.user_id = gpu.user_id
),
classified AS (
    -- 3. Revenue classification
    SELECT
        *,
        CASE
            WHEN prev_month IS NULL THEN 'new'
            WHEN month > (prev_month + INTERVAL '1 month') THEN 'back_from_churn'
            WHEN month = (prev_month + INTERVAL '1 month') AND revenue > prev_revenue THEN 'expansion'
            WHEN month = (prev_month + INTERVAL '1 month') AND revenue < prev_revenue THEN 'contraction'
            ELSE 'stable'
        END AS revenue_type,
        CASE
            WHEN next_month IS NULL THEN 1
            WHEN next_month > (month + INTERVAL '1 month') THEN 1
            ELSE 0
        END AS is_churned
    FROM user_month_enriched
),
user_lifetime AS (
    -- 4. User lifetime and lifetime value
    SELECT
        user_id,
        game_name,
        MIN(month) AS first_month,
        MAX(month) AS last_month,
        SUM(revenue) AS total_revenue,
        (
            (DATE_PART('year', MAX(month)) - DATE_PART('year', MIN(month))) * 12
            + (DATE_PART('month', MAX(month)) - DATE_PART('month', MIN(month)))
            + 1
        ) AS lifetime_months
    FROM user_month_revenue
    GROUP BY 1,2
),
monthly_metrics AS (
    -- 5. Monthly aggregated metrics
    SELECT
        c.month,
        c.game_name,
        c.language,
        c.age,
        COUNT(DISTINCT c.user_id) AS paid_users,
        SUM(c.revenue) AS mrr,
        SUM(c.revenue) / NULLIF(COUNT(DISTINCT c.user_id), 0) AS arppu,
        COUNT(DISTINCT CASE WHEN c.revenue_type = 'new' THEN c.user_id END) AS new_users,
        SUM(CASE WHEN c.revenue_type = 'new' THEN c.revenue END) AS new_mrr,
        COUNT(DISTINCT CASE WHEN c.is_churned = 1 THEN c.user_id END) AS churned_users,
        SUM(CASE WHEN c.is_churned = 1 THEN c.revenue END) AS churned_revenue,
        SUM(CASE WHEN c.revenue_type = 'expansion' THEN c.revenue - c.prev_revenue END) AS expansion_mrr,
        SUM(CASE WHEN c.revenue_type = 'contraction' THEN c.prev_revenue - c.revenue END) AS contraction_mrr,
        SUM(CASE WHEN c.revenue_type = 'back_from_churn' THEN c.revenue END) AS back_from_churn_mrr,
        AVG(ul.lifetime_months) AS lt,
        AVG(ul.total_revenue) AS ltv
    FROM classified c
    LEFT JOIN user_lifetime ul
        ON c.user_id = ul.user_id
       AND c.game_name = ul.game_name
    GROUP BY 1,2,3,4
),
final AS (
    -- 6. Previous month metrics for churn rates
    SELECT
        *,
        LAG(paid_users) OVER (
            PARTITION BY game_name, language, age
            ORDER BY month
        ) AS prev_paid_users,
        LAG(mrr) OVER (
            PARTITION BY game_name, language, age
            ORDER BY month
        ) AS prev_mrr
    FROM monthly_metrics
)
SELECT
    month,
    game_name,
    language,
    age,
    mrr,
    paid_users,
    arppu,
    new_users,
    new_mrr,
    churned_users,
    churned_revenue,
    expansion_mrr,
    contraction_mrr,
    back_from_churn_mrr,
    churned_users::float / NULLIF(prev_paid_users, 0) AS churn_rate,
    churned_revenue::float / NULLIF(prev_mrr, 0) AS revenue_churn_rate,
    lt,
    ltv
FROM final
ORDER BY month, game_name, language, age;