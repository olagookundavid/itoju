/// Seed data for the local catalog tables. The ids MUST equal the server SERIAL
/// ids (insertion order in the backend migrations 003/004/006/007), because
/// synced rows reference these ids (symptoms_id, metric_id, smiley_id,
/// conditions_id). Verify against production before shipping; never re-seed
/// destructively (guard with SyncMeta 'catalogSeedVersion').
///
/// Source of truth:
///   symptoms   → 006_create_symptoms_table.sql
///   smiley     → 004_create_smiley_table.sql
///   metrics    → 003_create_tracked_metrics_table.sql
///   conditions → 007_create_conditions_table.sql
library;

/// name-by-id, id = index + 1.
const List<String> kSymptomsSeed = [
  'Abdominal Pain (Left)',
  'Abdominal Pain (Lower)',
  'Abdominal Pain (Right)',
  'Abdominal Pain (Upper)',
  'Acne',
  'Back Pain (Lower)',
  'Back Pain (Upper)',
  'Bleeding',
  'Bloating',
  'Chest Pain',
  'Cold & Catarrh',
  'Constipation',
  'Cough',
  'Diarrhea',
  'Earache',
  'Eczema',
  'Eye Pain',
  'Fatigue',
  'Fever',
  'Flu',
  'Headache',
  'Indigestion',
  'Insomnia',
  'Joint Pain',
  'Knee Pain',
  'Leg Pain',
  'Loss of Smell',
  'Loss of Taste',
  'Menstrual Pain (Just Before & During)',
  'Migraine',
  'Mouth Sores',
  'Muscle Pain',
  'Nausea',
  'Neck Pain',
  'Pain During Bowel Movements',
  'Pain During Sex',
  'Pain During Urination',
  'Piles',
  'Rectal bleeding',
  'Sciatica',
  'Seizure',
  'Shortness of Breath',
  'Shoulder Pain (Left)',
  'Shoulder Pain (Right)',
  'Sore Throat',
  'Stomach Cramps',
  'Tinnitus',
  'Toothache',
  'Under-rib Pain',
  'Vertigo',
  'Vomiting',
];

const List<String> kSmileySeed = [
  'Very Good',
  'Good',
  'Mild',
  'Bad',
  'Very Bad',
];

const List<String> kTrackedMetricsSeed = [
  'Food Diary',
  'Symptoms',
  'Sleep',
  'Menstruation and Ovulation',
  'Bowel Movements',
  'Medications',
  'Urination',
  'Exercise',
];

const List<String> kConditionsSeed = [
  'Premenstrual syndrome (PMS)',
  'Ovarian cysts',
  'Endometriosis',
  'Uterine fibroids',
  'Polycystic ovarian syndrome (PCOS)',
  'Adenomyosis',
  'Urinary Incontinence',
  'Infertility',
  'Uterine Prolapse',
  'Cervical Cancer',
  'Ovarian Cancer',
  'Endometrial cancer',
  'Fibromyalgia',
  'Interstitial cystitis',
  'Dysmenorrhea (Painful periods)',
  'Amenorrhea (Absence of periods)',
  'Vaginismus',
  'Pelvic Inflammatory Disease',
  'Vulvodynia',
  'Menopause',
  'Vaginitis',
];
