# LDEWS Government Personnel Multi-District Authentication Audit (Before Implementation)

**Document Version:** 1.0.0  
**Project:** Livestock Disease Early Warning System (LDEWS) — SIH 2026  
**Status:** Pre-Implementation Baseline for Multi-District Enhancement  
**Scope:** Analysis of Current Government Personnel Limitations and Design of Multi-District Hierarchy  

---

## 1. Current Authentication Architecture

The LDEWS system currently implements a **Hybrid Authentication System** providing two access channels:

1. **Demo Mode (`POST /api/auth/demo-login`):**
   - Retains 5 predefined demo personas (Farmer, Vet, Lab, District, State).
   - Allows evaluators to jump directly into any role dashboard with a single click.
   - Reads the first matching user document from MongoDB where `{ role, active: true }`.

2. **Real / Registered Mode:**
   - **Public Farmers:** Can self-register via `POST /api/auth/register` with full name, email/phone, password, and a district selected from `['Nashik', 'Pune', 'Ahmednagar']`.
   - **Government Officers:** Cannot self-register. Officers enter their email, which is verified against MongoDB via `POST /api/auth/verify-official-email`. On first login, officers activate their account via `POST /api/auth/activate-official-account` by creating a password. Subsequent logins use `POST /api/auth/login`.

---

## 2. Current Government User Limitations

While the dual-mode structure is functional, the initial prototype suffered from key operational limitations:

1. **Single-Officer-Per-Role Limitation:**
   - The government personnel registry in `seed.js` only initialized a single sample officer per role (e.g. one Vet in Nashik, one District Officer in Pune).
   - In a realistic livestock surveillance infrastructure across Maharashtra, every operational district (**Nashik**, **Pune**, and **Ahmednagar**) requires its own assigned Veterinary Officer, Diagnostic Lab Officer, and District Surveillance Officer.
2. **Hardcoded Fallbacks in the Frontend:**
   - In `frontend/src/main.jsx`, the initial state defaulted `govEmail` to `'vet.nashik@gov.in'`.
   - A helper dictionary (`govRoleHelp`) was suggesting hardcoded sample emails for each role.
   - To reflect true production security, the login screen must start with a neutral, empty official email input field, requiring the officer to supply their government credential (`@gov.in`).
3. **Incomplete District Matrix:**
   - Officers for Pune and Ahmednagar were missing in the Veterinary and Laboratory tiers.
   - As a result, testing district-isolated veterinary queues (e.g. Pune Vet seeing only Pune reports) was not possible through the live authentication flow.

---

## 3. Current Hardcoded Identity Problem

In the initial implementation:
- The UI had residual default states (`useState('vet.nashik@gov.in')`) and static hints indicating specific officer names or emails.
- Although identity verification called `POST /api/auth/verify-official-email`, pre-filling an email created the illusion of a manual person selector rather than a dynamic government registry lookup.

**The Fix:**
- The official email input will start empty (`govEmail = ''`).
- The officer identity card (Name, Designation, Assigned District, Employee ID, Department) will **ONLY** render after a successful HTTP 200 response from `POST /api/auth/verify-official-email`.
- All displayed values will be 100% dynamic, populated directly from the MongoDB document returned by the backend.

---

## 4. Why Multi-District Personnel Mapping Is Required

In animal disease surveillance and epidemiologic containment:
1. **Jurisdictional Data Segregation:**
   - A Veterinary Officer in Pune (`vet.pune@gov.in`) must investigate suspected outbreaks only in Pune district (e.g., Junnar taluka, Alephata village). They should not be assigned to or verify cases in Nashik.
   - A Diagnostic Lab Officer in Ahmednagar (`lab.ahmednagar@gov.in`) should receive biological samples collected from Ahmednagar cases.
   - A District Surveillance Officer in Nashik (`officer.nashik@gov.in`) must monitor Nashik risk indices and submit vaccination requests specific to Nashik.
2. **State-Level Coordination:**
   - The State Animal Husbandry Officer (`director.state@gov.in`) sits above district boundaries, overseeing aggregated outbreak trends and allocating vaccine reserves across Nashik, Pune, and Ahmednagar.
3. **Realistic Demonstration:**
   - Testing multi-district officer authentication validates that LDEWS is architected for real-world state-wide deployment across India.

---

## 5. Proposed Government Hierarchy (10 Total Personnel)

The MongoDB government registry will be populated with exactly 10 pre-authorized personnel across the 3 approved districts:

### Veterinary Officers (3)
| Name | Role | District | Official Email | Employee ID | Designation | Organization |
|---|---|---|---|---|---|---|
| Dr. Nilesh Rathod | vet | Nashik | `vet.nashik@gov.in` | `VET-MH-042` | Senior Veterinary Officer | Department of Animal Husbandry & Dairying |
| Dr. Amit Patil | vet | Pune | `vet.pune@gov.in` | `VET-MH-043` | Senior Veterinary Officer | Department of Animal Husbandry & Dairying |
| Dr. Rohit Shinde | vet | Ahmednagar | `vet.ahmednagar@gov.in` | `VET-MH-044` | Senior Veterinary Officer | Department of Animal Husbandry & Dairying |

### Diagnostic Lab Officers (3)
| Name | Role | District | Official Email | Employee ID | Designation | Organization |
|---|---|---|---|---|---|---|
| Dr. Snehal Patil | lab | Nashik | `lab.nashik@gov.in` | `LAB-MH-018` | Diagnostic Microbiologist | Department of Animal Husbandry & Dairying |
| Dr. Priya Joshi | lab | Pune | `lab.pune@gov.in` | `LAB-MH-019` | Diagnostic Microbiologist | Department of Animal Husbandry & Dairying |
| Dr. Rahul Deshmukh | lab | Ahmednagar | `lab.ahmednagar@gov.in` | `LAB-MH-020` | Diagnostic Microbiologist | Department of Animal Husbandry & Dairying |

### District Surveillance Officers (3)
| Name | Role | District | Official Email | Employee ID | Designation | Organization |
|---|---|---|---|---|---|---|
| Vikram Deshmukh | district | Nashik | `officer.nashik@gov.in` | `DSO-MH-001` | District Animal Health Officer | Department of Animal Husbandry & Dairying |
| Rajesh Ghadge | district | Pune | `officer.pune@gov.in` | `DSO-MH-002` | District Animal Health Officer | Department of Animal Husbandry & Dairying |
| Anjali Kulkarni | district | Ahmednagar | `officer.ahmednagar@gov.in` | `DSO-MH-003` | District Animal Health Officer | Department of Animal Husbandry & Dairying |

### State Animal Husbandry Officer (1)
| Name | Role | Jurisdiction | Official Email | Employee ID | Designation | Organization |
|---|---|---|---|---|---|---|
| Dr. Kavita Sharma | state | Maharashtra | `director.state@gov.in` | `SAHO-MH-002` | Additional Director (Epidemiology) | Department of Animal Husbandry & Dairying |

---

## 6. Proposed Authentication Flow

```
                      User Opens Login Screen
                                 │
                                 ▼
                     Selects Operational Role
                  (Farmer / Vet / Lab / DSO / State)
                                 │
                                 ▼
                     Official Email Input
                (e.g., "vet.pune@gov.in") — Empty by default
                                 │
                                 ▼
                 Clicks "Verify Official Credentials"
                                 │
                                 ▼
                POST /api/auth/verify-official-email
                     Body: { email, role }
                                 │
                                 ▼
             Backend Queries MongoDB:
             User.findOne({
               email: normalizedEmail,
               role: selectedRole,
               accountType: 'government',
               active: true
             })
                                 │
                 ┌───────────────┴───────────────┐
                 │                               │
             MATCH FOUND                     NO MATCH
                 │                               │
                 ▼                               ▼
     Backend returns HTTP 200:            Backend returns HTTP 403/404:
     { verified: true, name, role,       "This official email is not authorized
       district, designation,             for the selected operational role."
       employeeId, accountActivated }     (Error displayed on frontend)
                 │
                 ▼
     Frontend dynamically renders
     Government Identity Card
                 │
         ┌───────┴───────┐
         │               │
  accountActivated?      │
         │               │
        NO              YES
         │               │
         ▼               ▼
  First-Time Form:      Existing User Form:
  Create Password       Enter Password
  Confirm Password       │
         │               ▼
         ▼              POST /api/auth/login
  POST /api/auth/        │
  activate-official      ▼
         │              JWT Issued
         ▼               │
  Bcrypt Password Hash,  ▼
  accountActivated: true, Enters Role Dashboard
  JWT Issued             (Scoped to Assigned District)
         │
         ▼
  Enters Role Dashboard
  (Scoped to Assigned District)
```

---

## 7. Next Steps

1. Update `backend/src/seed.js` with the complete 10-officer government hierarchy while preserving all 7 demo accounts and idempotency.
2. Refine `frontend/src/main.jsx` to remove any hardcoded emails or static hints, ensuring pure dynamic MongoDB-driven identity verification.
3. Update automated test suites (`backend/test_hybrid_auth.js` and `backend/test_http_auth.js`) to verify all 10 officers, district immutability, first-time activation, and wrong-role rejection.
4. Document the completed implementation in `docs/GOVERNMENT_MULTI_DISTRICT_AUTH_AFTER.md`.
