-- +goose Up

CREATE INDEX idx_user_food_date ON user_food_metric (user_id, date);
CREATE INDEX idx_user_bowel_date ON user_bowel_metric (user_id, date);
CREATE INDEX idx_user_symptom_date ON user_symptoms_metric (user_id, date);
CREATE INDEX idx_user_food_tags ON user_food_metric USING GIN(breakfast_tags, lunch_tags, dinner_tags, snack_tags);

-- +goose Down