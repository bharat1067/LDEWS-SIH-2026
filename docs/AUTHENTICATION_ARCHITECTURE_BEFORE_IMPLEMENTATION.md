# LDEWS Authentication Architecture (Pre-Implementation Audit)

**Document Version:** 1.0.0  
**Project:** Livestock Disease Early Warning System (LDEWS) — SIH 2026  
**Status:** Pre-Implementation Baseline  
**Scope:** Complete Codebase Audit & Architectural Walkthrough Before Hybrid Authentication Upgrade  

---

## Executive Summary

This document presents a comprehensive audit of the authentication, user identity, role authorization, and data isolation architecture of the Livestock Disease Early Warning System (LDEWS) prior to introducing the hybrid authentication model.

LDEWS currently operates as a working prototype featuring 5 specialized role dashboards:
1. **Farmer Dashboard** (`/farmer`, `/farmer/report`, `/farmer/reports`)
2. **Veterinary Officer Dashboard** (`/vet`, `/vet/cases`, `/vet/cases/:id`)
3. **Diagnostic Laboratory Officer Dashboard** (`/lab`, `/lab/samples`, `/lab/samples/:id`)
4. **District Surveillance Officer Dashboard** (`/district/overview`, `/district/cases`, `/district/clusters`)
5. **State Animal Husbandry Officer Dashboard** (`/state/overview`, `/state/districts`, `/state/requests`)

The current prototype relies on a **demo-only role selection login system** backed by MongoDB seeded user records and JSON Web Tokens (JWT). While this facilitates rapid hackathon evaluation and demonstration, it lacks self-service public registration for livestock farmers and secure credential provisioning for authorized government personnel.

The goal of this audit is to thoroughly inspect, map, and document the existing architecture so that real authentication (live mode) can be cleanly integrated in parallel with demo authentication (demo mode) without breaking any working workflow, ML contract, or automated test.

---

## 1. Current Project Authentication Architecture

### 1.1 End-to-End Authentication Flow

The existing authentication mechanism is an instant role-switching demo login. The flow is traced below from the user interface down to the database and back:

```
+-------------------------------------------------------------------------+
|                         Role Selection Page                             |
|                   (Login Component in main.jsx)                         |
|   Renders 5 official GOI role cards with pre-configured persona scopes  |
+-------------------------------------------------------------------------+
                                    |
                                    v (User clicks role card or handles login)
+-------------------------------------------------------------------------+
|                           handleLogin(role)                             |
|   Invokes context function: login(role)                                 |
+-------------------------------------------------------------------------+
                                    |
                                    v (HTTP POST)
+-------------------------------------------------------------------------+
|                  POST /api/auth/demo-login                              |
|   Body: { "role": "farmer" | "vet" | "lab" | "district" | "state" }     |
+-------------------------------------------------------------------------+
                                    |
                                    v (server.js line 199)
+-------------------------------------------------------------------------+
|               User.findOne({ role: req.body.role, active: true })       |
|   Queries MongoDB 'users' collection for the first active role document |
+-------------------------------------------------------------------------+
                                    |
                                    v (Document found)
+-------------------------------------------------------------------------+
|               JWT Creation via tokenFor(u)                              |
|   Signs: { id, role, name, phone, district, taluka }                    |
|   Key: process.env.JWT_SECRET || 'demo-secret-key-sih2026'              |
|   Expires in: '8h'                                                      |
+-------------------------------------------------------------------------+
                                    |
                                    v (JSON Response)
+-------------------------------------------------------------------------+
|   Returns: { token: "<JWT>", user: publicUser(u) }                      |
+-------------------------------------------------------------------------+
                                    |
                                    v (Frontend main.jsx line 2199)
+-------------------------------------------------------------------------+
|   Saved to localStorage under key: 'ldews-session'                      |
|   State session updated -> Triggers re-render in App()                  |
+-------------------------------------------------------------------------+
                                    |
                                    v (Role Routing)
+-------------------------------------------------------------------------+
|   RoleGuard checks user.role -> Navigates to role home:                 |
|   farmer   -> /farmer                                                   |
|   vet      -> /vet                                                      |
|   lab      -> /lab                                                      |
|   district -> /district/overview                                        |
|   state    -> /state/overview                                           |
+-------------------------------------------------------------------------+
```

### 1.2 Actual Source Code Locations

- **Frontend Login Component:** [`frontend/src/main.jsx`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/frontend/src/main.jsx#L2082-L2169)
- **Frontend App & Session State:** [`frontend/src/main.jsx`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/frontend/src/main.jsx#L2179-L2249)
- **Backend Demo-Login Endpoint:** [`backend/src/server.js`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/server.js#L199-L210)
- **Backend Password Login Endpoint:** [`backend/src/server.js`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/server.js#L180-L197)
- **Token Generation Helper:** [`backend/src/server.js`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/server.js#L70-L85)
- **Authentication Middleware:** [`backend/src/server.js`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/server.js#L88-L104)

---

## 2. Current Frontend Authentication Flow

### 2.1 Component Structure

The frontend authentication experience is organized around React Context and standard browser storage:

1. **`Auth` Context (`frontend/src/main.jsx:36`):**
   ```javascript
   const Auth = createContext();
   export const useAuth = () => useContext(Auth);
   ```

2. **`Login` Component (`frontend/src/main.jsx:2082`):**
   Renders the government-branded portal header (`Government of India | Department of Animal Husbandry & Dairying`), the official seal, title, and 5 selectable cards representing the predefined demo accounts:
   - **Farmer:** Suresh Patil (`9876543210`), Village Pimpalgaon, Nashik
   - **Veterinarian:** Dr Ananya Shah (`9000000001`), Field Investigation, Nashik
   - **Laboratory Officer:** Nisha Rao (`9000000002`), District Disease Investigation Lab
   - **District Officer:** Vikram Deshmukh (`9000000003`), District Headquarter, Nashik
   - **State Officer:** Priya Kulkarni (`9000000004`), State Command Center, Maharashtra

3. **Login Action (`frontend/src/main.jsx:2194`):**
   The `login` function is defined within the root `App` component:
   ```javascript
   const login = async role => {
     const r = await api('/auth/demo-login', {
       method: 'POST',
       body: JSON.stringify({ role })
     });
     localStorage.setItem('ldews-session', JSON.stringify(r));
     setSession(r);
   };
   ```

4. **API Request Abstraction (`frontend/src/main.jsx:39-78`):**
   Requests to backend endpoints use the `api(path, options)` helper. It reads `ldews-session` from `localStorage`, automatically adds the `Authorization: Bearer <token>` header, normalizes the URL using `buildApiUrl(path)` from [`frontend/src/config/api.js`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/frontend/src/config/api.js), and throws formatted errors if response status is not 2xx.

5. **Session Structure in `localStorage`:**
   Key: `'ldews-session'`
   Payload:
   ```json
   {
     "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
     "user": {
       "id": "66d8f1e5...",
       "name": "Dr Ananya Shah",
       "phone": "9000000001",
       "email": "vet@nashik.gov.in",
       "role": "vet",
       "district": "Nashik",
       "taluka": "Niphad"
     }
   }
   ```

6. **Role Guard & Route Protection (`frontend/src/main.jsx:2171`):**
   ```javascript
   function RoleGuard({ roles: allowedRoles, children }) {
     const { user } = useAuth();
     if (!allowedRoles.includes(user.role)) {
       return <Navigate to={homes[user.role] || '/login'} replace />;
     }
     return children;
   }
   ```
   Route map (`homes`):
   - `farmer`: `'/farmer'`
   - `vet`: `'/vet'`
   - `lab`: `'/lab'`
   - `district`: `'/district/overview'`
   - `state`: `'/state/overview'`

7. **Logout Flow:**
   Invoking `logout()` calls `localStorage.removeItem('ldews-session')` and sets React `session` state to `null`, instantly displaying the `Login` component again. In addition, an event listener on `window.addEventListener('ldews-logout', handleLogout)` enables deep components or 401 interceptors to trigger session eviction.

---

## 3. Current Backend Authentication Flow

### 3.1 Existing Endpoints in `backend/src/server.js`

#### Endpoint: `POST /api/auth/demo-login` (Lines 199–210)
- **Purpose:** Prototype role login without credentials.
- **Request Body:** `{ "role": "farmer" }` (or any of the 5 roles).
- **Backend Query:** `User.findOne({ role, active: true })`.
- **Response:**
  ```json
  {
    "token": "eyJhbGciOi...",
    "user": {
      "id": "60d0fe4f5311236168a109ca",
      "name": "Suresh Patil",
      "phone": "9876543210",
      "email": "suresh@farmer.gov.in",
      "role": "farmer",
      "district": "Nashik",
      "taluka": "Niphad"
    }
  }
  ```
- **Error Behavior:** Returns `503 Service Unavailable` if database is unseeded and no user with the requested role exists.

#### Endpoint: `POST /api/auth/login` (Lines 180–197)
- **Purpose:** Credential-based login using phone/email identifier and bcrypt password.
- **Request Body:** `{ "identifier": "9876543210", "password": "demo123" }`.
- **Backend Query:** `User.findOne({ $or: [{ phone: identifier }, { email: identifier }], active: true })`.
- **Password Check:** `await bcrypt.compare(password, u.password)`.
- **Response:** `{ token: tokenFor(u), user: publicUser(u) }`.
- **Current Limitation:** Does NOT validate whether the user matches the role required for a specific login portal. Anyone with credentials can authenticate regardless of role.

### 3.2 JWT Generation and Payload

Generated by `tokenFor(u)` in `backend/src/server.js:71`:
```javascript
const tokenFor = u => jwt.sign(
  { id: u._id, role: u.role, name: u.name, phone: u.phone, district: u.district, taluka: u.taluka },
  secret,
  { expiresIn: '8h' }
);
```
- **Secret:** Read from `process.env.JWT_SECRET`, fallback to `'demo-secret-key-sih2026'`.
- **Payload fields:** `id` (ObjectId string), `role` (enum string), `name`, `phone`, `district`, `taluka`.
- **Missing fields:** `email`, `accountType` (`demo` vs `public` vs `government`), `accountActivated`.

### 3.3 Authentication & Authorization Middleware

Defined in `backend/src/server.js:88-104`:
```javascript
const auth = (roles = []) => async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || '';
    if (!authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Authentication required' });
    }
    const token = authHeader.slice(7);
    const decoded = jwt.verify(token, secret);
    req.user = decoded;
    if (roles.length && !roles.includes(decoded.role)) {
      return res.status(403).json({ message: 'Insufficient role permission' });
    }
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid or expired authentication token' });
  }
};
```
- Attaches `req.user` with decoded token contents.
- Restricts endpoints based on the `roles` array argument (e.g. `auth(['farmer'])`).
- Returns HTTP 401 on missing/invalid/expired token.
- Returns HTTP 403 on role mismatch.

---

## 4. Existing Seed Architecture

The seed script is located at [`backend/src/seed.js`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/seed.js). It is idempotent and can run in standalone CLI mode (`node backend/src/seed.js`), via npm script (`npm run seed`), or programmatically during integration tests.

### 4.1 Collection Cleansing Sequence
The seed script performs reverse-dependency deletion across 12 collections:
1. `Notification`
2. `LabResult`
3. `Sample`
4. `VetAssignment`
5. `Advisory`
6. `FarmerReport`
7. `ActionRequest`
8. `HistoricalDiseaseRecord`
9. `Village`
10. `Taluka`
11. `District`
12. `User`

### 4.2 Seeded Users (7 Total)

| Role | Name | Phone | Official Email | District | Taluka | Default Password |
|---|---|---|---|---|---|---|
| `farmer` | Suresh Patil | `9876543210` | `suresh@farmer.gov.in` | Nashik | Niphad | `demo123` |
| `farmer` | Asha Kale | `9876543211` | `asha@farmer.gov.in` | Nashik | Niphad | `demo123` |
| `farmer` | Ramesh Wagh | `9876543212` | `ramesh@farmer.gov.in` | Nashik | Sinnar | `demo123` |
| `vet` | Dr Ananya Shah | `9000000001` | `vet@nashik.gov.in` | Nashik | Niphad | `demo123` |
| `lab` | Nisha Rao | `9000000002` | `lab@nashik.gov.in` | Nashik | - | `demo123` |
| `district` | Vikram Deshmukh | `9000000003` | `officer@nashik.gov.in` | Nashik | - | `demo123` |
| `state` | Priya Kulkarni | `9000000004` | `officer@state.gov.in` | Maharashtra | - | `demo123` |

### 4.3 Government Personnel Information In Seed Data

The existing seed data already defines valid, realistic government officer personas:
- **Veterinary Officer:** Dr Ananya Shah (`vet@nashik.gov.in`, phone `9000000001`, assigned to Nashik).
- **Laboratory Officer:** Nisha Rao (`lab@nashik.gov.in`, phone `9000000002`, District Disease Investigation Lab, Nashik).
- **District Surveillance Officer:** Vikram Deshmukh (`officer@nashik.gov.in`, phone `9000000003`, District Headquarter, Nashik).
- **State Animal Husbandry Officer:** Priya Kulkarni (`officer@state.gov.in`, phone `9000000004`, State Command Center, Maharashtra).

These 4 records represent ideal pre-authorized government personnel candidates for the live authentication system.

---

## 5. Existing User and Data Models

Defined in [`backend/src/models/index.js`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/models/index.js):

### 5.1 `User` Model
```javascript
export const User = model('User', new Schema({
  name: { type: String, required: true },
  phone: { type: String, unique: true, sparse: true, index: true },
  email: { type: String, unique: true, sparse: true, index: true },
  password: { type: String },
  role: {
    type: String,
    enum: ['farmer', 'vet', 'lab', 'district', 'state'],
    required: true,
    index: true
  },
  district: { type: String },
  taluka: { type: String },
  active: { type: Boolean, default: true }
}, { timestamps: true }));
```

### 5.2 Administrative Hierarchy Models
- **`District`:** `name` (unique, e.g. "Nashik"), `state` ("Maharashtra"), `riskScore` (Number 0-100), `mappedLab` (ref `User`), `assignedVet` (ref `User`).
- **`Taluka`:** `name` (e.g. "Niphad"), `district` (ref `District`).
- **`Village`:** `name` (e.g. "Pimpalgaon"), `taluka` (ref `Taluka`), `district` (String), `latitude`, `longitude`.

### 5.3 Disease Surveillance & Case Workflow Models
- **`FarmerReport`:** Primary case entity with `caseId` (e.g. `CASE-260901-01`), `farmer` (ref `User`), `farmerName`, `phone`, `animalType`, `symptoms` (array of strings), `location` (embedded schema: district, taluka, village, lat, lng), `source` (`web`, `ivr`, `voice`, `sms`), `language`, `suspectedDisease`, `triage` (`low`, `medium`, `high`), `localOutbreakRisk` (0-100), `status` (`Reported`, `Monitoring`, `Escalated to Vet`, `Vet Verified`, `Sample Collected`, `Lab Testing`, `Confirmed`, `Negative`, `Closed`), `clinicalObservations`, `advisory` (ref `Advisory`), `mlPrediction`, `imageScreening`, `photoUrl`.
- **`Advisory`:** `case` (ref `FarmerReport`), `disease`, `title`, `message`, `riskBand`, `approved`, `sentAt`.
- **`VetAssignment`:** `case` (ref `FarmerReport`), `vet` (ref `User`), `status` (`Assigned`, `Verified`), `assignedAt`, `verifiedAt`.
- **`Sample`:** `sampleId` (e.g. `SMP-260901-02`), `case` (ref `FarmerReport`), `collectedBy` (ref `User`), `lab` (ref `User`), `status` (`Collected`, `Received`, `Testing`, `Completed`), `collectedAt`, `receivedAt`, `notes`.
- **`LabResult`:** `sample` (ref `Sample`), `result` (`Confirmed`, `Negative`, `Inconclusive`), `disease`, `notes`, `submittedBy` (ref `User`), `submittedAt`.
- **`Notification`:** `user` (ref `User`), `title`, `message`, `type`, `case` (ref `FarmerReport`), `delivery`, `deliveredAt`, `read`.
- **`ActionRequest` (alias `VaccinationRequest`):** `requestId`, `type` (`vaccination`, `containment`), `district`, `taluka`, `village`, `disease`, `reason`, `createdBy` (ref `User`), `status` (`Pending`, `Approved`, `Rejected`, `Prioritized`, `Allocated`), `priority`, `allocation`, `reviewedBy` (ref `User`), `reviewedAt`.
- **`HistoricalDiseaseRecord`:** Segregated offline baseline records for outbreak analytics.

### 5.4 Relational Diagram

```
       +------------+
       |   User     | <---------------+----------------+----------------+
       +------------+                 |                |                |
             ^                        |                |                |
             | (farmer)               | (vet)          | (lab)          | (createdBy/reviewedBy)
             |                        |                |                |
       +------------+                 |                |                |
       |FarmerReport| <----+          |                |                |
       +------------+      |          |                |                |
        |          |       |          |                |                |
        v          v       |          v                v                v
   +--------+ +----------+ |    +-------------+   +--------+     +-------------+
   |Advisory| |Notification|    |VetAssignment|   | Sample |     |ActionRequest|
   +--------+ +----------+      +-------------+   +--------+     +-------------+
                                                       |
                                                       v
                                                  +---------+
                                                  |LabResult|
                                                  +---------+
```

---

## 6. Existing Role Architecture

The five roles implemented across the backend and frontend are:

### 1. `farmer` (Livestock Owner / Farmer)
- **Capabilities:**
  - Submit livestock disease symptom reports with optional photo: `POST /api/reports`
  - View personal submitted reports and advisory notifications: `GET /api/reports/my`, `GET /api/notifications`
  - View single case details: `GET /api/reports/:id`
- **Restrictions:**
  - Cannot access veterinary queues or verify cases.
  - Cannot access laboratory queues or submit lab findings.
  - Cannot view district or state containment dashboards.

### 2. `vet` (Government Veterinary Officer)
- **Capabilities:**
  - View escalated reports within jurisdiction or assigned cases: `GET /api/vet/cases`
  - Inspect case details: `GET /api/vet/cases/:id`
  - Submit clinical verification & update observations: `PATCH /api/vet/cases/:id/verify`
  - Transition clinical status: `PATCH /api/vet/cases/:id/status`
  - Order biological sample collection: `POST /api/vet/cases/:id/sample`
- **Restrictions:**
  - Cannot submit lab diagnostic results.
  - Cannot approve state-level emergency resource allocations.

### 3. `lab` (Diagnostic Laboratory Officer)
- **Capabilities:**
  - View sample testing queue assigned to lab: `GET /api/lab/samples`
  - Inspect sample details: `GET /api/lab/samples/:id`
  - Update sample testing status (`Received`, `Testing`): `PATCH /api/lab/samples/:id/status`
  - Publish confirmatory PCR/ELISA diagnostic result: `POST /api/lab/samples/:id/result`
- **Restrictions:**
  - Cannot perform clinical verification in the field.
  - Cannot create district action requests.

### 4. `district` (District Surveillance Officer)
- **Capabilities:**
  - Monitor district surveillance overview, trends, breakdowns, and active clusters: `GET /api/district/:district/overview`, `/trends`, `/breakdown`, `/clusters`
  - Submit containment and vaccination directives to State command: `POST /api/district/requests`
  - Track status of district action requests: `GET /api/district/requests`
- **Restrictions:**
  - Cannot allocate state-level vaccine reserves.
  - Cannot alter lab test records.

### 5. `state` (State Animal Husbandry Officer)
- **Capabilities:**
  - View multi-district operational risk rankings: `GET /api/state/districts`
  - Access state-wide GIS spatial map and active outbreak clusters: `GET /api/state/map`, `GET /api/state/outbreaks`
  - Review, prioritize, and allocate vaccine doses/quarantine directives: `GET /api/state/requests`, `PATCH /api/state/requests/:id`
  - Cross-inspect any district overview (`auth(['district', 'state'])`).

---

## 7. Existing District Architecture

### 7.1 The Three Canonical Districts

Inspection of `backend/src/seed.js`, `backend/src/models/index.js`, and existing records confirms that LDEWS is configured for **three specific districts in Maharashtra**:

1. **`Nashik`** (High Risk: Baseline score ~76; Talukas: Niphad, Sinnar; Villages: Pimpalgaon, Wavi)
2. **`Pune`** (Moderate Risk: Baseline score ~53; Talukas: Junnar; Villages: Alephata)
3. **`Ahmednagar`** (Low Risk: Baseline score ~34; Talukas: Sangamner; Villages: Ashwi)

### 7.2 Administrative Storage & Reference

- In `District` collection: `name` is the primary human-readable key (e.g. `'Nashik'`).
- In `FarmerReport`: `location.district` stores the district string.
- In `User`: `district` stores the assigned district string.
- In `ActionRequest`: `district` stores the target district for the intervention.
- In frontend `DistrictHome`:
  ```javascript
  const districtName = user.district || 'Nashik';
  const { d, e } = useLoad('/district/' + districtName + '/overview');
  ```
- In backend `GET /api/vet/cases`:
  ```javascript
  { 'location.district': req.user.district, status: { $in: ['Escalated to Vet', 'Vet Verified', 'Lab Testing'] } }
  ```

**Strict Constraint for Real Authentication:**  
To prevent fragmentation and broken GIS map rendering, **only these three approved districts (`Nashik`, `Pune`, `Ahmednagar`) will be permitted for Farmer registration and Government Officer assignment.**

---

## 8. Existing Workflow Dependencies and Risks

Before writing any new code, the following dependencies and risks have been cataloged:

1. **Dependency on `User.findOne({ role, active: true })`:**  
   The demo login endpoint queries MongoDB for any active user matching the requested role. If the database is cleared or if real users of role `farmer` are inserted before demo users, demo login could return a real user unless demo users are explicitly marked or prioritized.  
   *Mitigation:* Keep existing demo users active with `accountType: 'demo'`.

2. **Integration Test Assertions in `backend/test_flow.js`:**  
   - Line 69: `assert(countUsersPass1 >= 7, 'Seeded users: >= 7')`  
   - Line 80: `assert(countUsersPass1 === countUsersPass2, 'Idempotent User count')`  
   - Line 89: `User.findOne({ role, active: true })` checked for all 5 roles  
   - Line 91: `bcrypt.compare('demo123', u.password)`  
   *Mitigation:* Any extension of `seed.js` or `User` model must strictly preserve these counts and ensure `seedDatabase()` remains 100% idempotent.

3. **Frontend `localStorage` Key `'ldews-session'`:**  
   All 5 dashboards consume `const { user } = useAuth()` and expect `user.id`, `user.name`, `user.role`, and `user.district`.  
   *Mitigation:* Both demo and live login must return the exact same user object structure (with additive fields like `accountType`).

4. **Public Registration Security Exposure:**  
   If an open registration endpoint accepts a `role` field from the client payload, an attacker could register as a `vet`, `district`, or `state` officer and view state surveillance data.  
   *Mitigation:* The public registration endpoint (`POST /api/auth/register`) must reject any request with `role !== 'farmer'` with HTTP 403 Forbidden.

5. **Government Officer Self-Registration Protection:**  
   Government officers must never self-register. Their profiles (name, designation, official email, assigned district, employee ID) must be pre-provisioned in MongoDB. First-time login only verifies official email and allows password setting.

---

## 9. Comprehensive Implementation Plan

### 9.1 Database Schema Extension (`backend/src/models/index.js`)

Extend the existing `User` model rather than creating a disconnected `GovernmentOfficer` collection. This ensures unified Mongoose ObjectId references across `VetAssignment`, `Sample`, `Notification`, `District`, and `ActionRequest` without requiring polymorphic lookups or duplicate middleware:

```javascript
export const User = model('User', new Schema({
  name: { type: String, required: true },
  phone: { type: String, unique: true, sparse: true, index: true },
  email: { type: String, unique: true, sparse: true, index: true },
  password: { type: String },
  role: {
    type: String,
    enum: ['farmer', 'vet', 'lab', 'district', 'state'],
    required: true,
    index: true
  },
  district: { type: String },
  taluka: { type: String },
  active: { type: Boolean, default: true },

  // --- New Additive Fields for Hybrid Authentication ---
  accountType: {
    type: String,
    enum: ['demo', 'public', 'government'],
    default: 'public',
    index: true
  },
  accountActivated: {
    type: Boolean,
    default: true
  },
  organization: {
    type: String,
    default: 'Department of Animal Husbandry & Dairying'
  },
  designation: {
    type: String
  },
  employeeId: {
    type: String,
    sparse: true,
    index: true
  }
}, { timestamps: true }));
```

### 9.2 Central District Configuration
Create a shared configuration for allowed districts:
```javascript
export const APPROVED_DISTRICTS = ['Nashik', 'Pune', 'Ahmednagar'];
```

### 9.3 Backend APIs to Implement

1. **`POST /api/auth/register` (Farmer Self-Registration Only):**
   - Validates `fullName` (or `name`), `email`, `phone`, `password`, `district`.
   - Validates that `district` is one of `['Nashik', 'Pune', 'Ahmednagar']`.
   - Rejects non-farmer roles with HTTP 403.
   - Checks duplicate email and phone.
   - Hashes password with `bcrypt.hash(password, 10)`.
   - Creates `User` with `role: 'farmer'`, `accountType: 'public'`, `accountActivated: true`.
   - Returns `{ token, user: publicUser(u) }`.

2. **`POST /api/auth/verify-official-email` (Government Personnel Verification):**
   - Receives `{ email, role }`.
   - Queries `User.findOne({ email: email.toLowerCase().trim(), role, active: true })`.
   - Validates that user exists and has `accountType === 'government'` (or pre-authorized).
   - Rejects if role mismatch or account inactive.
   - Returns safe profile:
     ```json
     {
       "verified": true,
       "name": u.name,
       "email": u.email,
       "role": u.role,
       "district": u.district,
       "designation": u.designation,
       "organization": u.organization,
       "employeeId": u.employeeId,
       "accountActivated": u.accountActivated
     }
     ```

3. **`POST /api/auth/activate-official-account` (First-Time Activation):**
   - Receives `{ email, role, password }`.
   - Validates officer in database.
   - Rejects if already activated or if credentials invalid.
   - Hashes password with `bcrypt.hash(password, 10)`.
   - Sets `password = hash` and `accountActivated = true`.
   - Returns `{ token, user: publicUser(u) }`.

4. **`POST /api/auth/login` (Credential-Based Live Login):**
   - Receives `{ identifier, password, role }`.
   - Finds user by phone or email.
   - Validates `bcrypt.compare(password, u.password)`.
   - Validates role match (`if (role && u.role !== role)` -> return 403 with descriptive message).
   - For government officers, checks `accountActivated === true`.
   - Returns `{ token, user: publicUser(u) }`.

5. **`GET /api/auth/me` (Profile Check):**
   - Protected by `auth()`.
   - Returns sanitized user record.

6. **Preserve `POST /api/auth/demo-login`:**
   - Remains 100% untouched and functional.

### 9.4 Pre-Authorized Government Officers in Seed Data
Update [`backend/src/seed.js`](file:///c:/Users/bhara/Documents/Codex/2026-09-01/we-are-building-a-smart-india/backend/src/seed.js) so that:
- The 7 demo users have `accountType: 'demo'`, `accountActivated: true`.
- Pre-provision additional authorized government officers (or configure specific demo officer records) with:
  - `accountType: 'government'`
  - `accountActivated: false` (to simulate realistic first-time onboarding) or pre-activated records for instant testing.
  - Official designations, organizations, and employee IDs (e.g. `VET-MH-01`, `LAB-MH-01`, `DSO-MH-01`, `SAHO-MH-01`).

### 9.5 Frontend Enhancements in `frontend/src/main.jsx`
- Maintain the existing visual layout, GOI header, seal, and demo role cards.
- Add a subtle toggle / secondary navigation:
  - **Tab 1: "Demo Instant Access"** (existing cards and instant enter button)
  - **Tab 2: "Official / Registered User Login"**
- Under "Official / Registered User Login":
  - If **Farmer** is selected:
    - Tab between **"Farmer Login"** (Email/Phone + Password) and **"Farmer Registration"** (Full Name, Email, Phone, Password, Confirm Password, District dropdown).
  - If a **Government Officer** role (`vet`, `lab`, `district`, `state`) is selected:
    - **Step 1:** Enter official email (`dr.ananya@nashik.gov.in` etc.) -> clicks "Verify Official Identity".
    - **Step 2A (If `accountActivated === false`):** Shows government verified card (Name, Designation, Assigned District, Employee ID) with "Set Account Password" form.
    - **Step 2B (If `accountActivated === true`):** Shows standard password login form.

### 9.6 Architectural Safeguards & Compatibility Assurances

To guarantee zero regression and production integrity, the following safeguards are formally established:

1. **No Duplicate Password Fields & Strict Hash Protection:**
   - The existing `password` field in the `User` schema will be utilized for bcrypt hashes. No duplicate `passwordHash` field will be introduced.
   - Password hashes will never be exposed in API responses or JWT payloads. The `publicUser(u)` mapping function sanitizes user objects and strips credentials before sending JSON to clients.
   - Schema-level queries will avoid breaking existing test suites (e.g. `backend/test_flow.js:91`) that test hash validity on seeded objects.

2. **Context-Aware District Validation (No Universal Enum):**
   - The `district` field on the `User` model will remain `{ type: String }` without a universal enum restriction because State-level officers represent the entire state (`district: null` or `'Maharashtra'`, `state: 'Maharashtra'`).
   - District validation is enforced context-aware at the API/business layer:
     - **Farmers:** Must select from `['Nashik', 'Pune', 'Ahmednagar']`.
     - **Field/District Personnel (Vet, Lab, District):** Assigned to one of `['Nashik', 'Pune', 'Ahmednagar']` by the administrative registry.
     - **State Officers:** District is not restricted to local boundaries.

3. **Strict Isolation Between Demo Mode and Real Authentication Mode:**
   - `POST /api/auth/demo-login` remains unchanged for one-click hackathon evaluation.
   - `POST /api/auth/login` will reject users with `accountType === 'demo'` with HTTP 403, instructing them to use Demo Instant Access. Real mode is strictly for registered farmers (`accountType: 'public'`) and activated officers (`accountType: 'government'`).

4. **Seed Idempotency & Duplicate Prevention:**
   - Pre-authorized government personnel are seeded inside `seedDatabase()` alongside demo users.
   - Because `seedDatabase()` employs reverse-dependency `deleteMany({})` cleanups, multiple executions will never produce duplicate records, guaranteeing exact document count stability.

5. **Cross-Model Reference Integrity:**
   - All 7 models referencing `User` (`FarmerReport`, `VetAssignment`, `Sample`, `LabResult`, `Notification`, `ActionRequest`, `District`) remain 100% compatible since all identities (demo, public, government) reside in the unified `User` collection.

---

## 10. Audit Sign-Off

This audit confirms that the LDEWS codebase is in a healthy, test-verified state and ready for hybrid authentication implementation:
- All 12 Mongoose models documented.
- All 5 role permissions analyzed.
- All district mappings verified (`Nashik`, `Pune`, `Ahmednagar`).
- Zero code modifications have been made during this pre-implementation phase.
- Clear separation between demo authentication and live authentication defined.
- All 6 architectural safeguards incorporated into the baseline specification.
