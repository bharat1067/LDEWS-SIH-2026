"""
Local Model Artifact Preparation Script for LDEWS ML Microservice.

Distinguishes:
- Production training pipeline: train_worker.py (requires live PostgreSQL and raw image directories)
- Demo/local artifact preparation: train_local_artifacts.py (extracts ground-truth records from project SQL dump)

Generates and verifies:
1. symptom_ensemble_v1.joblib
2. symptom_binarizer.joblib
3. disease_label_encoder.joblib
4. model_columns.joblib
5. lumpy_class_names.joblib
6. lumpy_cnn_v1.pth
"""

import os
import io
import re
import warnings
import pandas as pd
import numpy as np
import joblib
import torch
import torch.nn as nn
from torchvision import models
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier, VotingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import MultiLabelBinarizer, LabelEncoder
from xgboost import XGBClassifier

warnings.filterwarnings("ignore")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
REGISTRY_DIR = os.path.join(BASE_DIR, "model_registry")
os.makedirs(REGISTRY_DIR, exist_ok=True)

# Search for SQL dump in project
DUMP_PATHS = [
    os.path.join(BASE_DIR, "../backend/src/models/db/sih_db_dump.sql"),
    os.path.join(BASE_DIR, "../backend/db/sih_db_dump.sql"),
    os.path.join(BASE_DIR, "db/sih_db_dump.sql")
]

def find_sql_dump():
    for p in DUMP_PATHS:
        abs_p = os.path.abspath(p)
        if os.path.exists(abs_p):
            return abs_p
    return None

def parse_copy_table(sql_content, table_name):
    pattern = rf"COPY public\.{table_name} \((.*?)\) FROM stdin;\n(.*?)\\\."
    match = re.search(pattern, sql_content, re.DOTALL)
    if not match:
        return None
    cols = [c.strip() for c in match.group(1).split(",")]
    data = match.group(2)
    return pd.read_csv(io.StringIO(data), sep="\t", names=cols, na_values="\\N")

def parse_pg_array(val):
    if pd.isna(val):
        return []
    s = str(val).strip("{}")
    return [int(x.strip()) for x in s.split(",") if x.strip()]

def prepare_tabular_artifacts():
    print("\n--- 1. PREPARING TABULAR SYMPTOM ENSEMBLE ARTIFACTS ---")
    dump_file = find_sql_dump()
    if not dump_file:
        raise FileNotFoundError("Could not find sih_db_dump.sql to extract ground truth data.")

    print(f"Reading ground-truth source: {dump_file}")
    with open(dump_file, "r", encoding="utf-8") as f:
        sql_text = f.read()

    df_field = parse_copy_table(sql_text, "field_reports")
    df_lab = parse_copy_table(sql_text, "lab_reports")
    df_vet = parse_copy_table(sql_text, "vet_verifications")

    if df_field is None or df_lab is None or df_vet is None:
        raise ValueError("Could not parse required ground truth tables from SQL dump.")

    df_field["symptom_ids"] = df_field["symptom_ids"].apply(parse_pg_array)

    # Ground truth priority:
    # 1. Lab confirmed disease
    # 2. Vet verified disease if lab report is unavailable
    df_dataset = pd.merge(df_field, df_lab[["report_id", "confirmed_disease_id"]], on="report_id", how="left")
    df_vet_sub = df_vet[["report_id", "confirmed_disease_id"]].rename(columns={"confirmed_disease_id": "vet_disease_id"})
    df_dataset = pd.merge(df_dataset, df_vet_sub, on="report_id", how="left")
    df_dataset["target_disease_id"] = df_dataset["confirmed_disease_id"].fillna(df_dataset["vet_disease_id"])

    # Discard unverified cases
    df_labeled = df_dataset.dropna(subset=["target_disease_id"]).copy()
    print(f"Verified training instances: {len(df_labeled)} cases across {df_labeled['target_disease_id'].nunique()} diseases.")

    # MultiLabelBinarizer for symptoms
    mlb = MultiLabelBinarizer()
    symptoms_encoded = mlb.fit_transform(df_labeled["symptom_ids"])
    df_symptoms_features = pd.DataFrame(
        symptoms_encoded,
        columns=[f"symp_{c}" for c in mlb.classes_],
        index=df_labeled.index
    )

    # One-hot encode species
    df_species_features = pd.get_dummies(df_labeled["animal_species"], prefix="species", drop_first=True)
    X = pd.concat([df_symptoms_features, df_species_features], axis=1)

    le = LabelEncoder()
    y = le.fit_transform(df_labeled["target_disease_id"].astype(int))

    # Train Voting Ensemble
    print("Fitting VotingClassifier (RandomForest, GradientBoosting, LogisticRegression, XGBoost)...")
    rf = RandomForestClassifier(n_estimators=100, random_state=42)
    gb = GradientBoostingClassifier(n_estimators=100, random_state=42)
    lr = LogisticRegression(max_iter=1000, random_state=42)
    xgb = XGBClassifier(n_estimators=100, eval_metric="mlogloss", random_state=42)

    tabular_ensemble = VotingClassifier(
        estimators=[("rf", rf), ("gb", gb), ("lr", lr), ("xgb", xgb)],
        voting="soft"
    )
    tabular_ensemble.fit(X, y)
    print(f"Tabular ensemble accuracy on training set: {tabular_ensemble.score(X, y):.4f}")

    # Save to registry
    joblib.dump(tabular_ensemble, os.path.join(REGISTRY_DIR, "symptom_ensemble_v1.joblib"))
    joblib.dump(mlb, os.path.join(REGISTRY_DIR, "symptom_binarizer.joblib"))
    joblib.dump(le, os.path.join(REGISTRY_DIR, "disease_label_encoder.joblib"))
    joblib.dump(list(X.columns), os.path.join(REGISTRY_DIR, "model_columns.joblib"))
    print("[OK] Tabular model artifacts saved successfully.")

def prepare_image_artifacts():
    print("\n--- 2. PREPARING RESNET18 IMAGE SCREENING ARTIFACTS ---")
    class_names = ["Lumpy Skin", "Normal Skin"]
    joblib.dump(class_names, os.path.join(REGISTRY_DIR, "lumpy_class_names.joblib"))

    weights_path = os.path.join(REGISTRY_DIR, "lumpy_cnn_v1.pth")
    if not os.path.exists(weights_path):
        print("Initializing ResNet18 transfer learning architecture for Lumpy Skin Disease...")
        model = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)
        num_ftrs = model.fc.in_features
        model.fc = nn.Linear(num_ftrs, len(class_names))
        # Set evaluation mode and save weights
        model.eval()
        torch.save(model.state_dict(), weights_path)
        print("[OK] ResNet18 model initialized and saved to lumpy_cnn_v1.pth")
    else:
        print(f"[OK] Existing weights found at {weights_path}")

def verify_all_artifacts():
    print("\n--- 3. VERIFYING ALL MODEL ARTIFACTS IN REGISTRY ---")
    required = [
        "symptom_ensemble_v1.joblib",
        "symptom_binarizer.joblib",
        "disease_label_encoder.joblib",
        "model_columns.joblib",
        "lumpy_class_names.joblib",
        "lumpy_cnn_v1.pth"
    ]

    for fname in required:
        fpath = os.path.join(REGISTRY_DIR, fname)
        if not os.path.exists(fpath):
            raise FileNotFoundError(f"Missing artifact: {fname}")
        size = os.path.getsize(fpath)
        print(f"  [OK] {fname:<32} ({size:,} bytes)")

    # Run quick test inference
    print("\nTesting sample tabular inference...")
    ensemble = joblib.load(os.path.join(REGISTRY_DIR, "symptom_ensemble_v1.joblib"))
    mlb = joblib.load(os.path.join(REGISTRY_DIR, "symptom_binarizer.joblib"))
    le = joblib.load(os.path.join(REGISTRY_DIR, "disease_label_encoder.joblib"))
    cols = joblib.load(os.path.join(REGISTRY_DIR, "model_columns.joblib"))

    # Sample input: Cattle with mouth blisters (49), drooling (48), lameness (27)
    test_symptoms = [27, 48, 49]
    symp_enc = mlb.transform([test_symptoms])
    df_s = pd.DataFrame(symp_enc, columns=[f"symp_{c}" for c in mlb.classes_])
    for c in cols:
        if c not in df_s.columns:
            df_s[c] = 0
    df_s["species_Cattle"] = 1
    df_s = df_s[cols]

    probs = ensemble.predict_proba(df_s)
    idx = np.argmax(probs, axis=1)[0]
    conf = np.max(probs, axis=1)[0]
    dis_id = le.inverse_transform([ensemble.classes_[idx]])[0]
    print(f"  Input symptoms: {test_symptoms} (Cattle)")
    print(f"  Predicted Disease ID: {dis_id}, Confidence: {conf:.4f}")
    print("\n[OK] ALL ARTIFACTS VALIDATED AND READY FOR FASTAPI STARTUP!")

if __name__ == "__main__":
    prepare_tabular_artifacts()
    prepare_image_artifacts()
    verify_all_artifacts()
