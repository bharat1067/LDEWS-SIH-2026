import joblib
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
import pandas as pd
import numpy as np
from fastapi import FastAPI, HTTPException, UploadFile, File
from pydantic import BaseModel, Field
from typing import List
from sklearn.cluster import HDBSCAN
import math
import io
from PIL import Image
import torch
import torch.nn as nn
from torchvision import transforms, models

app = FastAPI(title="Livestock Disease ML Microservice")

# Global variables to hold models in RAM
model = None
mlb = None
le = None
expected_columns = None

# Image Model Global variables
image_model = None
image_class_names = None
device = torch.device("cpu") # For inference, CPU is fine

def load_models():
    global model, mlb, le, expected_columns, image_model, image_class_names
    print("Loading models from /model_registry into RAM...")
    try:
        model = joblib.load(os.path.join(BASE_DIR, "model_registry/symptom_ensemble_v1.joblib"))
        mlb = joblib.load(os.path.join(BASE_DIR, "model_registry/symptom_binarizer.joblib"))
        le = joblib.load(os.path.join(BASE_DIR, "model_registry/disease_label_encoder.joblib"))
        expected_columns = joblib.load(os.path.join(BASE_DIR, "model_registry/model_columns.joblib"))
        print("Tabular Models loaded successfully!")
        
        # Load Image Model
        image_class_names = joblib.load(os.path.join(BASE_DIR, "model_registry/lumpy_class_names.joblib"))
        image_model = models.resnet18()
        num_ftrs = image_model.fc.in_features
        image_model.fc = nn.Linear(num_ftrs, len(image_class_names))
        image_model.load_state_dict(torch.load(os.path.join(BASE_DIR, "model_registry/lumpy_cnn_v1.pth"), map_location=device))
        image_model.eval()
        image_model = image_model.to(device)
        print("Image Model loaded successfully!")
        
    except FileNotFoundError:
        print("WARNING: Models not found! Please run train_worker.py and train_image_worker.py first.")

# Load models at startup
load_models()

# Pydantic schema for the incoming JSON POST request
class PredictionRequest(BaseModel):
    species: str
    symptoms: List[int]
    is_vaccinated: bool = False  # Is the animal vaccinated against the suspected disease?

@app.post("/predict")
def predict_disease(req: PredictionRequest):
    if model is None:
        raise HTTPException(status_code=503, detail="Model is currently loading or unavailable.")
    
    try:
        # 1. Transform symptoms
        # We wrap in a try-except in case they send a symptom ID the model has never seen
        try:
            symp_encoded = mlb.transform([req.symptoms])
        except Exception:
            # Fallback: ignore unknown symptoms for simplicity in this demo
            symp_encoded = np.zeros((1, len(mlb.classes_)))
            
        df_custom_symp = pd.DataFrame(symp_encoded, columns=[f"symp_{c}" for c in mlb.classes_])

        # 2. Transform species
        df_custom_spec = pd.DataFrame(columns=[c for c in expected_columns if c.startswith('species_')])
        df_custom_spec.loc[0] = 0
        species_col = f"species_{req.species}"
        if species_col in df_custom_spec.columns:
            df_custom_spec.at[0, species_col] = 1

        # 3. Vaccination feature (binary: 1 = vaccinated against potential disease)
        df_vacc_feature = pd.DataFrame({'is_vaccinated': [int(req.is_vaccinated)]})

        # 4. Combine Features exactly matching the training data
        X_custom = pd.concat([df_custom_symp, df_custom_spec, df_vacc_feature], axis=1)
        X_custom = X_custom.reindex(columns=expected_columns, fill_value=0)
        
        # 4. Predict
        probs = model.predict_proba(X_custom)
        pred_idx = np.argmax(probs, axis=1)[0]
        conf = np.max(probs, axis=1)[0]
        
        # Reverse encode the predicted class
        disease_id = le.inverse_transform([model.classes_[pred_idx]])[0]
        
        return {
            "status": "success",
            "predicted_disease_id": int(disease_id),
            "confidence_score": float(conf),
            "requires_vet_review": bool(conf < 0.6)  # Our auto-triage logic!
        }
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/reload-model")
def reload_model_from_disk():
    """Endpoint called by train_worker.py after saving a new model."""
    load_models()
    return {"status": "success", "message": "New models loaded into RAM!"}

class CaseCoordinate(BaseModel):
    report_id: int
    latitude: float
    longitude: float

class ClusterRequest(BaseModel):
    # DEPRECATED: HDBSCAN calculates radius dynamically based on density. Parameter ignored.
    radius_km: float = Field(15.0, description="DEPRECATED: Parameter ignored. HDBSCAN calculates radius dynamically.")
    min_cases: int = 3
    cases: List[CaseCoordinate]

@app.post("/detect-outbreaks")
def detect_outbreaks(req: ClusterRequest):
    if not req.cases:
        return {"outbreaks": []}
        
    # Extract coordinates in radians for Haversine metric
    coords = []
    for c in req.cases:
        coords.append([math.radians(c.latitude), math.radians(c.longitude)])
    
    # HDBSCAN clustering
    # HDBSCAN dynamically finds clusters of varying densities without a strict eps radius.
    # The haversine metric correctly calculates distance on a sphere based on the radians coordinates.
    db = HDBSCAN(min_cluster_size=req.min_cases, metric='haversine').fit(coords)
    
    labels = db.labels_
    
    outbreaks = []
    unique_labels = set(labels)
    
    for label in unique_labels:
        if label == -1:
            continue # Noise (not in an outbreak)
            
        cluster_cases = [req.cases[i] for i in range(len(labels)) if labels[i] == label]
        
        # Calculate centroid
        avg_lat = sum(c.latitude for c in cluster_cases) / len(cluster_cases)
        avg_lon = sum(c.longitude for c in cluster_cases) / len(cluster_cases)
        
        outbreaks.append({
            "cluster_id": int(label),
            "centroid_latitude": float(avg_lat),
            "centroid_longitude": float(avg_lon),
            "sumCases": len(cluster_cases),
            "affected_report_ids": [c.report_id for c in cluster_cases]
        })
        
    return {"outbreaks": outbreaks}

@app.post("/predict-image")
async def predict_image(file: UploadFile = File(...)):
    if image_model is None:
        raise HTTPException(status_code=503, detail="Image model is not loaded yet.")
        
    try:
        # Read the uploaded image bytes
        image_bytes = await file.read()
        img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        
        # Preprocess exactly how ResNet expects it
        transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ])
        
        img_tensor = transform(img).unsqueeze(0).to(device)
        
        # Inference
        with torch.no_grad():
            outputs = image_model(img_tensor)
            probabilities = torch.nn.functional.softmax(outputs[0], dim=0)
            
            conf, pred_idx = torch.max(probabilities, 0)
            
            prediction = image_class_names[pred_idx.item()]
            
        return {
            "status": "success",
            "image_prediction": prediction,
            "confidence_score": conf.item(),
            "filename": file.filename
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Image processing failed: {str(e)}")

