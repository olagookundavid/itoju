-- ===========================================================
-- 🎯 SINGLE QUERY FOR ALL ANALYTICS (Call this once)
-- ===========================================================
WITH user_data AS (
  SELECT 
    u.id as user_id,
    concat(u.first_name, ' ', u.last_name) as user_name,
    CURRENT_DATE - INTERVAL '30 days' as report_start,
    CURRENT_DATE as report_end
  FROM users u
  WHERE u.id = $1  -- parameter for specific user
),
food_meals AS (
  -- All meals in last 30 days
  SELECT 
    user_id, date, 
    'Breakfast' as meal_type, breakfast_meal as meal
  FROM user_food_metric 
  WHERE user_id = (SELECT user_id FROM user_data) 
    AND date >= (SELECT report_start FROM user_data)
    AND coalesce(breakfast_meal, '') <> ''
  UNION ALL 
  SELECT user_id, date, 'Lunch', lunch_meal 
  FROM user_food_metric 
  WHERE user_id = (SELECT user_id FROM user_data) 
    AND date >= (SELECT report_start FROM user_data) 
    AND coalesce(lunch_meal, '') <> ''
  UNION ALL 
  SELECT user_id, date, 'Dinner', dinner_meal 
  FROM user_food_metric 
  WHERE user_id = (SELECT user_id FROM user_data) 
    AND date >= (SELECT report_start FROM user_data) 
    AND coalesce(dinner_meal, '') <> ''
  UNION ALL 
  SELECT user_id, date, 'Snack', snack_name 
  FROM user_food_metric 
  WHERE user_id = (SELECT user_id FROM user_data) 
    AND date >= (SELECT report_start FROM user_data) 
    AND coalesce(snack_name, '') <> ''
),
food_tags AS (
  -- All food tags in last 30 days
  SELECT user_id, date, unnest(breakfast_tags) as tag 
  FROM user_food_metric 
  WHERE user_id = (SELECT user_id FROM user_data) 
    AND date >= (SELECT report_start FROM user_data)
    AND array_length(breakfast_tags, 1) > 0
  UNION ALL 
  SELECT user_id, date, unnest(lunch_tags) 
  FROM user_food_metric 
  WHERE user_id = (SELECT user_id FROM user_data) 
    AND date >= (SELECT report_start FROM user_data)
    AND array_length(lunch_tags, 1) > 0
  UNION ALL 
  SELECT user_id, date, unnest(dinner_tags) 
  FROM user_food_metric 
  WHERE user_id = (SELECT user_id FROM user_data) 
    AND date >= (SELECT report_start FROM user_data)
    AND array_length(dinner_tags, 1) > 0
  UNION ALL 
  SELECT user_id, date, unnest(snack_tags) 
  FROM user_food_metric 
  WHERE user_id = (SELECT user_id FROM user_data) 
    AND date >= (SELECT report_start FROM user_data)
    AND array_length(snack_tags, 1) > 0
),
symptom_days AS (
  -- Days with symptoms (using average severity per day)
  SELECT user_id, date, symptoms_id,
         (morning_severity + afternoon_severity + night_severity) / 3 as avg_daily_severity,
         (morning_severity + afternoon_severity + night_severity) as total_daily_severity
  FROM user_symptoms_metric 
  WHERE user_id = (SELECT user_id FROM user_data) 
    AND date >= (SELECT report_start FROM user_data)
)
SELECT 
  -- User Info
  ud.user_name,
  ud.report_start,
  ud.report_end,
  
  -- Food Analytics (Last 30 days)
  (SELECT COUNT(DISTINCT date) FROM food_meals) as days_with_food_logs,
  (SELECT COUNT(*) FROM food_meals) as total_meals_logged,
  (SELECT json_agg(fm) FROM (
    SELECT date, meal_type, meal 
    FROM food_meals 
    ORDER BY date DESC, 
      CASE meal_type 
        WHEN 'Breakfast' THEN 1 
        WHEN 'Lunch' THEN 2 
        WHEN 'Dinner' THEN 3 
        WHEN 'Snack' THEN 4 
      END
    LIMIT 10
  ) fm) as recent_meals,
  
  -- Gluten/Dairy Intake
  (SELECT COUNT(DISTINCT date) FROM food_tags WHERE tag = 'Gluten') as gluten_days,
  (SELECT COUNT(*) FROM food_tags WHERE tag = 'Gluten') as gluten_frequency,
  (SELECT COUNT(DISTINCT date) FROM food_tags WHERE tag = 'Dairy') as dairy_days,
  (SELECT COUNT(*) FROM food_tags WHERE tag = 'Dairy') as dairy_frequency,
  
  -- Bowel Analytics
  (SELECT COUNT(*) 
   FROM user_bowel_metric 
   WHERE user_id = ud.user_id AND date >= ud.report_start) as total_bowel_movements,
  (SELECT COALESCE(ROUND(AVG(type), 1), 0) 
   FROM user_bowel_metric 
   WHERE user_id = ud.user_id AND date >= ud.report_start) as avg_stool_type,
  (SELECT COALESCE(ROUND(AVG(pain), 1), 0) 
   FROM user_bowel_metric 
   WHERE user_id = ud.user_id AND date >= ud.report_start) as avg_pain_level,
  (SELECT json_agg(bm) FROM (
    SELECT date, type, pain, time
    FROM user_bowel_metric 
    WHERE user_id = ud.user_id AND date >= ud.report_start 
    ORDER BY date DESC, time DESC 
    LIMIT 7
  ) bm) as recent_bowel_movements,
  
  -- Symptom Analytics
  (SELECT COUNT(DISTINCT date) FROM symptom_days) as days_with_symptoms,
  (SELECT COALESCE(ROUND(AVG(avg_daily_severity), 2), 0) 
   FROM symptom_days) as avg_daily_symptom_severity,
  (SELECT json_agg(sm) FROM (
    SELECT s.name as symptom, 
           ROUND(AVG((usm.morning_severity + usm.afternoon_severity + usm.night_severity) / 3), 2) as avg_severity,
           COUNT(DISTINCT usm.date) as days_reported
    FROM user_symptoms_metric usm
    JOIN symptoms s ON usm.symptoms_id = s.id
    WHERE usm.user_id = ud.user_id AND usm.date >= ud.report_start
    GROUP BY s.name
    ORDER BY avg_severity DESC
    LIMIT 5
  ) sm) as top_symptoms,
  
  -- Food-Symptom Correlations (CORRECTED: foods eaten BEFORE symptoms)
  (SELECT COUNT(DISTINCT sd.date)
   FROM symptom_days sd
   WHERE EXISTS (
     SELECT 1 FROM food_tags ft
     WHERE ft.user_id = sd.user_id 
       AND ft.tag IN ('Gluten', 'Dairy')
       AND ft.date BETWEEN sd.date - INTERVAL '1 day' AND sd.date
   )
   AND sd.avg_daily_severity > 0.5) as symptom_days_after_common_triggers,
   
  -- Recent Timeline (Last 7 days)
  (SELECT json_agg(timeline) FROM (
    SELECT 
      d.date,
      -- Food
      EXISTS(SELECT 1 FROM user_food_metric WHERE user_id = ud.user_id AND date = d.date AND coalesce(breakfast_meal, '') <> '') as had_breakfast,
      EXISTS(SELECT 1 FROM user_food_metric WHERE user_id = ud.user_id AND date = d.date AND coalesce(lunch_meal, '') <> '') as had_lunch,
      EXISTS(SELECT 1 FROM user_food_metric WHERE user_id = ud.user_id AND date = d.date AND coalesce(dinner_meal, '') <> '') as had_dinner,
      -- Bowel
      (SELECT COUNT(*) FROM user_bowel_metric WHERE user_id = ud.user_id AND date = d.date) as bowel_count,
      (SELECT COALESCE(ROUND(AVG(type), 1), 0) FROM user_bowel_metric WHERE user_id = ud.user_id AND date = d.date) as avg_stool_type,
      -- Symptoms
      (SELECT COALESCE(ROUND(AVG((morning_severity + afternoon_severity + night_severity) / 3), 2), 0)
       FROM user_symptoms_metric WHERE user_id = ud.user_id AND date = d.date) as avg_symptom_severity,
      (SELECT COUNT(DISTINCT symptoms_id) FROM user_symptoms_metric WHERE user_id = ud.user_id AND date = d.date) as symptom_count
    FROM generate_series(
      CURRENT_DATE - INTERVAL '6 days', 
      CURRENT_DATE, 
      '1 day'::interval
    )::date as d
    ORDER BY d.date DESC
  ) timeline) as last_7_days_timeline

FROM user_data ud;