import os
import warnings
import pandas as pd
import psycopg2
import joblib
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier, VotingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import MultiLabelBinarizer, LabelEncoder
from xgboost import XGBClassifier

warnings.filterwarnings('ignore')

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
REGISTRY_DIR = os.path.join(BASE_DIR, "model_registry")

def get_db_connection():
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
    X = pd.concat([df_symptoms_features, df_species_features], axis=1)
    
    le = LabelEncoder()
    y = le.fit_transform(df_labeled['target_disease_id'].astype(int))
    
    # 4. Train Model
    rf = RandomForestClassifier(n_estimators=100, random_state=42)
    gb = GradientBoostingClassifier(n_estimators=100, random_state=42)
    lr = LogisticRegression(max_iter=1000, random_state=42)
    xgb = XGBClassifier(n_estimators=100, eval_metric='mlogloss', random_state=42)
    
    tabular_ensemble = VotingClassifier(
        estimators=[('rf', rf), ('gb', gb), ('lr', lr), ('xgb', xgb)],
        voting='soft'
    )
    
    print("Training Tabular Ensemble...")
    tabular_ensemble.fit(X, y)
    
    # 5. Save to Model Registry
    os.makedirs(REGISTRY_DIR, exist_ok=True)
    
    joblib.dump(tabular_ensemble, os.path.join(REGISTRY_DIR, "symptom_ensemble_v1.joblib"))
    joblib.dump(mlb, os.path.join(REGISTRY_DIR, "symptom_binarizer.joblib"))
    joblib.dump(le, os.path.join(REGISTRY_DIR, "disease_label_encoder.joblib"))
    joblib.dump(list(X.columns), os.path.join(REGISTRY_DIR, "model_columns.joblib"))
    
    print("--- TRAINING COMPLETE ---")
    print("Model and Encoders successfully saved to /model_registry!")

if __name__ == "__main__":
    train_and_save_model()
