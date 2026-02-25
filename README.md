
  <img width="1536" height="1024" alt="SQL project" src="https://github.com/user-attachments/assets/bf92cd08-c934-4dd1-847f-f921e848f782" />

  # SQL Mentor — User Performance Analysis (SQL + Power BI)
  
## 📊 Executive Summary

This project analyzes SQL practice platform submission data using PostgreSQL to measure user performance, engagement, and learning trends.  
I designed a clean analytics schema, built advanced SQL views (ranking, streaks, rolling metrics), and transformed raw logs into actionable insights.  
A Power BI dashboard visualizes performance KPIs, leaderboards, and question difficulty to simulate a real EdTech analytics system.
   

## 📌 Goals
- Build a clean analytics dataset from raw submission logs
- Measure user performance: points, attempts, unique questions, trends
- Identify engagement patterns: active users, streaks, momentum
- Create a Power BI dashboard for stakeholder-friendly insights

## 🧱 Dataset
Source file: `data/user_sub_sql_mentor06nov.csv`

### 📂 Dataset Description File: `user_sub_sql_mentor06nov.csv`

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | INTEGER | Unique submission record ID |
| `user_id` | BIGINT | Unique identifier for each user |
| `question_id` | INTEGER | Identifier of the question attempted |
| `points` | INTEGER | Points earned (negative = penalty, 0 = no score, positive = correct) |
| `submitted_at` | TIMESTAMP WITH TZ | Submission timestamp (IST, UTC+5:30) |
| `username` | VARCHAR | Display name of the user |


Columns:
- `id` (submission id)
- `user_id`
- `username`
- `question_id`
- `points` (can be negative)
- `submitted_at` (timestamp with timezone offset)
  
**Dataset Stats**

📅 Date Range: Oct 26 – Nov 6, 2024
👥 Total Users: 30+
📝 Total Submissions: 650+
❓ Unique Questions: 300+


**🔍 Analysis Modules**
1️⃣ Data Exploration & Overview

Record counts, date range, distinct users and questions
Sample data preview

2️⃣ Overall User Performance Summary

Total points, submissions, and unique questions per user
Accuracy rate (correct vs total submissions)

3️⃣ Daily Activity Analysis

Daily submissions and points per user
Most active days across the platform

4️⃣ Streak Analysis 🔥
Using window functions and date arithmetic to identify:

Longest consecutive active days per user
First and last activity dates

5️⃣ Question-Level Analysis

Most attempted questions
Hardest questions (lowest accuracy with ≥3 attempts)
Easiest questions (highest accuracy with ≥3 attempts)

6️⃣ Retry Behavior Analysis

Users who retried the same question
Retry outcome classification: Recovered, Still Struggling, Correct on Retry
Retry success rate per user

7️⃣ Performance Ranking & Leaderboard

Overall leaderboard with RANK() window function
Daily leaderboard — top user each day

8️⃣ Point Category Breakdown

Points bucketed into Penalty / Zero / Low / Medium / High / Very High
Per-user distribution across buckets

9️⃣ Hourly Activity Pattern

Submissions grouped by hour of day (IST)
Peak activity hours identified

🔟 User Improvement Over Time

Rolling 3-day average points using ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
First vs Last day performance comparison with trend classification

**1️⃣1️⃣ Achievement Badge System 🏅**
Users classified into badges based on total points + accuracy:
BadgeCriteria🥇 SQL ChampionPoints ≥ 2000 & Accuracy ≥ 80%🥈 Advanced LearnerPoints ≥ 1000 & Accuracy ≥ 70%🥉 Intermediate CoderPoints ≥ 500 & Accuracy ≥ 60%🔰 BeginnerPoints ≥ 100🌱 Just StartedPoints < 100

**💡 Key Insights**

najir_11320 consistently tops the leaderboard with the highest total points and longest active streak.
Retry behavior reveals that most users who retry a failed question eventually succeed — showing platform effectiveness.
Peak activity hours fall between 9 PM – 12 AM IST, indicating learners primarily practice in the evening.
Several questions show a 0% first-attempt accuracy but high retry success, indicating they are well-designed challenge problems.
mansi6806 shows the steepest improvement curve across days — rising from beginner to advanced tier.

**🔍 What I discovered**

✅ Leaderboard Kings: Top performers like bhavin0952 and najir_11320 are setting the pace with over 4,000 points!
✅ Engagement Spikes: Activity peaked on November 3rd, showing a massive surge in weekend learning.
✅ The "Hard" Truth: By analyzing average points, I identified the toughest SQL questions that are causing the most trouble for students (Question IDs 199 & 209).

## ✅ Key Metrics
**User-level**
- Total points, total submissions
- Unique questions attempted
- Avg points per submission
- Negative submission count
- First/last activity + active span
-
- ## 🧪 How to Run (PostgreSQL)
1. Create a database (example: `sql_mentor`)
2. Run:
   - `sql/01_schema.sql`
   - `sql/02_load.sql`
   - `sql/03_cleaning.sql`
   - `sql/04_analysis_views.sql`
   - `sql/05_ad_hoc_analysis.sql`

> Tip: Use `psql` and `\copy` for reliable CSV loading.

## 📊 Power BI
Two options:
1) Import CSV directly  
2) (Recommended) Connect to PostgreSQL and load these views:
- `vw_user_summary`
- `vw_user_daily`
- `vw_question_stats`
- `vw_user_best_streak`

**Dashboard pages**
- Overview (KPIs + trends + leaderboard)
- User Deep Dive (filter by username)
- Question Insights (attempts + negative rates)

## 🔎 Example Insights
- Who are the top learners by total points?
- Which users attempt many questions but score low (needs mentoring)?
- Which questions generate the most negative points (hard/confusing)?
- Who has the strongest learning streak?
 Best streak (consecutive active days)

**Question-level**
- Attempts, unique users
- Avg/median points
- Negative attempt rate (difficulty proxy)

  ## 🛠 Tech Stack
- PostgreSQL (schema, cleaning, analytics views)
- SQL (window functions, streak logic, rolling aggregates)
- Power BI (dashboard + DAX measures)
- pgAdmin / DBeaverQuery (execution & result visualization)
- CSV / Excel (Data input and output review)

  **👤 Author**
   Sarah Sasir
Data Analyst | SQL Enthusiast
📧 sarahsair@gmail.com
