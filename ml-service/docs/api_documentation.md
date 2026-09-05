# FastAPI Microservice Documentation

This document outlines the inputs and outputs for every endpoint exposed by the central MLOps FastAPI server (`src/api.py`).

The server runs on `http://0.0.0.0:8000` by default.

---

## 1. Tabular Symptom Prediction
**Endpoint**: `POST /predict`
**Description**: Takes the animal species and a list of symptom IDs, and returns the predicted disease and confidence score using the Tabular Ensemble Model (Random Forest, XGBoost, etc.).

### Input (JSON Request Body)
```json
{
  "species": "Cow",
  "symptoms": [1, 5, 12]
}
```

### Output (JSON Response)
```json
{
  "status": "success",
  "predicted_disease_id": 3,
  "confidence_score": 0.89,
  "requires_vet_review": false
}
```
> [!NOTE]
> `requires_vet_review` automatically flags `true` if the AI's confidence score drops below 60%.

---

## 2. Image Disease Detection (CNN)
**Endpoint**: `POST /predict-image`
**Description**: Accepts a high-resolution image upload and runs it through the PyTorch ResNet18 Convolutional Neural Network to detect visual skin diseases (e.g., Lumpy Skin Disease).

### Input (Multipart Form Data)
- **Field Name**: `file`
- **Value**: `(An uploaded .jpg, .png, or .jpeg file)`

### Output (JSON Response)
```json
{
  "status": "success",
  "image_prediction": "Lumpy Skin",
  "confidence_score": 0.965,
  "filename": "cow_skin_lesion_14.jpg"
}
```

---

## 3. Spatial Outbreak Detection
**Endpoint**: `POST /detect-outbreaks`
**Description**: Runs the HDBSCAN clustering algorithm over raw GPS coordinates using the Haversine metric to detect active disease outbreak epicenters.

### Input (JSON Request Body)
```json
{
  "radius_km": 15.0,
  "min_cases": 3,
  "cases": [
    {"report_id": 101, "latitude": 28.6139, "longitude": 77.2090},
    {"report_id": 102, "latitude": 28.6200, "longitude": 77.2100},
    {"report_id": 103, "latitude": 28.6150, "longitude": 77.2050}
  ]
}
```

### Output (JSON Response)
```json
{
  "outbreaks": [
    {
      "cluster_id": 0,
      "centroid_latitude": 28.6163,
      "centroid_longitude": 77.2080,
      "sumCases": 3,
      "affected_report_ids": [101, 102, 103]
    }
  ]
}
```

---

## 4. Hot-Reload Models
**Endpoint**: `POST /reload-model`
**Description**: An internal webhook endpoint. The background training workers (`train_worker.py` and `train_image_worker.py`) call this endpoint the exact second they finish saving new models to disk. It forces the FastAPI server to instantly load the fresh `.joblib` and `.pth` files into RAM without needing a server restart.

### Input
*(No input required)*

### Output (JSON Response)
```json
{
  "status": "success",
  "message": "New models loaded into RAM!"
}
```
