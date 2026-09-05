# LDEWS Hindi Multilingual Support: Pre-Implementation Architecture Audit

**Document Version:** 1.0.0  
**Audit Date:** 2026-09-06  
**System:** Livestock Disease Early Warning System (LDEWS) — SIH 2026  
**Subject:** Comprehensive Architectural Audit Prior to Hindi Multilingual Implementation  

---

## 1. Current Navbar Language System

### 1.1 Existing UI Placement
In [`frontend/src/main.jsx`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/frontend/src/main.jsx#L198-L202), inside the `<header>` component (`Shell` layout), the top national header bar (`.govline`) displays:

```jsx
<div className="govline-right">
  <span className="lang-switch">English | हिंदी | मराठी</span>
  <span className="helpline-pill"><Phone size={11} /> Helpline: 1962</span>
</div>
```

### 1.2 Current Functionality
* **No Click Handlers:** The text `"English | हिंदी | मराठी"` is currently rendered as a single static string within a plain `<span>` element. There are no `<button>`, `onClick`, or navigation bindings.
* **No State Management:** There is no React state (`useState`, `useContext`, or Redux) holding a selected language in the application.
* **No Persistence:** No language preference is stored in `localStorage`, `sessionStorage`, or cookies.
* **Missing on Login Screen:** The login page (`Login` component, lines 2294–2310) contains a `.govline` top bar, but it does not have the `.lang-switch` selector at all.

---

## 2. Current Frontend Text Architecture

### 2.1 Storage of UI Strings
User-facing UI strings are **100% hardcoded in English directly inside React JSX components** in [`frontend/src/main.jsx`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/frontend/src/main.jsx). There is no internationalization (i18n) framework (such as `react-i18next` or custom translation dictionary) in place.

### 2.2 Hardcoded English Components Breakdown

| Component Area | File & Line Range | Hardcoded English Content |
|---|---|---|
| **Portal Shell & Navbar** | `main.jsx:165–293` | Navigation titles ("My Reports", "Field Investigation Queue", "Sample Queue", "District Overview", "Strategic Priority Matrix"), branding, helpline, sign-out button. |
| **Authentication & Login** | `main.jsx:2088–2740` | "LDEWS Official Access", "Select Operational Role", "Demo Instant Access", "Official / Registered User Login", "Register New Farmer", "Government Identity Verified", "Activate Official Account", password fields, validation errors. |
| **Farmer Dashboard & Reports** | `main.jsx:441–700` | "Livestock Owner Health Assistance Portal", "Report Animal Health Problem", "Assigned Status", "Automated Risk Triage", "Predicted Condition", symptom presets ("Mouth blisters", "Excessive drooling", "Sudden lameness", etc.). |
| **Veterinary Officer Dashboard** | `main.jsx:702–1020` | "Field Investigation & Case Verification Queue", "Case Detail", "Record Clinical Observations", "Collect Diagnostic Sample", "Mark Verified". |
| **Laboratory Dashboard** | `main.jsx:1022–1280` | "Diagnostic Laboratory Queue", "Record Diagnostic Test Result", "Sample Received", "RT-PCR Test", "Publish Lab Confirmation". |
| **District Officer Dashboard** | `main.jsx:1282–1650` | "District Live Operational Situation", "Active Outbreak Cluster Detection", "District Case Register", "Request Ring Vaccination". |
| **State Officer Dashboard** | `main.jsx:1652–2085` | "State Strategic Command Center", "District Operational Risk Ranking", "Resource Allocation Decisions", "Approve Vaccination Request". |
| **Notifications Drawer** | `main.jsx:215–245` | "Notifications", "Mark as read", "No notifications". |
| **Modals & Form Inputs** | Across `main.jsx` | Placeholders, confirmation alerts, status badges ("Monitoring", "Escalated to Vet", "Lab Testing", "Confirmed"). |

---

## 3. Current Report Submission Flow

```text
Farmer Report Form (frontend/src/main.jsx)
        ↓
submit() creates payload / FormData
        ↓
API Client (api('/reports'))
        ↓
HTTP POST /api/reports (backend/src/server.js)
        ↓
Multer handles optional photo upload (ResNet18 screening)
        ↓
processReport(payload, farmer) (backend/src/services/workflowService.js)
        ↓
Village lookup & coordinates enrichment (Village.findOne)
        ↓
ML normalization & prediction (FastAPI predictSymptoms or fallback predict)
        ↓
FarmerReport.create() & Advisory.create()
        ↓
Saved in MongoDB & JSON returned to Frontend
```

### Exact Fields Sent in `POST /api/reports`
When the farmer submits the form ([`frontend/src/main.jsx:599–633`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/frontend/src/main.jsx#L599-L633)):
* `animalType`: String (e.g. `'Cattle'`, `'Buffalo'`, `'Goat'`)
* `symptoms`: Array of strings (e.g. `['Mouth blisters', 'excessive drooling', 'lameness']`)
* `district`: String (e.g. `'Nashik'`)
* `taluka`: String (e.g. `'Niphad'`)
* `village`: String (e.g. `'Pimpalgaon'`)
* `source`: String (`'web'`)
* `location`: Object `{ district, taluka, village }`
* `photo`: File (optional, sent in `multipart/form-data`)

Notice: `language` is **not** currently sent in regular web reports (it is only sent as hardcoded `'Hindi'` in the IVR test mode).

---

## 4. Current Language Field Usage

### 4.1 Schema Definition
In [`backend/src/models/index.js:84`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/models/index.js#L84), the `FarmerReport` model defines:
```javascript
language: { type: String, default: 'English' }
```

### 4.2 Where it is Received & Stored
* In [`backend/src/services/workflowService.js:156`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/services/workflowService.js#L156):
  ```javascript
  language: payload.language || 'English',
  ```
* In [`backend/src/seed.js`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/seed.js): Several seed cases are tagged with `'Marathi'`, `'Hindi'`, or `'English'` as a simulation of call-center/IVR intake language.
* In [`backend/src/server.js:640`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/server.js#L640): The IVR endpoint defaults to `'ivr'` source and receives `b.language`.

### 4.3 How it is Currently Used
* **Passive Storage Only:** The `language` field is merely stored as a database string in `FarmerReport`.
* **Not Used for Localization:** It is **never** used to change the advisory text, notification text, or API response labels. Everything is returned in English regardless of `language`.

---

## 5. Current ML Pipeline

### 5.1 End-to-End Pipeline Trace
```text
Frontend Report Submission
        ↓
POST /api/reports (backend/src/server.js)
        ↓
processReport(payload, farmer) (backend/src/services/workflowService.js)
        ↓
normSpecies = normalizeSpecies(payload.animalType)
symptomIds = mapSymptomsToIds(payload.symptoms)
        ↓
predictSymptoms({ species: normSpecies, symptoms: symptomIds }) (backend/src/services/mlClient.js)
        ↓
HTTP POST http://localhost:8000/predict
        ↓
FastAPI Microservice (backend/src/models/src/api.py)
        ↓
VotingClassifier Ensemble (Random Forest + Gradient Boosting + Extra Trees)
        ↓
Returns JSON: { predicted_disease_id: 8, confidence_score: 0.88, requires_vet_review: false }
        ↓
Node.js maps disease ID to English Name: mapDiseaseIdToName(8) -> "Foot and Mouth Disease"
```

### 5.2 Critical ML Invariants
* **What reaches the ML service:**
  Only `{ species: "Cattle", symptoms: [1, 27, 48, 49] }`.
* **Does latitude/longitude reach the ML model?**
  **NO.** Geographic coordinates are completely excluded from `POST /predict`.
* **Does language reach the ML model?**
  **NO.** Language is completely excluded from `POST /predict`.
* **What language does the ML model expect?**
  The model expects **strictly integer symptom IDs (1–69)** and **canonical English species strings** (`'Cattle'`, `'Goat'`, `'Sheep'`, `'Pig'`, `'Poultry'`).
* **Format conversion:**
  `mapSymptomsToIds()` converts natural language symptom strings into integer IDs using regex patterns.
* **Return format:**
  FastAPI returns ground-truth integer `predicted_disease_id`, which Node.js maps to canonical English disease name (`"Foot and Mouth Disease"`, `"Lumpy Skin Disease"`, etc.).

---

## 6. Current Advisory System

### 6.1 Generation & Storage
* In [`backend/src/services/workflowService.js:18–33`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/services/workflowService.js#L18-L33), advisories are selected from a static in-memory English dictionary:
  ```javascript
  const advice = {
    'Foot and Mouth Disease': 'Isolate affected animals, avoid animal movement, disinfect sheds, and await veterinary guidance.',
    'Lumpy Skin Disease': 'Isolate affected animals, control insects and vectors, provide fluids, and contact veterinary officer.',
    ...
  };
  ```
* In `processReport()`, an `Advisory` document is created:
  ```javascript
  const advisory = await Advisory.create({
    case: report._id,
    disease: result.suspectedDisease,
    title: `Advisory: ${result.suspectedDisease}`,
    message: advice[result.suspectedDisease] || 'Observe the animal, keep it separated...',
    riskBand: result.triage,
    approved: true
  });
  ```
* **Language Awareness:** The current advisory system is **100% English only**. It does not consider `payload.language` or user preference.

---

## 7. Current Notification System

### 7.1 Generation & Storage
* In [`backend/src/services/workflowService.js:35–46`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/services/workflowService.js#L35-L46):
  ```javascript
  export const notify = async (user, title, message, caseId = null, type = 'workflow') => {
    return Notification.create({ user: userId, title, message, case: caseId, type, deliveredAt: new Date() });
  };
  ```
* Notification records are created with hardcoded English strings:
  * Farmer: `'Animal health advisory generated'`
  * Vet: `'High-risk livestock case assigned'`
  * Lab: `'New sample received for testing'`
  * District: `'Confirmed FMD cluster in Pimpalgaon'`
  * State: `'Nashik district risk level updated'`
* **User Language Preference:** The `User` model currently has no `preferredLanguage` field. All notifications are stored and rendered exclusively in English.

---

## 8. Current Database Architecture

### 8.1 What is Currently Stored in English

| Field / Collection | Stored Language | Canonical Requirement |
|---|---|---|
| `FarmerReport.suspectedDisease` | English (e.g. `'Foot and Mouth Disease'`) | **Must remain canonical English** for reporting, queries, aggregation, and ML backward compatibility. |
| `FarmerReport.symptoms` | English array (e.g. `['Mouth blisters', 'Drooling']`) | **Must remain canonical English** or normalized for `mapSymptomsToIds()`. |
| `FarmerReport.location.district` | English (e.g. `'Nashik'`, `'Pune'`, `'Ahmednagar'`) | **Must remain canonical English** for `District.findOne` and spatial indexing. |
| `FarmerReport.location.village` | English (e.g. `'Pimpalgaon'`, `'Wavi'`) | **Must remain canonical English** for `Village.findOne` coordinates lookup. |
| `FarmerReport.status` | English enum (`'Monitoring'`, `'Escalated to Vet'`, `'Confirmed'`, etc.) | **Must remain canonical English** for workflow state machines. |
| `Advisory.title` / `message` | English | Can include localized companion fields or dynamic response translation. |
| `Notification.title` / `message` | English | Can include localized companion fields or dynamic response translation. |

---

## 9. Proposed Hindi Architecture

### 9.1 Separation of Concerns: Internal Canonical vs. User Display

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          USER INTERFACE LAYER                               │
│  [English | हिंदी | मराठी] Toggle (Navbar & Login Header)                   │
│  Selected Language stored in localStorage & LanguageContext                 │
│  t('key') translates labels, buttons, cards, statuses, and headings         │
│  Hindi inputs mapped to canonical English before transmission               │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ HTTP Request with:
                                       │ - X-LDEWS-Language: hi
                                       │ - Accept-Language: hi
                                       │ - payload: { ..., language: "hi" }
┌──────────────────────────────────────▼──────────────────────────────────────┐
│                    NODE.JS BACKEND PRESENTATION ADAPTER                     │
│  getRequestLanguage(req) detects language ('hi' | 'en')                     │
│  normalizeSpecies() & normalizeSymptoms() translate Hindi inputs to English │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ Canonical English / Integer IDs
                                       │ { species: "Cattle", symptoms: [1, 48, 49] }
┌──────────────────────────────────────▼──────────────────────────────────────┐
│               INTERNAL ML & CORE SERVICES (100% UNCHANGED)                  │
│  - predictSymptoms() sends canonical payload to FastAPI                     │
│  - FastAPI /predict runs VotingClassifier over integer symptom IDs          │
│  - FastAPI /detect-outbreaks runs DBSCAN over float (lat, lon)              │
│  - MongoDB stores canonical English disease names, districts, and statuses  │
│  - Village coordinate lookup uses canonical village names                   │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ Prediction Result (Canonical: "Lumpy Skin Disease")
┌──────────────────────────────────────▼──────────────────────────────────────┐
│                    LOCALIZED RESPONSE ENRICHMENT LAYER                      │
│  If language === 'hi':                                                      │
│    - suspectedDiseaseDisplay = "लंपी स्किन रोग"                             │
│    - advisory.title = "सलाह: लंपी स्किन रोग"                                │
│    - advisory.message = "पशु को अलग रखें, कीटनाशक छिड़कें..."               │
│    - notification.title = "पशु स्वास्थ्य सलाह तैयार की गई है"               │
│  If language === 'en':                                                      │
│    - Returns standard English strings                                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.2 Zero ML Intrusion Guarantee
1. **The ML Microservice receives zero Hindi strings.**
2. **The ML Microservice receives zero language metadata.**
3. **The ML model training weights, feature binarizer, and label encoder are untouched.**
4. **All database queries, relations, and geospatial lookups remain on canonical English identifiers.**

---

*This document completes Phase 0. Implementation will proceed according to this pre-audit plan.*
