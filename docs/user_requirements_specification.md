# 👥 Blipto: User Requirements Specification (URD)

## 1. Overview
Blipto unifies three primary user personas into a single, high-efficiency hyper-local ecosystem:
1. **The Consumer (Shopper):** Seeks rapid (<20m) everyday essentials from trusted neighborhood stores with transparent flat pricing and zero phantom stockouts.
2. **The Local Merchant (Kirana Owner):** Seeks expanded catchment area and predictable digital cashflow without costly warehouse leases, commissions, or complex desktop ERPs.
3. **The Store Delivery Partner (In-House Staff):** Underutilized store staff executing local fulfillment on bicycles/scooters with easy OTP/photo doorstep handoffs.

---

## 2. Detailed Persona Requirements

### Persona A: The Consumer (Shopper)
- **[REQ-CON-01] Hyper-Local Store Discovery:**
  - Automatic detection of user GPS location.
  - Render stores strictly within a 500m – 2000m radius with real-time open/closed and capacity indicators.
  - Display estimated delivery time (e.g., "12–18 mins").
- **[REQ-CON-02] Real-Time Stock Browsing:**
  - SKU counts reflect exact in-store shelf availability.
  - Automatic disabling of "Add to Cart" if stock $\le 0$.
  - "Low Stock" indicator when stock $\le 2$.
- **[REQ-CON-03] Honest & Flat Checkout:**
  - Clear billing: Item subtotal + Flat store delivery fee (₹0 - ₹15) + Tax.
  - Strict prohibition of dark patterns: No surge fees, no rain fees, no small-order penalties.
- **[REQ-CON-04] Live Delivery Tracking:**
  - Dynamic stepper: `Order Placed` $\rightarrow$ `Being Packed at Store` $\rightarrow$ `Out for Delivery (Staff en route)` $\rightarrow$ `Delivered`.
  - Display delivery staff phone number and unique 4-digit verification OTP.
- **[REQ-CON-05] Instant Photo Dispute & Wallet Refund:**
  - 15-minute post-delivery window to report damaged, expired, or missing items.
  - Mandatory camera photo capture with instant automated wallet credit refund upon algorithmic validation.

---

### Persona B: The Local Merchant (Store Owner)
- **[REQ-MER-01] Mobile-First Barcode Inventory Intake:**
  - Continuous camera scanning mode for fast shelf auditing.
  - Global SKU database integration (instant auto-fill of title, image, and category from barcode).
  - One-tap stock increment/decrement and price updates.
- **[REQ-MER-02] High-Priority Order Dispatch Terminal:**
  - Continuous audio chime and haptic ping on new incoming orders.
  - 60-second acceptance countdown timer.
  - Clear packing checklist with item locations and quantities.
- **[REQ-MER-03] Capacity Management & "Busy Mode":**
  - Live counter of active in-flight deliveries.
  - "Busy Mode" toggle when in-store footfall surges, triggering automatic peer order spillover.
- **[REQ-MER-04] Digital Escrow & Instant Payouts:**
  - Replaces traditional informal credit (*udhari*) with guaranteed digital settlement.
  - View real-time escrow balance and initiate instant UPI payout upon verified handoff.

---

### Persona C: The In-House Delivery Staff
- **[REQ-DLV-01] In-Store Staff Delivery Terminal:**
  - Mobile task feed showing assigned orders, customer distance (<2 km), and turn-by-turn map directions.
  - One-tap customer call mask.
- **[REQ-DLV-02] Secure Dual Handoff Verification:**
  - Input and verify 4-digit customer OTP.
  - Fallback option: Geotagged camera photo proof of handoff at customer door.

---

### Persona D: The App Owner (Platform Super-Admin)
- **[REQ-ADM-01] Real-Time Control Tower & Master Data Persistence:**
  - Full platform telemetry: live GMV, active stores, order stream, inventory counts.
  - Master data export: One-click export of platform state into structured JSON and tabular CSV.
- **[REQ-ADM-02] Safe Escrow & Payout Control:**
  - Audit locked funds, disbursed funds to kiranas, and customer wallet refunds.
- **[REQ-ADM-03] Store Geofence & Governance:**
  - Adjust delivery radius per store (0.5 km to 3.0 km) and manage seller de-platforming.

---

### Universal UX Standard
- **[REQ-UX-01] Natural Everyday Language (Zero Academic/Technical Jargon):**
  - Customer screens use plain, reassuring phrases ("Your Trusted Neighborhood Kiranas", "Clean & Honest Bill", "Instant Refund: Return Bad Items", "Delivery Code").
  - Merchant screens speak the shopkeeper's language ("Kirana Shop Dashboard", "Shop Rush? (Busy Mode)", "My Earnings & Bank Payouts", "No More Udhari!").
  - Delivery screens provide direct instructions ("Orders to Deliver", "Ask Customer for 4-Digit Code", "Customer not answering? Take photo of packet at door").
- **[REQ-UX-02] Always-Visible Order Tracking & Responsive Feed:**
  - An unmistakable "My Orders & Delivery Tracking" card remains anchored on the Customer feed at all times, accompanied by an AppBar shortcut button.
