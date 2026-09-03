# Edge Cases & Fallback Architecture
**Livestock Disease Detection & Outbreak Management Platform**

This document outlines how the system handles edge cases, unexpected inputs, conflicting data, and potential system failures to ensure stability and accuracy.

---

## 1. Machine Learning & Ground Truth Edge Cases

### 1.1 Conflicting Ground Truth (Vet vs. Lab)
**Scenario**: A Veterinarian physically diagnoses an animal with Disease A, but the subsequent Lab Report confirms Disease B. Which does the model learn from?
**How it's handled**: The system uses a strict priority hierarchy in `src/train_worker.py`. 
```python
df_dataset['target_disease_id'] = df_dataset['lab_confirmed_id'].fillna(df_dataset['vet_confirmed_id'])
```
The **Lab Report** is always Priority 1. The **Vet Verification** is Priority 2 (fallback). The AI will exclusively train on the Lab Report's conclusion if both exist.

### 1.2 Unverified "Junk" Data
**Scenario**: A farmer randomly selects symptoms just to test the app, or submits a completely incorrect self-diagnosis. No vet or lab ever verifies it.
**How it's handled**: The AI pipeline has strict "Garbage-In, Garbage-Out" protection. During retraining, any `field_report` that lacks a linked `lab_report` or `vet_verification` is explicitly dropped using `dropna(subset=['target_disease_id'])`. The unverified data is kept for Outbreak tracking, but is banned from altering the ML weights.

### 1.3 Unknown or New Symptoms
**Scenario**: The MERN frontend is updated with a new symptom checkbox (e.g., ID 99), but the ML model hasn't been retrained to recognize it yet.
**How it's handled**: In `src/api.py`, the `MultiLabelBinarizer` transform is wrapped in a `try/except` block. If an unknown symptom ID is received, the API gracefully ignores the unknown ID (treating it as zero) and makes a prediction based on the remaining known symptoms, preventing a 500 Internal Server Error.

### 1.4 AI Confusion / Low Confidence
**Scenario**: A cow presents with a highly unusual combination of symptoms that the Tabular model has never seen before, resulting in a 45% confidence score spread across three different diseases.
**How it's handled**: The API flags `requires_vet_review = true` whenever confidence drops below 60%. The MERN Escalation Engine intercepts this flag and forces the `field_report` into "REVIEW" status, automatically dispatching a human vet. When the vet solves the mystery, their diagnosis becomes new Ground Truth, teaching the AI to handle this edge case in the next retraining cycle.

---

## 2. Spatial & Outbreak Edge Cases

### 2.1 The "Lone Wolf" False Alarm
**Scenario**: A highly contagious disease (e.g., Anthrax) is predicted with 99% confidence, but it's an isolated case hundreds of miles from any other farms. 
**How it's handled**: The DBSCAN algorithm (`POST /detect-outbreaks`) requires a minimum density (e.g., `min_cases=3` within a `radius_km=15`). The lone case is correctly classified as "Noise" (Cluster -1) by DBSCAN, meaning an Outbreak Alert is *not* broadcasted. However, because it's Anthrax (a High-Risk list disease), the MERN Escalation engine will still dispatch a Vet.

### 2.2 Uploading Non-Animal Photos (Image ML)
**Scenario**: A user uploads a picture of a car, a dog, or a human face to the `/predict-image` endpoint for Lumpy Skin Disease.
**How it's handled**: The ResNet18 CNN will output a very low `confidence_score` because the visual features do not match cattle skin lesions. The Escalation Engine catches this low confidence and forces a human review, preventing the system from falsely diagnosing a car with Lumpy Skin Disease.

---

## 3. System & Infrastructure Edge Cases

### 3.1 Model Retraining Downtime
**Scenario**: It's the end of the month, and `train_worker.py` takes 20 minutes to process 50,000 new verified cases. Does the live API go down for 20 minutes?
**How it's handled**: Zero-downtime hot-swapping. `train_worker.py` runs as a completely isolated background process. The live FastAPI server (`api.py`) continues serving predictions using the old models in RAM. The exact millisecond the new models finish saving to the disk, the worker sends a `POST /reload-model` webhook to the server, which instantly swaps the fresh weights into RAM without dropping a single user request.

### 3.2 Database Connection Failures
**Scenario**: The Docker container bridging fails, or the local environment binds PostgreSQL to a different port (5433 instead of 5432).
**How it's handled**: The Python worker scripts employ graceful degradation for DB connections. They first attempt to connect to the native port `5432`, and if a `psycopg2.Error` is caught, they automatically failover to port `5433` (the standard Docker override port).

### 3.3 The "Zero Data" Cold Start
**Scenario**: The database is entirely wiped, and the Retraining Worker is triggered when there are exactly 0 verified rows in the system.
**How it's handled**: The Random Forest algorithms mathematically require at least 1 row to train. If `len(df_labeled) == 0`, the script will gracefully abort rather than crashing or saving a corrupted/empty model to the registry, ensuring the existing models remain safe.
