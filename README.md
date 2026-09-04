# Livestock Disease Early Warning System (LDEWS)

SIH 2026 prototype for early livestock disease warning, AI/ML-assisted risk triage, veterinary escalation, diagnostic laboratory confirmation, district surveillance, and state-level resource allocation.

---

## Production Deployment Architecture

```
Browser
   |
   v
Vercel Frontend (https://ldews-sih-2026.vercel.app)
   |
   | HTTPS API Requests
   v
Render Node.js Backend (https://ldews-backend.onrender.com)
   |
   | Internal HTTP Requests (with zero-downtime fallback)
   v
Render FastAPI ML Service (https://<your-ml-service>.onrender.com)
   |
   v
MongoDB (Atlas or Persistent Service)
```

---

## Production Deployment Guide

### Step 1: Deploy Python FastAPI ML Service (Render)
1. In Render, create a new **Web Service**.
2. Connect your Git repository.
3. Configure service settings:
   - **Root Directory**: `ml-service`
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn src.api:app --host 0.0.0.0 --port $PORT`
4. Health check endpoint: `GET /health` (reports `healthy` or `degraded`).
5. Copy your deployed service URL (e.g. `https://ldews-ml.onrender.com`).

### Step 2: Deploy Node.js Express Backend (Render)
1. In Render, create a new **Web Service**.
2. Connect your Git repository.
3. Configure service settings:
   - **Root Directory**: `backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
4. Configure Environment Variables in Render Dashboard:
   - `NODE_ENV` = `production`
   - `PORT` = `5000` (Render will automatically assign its dynamic `$PORT`)
   - `MONGODB_URI` = `<Your MongoDB Atlas Connection String>`
   - `JWT_SECRET` = `<Your Secure Random Secret Key>`
   - `FRONTEND_URL` = `https://ldews-sih-2026.vercel.app`
   - `ML_SERVICE_URL` = `https://<your-ml-service>.onrender.com` (from Step 1)
5. Health check endpoints:
   - `GET /health` (returns `{ "status": "healthy", "service": "ldews-backend" }`)
   - `GET /api/ml/health` (returns backend ML proxy status)
6. Verify your deployed backend URL (e.g. `https://ldews-backend.onrender.com`).

### Step 3: Deploy React Frontend (Vercel)
1. In Vercel, import the project repository.
2. Configure project settings:
   - **Framework Preset**: `Vite`
   - **Root Directory**: `frontend`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
3. Configure Environment Variables in Vercel Dashboard:
   - `VITE_API_BASE_URL` = `https://ldews-backend.onrender.com`
   > **Note**: Vite environment variables are embedded at build time. When changing `VITE_API_BASE_URL`, trigger a new deployment.
4. Deploy and verify at `https://ldews-sih-2026.vercel.app`.

---

## Deployment Order Summary
1. **Deploy ML Service** on Render → Obtain ML service URL.
2. **Deploy Backend** on Render with `ML_SERVICE_URL` and `FRONTEND_URL`.
3. **Deploy Frontend** on Vercel with `VITE_API_BASE_URL=https://ldews-backend.onrender.com`.

---

## Run Locally

### Prerequisites
- Node.js (v18+)
- Python 3.10+ (with virtual environment in `.venv`)

### 1. Configure Environment Files
Copy example environment files:
```bash
# Frontend
cp frontend/.env.example frontend/.env

# Backend
cp backend/.env.example backend/.env
```

### 2. Install Dependencies
```bash
npm install
npm install --prefix backend
npm install --prefix frontend
```

### 3. Start Development Services
Run all 3 services concurrently:
```bash
npm run dev:all
```
- **Frontend**: `http://localhost:5173` or `http://localhost:5174`
- **Backend API**: `http://localhost:5000` (Health: `http://localhost:5000/api/health`)
- **FastAPI ML**: `http://localhost:8000` (Health: `http://localhost:8000/health`)

### 4. Seed Demo Data (Optional)
```bash
npm run seed
```
Demo accounts: password `demo123`
- Farmer: `9876543210` (Suresh Patil)
- Vet: `9000000001` (Dr Ananya Shah)
- Lab: `9000000002` (Nisha Rao)
- District Officer: `9000000003` (Vikram Deshmukh - Nashik)
- State Officer: `9000000004` (Priya Kulkarni - Maharashtra)

---

## Testing & Verification

Run automated test suites:
```bash
# Full end-to-end integration and workflow test (61 assertions)
node backend/test_flow.js

# ML Microservice & DBSCAN integration test (20 assertions)
node backend/test_ml_integration.js

# Frontend production build validation
npm run build --prefix frontend
```
