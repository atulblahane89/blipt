# 📋 Blipto: Use Case Specifications

---

## Use Case UC-01: Barcode Stock Intake & Shelf Synchronization
- **Primary Actor:** Local Merchant
- **Mapped Requirement:** `REQ-MER-01`, `REQ-CON-02`
- **Preconditions:** Merchant is logged into Blipto Merchant Hub with camera permissions granted.
- **Main Flow:**
  1. Merchant taps **"Quick Barcode Scan"**.
  2. Merchant points camera at product barcode (EAN-13 / UPC).
  3. System matches barcode against global master catalog:
     - *If match found:* Auto-fills Name, Brand, Category, Pack Size, and Default Image.
     - *If new SKU:* Prompts merchant to enter Name and Category.
  4. Merchant enters Selling Price (₹) and Shelf Quantity (e.g. 24 units).
  5. Merchant taps **"Sync to Shelf"**.
  6. Realtime database immediately broadcasts stock availability to all consumers within 2 km.
- **Postconditions:** Inventory active and purchasable in consumer app.

---

## Use Case UC-02: Peak-Load Capacity Detection & Dynamic Spillover
- **Primary Actor:** System Dispatch Engine / Merchant
- **Mapped Requirement:** `REQ-MER-03`, `REQ-OPS-01`
- **Preconditions:** Store A receives an order while its active delivery queue is full ($\ge 4$ orders) or Merchant has activated **"Busy Mode"**.
- **Main Flow:**
  1. Consumer places order for Store A.
  2. System detects Store A is at peak capacity or Busy Mode is enabled.
  3. System initiates **Dynamic Spillover Search**:
     - Scans for Partner Stores within 1.2 km carrying matching SKUs.
     - Selects Store B (nearest partner with available delivery bandwidth).
  4. System prompts Consumer: *"Store A is currently bustling! Fulfilling with Partner Store B (400m away) at exact same price and SLA."*
  5. Order is dispatched to Store B terminal.
  6. **Split Margin Execution:** Store B receives product margin; Store A receives 1.5% referral credit for originating the user session.
- **Postconditions:** Consumer receives order without delay; Store A retains loyalty revenue without breaking fulfillment SLA.

---

## Use Case UC-03: Doorstep Handoff & Escrow Release
- **Primary Actor:** Store Delivery Boy & Consumer
- **Mapped Requirement:** `REQ-DLV-01`, `REQ-DLV-02`, `REQ-MER-04`
- **Preconditions:** Order status is `Out for Delivery`.
- **Main Flow:**
  1. Delivery boy arrives at customer location within hyper-local radius.
  2. Boy taps **"Arrived at Doorstep"**.
  3. Boy requests 4-digit OTP generated on Consumer's tracking screen.
  4. Boy enters OTP into Delivery Terminal:
     - *Success:* System verifies OTP match.
     - *Offline/Exception:* Boy takes geotagged doorstep photo showing package and house door.
  5. System marks order status `Delivered`.
  6. Digital Escrow Engine automatically unlocks order settlement funds:
     - Merchant net payout is credited to their instant payout ledger.
     - Consumer receives delivery confirmation receipt.
- **Postconditions:** Order complete, funds settled into merchant wallet, review prompt displayed.

---

## Use Case UC-04: Automated Photo Dispute & Instant Escrow Refund
- **Primary Actor:** Consumer & Automated Governance Engine
- **Mapped Requirement:** `REQ-CON-05`, `REQ-OPS-02`
- **Preconditions:** Order marked `Delivered` within last 15 minutes.
- **Main Flow:**
  1. Consumer taps **"Report Item Issue"** on completed order.
  2. Consumer selects damaged/spoiled item (e.g., broken eggs, expired curd).
  3. App launches camera and requires live photo capture of defective item.
  4. Governance engine validates timestamp and order record.
  5. System triggers **Instant Refund**:
     - Full item value refunded directly to consumer wallet.
     - Seller escrow deduction held for review.
  6. Merchant terminal receives notification with photo evidence.
  7. If merchant incurs $\ge 3$ verified defect claims within a 30-day window, system triggers an automated Quality Audit Freeze (Three-Strike Rule).
- **Postconditions:** Consumer is made whole instantly; merchant quality accountability maintained without call centers.

---

## Use Case UC-05: App Owner Command Center & Master Data Export
- **Primary Actor:** App Owner (Super-Admin)
- **Mapped Requirement:** `REQ-ADM-01`, `REQ-ADM-02`, `REQ-ADM-03`
- **Preconditions:** Owner accesses the secure dashboard at `/admin`.
- **Main Flow:**
  1. Owner views real-time telemetry: Gross Merchandise Value (GMV), 4.5% commission revenue, escrow funds, and active delivery counts.
  2. Owner inspects specific stores and adjusts delivery catchment radius (e.g., from 1.5 km to 2.0 km) via geofence controls.
  3. Owner reviews the live customer orders stream and instant dispute refund log.
  4. Owner taps **"Download Master JSON"** or **"Export Orders CSV"**.
  5. System packages full database state into a downloadable master JSON or CSV file for local offline archival.
- **Postconditions:** Owner retains absolute custody of all marketplace records, financial ledgers, and operational parameters.
