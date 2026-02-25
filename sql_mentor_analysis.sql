-- ============================================================
-- SQL MENTOR USER PERFORMANCE ANALYSIS
-- Dataset: user_sub_sql_mentor06nov
-- Columns: id, user_id, question_id, points, submitted_at, username
-- ============================================================

-- ============================================================
-- SECTION 1: DATA EXPLORATION & OVERVIEW
-- ============================================================

-- 1.1 Total Records & Date Range
SELECT 
    COUNT(*)                                        AS total_submissions,
    COUNT(DISTINCT user_id)                         AS total_users,
    COUNT(DISTINCT question_id)                     AS total_questions_attempted,
    MIN(submitted_at::DATE)                         AS first_submission_date,
    MAX(submitted_at::DATE)                         AS last_submission_date
FROM user_sub_sql_mentor06nov;

-- 1.2 Sample Data Preview
SELECT *
FROM user_sub_sql_mentor06nov
ORDER BY submitted_at
LIMIT 10;


-- ============================================================
-- SECTION 2: OVERALL USER PERFORMANCE SUMMARY
-- ============================================================

-- 2.1 Total Points, Submissions, and Unique Questions per User
SELECT 
    user_id,
    username,
    COUNT(*)                                        AS total_submissions,
    COUNT(DISTINCT question_id)                     AS unique_questions_attempted,
    SUM(points)                                     AS total_points,
    ROUND(AVG(points), 2)                           AS avg_points_per_submission,
    SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END)    AS correct_submissions,
    SUM(CASE WHEN points <= 0 THEN 1 ELSE 0 END)   AS incorrect_submissions
FROM user_sub_sql_mentor06nov
GROUP BY user_id, username
ORDER BY total_points DESC;

-- 2.2 Accuracy Rate per User
SELECT 
    user_id,
    username,
    COUNT(*)                                                            AS total_submissions,
    SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END)                       AS correct_submissions,
    ROUND(
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                                                   AS accuracy_rate_pct
FROM user_sub_sql_mentor06nov
GROUP BY user_id, username
ORDER BY accuracy_rate_pct DESC;


-- ============================================================
-- SECTION 3: DAILY ACTIVITY ANALYSIS
-- ============================================================

-- 3.1 Daily Submissions per User
SELECT 
    user_id,
    username,
    submitted_at::DATE                              AS submission_date,
    COUNT(*)                                        AS daily_submissions,
    SUM(points)                                     AS daily_points
FROM user_sub_sql_mentor06nov
GROUP BY user_id, username, submitted_at::DATE
ORDER BY username, submission_date;

-- 3.2 Most Active Day (Overall)
SELECT 
    submitted_at::DATE                              AS submission_date,
    COUNT(*)                                        AS total_submissions,
    COUNT(DISTINCT user_id)                         AS active_users,
    SUM(points)                                     AS total_points_earned
FROM user_sub_sql_mentor06nov
GROUP BY submitted_at::DATE
ORDER BY total_submissions DESC;


-- ============================================================
-- SECTION 4: STREAK ANALYSIS
-- ============================================================

-- 4.1 Consecutive Active Days Streak per User (Current/Best Streak)
WITH daily_active AS (
    -- Get distinct active dates per user
    SELECT 
        user_id,
        username,
        submitted_at::DATE AS activity_date
    FROM user_sub_sql_mentor06nov
    GROUP BY user_id, username, submitted_at::DATE
),
date_groups AS (
    -- Assign group number to detect consecutive days
    SELECT 
        user_id,
        username,
        activity_date,
        activity_date - ROW_NUMBER() OVER (
            PARTITION BY user_id ORDER BY activity_date
        )::INTEGER AS grp
    FROM daily_active
),
streaks AS (
    SELECT 
        user_id,
        username,
        grp,
        MIN(activity_date)  AS streak_start,
        MAX(activity_date)  AS streak_end,
        COUNT(*)            AS streak_length
    FROM date_groups
    GROUP BY user_id, username, grp
)
SELECT 
    user_id,
    username,
    MAX(streak_length)  AS longest_streak_days,
    MIN(streak_start)   AS first_activity_date,
    MAX(streak_end)     AS last_activity_date
FROM streaks
GROUP BY user_id, username
ORDER BY longest_streak_days DESC;


-- ============================================================
-- SECTION 5: QUESTION-LEVEL ANALYSIS
-- ============================================================

-- 5.1 Most Attempted Questions
SELECT 
    question_id,
    COUNT(*)                                        AS total_attempts,
    COUNT(DISTINCT user_id)                         AS users_attempted,
    ROUND(AVG(points), 2)                           AS avg_points,
    SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END)    AS correct_attempts,
    SUM(CASE WHEN points <= 0 THEN 1 ELSE 0 END)   AS incorrect_attempts,
    ROUND(
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                               AS question_accuracy_pct
FROM user_sub_sql_mentor06nov
GROUP BY question_id
ORDER BY total_attempts DESC
LIMIT 20;

-- 5.2 Hardest Questions (Lowest Accuracy)
SELECT 
    question_id,
    COUNT(*)                                        AS total_attempts,
    ROUND(
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                               AS accuracy_pct,
    ROUND(AVG(points), 2)                           AS avg_points
FROM user_sub_sql_mentor06nov
GROUP BY question_id
HAVING COUNT(*) >= 3           -- At least 3 attempts
ORDER BY accuracy_pct ASC
LIMIT 10;

-- 5.3 Easiest Questions (Highest Accuracy with multiple attempts)
SELECT 
    question_id,
    COUNT(*)                                        AS total_attempts,
    ROUND(
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                               AS accuracy_pct,
    ROUND(AVG(points), 2)                           AS avg_points
FROM user_sub_sql_mentor06nov
GROUP BY question_id
HAVING COUNT(*) >= 3
ORDER BY accuracy_pct DESC
LIMIT 10;


-- ============================================================
-- SECTION 6: RETRY BEHAVIOR ANALYSIS
-- ============================================================

-- 6.1 Users Who Retried the Same Question (Persistence Metric)
SELECT 
    user_id,
    username,
    question_id,
    COUNT(*)            AS attempt_count,
    MIN(points)         AS worst_score,
    MAX(points)         AS best_score,
    SUM(points)         AS total_points_on_question,
    CASE 
        WHEN MIN(points) <= 0 AND MAX(points) > 0 THEN 'Recovered'
        WHEN MAX(points) <= 0 THEN 'Still Struggling'
        ELSE 'Correct on Retry'
    END                 AS retry_outcome
FROM user_sub_sql_mentor06nov
GROUP BY user_id, username, question_id
HAVING COUNT(*) > 1
ORDER BY attempt_count DESC;

-- 6.2 Retry Success Rate per User
WITH retry_data AS (
    SELECT 
        user_id,
        username,
        question_id,
        COUNT(*)                                                    AS attempts,
        MAX(CASE WHEN points > 0 THEN 1 ELSE 0 END)                AS eventually_correct
    FROM user_sub_sql_mentor06nov
    GROUP BY user_id, username, question_id
    HAVING COUNT(*) > 1
)
SELECT 
    user_id,
    username,
    COUNT(*)                                                AS retried_questions,
    SUM(eventually_correct)                                 AS recovered_questions,
    ROUND(SUM(eventually_correct) * 100.0 / COUNT(*), 2)   AS retry_success_rate_pct
FROM retry_data
GROUP BY user_id, username
ORDER BY retry_success_rate_pct DESC;


-- ============================================================
-- SECTION 7: PERFORMANCE RANKING & LEADERBOARD
-- ============================================================

-- 7.1 Overall Leaderboard
SELECT 
    RANK() OVER (ORDER BY SUM(points) DESC)         AS rank,
    user_id,
    username,
    COUNT(*)                                        AS total_submissions,
    COUNT(DISTINCT question_id)                     AS unique_questions,
    SUM(points)                                     AS total_points,
    ROUND(AVG(points), 2)                           AS avg_points,
    SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END)    AS correct_answers,
    ROUND(
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                               AS accuracy_pct
FROM user_sub_sql_mentor06nov
GROUP BY user_id, username
ORDER BY rank;

-- 7.2 Daily Leaderboard (Top User Each Day)
WITH daily_points AS (
    SELECT 
        submitted_at::DATE  AS submission_date,
        user_id,
        username,
        SUM(points)         AS daily_points,
        COUNT(*)            AS daily_submissions
    FROM user_sub_sql_mentor06nov
    GROUP BY submitted_at::DATE, user_id, username
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY submission_date ORDER BY daily_points DESC) AS daily_rank
    FROM daily_points
)
SELECT *
FROM ranked
WHERE daily_rank = 1
ORDER BY submission_date;


-- ============================================================
-- SECTION 8: POINT CATEGORY BREAKDOWN
-- ============================================================

-- 8.1 Points Distribution by Bucket
SELECT 
    CASE 
        WHEN points < 0    THEN 'Penalty (< 0)'
        WHEN points = 0    THEN 'Zero (0)'
        WHEN points <= 60  THEN 'Low (1–60)'
        WHEN points <= 100 THEN 'Medium (61–100)'
        WHEN points <= 130 THEN 'High (101–130)'
        ELSE                    'Very High (> 130)'
    END                     AS points_bucket,
    COUNT(*)                AS submission_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM user_sub_sql_mentor06nov
GROUP BY points_bucket
ORDER BY MIN(points);

-- 8.2 Per User Point Category Distribution
SELECT 
    username,
    SUM(CASE WHEN points < 0   THEN 1 ELSE 0 END)  AS penalty_count,
    SUM(CASE WHEN points = 0   THEN 1 ELSE 0 END)  AS zero_count,
    SUM(CASE WHEN points > 0 AND points <= 60  THEN 1 ELSE 0 END) AS low_score_count,
    SUM(CASE WHEN points > 60 AND points <= 100 THEN 1 ELSE 0 END) AS medium_score_count,
    SUM(CASE WHEN points > 100 THEN 1 ELSE 0 END)  AS high_score_count
FROM user_sub_sql_mentor06nov
GROUP BY username
ORDER BY username;


-- ============================================================
-- SECTION 9: HOURLY ACTIVITY PATTERN
-- ============================================================

-- 9.1 Submissions by Hour of Day
SELECT 
    EXTRACT(HOUR FROM submitted_at AT TIME ZONE 'Asia/Kolkata')    AS hour_of_day,
    COUNT(*)                                                        AS total_submissions,
    COUNT(DISTINCT user_id)                                         AS active_users,
    SUM(points)                                                     AS total_points
FROM user_sub_sql_mentor06nov
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 9.2 Peak Activity Window (Top 5 Hours)
SELECT 
    EXTRACT(HOUR FROM submitted_at AT TIME ZONE 'Asia/Kolkata')    AS hour_of_day,
    COUNT(*)                                                        AS submissions
FROM user_sub_sql_mentor06nov
GROUP BY hour_of_day
ORDER BY submissions DESC
LIMIT 5;


-- ============================================================
-- SECTION 10: USER IMPROVEMENT OVER TIME
-- ============================================================

-- 10.1 Rolling 3-Day Average Points per User
WITH daily_user_points AS (
    SELECT 
        user_id,
        username,
        submitted_at::DATE      AS activity_date,
        SUM(points)             AS daily_points
    FROM user_sub_sql_mentor06nov
    GROUP BY user_id, username, submitted_at::DATE
)
SELECT 
    user_id,
    username,
    activity_date,
    daily_points,
    ROUND(AVG(daily_points) OVER (
        PARTITION BY user_id 
        ORDER BY activity_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                       AS rolling_3day_avg
FROM daily_user_points
ORDER BY username, activity_date;

-- 10.2 First vs Last Day Performance Comparison per User
WITH first_last AS (
    SELECT 
        user_id,
        username,
        submitted_at::DATE AS activity_date,
        SUM(points) AS daily_points,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY submitted_at::DATE ASC)  AS rn_asc,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY submitted_at::DATE DESC) AS rn_desc
    FROM user_sub_sql_mentor06nov
    GROUP BY user_id, username, submitted_at::DATE
)
SELECT 
    f.user_id,
    f.username,
    f.activity_date                                     AS first_day,
    f.daily_points                                      AS first_day_points,
    l.activity_date                                     AS last_day,
    l.daily_points                                      AS last_day_points,
    (l.daily_points - f.daily_points)                  AS points_improvement,
    CASE 
        WHEN l.daily_points > f.daily_points THEN '📈 Improving'
        WHEN l.daily_points < f.daily_points THEN '📉 Declining'
        ELSE '➡️ Stable'
    END                                                 AS trend
FROM first_last f
JOIN first_last l ON f.user_id = l.user_id AND l.rn_desc = 1
WHERE f.rn_asc = 1
ORDER BY points_improvement DESC;


-- ============================================================
-- SECTION 11: BADGES / ACHIEVEMENT CLASSIFICATION
-- ============================================================

-- 11.1 Assign Achievement Badge to Each User Based on Performance
WITH user_stats AS (
    SELECT 
        user_id,
        username,
        COUNT(*)                                        AS total_submissions,
        COUNT(DISTINCT question_id)                     AS unique_questions,
        SUM(points)                                     AS total_points,
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END)    AS correct_count,
        ROUND(
            SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
        )                                               AS accuracy_pct
    FROM user_sub_sql_mentor06nov
    GROUP BY user_id, username
)
SELECT 
    user_id,
    username,
    total_submissions,
    unique_questions,
    total_points,
    accuracy_pct,
    CASE 
        WHEN total_points >= 2000 AND accuracy_pct >= 80 THEN '🥇 SQL Champion'
        WHEN total_points >= 1000 AND accuracy_pct >= 70 THEN '🥈 Advanced Learner'
        WHEN total_points >= 500  AND accuracy_pct >= 60 THEN '🥉 Intermediate Coder'
        WHEN total_points >= 100                          THEN '🔰 Beginner'
        ELSE                                                   '🌱 Just Started'
    END AS badge
FROM user_stats
ORDER BY total_points DESC;
