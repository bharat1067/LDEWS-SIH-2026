import os
import io
import math
from typing import List, Optional
import joblib
import pandas as pd
import numpy as np
from PIL import Image
import torch
import torch.nn as nn
from torchvision import transforms, models
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REGISTRY_DIR = os.path.join(BASE_DIR, "model_registry")

app = FastAPI(title="LDEWS ML Microservice", version="1.0.0")

# CORS middleware for local service requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables holding models in RAM
model = None
mlb = None
le = None
expected_columns = None
image_model = None
image_class_names = None
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

def load_models():
    global model, mlb, le, expected_columns, image_model, image_class_names
    print(f"Loading models from {REGISTRY_DIR} into RAM...")
    
    # 1. Tabular Ensemble Models
    try:
        ensemble_path = os.path.join(REGISTRY_DIR, "symptom_ensemble_v1.joblib")
        binarizer_path = os.path.join(REGISTRY_DIR, "symptom_binarizer.joblib")
        encoder_path = os.path.join(REGISTRY_DIR, "disease_label_encoder.joblib")
        columns_path = os.path.join(REGISTRY_DIR, "model_columns.joblib")

        if (os.path.exists(ensemble_path) and os.path.exists(binarizer_path) and
            os.path.exists(encoder_path) and os.path.exists(columns_path)):
            model = joblib.load(ensemble_path)
            mlb = joblib.load(binarizer_path)
            le = joblib.load(encoder_path)
            expected_columns = joblib.load(columns_path)
            print("[OK] Tabular Voting Ensemble models loaded successfully!")
        else:
            print("Notice: One or more tabular model files missing in model_registry.")
    except Exception as e:
        print(f"Error loading tabular models: {e}")
        model = None

    # 2. ResNet18 Image Model
    try:
        class_names_path = os.path.join(REGISTRY_DIR, "lumpy_class_names.joblib")
        weights_path = os.path.join(REGISTRY_DIR, "lumpy_cnn_v1.pth")

        if os.path.exists(class_names_path) and os.path.exists(weights_path):
            image_class_names = joblib.load(class_names_path)
            res18 = models.resnet18(weights=None)
            num_ftrs = res18.fc.in_features
            res18.fc = nn.Linear(num_ftrs, len(image_class_names))
            res18.load_state_dict(torch.load(weights_path, map_location=device))
            res18.eval()
            image_model = res18.to(device)
            print("[OK] ResNet18 Image Screening model loaded successfully!")
        else:
            print("Notice: Image model files missing in model_registry.")
    except Exception as e:
        print(f"Error loading image model: {e}")
        image_model = None

# Initial load on startup
load_models()

@app.get("/health")
def health_check():
    """Health check reflecting actual status of loaded models."""
    return {
        "status": "healthy",
        "tabularModelLoaded": model is not None,
        "imageModelLoaded": image_model is not None,
        "device": str(device)
    }

class PredictionRequest(BaseModel):
    species: str
    symptoms: List[int]

@app.post("/predict")
def predict_disease(req: PredictionRequest):
    """Tabular symptom prediction using VotingClassifier ensemble."""
    if model is None or mlb is None or le is None or expected_columns is None:
        raise HTTPException(status_code=503, detail="Tabular ML models are currently unavailable.")

    try:
        # 1. Transform symptoms safely handling unknown classes
        try:
            # Filter to classes known by the binarizer
            valid_symptoms = [s for s in req.symptoms if s in mlb.classes_]
            if valid_symptoms:
                symp_encoded = mlb.transform([valid_symptoms])
            else:
                symp_encoded = np.zeros((1, len(mlb.classes_)))
        except Exception:
            symp_encoded = np.zeros((1, len(mlb.classes_)))

        df_custom_symp = pd.DataFrame(symp_encoded, columns=[f"symp_{c}" for c in mlb.classes_])

        # 2. Transform species
        df_custom_spec = pd.DataFrame(columns=[c for c in expected_columns if c.startswith("species_")])
        df_custom_spec.loc[0] = 0
        species_col = f"species_{req.species}"
        if species_col in df_custom_spec.columns:
            df_custom_spec.at[0, species_col] = 1

        # 3. Combine Features in exact expected column order
        X_custom = pd.concat([df_custom_symp, df_custom_spec], axis=1)
        # Ensure all expected columns exist
        for col in expected_columns:
            if col not in X_custom.columns:
                X_custom[col] = 0
        X_custom = X_custom[expected_columns]

        # 4. Inference
        probs = model.predict_proba(X_custom)
        pred_idx = np.argmax(probs, axis=1)[0]
        conf = float(np.max(probs, axis=1)[0])

        # Reverse encode the predicted class
        disease_id = int(le.inverse_transform([model.classes_[pred_idx]])[0])
        requires_vet = bool(conf < 0.60)

        return {
            "status": "success",
            "predicted_disease_id": disease_id,
            "confidence_score": round(conf, 4),
            "requires_vet_review": requires_vet
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Prediction error: {str(e)}")

@app.post("/predict-image")
async def predict_image(file: UploadFile = File(...)):
    """AI Visual Screening using ResNet18 trained on Lumpy Skin lesions."""
    if image_model is None or image_class_names is None:
        raise HTTPException(status_code=503, detail="Image model is not loaded yet.")

    # Validate image MIME
    if file.content_type and not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Uploaded file must be a valid image (JPEG/PNG).")

    try:
        image_bytes = await file.read()
        if len(image_bytes) > 5 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="Image size exceeds the 5MB limit.")

        img = Image.open(io.BytesIO(image_bytes)).convert("RGB")

        transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ])

        img_tensor = transform(img).unsqueeze(0).to(device)

        with torch.no_grad():
            outputs = image_model(img_tensor)
            probabilities = torch.nn.functional.softmax(outputs[0], dim=0)
            conf, pred_idx = torch.max(probabilities, 0)
            prediction = image_class_names[pred_idx.item()]

        return {
            "status": "success",
            "image_prediction": prediction,
            "confidence_score": round(conf.item(), 4),
            "filename": file.filename
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Image processing failed: {str(e)}")

class CaseCoordinate(BaseModel):
    report_id: int
    latitude: float
    longitude: float

class ClusterRequest(BaseModel):
    radius_km: float = 15.0
    min_cases: int = 3
    cases: List[CaseCoordinate]

@app.post("/detect-outbreaks")
def detect_outbreaks(req: ClusterRequest):
    """Spatial outbreak cluster detection using DBSCAN with Haversine distance."""
    from sklearn.cluster import DBSCAN

    if not req.cases or len(req.cases) < req.min_cases:
        return {"outbreaks": []}

    try:
        # Convert lat/lng coordinates to radians for Haversine
        coords = []
        for c in req.cases:
            coords.append([math.radians(c.latitude), math.radians(c.longitude)])

        # Earth radius in km = 6371.0
        eps_rad = req.radius_km / 6371.0
        db = DBSCAN(eps=eps_rad, min_samples=req.min_cases, algorithm="ball_tree", metric="haversine").fit(coords)
        labels = db.labels_

        outbreaks = []
        unique_labels = set(labels)

        for label in unique_labels:
            if label == -1:
                continue  # Noise points

            cluster_cases = [req.cases[i] for i in range(len(labels)) if labels[i] == label]
            avg_lat = sum(c.latitude for c in cluster_cases) / len(cluster_cases)
            avg_lon = sum(c.longitude for c in cluster_cases) / len(cluster_cases)

            outbreaks.append({
                "cluster_id": int(label),
                "centroid_latitude": round(float(avg_lat), 6),
                "centroid_longitude": round(float(avg_lon), 6),
                "sumCases": len(cluster_cases),
                "affected_report_ids": [c.report_id for c in cluster_cases]
            })

        return {"outbreaks": outbreaks}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Clustering calculation failed: {str(e)}")

@app.post("/reload-model")
def reload_model_from_disk():
    """Hot reload endpoint to refresh model weights into memory."""
    load_models()
    return {
        "status": "success",
        "message": "New models loaded into RAM!",
        "tabularModelLoaded": model is not None,
        "imageModelLoaded": image_model is not None
    }
