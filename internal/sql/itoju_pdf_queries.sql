-- ----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- Foods eaten in the last 24 hours
select * from user_food_metric f
where f.date > now() - interval '24 hours';

select * from users;

with meals as
(
select b.user_id, b.date, 'Breakfast' as meal_type, b.breakfast_meal as meal 
from user_food_metric b
union all
select l.user_id, l.date, 'Lunch' as meal_type, l.lunch_meal as meal 
from user_food_metric l
union all
select d.user_id, d.date, 'Dinner' as meal_type, d.dinner_meal as meal 
from user_food_metric d
)
select u.first_name || ' ' || u.last_name as User, 
meals.date,
meals.meal_type,
meals.meal
from users u
join meals on u.id = meals.user_id
where meals.date > now() - interval '24 hours';


-- Foods eaten in the last 30 days
with meals as
(
select b.user_id, b.date, 'Breakfast' as meal_type, b.breakfast_meal as meal 
from user_food_metric b
union all
select l.user_id, l.date, 'Lunch' as meal_type, l.lunch_meal as meal 
from user_food_metric l
union all
select d.user_id, d.date, 'Dinner' as meal_type, d.dinner_meal as meal 
from user_food_metric d
)
select u.first_name || ' ' || u.last_name as User, 
meals.date,
meals.meal_type,
meals.meal
from users u
join meals on u.id = meals.user_id
where meals.date > now() - interval '30 days'
and meals.meal <> ''
order by User, meals.date;


-- Analysis of Gluten intake in the last 24 hours
with meals as
(
SELECT b.user_id, b.date, b.breakfast_tags, trim(both '"' 
            FROM unnest(string_to_array(replace
                                        (replace
                                         (replace
                                          (replace(b.breakfast_tags, '[', ''), ']', ''),'{',''),'}',''), ','))) AS tag
FROM user_food_metric b   
union all
SELECT l.user_id, l.date, l.lunch_tags, trim(both '"' 
            FROM unnest(string_to_array(replace
                                        (replace
                                         (replace
                                          (replace(l.lunch_tags, '[', ''), ']', ''),'{',''),'}',''), ','))) AS tag
FROM user_food_metric l
union all
SELECT d.user_id, d.date, d.dinner_tags, trim(both '"' 
            FROM unnest(string_to_array(replace
                                        (replace
                                         (replace
                                          (replace(d.dinner_tags, '[', ''), ']', ''),'{',''),'}',''), ','))) AS tag
FROM user_food_metric d
)
select u.first_name || ' ' || u.last_name as User, 
meals.date,
count(tag) as FrequencyOfGlutenIntake
from users u
join meals on u.id = meals.user_id
where meals.date > now() - interval '24 hours'
and meals.tag = 'Gluten'
group by u.first_name || ' ' || u.last_name, meals.date;




-- Analysis of Dairy intake in the last 24 hours
with meals as
(
SELECT b.user_id, b.date, b.breakfast_tags, trim(both '"' 
            FROM unnest(string_to_array(replace
                                        (replace
                                         (replace
                                          (replace(b.breakfast_tags, '[', ''), ']', ''),'{',''),'}',''), ','))) AS tag
FROM user_food_metric b   
union all
SELECT l.user_id, l.date, l.lunch_tags, trim(both '"' 
            FROM unnest(string_to_array(replace
                                        (replace
                                         (replace
                                          (replace(l.lunch_tags, '[', ''), ']', ''),'{',''),'}',''), ','))) AS tag
FROM user_food_metric l
union all
SELECT d.user_id, d.date, d.dinner_tags, trim(both '"' 
            FROM unnest(string_to_array(replace
                                        (replace
                                         (replace
                                          (replace(d.dinner_tags, '[', ''), ']', ''),'{',''),'}',''), ','))) AS tag
FROM user_food_metric d
)
select u.first_name || ' ' || u.last_name as User, 
meals.date,
count(tag) as FrequencyOfDairyIntake
from users u
join meals on u.id = meals.user_id
where meals.date > now() - interval '24 hours'
and meals.tag = 'Dairy'
group by u.first_name || ' ' || u.last_name, meals.date;


-- Frequency of bowel movement
select u.first_name || ' ' || u.last_name as User, 
user_bowel_metric.date,
count(user_bowel_metric.id) as Frequency
from users u
join user_bowel_metric on u.id = user_bowel_metric.user_id
where user_bowel_metric.date > now() - interval '30 days'
group by u.first_name || ' ' || u.last_name, user_bowel_metric.date;

-- Frequency of bowel movement by type
select u.first_name || ' ' || u.last_name as User, 
user_bowel_metric.date,
count(case when user_bowel_metric.type = 1 then user_bowel_metric.id else null end) as Frequency_Type1,
count(case when user_bowel_metric.type = 2 then user_bowel_metric.id else null end) as Frequency_Type2,
count(case when user_bowel_metric.type = 3 then user_bowel_metric.id else null end) as Frequency_Type3,
count(case when user_bowel_metric.type = 4 then user_bowel_metric.id else null end) as Frequency_Type4,
count(case when user_bowel_metric.type = 5 then user_bowel_metric.id else null end) as Frequency_Type5,
count(case when user_bowel_metric.type = 6 then user_bowel_metric.id else null end) as Frequency_Type6,
count(case when user_bowel_metric.type = 7 then user_bowel_metric.id else null end) as Frequency_Type7
from users u
join user_bowel_metric on u.id = user_bowel_metric.user_id
where user_bowel_metric.date > now() - interval '30 days'
group by u.first_name || ' ' || u.last_name, user_bowel_metric.date;


-- Frequency of symptoms
select u.first_name || ' ' || u.last_name as User, 
user_symptoms_metric.date,
symptoms.name,
user_symptoms_metric.morning_severity,
user_symptoms_metric.afternoon_severity,
user_symptoms_metric.night_severity
from users u
join user_symptoms_metric on u.id = user_symptoms_metric.user_id
join symptoms on user_symptoms_metric.symptoms_id = symptoms.id
where user_symptoms_metric.date > now() - interval '30 days'
order by u.first_name || ' ' || u.last_name, user_symptoms_metric.date;


-- foods eaten 24 hours or less before symptoms
select u.first_name || ' ' || u.last_name as User, 
user_symptoms_metric.date as symptom_date,
user_food_metric.date as food_date,
symptoms.name as symptom,
user_symptoms_metric.morning_severity,
user_symptoms_metric.afternoon_severity,
user_symptoms_metric.night_severity,
user_food_metric.breakfast_meal,
user_food_metric.lunch_meal,
user_food_metric.dinner_meal,
user_food_metric.snack_name
from users u
join user_symptoms_metric on u.id = user_symptoms_metric.user_id
join symptoms on user_symptoms_metric.symptoms_id = symptoms.id
join user_food_metric on user_symptoms_metric.user_id = user_food_metric.user_id
	and user_symptoms_metric.date between user_food_metric.date and user_food_metric.date + interval '24 hours'
where user_symptoms_metric.date > now() - interval '30 days'
order by u.first_name || ' ' || u.last_name, user_symptoms_metric.date;



-- foods eaten 6 or less hours before a painful bowel movement or bowel movement from 6 and above










