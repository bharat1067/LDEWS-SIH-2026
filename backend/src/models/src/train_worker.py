import os
import pandas as pd
import psycopg2
import warnings
import joblib
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier, VotingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import MultiLabelBinarizer, LabelEncoder
from xgboost import XGBClassifier

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
warnings.filterwarnings('ignore')

def get_db_connection():
    # Try connecting to the local system DB first, then fallback to Docker on 5433
    try:
        print("Attempting to connect to PostgreSQL on port 5432...")
        conn = psycopg2.connect(dbname="sih_db", user="parag", password="parag", host="localhost", port="5432")
    except psycopg2.Error:
        print("Failed on 5432. Attempting to connect on port 5433 (Docker)...")
        conn = psycopg2.connect(dbname="sih_db", user="parag", password="parag", host="localhost", port="5433")
    return conn

def train_and_save_model():
    print("--- STARTING BACKGROUND TRAINING WORKER ---")
    conn = get_db_connection()
    
    # 1. Fetch Data
    print("Loading data from database...")
    df_field_reports = pd.read_sql_query('SELECT * FROM field_reports;', conn)
    df_lab_reports = pd.read_sql_query('SELECT * FROM lab_reports;', conn)
    df_vet_verifs = pd.read_sql_query('SELECT * FROM vet_verifications;', conn)
    df_diseases = pd.read_sql_query('SELECT * FROM diseases;', conn)
    df_symptoms = pd.read_sql_query('SELECT * FROM symptoms;', conn)
    df_species = pd.read_sql_query('SELECT * FROM species;', conn)
    # Fetch vaccination data: one row per (animal_tag, disease) where is_current=TRUE
    df_vacc = pd.read_sql_query(
        'SELECT animal_tag_id, animal_species, disease_protected_id FROM vaccination_records WHERE is_current = TRUE;',
        conn
    )
    conn.close()

    # 2. Join for Ground Truth
    df_dataset = pd.merge(df_field_reports, df_lab_reports[['report_id', 'confirmed_disease_id']], on='report_id', how='left')
    df_vet_subset = df_vet_verifs[['report_id', 'confirmed_disease_id']].rename(columns={'confirmed_disease_id': 'vet_disease_id'})
    df_dataset = pd.merge(df_dataset, df_vet_subset, on='report_id', how='left')
    df_dataset['target_disease_id'] = df_dataset['confirmed_disease_id'].fillna(df_dataset['vet_disease_id'])

    # Drop unverified cases
    df_labeled = df_dataset.dropna(subset=['target_disease_id']).copy()
    print(f"Found {len(df_labeled)} verified cases for training.")

    # 3. Preprocessing
    mlb = MultiLabelBinarizer()
    symptoms_encoded = mlb.fit_transform(df_labeled['symptom_ids'])
    df_symptoms_features = pd.DataFrame(symptoms_encoded, columns=[f"symp_{c}" for c in mlb.classes_], index=df_labeled.index)

    df_species_features = pd.get_dummies(df_labeled['animal_species'], prefix='species', drop_first=True)

    # --- VACCINATION FEATURE ---
    # For each field report, check if the reporting animal's species has an active
    # vaccination against the confirmed disease. This creates a binary feature
    # that helps the model learn that vaccinated animals presenting with symptoms
    # are statistically more likely to have a DIFFERENT disease (differential diagnosis).
    vaccinated_set = set(
        zip(df_vacc['animal_species'].str.lower(), df_vacc['disease_protected_id'].astype(int))
    )

    def is_vaccinated(row):
        """Return 1 if the species has an active vaccination against its confirmed disease."""
        try:
            return int((str(row['animal_species']).lower(), int(row['target_disease_id'])) in vaccinated_set)
        except Exception:
            return 0

    df_labeled['is_vaccinated'] = df_labeled.apply(is_vaccinated, axis=1)
    df_vacc_feature = df_labeled[['is_vaccinated']].copy()
    df_vacc_feature.index = df_labeled.index

    X = pd.concat([df_symptoms_features, df_species_features, df_vacc_feature], axis=1).fillna(0)
    # ----------------------------

    le = LabelEncoder()
    y = le.fit_transform(df_labeled['target_disease_id'].astype(int))
    
    # 4. Train Model
    rf = RandomForestClassifier(n_estimators=100, random_state=42)
    gb = GradientBoostingClassifier(n_estimators=100, random_state=42)
    lr = LogisticRegression(max_iter=1000, random_state=42)
    xgb = XGBClassifier(n_estimators=100, use_label_encoder=False, eval_metric='mlogloss', random_state=42)
    
    tabular_ensemble = VotingClassifier(
        estimators=[('rf', rf), ('gb', gb), ('lr', lr), ('xgb', xgb)],
        voting='soft'
    )
    
    print("Training Tabular Ensemble...")
    tabular_ensemble.fit(X, y)
    
    # 5. Save to Model Registry
    os.makedirs(os.path.join(BASE_DIR, "model_registry"), exist_ok=True)
    
    joblib.dump(tabular_ensemble, os.path.join(BASE_DIR, "model_registry/symptom_ensemble_v1.joblib"))
    joblib.dump(mlb, os.path.join(BASE_DIR, "model_registry/symptom_binarizer.joblib"))
    joblib.dump(le, os.path.join(BASE_DIR, "model_registry/disease_label_encoder.joblib"))
    
    # Also save X.columns so the API knows the exact expected column order during inference
    joblib.dump(list(X.columns), os.path.join(BASE_DIR, "model_registry/model_columns.joblib"))
    
    print("--- TRAINING COMPLETE ---")
    print("Model and Encoders successfully saved to /model_registry!")
    
if __name__ == "__main__":
    train_and_save_model()
