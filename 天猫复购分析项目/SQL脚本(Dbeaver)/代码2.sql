USE tmall_repurchase;

1.每日行为量

SELECT
    time_stamp,
    COUNT(*) AS total_behavior,
    COUNT(DISTINCT user_id) AS active_user
FROM user_log_format1
GROUP BY time_stamp
ORDER BY time_stamp;

2. 各行为月度分布

SELECT
    action_type,
    COUNT(*) AS cnt
FROM user_log_format1
GROUP BY action_type;

3. 复购 / 非复购 整体数量

SELECT
    label,
    COUNT(DISTINCT user_id) AS user_num
FROM train_format1
GROUP BY label;

4. 用户年龄段分布

SELECT
    age_range,
    COUNT(DISTINCT user_id) AS user_count
FROM user_info_format1
GROUP BY age_range;

5. 性别分布

SELECT
    gender,
    COUNT(DISTINCT user_id) AS user_count
FROM user_info_format1
GROUP BY gender;

6. 商家流量分层

SELECT
    merchant_id,
    COUNT(*) AS view_num,
    COUNT(DISTINCT user_id) AS uv
FROM user_log_format1
GROUP BY merchant_id
HAVING view_num > 50
ORDER BY view_num DESC;

7. 高活跃用户 TOP

SELECT
    user_id,
    COUNT(*) AS behavior_total
FROM user_log_format1
GROUP BY user_id
ORDER BY behavior_total DESC
LIMIT 30;

8. 转化指标总表

SELECT
    merchant_id,
    SUM(IF(action_type=0,1,0)) AS browse,
    SUM(IF(action_type=2,1,0)) AS order_num,
    SUM(IF(action_type=3,1,0)) AS pay_num,
    ROUND(SUM(IF(action_type=3,1,0))/SUM(IF(action_type=0,1,0))*100,2) AS pay_conv
FROM user_log_format1
GROUP BY merchant_id
HAVING browse >= 20
ORDER BY pay_conv DESC;