# Livestock Disease Early Warning System

SIH 2026 prototype for reporting livestock illness, ML-assisted risk triage, veterinary escalation, lab results, and district/state monitoring.

## Run locally

1. Copy `backend/.env.example` to `backend/.env` and `frontend/.env.example` to `frontend/.env`.
2. Ensure MongoDB is running if persistent storage is required. The API still starts in a demo-memory mode without it.
3. From the project root:

```bash
npm install
npm install --prefix backend
npm install --prefix frontend
npm run dev
```

Open `http://localhost:5173`. API health: `http://localhost:5000/api/health`.

Optional persistent demo seed: `npm run seed` (requires MongoDB). Demo users use password `demo123`; phone numbers are in `backend/src/seed.js`.

## Architecture

- `frontend/`: Vite React portal, role-based routes, responsive government-style UI.
- `backend/`: Express REST API, Mongoose entities, JWT demo login, and workflow endpoints.
- `POST /api/ml/predict`: a replaceable ML adapter contract. It returns only prediction and score; backend routes apply the `RISK_THRESHOLD`, assign escalation state, and create workflow actions.
- `POST /api/ivr/report`: provider-independent IVR simulation endpoint.

Demo roles: Farmer, Government Veterinarian, Lab Assistant, District Officer, and State Officer. Use the role selector at login.

## Key APIs

- `POST /api/auth/login` and `POST /api/auth/demo-login` — JWT login
- `POST /api/reports`, `GET /api/reports/my` — authenticated farmer reporting
- `POST /api/ivr/report` — IVR simulation
- `GET/PATCH /api/vet/cases/:id/*` and `GET/POST/PATCH /api/lab/samples/:id/*` — field/lab workflow
- `/api/district/:district/*` and `/api/state/*` — monitoring, maps, trends, clusters, and requests
