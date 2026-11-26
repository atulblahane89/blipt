# ⚡ Blipto — Decentralized Hyper-Local Quick Commerce

> **Blipto** connects neighborhood retail stores (kiranas) directly with local consumers for ultra-fast (<15 min) fulfillment within a 500m–2km radius, completely eliminating dark-store capital expenditures and delivery fleet payroll.

---

## 📱 One Unified Product — Four Operating Roles

Blipto is **one integrated commercial platform**, serving four key roles:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                 BLIPTO                                      │
├───────────────────────────────────────┬─────────────────────────────────────┤
│             Mobile App Flows          │          Owner Platform             │
│        (http://localhost:3000)        │      (http://localhost:8080/admin)  │
│                                       │                                     │
│  🛒 Customer (Neighborhood Shopper)   │  👑 App Owner Dashboard             │
│  🏪 Shopkeeper (Local Kirana Merchant)│     • Live Sales (GMV) & Revenue    │
│  🛵 Delivery Boy (In-House Store Boy) │     • Geofence Radius Controls      │
│                                       │     • Customer Complaints & Refunds │
│                                       │     • One-Click JSON & CSV Backup   │
└───────────────────────────────────────┴─────────────────────────────────────┘
```

---

## 🗣️ Everyday Conversational Language Standard

To ensure neighborhood shopkeepers, consumers, and delivery boys never have to "search for a dictionary", all academic and textbook jargon has been replaced with plain, natural words:

| Area | Traditional Tech Jargon | Blipto Everyday Language |
| :--- | :--- | :--- |
| **Customer** | Dynamic Spillover Engine | *"Shop is busy! A friendly partner shop nearby will pack your order."* |
| **Customer** | Cryptographic Delivery OTP | **Delivery Code: 4192** *(Show this code to delivery boy)* |
| **Customer** | Automated Photo Dispute | **Instant Refund: Return Bad Items** |
| **Customer** | Zero-Surge Pricing | **Clean & Honest Bill (No Surprise Fees)** |
| **Merchant** | Peak-Load Spillover Toggle | **Shop Rush? (Busy Mode)** |
| **Merchant** | Digital Escrow Settlement | **My Earnings & Bank Payouts (No More Udhari!)** |
| **Merchant** | Mobile SKU Intake | **Add Items by Scanning Barcode** |
| **Delivery** | In-House Fulfillment Run | **Orders to Deliver (Nearby Kirana Stores)** |
| **Delivery** | Doorstep OTP Handoff | **Ask Customer for 4-Digit Delivery Code** |
| **Owner** | Platform Control Tower | **App Owner Dashboard & Master Data Hub** |

---

## 🚀 Running Blipto Locally

### 1. Prerequisites
- **Python 3.10+**
- **Flutter SDK 3.13+**

### 2. Start the Backend API & Owner Dashboard
```powershell
python -m backend.app
```
- API Base URL: `http://localhost:8080/v1`
- **Owner Command Center:** `http://localhost:8080/admin`

### 3. Start the Mobile Web App
```powershell
flutter build web --release
python -m http.server 3000 --directory build/web
```
- Open **`http://localhost:3000`** in any desktop or mobile browser.
- Use the top green bar to switch freely between **Customer**, **Shopkeeper**, and **Delivery Boy**.

---

## 🧪 Running Automated Tests
```powershell
python -m unittest discover tests
```
Includes 13 end-to-end integration and unit tests covering:
- Store discovery and Haversine geo-filtering.
- Real-time catalog intake and inventory buffer locks.
- Dynamic partner store order spillover.
- Digital escrow hold, OTP release, and dispute refunds.
- Owner admin analytics, geofence radius updates, and master JSON/CSV data export.

---

## 📂 Documentation Directory (`docs/`)
- [docs/RTM.md](file:///d:/blipto/docs/RTM.md) — Requirements Traceability Matrix (`REQ-CON`, `REQ-MER`, `REQ-DLV`, `REQ-ADM`, `REQ-UX`).
- [docs/system_design_document.md](file:///d:/blipto/docs/system_design_document.md) — System Design Document (Architecture & Topology).
- [docs/user_requirements_specification.md](file:///d:/blipto/docs/user_requirements_specification.md) — User Requirements Document.
- [docs/use_case_specifications.md](file:///d:/blipto/docs/use_case_specifications.md) — Use Case Specifications across all personas.
- [docs/openapi_spec.yaml](file:///d:/blipto/docs/openapi_spec.yaml) — OpenAPI 3.0 specification for backend endpoints.
- [docs/security_and_privacy_assessment.md](file:///d:/blipto/docs/security_and_privacy_assessment.md) — Security & Fraud Prevention Controls.
