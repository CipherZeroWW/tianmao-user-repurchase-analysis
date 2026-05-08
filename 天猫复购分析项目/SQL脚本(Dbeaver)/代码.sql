USE tmall_repurchase;

-- 1.数据清洗（字段类型修改+脏数据过滤）
ALTER TABLE user_log_format1
MODIFY COLUMN user_id BIGINT,
MODIFY COLUMN item_id BIGINT,
MODIFY COLUMN merchant_id BIGINT,
MODIFY COLUMN brand_id BIGINT,
MODIFY COLUMN time_stamp INT,
MODIFY COLUMN action_type TINYINT;

DELETE FROM user_log_format1
WHERE user_id IS NULL 
   OR merchant_id IS NULL 
   OR action_type NOT IN (0,1,2,3);



-- 2.基础统计（用户/商家/行为分布）
SELECT 
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT merchant_id) AS unique_merchants,
    COUNT(DISTINCT item_id) AS unique_items,
    COUNT(*) AS total_actions
FROM user_log_format1;

SELECT 
    action_type,
    COUNT(*) AS action_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM user_log_format1) * 100, 2) AS action_percent
FROM user_log_format1
GROUP BY action_type
ORDER BY action_count DESC;

-- 3.复购用户行为差异分析
SELECT
    CASE WHEN t.label = 1 THEN '复购用户' ELSE '非复购用户' END AS user_type,
    COUNT(DISTINCT t.user_id) AS user_count,
    ROUND(AVG(view_count), 2) AS avg_view,
    ROUND(AVG(order_count), 2) AS avg_order,
    ROUND(AVG(pay_count), 2) AS avg_pay,
    ROUND(SUM(CASE WHEN pay_count > 0 THEN 1 ELSE 0 END) / SUM(CASE WHEN order_count > 0 THEN 1 ELSE 0 END) * 100, 2) AS pay_conversion_rate
FROM train_format1 t
LEFT JOIN (
    SELECT
        user_id,
        SUM(CASE WHEN action_type = 0 THEN 1 ELSE 0 END) AS view_count,
        SUM(CASE WHEN action_type = 2 THEN 1 ELSE 0 END) AS order_count,
        SUM(CASE WHEN action_type = 3 THEN 1 ELSE 0 END) AS pay_count
    FROM user_log_format1
    GROUP BY user_id
) u ON t.user_id = u.user_id
GROUP BY t.label;

-- 4.商家转化率Top10
SELECT
    merchant_id,
    SUM(CASE WHEN action_type = 0 THEN 1 ELSE 0 END) AS view_count,
    SUM(CASE WHEN action_type = 3 THEN 1 ELSE 0 END) AS pay_count,
    ROUND(SUM(CASE WHEN action_type = 3 THEN 1 ELSE 0 END) / SUM(CASE WHEN action_type = 0 THEN 1 ELSE 0 END) * 100, 2) AS conversion_rate
FROM user_log_format1
GROUP BY merchant_id
HAVING view_count > 100
ORDER BY conversion_rate DESC
LIMIT 10;