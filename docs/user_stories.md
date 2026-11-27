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

### [US-CON-06] Multi-Mode Payment (UPI, Credit/Debit Cards & Blipto Wallet)
- **User Story:** As a customer, I want to pay using UPI (Google Pay, PhonePe, Paytm), Credit/Debit Card, my Blipto Wallet balance, or Cash on Delivery, so that I have complete freedom at checkout without having to hunt for exact physical cash.
- **Acceptance Criteria:**
  - **Given** items in the cart and a non-zero wallet balance,
  - **When** the customer views the payment options,
  - **Then** they can apply their Blipto Wallet balance with 1 tap, reducing the payable amount.
  - **And** the remaining amount can be completed using UPI, Card, or Cash on Delivery.
  - **And** upon order completion, funds are safely held in escrow until doorstep verification.

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

---

## 🚀 Blipto V2 Product Backlog (New Features)

### 🛒 Module 1: Customer App (V2)

#### [US-V2-CON-01] Scheduled & Recurring Daily Essentials *(Implemented & Verified in Sprint 4)*
- **User Story:** As a busy household customer, I want to set up an automatic recurring morning delivery for daily essentials (like milk, bread, and eggs at 7:00 AM), so that I never have to wake up and place a manual order every morning.
- **Acceptance Criteria:**
  - **Given** items in the store catalog (e.g. fresh milk packet),
  - **When** the customer selects "Subscribe Daily / Alternate Days" and chooses a time slot (e.g. 6:30 AM – 7:30 AM),
  - **Then** orders are auto-scheduled in the background with automatic wallet/card deduction.
  - **And** the customer can pause or cancel the subscription anytime with 1 tap before 10:00 PM the previous night.

#### [US-V2-CON-02] Pre-Checkout Smart Substitute Approval *(Implemented & Verified in Sprint 4)*
- **User Story:** As a customer, I want to pre-approve backup substitute items in case my preferred brand is physically missing from the shelf, so that my order isn't canceled or delayed by phone calls.
- **Acceptance Criteria:**
  - **Given** an item in the cart (e.g. Amul Milk 500ml),
  - **When** the customer checks out,
  - **Then** they can choose a substitute preference: *"Replace with similar brand"*, *"Call me first"*, or *"Refund missing item immediately"*.
  - **And** the shopkeeper's packing screen automatically highlights the pre-approved substitute if the main SKU is exhausted.

#### [US-V2-CON-03] Multi-Shop Split Cart (Single Delivery Zone) *(Implemented & Verified in Sprint 5)*
- **User Story:** As a customer, I want to add fresh veggies from the green grocer and packed snacks from the general kirana in one checkout, so that I don't have to place two separate orders and pay double checkout fees.
- **Acceptance Criteria:**
  - **Given** stores within the same 500m hyper-local zone,
  - **When** the customer adds items from Store A and Store B into their cart,
  - **Then** the cart cleanly groups items by store and shows one unified bill with a combined hyper-local delivery fee.
  - **And** both store terminals receive their respective packing lists simultaneously.

#### [US-V2-CON-04] Store Trust & Reliability Badges *(Implemented & Verified in Sprint 4)*
- **User Story:** As a customer, I want to see trust badges (like "Verified Neighborhood Partner", "99% On-Time Delivery", "Freshness Rated 4.9★"), so that I can buy with complete confidence from trusted local merchants.
- **Acceptance Criteria:**
  - **Given** the store list on the home screen,
  - **When** a store maintains $\ge 4.8$ rating and 0 strikes,
  - **Then** a prominent green badge *"Trusted Neighborhood Kirana"* is shown.
  - **And** stores with fast packing speeds display *"Lightning Packer (<5 min)"*.

---

### 🏪 Module 2: Seller App (V2)

#### [US-V2-MER-01] Voice-to-Stock & Shelf Photo Catalog Assist *(Implemented & Verified in Sprint 5)*
- **User Story:** As a kirana shopkeeper who dislikes typing on small phone keyboards, I want to speak item names or snap a photo of my shelf, so that items are instantly recognized and added to my digital shop.
- **Acceptance Criteria:**
  - **Given** the shopkeeper opens the "Add Items" screen,
  - **When** they hold the mic and say *"Add 10 packets of Fortune Sunflower Oil 1 Litre at ₹135"*,
  - **Then** the voice engine extracts Name, SKU, Quantity, and Price into the form automatically.
  - **And** taking a photo of shelf products auto-suggests barcode matches.

#### [US-V2-MER-02] Low-Stock & Perishable Expiry Alerts *(Implemented & Verified in Sprint 4)*
- **User Story:** As a shopkeeper selling perishables (milk, bread, paneer), I want proactive expiry and low-stock alerts, so that I don't accidentally sell expired goods or run out of fast-moving staples.
- **Acceptance Criteria:**
  - **Given** perishables in inventory,
  - **When** an item is 24 hours away from expiry or stock hits $\le 2$,
  - **Then** a high-priority yellow notification appears on the Kirana Dashboard.
  - **And** the item price can be marked down with 1 tap for quick clearance.

#### [US-V2-MER-03] Daily Settlement & GST-Ready Tax Summary *(Implemented & Verified in Sprint 4)*
- **User Story:** As a shopkeeper, I want a clean 1-page daily earnings and GST-ready tax summary, so that I can share it with my accountant and track my business income without bookkeeping hassles.
- **Acceptance Criteria:**
  - **Given** completed orders for the day,
  - **When** the merchant visits "My Earnings",
  - **Then** they can tap "Download Daily GST Summary" to get a clean PDF/CSV showing Gross Sales, Tax Breakdowns, Commission, and Net Bank Transfer amount.

#### [US-V2-MER-04] Neighborhood Unfulfilled Demand Signals *(Implemented & Verified in Sprint 5)*
- **User Story:** As a shopkeeper, I want to see what items nearby customers searched for that were missing from local shelves, so that I know exactly what new stock to purchase from wholesalers to maximize profit.
- **Acceptance Criteria:**
  - **Given** consumer searches within 1.5km that returned 0 results,
  - **When** the shopkeeper checks "Local Demand Insights",
  - **Then** a ranked list of high-demand missing items is shown (e.g. *"28 neighbors searched for Oat Milk this week"*).

---

### 🛵 Module 3: Delivery Partner App (V2)

#### [US-V2-DLV-01] Multi-Order Route Batching Along Same Street *(Implemented & Verified in Sprint 5)*
- **User Story:** As a store delivery boy, I want the app to batch multiple orders going to the same apartment building or street into one trip, so that I can make more deliveries per hour without zig-zagging.
- **Acceptance Criteria:**
  - **Given** 2 or more orders with delivery addresses within 200m of each other,
  - **When** the delivery feed loads,
  - **Then** the system groups them into a single "Batched Run" with an optimized sequential drop order.

#### [US-V2-DLV-02] Fragile & Cold Packing Checklist *(Implemented & Verified in Sprint 4)*
- **User Story:** As a delivery boy, I want a quick visual checklist before leaving the shop (e.g. *"Egg crate inside? Ice cream bag sealed?"*), so that goods don't get damaged on my bike.
- **Acceptance Criteria:**
  - **Given** an order containing fragile items (eggs, bread) or cold dairy (ice cream, milk),
  - **When** the delivery boy marks "Picked Up from Counter",
  - **Then** a quick checklist pops up requiring 1 tap to confirm fragile/cold items are secured.

#### [US-V2-DLV-03] Offline-Resilient Sync for Weak Signal Zones
- **User Story:** As a delivery boy entering apartment basements or elevators with zero mobile signal, I want to verify delivery codes offline, so that I don't get stuck waiting for internet.
- **Acceptance Criteria:**
  - **Given** a device with no cellular data,
  - **When** the delivery boy enters the customer's 4-digit code,
  - **Then** the app validates against locally cached cryptographic order hash, shows green success, and queues the sync to server as soon as connection resumes.

---

### ⚙️ Module 4: Platform Engine & Owner Dashboard (V2)

#### [US-V2-OPS-01] Peer-to-Peer Overflow Routing Across Partner Shops *(Implemented & Verified in Sprint 5)*
- **User Story:** As the app owner, I want orders to automatically overflow across rival partner stores when one shop is slammed with foot traffic, sharing margins so both stores stay profitable.
- **Acceptance Criteria:**
  - **Given** Store A has Busy Mode on or queue full,
  - **When** an order is placed,
  - **Then** order is routed to Store B carrying matching inventory within 1.2km.
  - **And** Store B gets product sale revenue while Store A receives 1.5% referral credit.

#### [US-V2-OPS-02] Automated AI/OCR Photo-Defect Verification
- **User Story:** As the app owner, I want an automated image classifier to inspect customer dispute photos (detecting broken egg yolk, cracked containers, torn bags), so that genuine claims are refunded instantly while fraudulent claims are flagged.
- **Acceptance Criteria:**
  - **Given** a customer dispute photo upload,
  - **When** the image is evaluated,
  - **Then** damaged packaging or spoiled item is visually confirmed $\ge 85\%$ confidence for instant refund.
  - **And** duplicate/recycled stock photos are automatically rejected.

#### [US-V2-OPS-03] Automated Seller Strike Appeal Workflow *(Implemented & Verified in Sprint 5)*
- **User Story:** As a shopkeeper accused of a strike due to customer error, I want to submit counter-proof (e.g. counter CCTV packing photo), so that honest merchants are not unfairly penalized.
- **Acceptance Criteria:**
  - **Given** a merchant receiving a defect strike,
  - **When** they tap "Appeal Strike" in their dashboard and upload counter-proof,
  - **Then** the appeal appears in the Owner Dashboard at `/admin` under "Dispute Desk" with 1-click Approve/Dismiss buttons.

#### [US-V2-OPS-04] Same-Shop Basket Add-On Nudges *(Implemented & Verified in Sprint 4)*
- **User Story:** As a customer adding tea powder to my cart, I want smart suggestions from the same shop (like sugar, milk, or biscuits), so that I don't forget essentials.
- **Acceptance Criteria:**
  - **Given** items in the cart,
  - **When** the customer views their cart,
  - **Then** relevant complementary items from the *same store* are suggested with a 1-tap "+ Add" button.
