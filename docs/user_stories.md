# 📖 Blipto: User Stories & Acceptance Criteria

This document maintains the canonical **User Story Backlog** for Blipto across all 4 operational personas, formatted in agile *As a... I want to... So that...* with executable *Given-When-Then* Acceptance Criteria.

---

## 🛒 Persona 1: Neighborhood Customer (Shopper)

### [US-CON-01] Hyper-Local Kirana Discovery
- **User Story:** As a neighborhood resident, I want to see open grocery stores within 500m to 2km from my home, so that I can order daily essentials with guaranteed 15-minute delivery.
- **Acceptance Criteria:**
  - **Given** the customer opens Blipto with location enabled,
  - **When** the home screen loads,
  - **Then** only stores within $\le 2000\text{m}$ are displayed, sorted by distance, with real-time delivery estimates (e.g. "12-15 mins").
  - **And** stores marked as closed or out-of-catchment are not displayed.

### [US-CON-02] Real-Time Shelf Stock Verification
- **User Story:** As a shopper, I want to see exact stock numbers for every item, so that I never face last-minute item cancellations after placing my order.
- **Acceptance Criteria:**
  - **Given** an item on the store shelf has 0 physical stock,
  - **When** the customer views the catalog,
  - **Then** the "ADD" button is disabled and marked "Out of Stock".
  - **And** when stock is $\le 2$, a warning tag "Only X Left" is displayed.

### [US-CON-03] Clean & Transparent Billing
- **User Story:** As a customer, I want to see a flat, honest bill with zero surge fees or hidden packaging charges, so that I feel respected and never tricked.
- **Acceptance Criteria:**
  - **Given** items added to the cart,
  - **When** the customer views the checkout bill,
  - **Then** the bill breaks down only: Item Total + Delivery Boy Fee (₹0–₹15) + Tax.
  - **And** Surge Fee, Rain Fee, Platform Handling Fee, and Small Order Fees are strictly ₹0.

### [US-CON-04] Live Delivery Tracking & 4-Digit Doorstep Code
- **User Story:** As a customer, I want a permanent, centered order tracking card showing my live status and a 4-digit delivery code, so that I can verify handoff securely at my door.
- **Acceptance Criteria:**
  - **Given** an order is placed,
  - **When** the customer views the app,
  - **Then** an unmissable tracking card appears prominently in the center of the home screen and in the top bar.
  - **And** a 4-digit code (e.g., `4192`) is shown with the instruction: *"Tell this code to delivery person"*.

### [US-CON-05] Instant Photo Refund Without Call Centers
- **User Story:** As a customer who received damaged milk or spoiled eggs, I want to snap a photo and get an instant refund to my wallet, so that I don't have to wait on hold with customer support.
- **Acceptance Criteria:**
  - **Given** a delivered order within the last 15 minutes,
  - **When** the customer taps "Instant Refund: Return Bad Items", picks the item, and snaps a photo,
  - **Then** the item's full value is immediately credited to their Blipto wallet.
  - **And** the customer sees a green confirmation without human intervention.

---

## 🏪 Persona 2: Local Shopkeeper (Kirana Merchant)

### [US-MER-01] Barcode Stock Intake via Phone Camera
- **User Story:** As a kirana shopkeeper, I want to scan product barcodes with my phone camera to add stock, so that I don't need a computer, barcode gun, or expensive billing machine.
- **Acceptance Criteria:**
  - **Given** the merchant is in the Kirana Shop Dashboard,
  - **When** they tap "Add Items by Scanning Barcode" and point their camera at an EAN-13 barcode,
  - **Then** the product name, category, and unit are automatically filled from the catalog.
  - **And** tapping "Put on Shelf" instantly publishes the item to shoppers within 2km.

### [US-MER-02] Loud Order Dispatch Alerts & 60-Second Packing
- **User Story:** As a busy shopkeeper, I want an unmistakable audio chime when an order arrives, so that my counter staff can pack it in 60 seconds.
- **Acceptance Criteria:**
  - **Given** a customer places an order,
  - **When** the order reaches the merchant terminal,
  - **Then** a distinct sound alert plays and the screen highlights the packing checklist.

### [US-MER-03] "Shop Rush? (Busy Mode)" Order Spillover
- **User Story:** As a shopkeeper overwhelmed with evening counter rush, I want to toggle Busy Mode so nearby partner stores fulfill online orders without losing my customer base.
- **Acceptance Criteria:**
  - **Given** the store hits max capacity or the shopkeeper toggles "Busy Mode",
  - **When** a new order comes in,
  - **Then** the system automatically routes the order to the nearest verified partner store.
  - **And** the originating store earns a 1.5% referral credit without bearing fulfillment burden.

### [US-MER-04] Guaranteed Earnings & No More Udhari
- **User Story:** As a shopkeeper tired of informal credit (*udhari*), I want guaranteed digital payments held in escrow and released immediately on delivery, so that my working capital is secure.
- **Acceptance Criteria:**
  - **Given** an order is verified at the doorstep via OTP,
  - **When** handoff completes,
  - **Then** order funds move straight into "Ready to Transfer to Bank" on their ledger.

---

## 🛵 Persona 3: Delivery Partner (Store Delivery Boy)

### [US-DLV-01] Task Feed for Hyper-Local Drops
- **User Story:** As a store delivery boy, I want a clean list of pending deliveries within my immediate neighborhood (500m–2km), so that I can drop packets quickly on my bicycle or scooter.
- **Acceptance Criteria:**
  - **Given** packed orders ready at the store,
  - **When** the delivery boy opens the app,
  - **Then** orders appear with customer addresses, distance, and one-tap calling.

### [US-DLV-02] Doorstep Verification via 4-Digit Code or Photo
- **User Story:** As a delivery boy, I want to enter the customer's 4-digit code (or snap a photo if they aren't at the door), so that proof of delivery is undisputed.
- **Acceptance Criteria:**
  - **Given** the boy is at the customer doorstep,
  - **When** they enter the matching 4-digit code,
  - **Then** the delivery is marked complete and escrow funds are released to the store.
  - **And** if the customer is unreachable, taking a photo of the packet at the door marks delivery safely.

---

## 👑 Persona 4: App Owner (Platform Super-Admin)

### [US-ADM-01] Real-Time Platform Sales & Earnings Telemetry
- **User Story:** As the Blipto founder and app owner, I want a dedicated web command center to monitor live sales (GMV), 4.5% commission revenue, and active stores, so that I have complete oversight over operations.
- **Acceptance Criteria:**
  - **Given** the app owner visits `/admin`,
  - **When** the dashboard loads,
  - **Then** GMV, platform commission, escrow locked funds, merchant payouts, and live order counters update in real time.

### [US-ADM-02] Dynamic Store Geofence Radius Adjustment
- **User Story:** As the app owner, I want to adjust the delivery distance (0.5km to 3.0km) for any individual store, so that I can prevent late deliveries in congested neighborhoods.
- **Acceptance Criteria:**
  - **Given** a store in the admin dashboard,
  - **When** the owner changes the delivery radius slider and clicks Save,
  - **Then** the backend updates the catchment geofence immediately without restarting servers.

### [US-ADM-03] One-Click Master Data Persistence (JSON / CSV)
- **User Story:** As the app owner, I want to download the entire marketplace database in one click as JSON and CSV, so that I always own and preserve all business data locally.
- **Acceptance Criteria:**
  - **Given** the owner is in the "Save & Download All Data" tab,
  - **When** they click "Download Master JSON" or "Export Orders CSV",
  - **Then** a complete backup file containing stores, inventory, orders, escrow balances, and disputes is saved locally.
