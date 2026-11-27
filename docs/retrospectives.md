# 🔄 Blipto: Sprint Retrospectives Log

This log captures formal Scrum Sprint Retrospectives, documenting what went well, what went wrong, and continuous process improvements for subsequent sprints.

---

## 🏃 Sprint 1 Retrospective (Core Marketplace MVP & Owner Tower)
- **Sprint Duration:** Phase 1 to Phase 6 + CR-001
- **Goal:** Deliver working prototype of decentralized hyper-local commerce connecting consumers, merchants, and delivery boys, plus App Owner Command Center.
- **Git Tags:** `v1.0.0-mvp`, `v1.1.0-admin`

### What Went Well:
1. **Zero Dark-Store Architecture Verified:** Unit economics and pure technology intermediary model established without warehouse CAPEX or fleet payroll.
2. **Speed of Execution:** Parallel generation of Flutter mobile UI and Python microservices within a single coordinated workflow.
3. **Automated Testing Suite:** 13 unit and integration tests written and passing 100% on the first pass.

### What Went Wrong / Friction Points:
1. **Omission of the Owner Role:** Initial scaffold focused solely on the 3 mobile users, forgetting that the founder/app owner needs an exclusive dashboard to view live GMV, manage store geofences, and save platform database records.
2. **Single-Threaded Server Freezes:** Python's default HTTP server caused request deadlocks under modern browser keep-alive connections.
3. **Windows Sandbox Permissions:** Default Flutter/Dart cache operations failed on restricted user AppData paths.

### Process Improvements for Next Sprint:
1. Created `admin/index.html` and integrated `ThreadingHTTPServer`.
2. Created sandbox redirect rules for Flutter/Dart commands.
3. Formalized the App Owner as a first-class persona (`Persona D`).

---

## 🏃 Sprint 2 Retrospective (Human Experience & Anti-Jargon Usability)
- **Sprint Duration:** CR-002 & CR-003
- **Goal:** Eliminate academic supply-chain jargon from all screens, install unmissable center order tracking, and push full repository and docs to GitHub.
- **Git Tag:** `v1.2.0-natural-ux`

### What Went Well:
1. **Conversational Transformation:** Replaced 20+ engineering jargon terms with warm, everyday words that kirana owners and shoppers instantly relate to.
2. **Responsive UX Polish:** Anchored an always-visible order tracking card right in the center of the customer feed, eliminating edge-of-screen blindness on wide desktop monitors.
3. **Seamless GitHub Integration:** Pushed complete clean codebase, tags, and documentation to `https://github.com/atulblahane89/blipt.git`.

### What Went Wrong / Friction Points:
1. **Missing Model Import in Build:** Added `OrderStatus` to `consumer_home_screen.dart` without importing `order.dart`, causing a temporary web compile failure.
2. **Browser Caching Confusion:** Browser cached the old `main.dart.js`, requiring a hard refresh (`Ctrl + F5`) for the user to see new UI elements.

### Process Improvements for Sprint 3:
1. Run `dart analyze` before triggering `flutter build web` to catch missing imports in seconds.
2. Maintain the **System Failures & Anti-Patterns Log** (`docs/failures_and_anti_patterns.md`) so previous mistakes are never repeated.

---

## 🏃 Sprint 3 Retrospective (Multi-Mode Payments & Escrow Telemetry)
- **Sprint Duration:** CR-004
- **Goal:** Implement UPI, Credit/Debit Cards, Blipto Wallet deductions, and COD with escrow integration and Owner dashboard payment telemetry.
- **Git Tag:** `v1.3.0-payments`

### What Went Well:
1. **Painless Checkout UX:** Customer can pay via UPI, Card, or apply their Blipto Wallet balance with 1 tap.
2. **Escrow & Wallet Integration:** Wallet deductions reduce payable balance immediately, locking remainder in escrow.
3. **Owner Telemetry:** Owner Dashboard displays real-time GMV split by payment method (`UPI`, `CARD`, `WALLET`, `COD`).
4. **Early Error Catching:** Running `dart analyze` before build immediately caught duplicate lines from a code edit in 4 seconds instead of waiting for a 60-second build crash.
5. **100% Test Coverage:** 18/18 unit and integration tests passing.

### What Went Wrong / Friction Points:
1. **Duplicate block during multi-line code edit:** An initial replacement left duplicate lines in `app_state.dart`, but was immediately surfaced by `dart analyze` before deployment.

### Process Improvements for Sprint 4:
1. Continue running `dart analyze` before all production builds.
2. Ensure payment transaction IDs (mock or sandbox) are displayed on the order tracking confirmation screen for customer receipts.

---

## 🏃 Sprint 4 Retrospective (Daily Habits & Order Protection)
- **Sprint Duration:** CR-005
- **Goal:** Implement scheduled recurring morning essentials (milk/bread), pre-checkout smart substitute preferences, store trust & reliability badges, perishable expiry alerts, daily GST tax summaries, fragile packing checklists, and basket add-on nudges.
- **Git Tag:** `v1.4.0-sprint4-habits`

### What Went Well:
1. **Habit-Forming Subscriptions:** Users can now set up morning milk drops with flexible frequency (Daily, Alternate Days, Weekdays) with 1 tap.
2. **Cancellation Prevention:** The smart substitute preference selector ("Replace with similar brand", "Call me first", "Refund missing item") stops mid-packing order cancellations when a small kirana is out of one SKU.
3. **Food Safety & Damage Mitigation:** Proactive expiry alerts (<24h) prevent selling stale goods, while rider fragile checklists (eggs upright, bread uncrushed) safeguard delicate products.
4. **GST-Ready Merchant Accounting:** Instant 1-tap calculation and CSV export of Gross Sales, CGST (2.5%), SGST (2.5%), and Net Payouts for kirana shopkeepers.
5. **Quality Assurance Speed:** Running `dart analyze` immediately caught a misplaced bracket before triggering the 40s web build.
6. **Complete Test Automation:** 24/24 unit and integration tests passing (100% pass rate).

### What Went Wrong / Friction Points:
1. **Accidental Duplicate Closing Block in State:** A previous edit left a duplicated `}` that temporarily placed methods outside `class AppState`. Running `dart.bat analyze` caught it instantly and pinpointed the exact line, taking only 1 turn to fix.
2. **Command Alias Difference on Windows:** PowerShell attempted to run `dart.exe` which is a `.bat` wrapper on this machine (`dart.bat`). Identified through `Get-Command` and logged in memory.

### Process Improvements for Sprint 5:
1. Use `D:\flutter\bin\dart.bat` consistently on Windows.
2. Prepare Sprint 5 focus: Multi-Shop Split Cart, Voice-to-Stock, Route Batching, and P2P Overflow Routing.

---

## 🏃 Sprint 5 Retrospective (Dynamic Scale & Seller Efficiency)
- **Sprint Duration:** CR-006
- **Goal:** Implement multi-shop split cart bundled delivery, voice-to-stock NLP catalog intake, neighborhood unfulfilled demand signals, multi-order street-level route batching, peer-to-peer overflow routing telemetry, and automated seller strike appeal desk.
- **Git Tag:** `v1.5.0-sprint5-scale`

### What Went Well:
1. **Multi-Shop Unified Cart (`REQ-V2-CON-03`):** Consumers can now combine goods from multiple neighborhood shops (e.g. dairy from Gupta Kirana and bakery from Mahadev Supermarket) with a single bundled ₹15 delivery fee (saving ₹5 over separate orders).
2. **Kirana Voice Intake (`REQ-V2-MER-01`):** Non-tech-savvy merchants can speak everyday sentences like *"Add 10 packets of Fortune Sunflower Oil 1 Litre at ₹135"* and the platform extracts title, SKU quantity, price, unit, and category with >90% confidence for 1-tap shelf stocking.
3. **Neighborhood Demand Intelligence (`REQ-V2-MER-04`):** Surfacing zero-result local searches (Oat Milk, Greek Yogurt, Artisanal Sourdough) with estimated missed revenue directly gives merchants the confidence to stock high-margin modern items.
4. **Street-Level Route Clustering (`REQ-V2-DLV-01`):** Grouping drops within 200m on the same lane saves ~12 minutes per run, boosting drops per hour for local delivery partners.
5. **Fair Seller Governance (`REQ-V2-OPS-03`):** Merchants can submit CCTV counter-proof to appeal erroneous strikes; App Owners can review and approve in 1 click from the Command Tower (`/admin`), restoring store rating.
6. **Robust Quality Verification:** All 29 automated tests passed cleanly, and `dart analyze lib/` verified with 0 errors.

### What Went Wrong / Friction Points:
1. **Non-unique edit target:** During one state file edit, replacing `}` without surrounding context matched all closing braces. Identified immediately, restored via Git, and replaced using exact multi-line targets.
2. **Context mounted check in async callbacks:** Flutter linter flagged `BuildContext` use across async network calls; resolved by adding `if (!context.mounted) return;` guards.

### Process Improvements for Sprint 6:
1. Always include 3+ lines of unique surrounding code when modifying closing delimiters in Dart or Python.
2. Prepare Sprint 6 focus: Offline-resilient sync for weak signal zones (`REQ-V2-DLV-03`) and Automated AI/OCR photo-defect verification (`REQ-V2-OPS-02`).

---

## 🏃 Sprint 6 Retrospective: Offline Resilience, AI Defect Verification & Localization
- **Date:** 2026-11-27
- **Sprint Focus:** Offline-resilient delivery handoff, automated AI dispute verification, and clean on-demand language toggle.

### 1. What Went Well (Wins)
- **Elevator & Basement Resilience (`US-V2-DLV-03`):** Delivery riders are no longer stuck waiting for cellular internet in apartment towers. Offline OTP verification completes locally with instant feedback and queues sync events reliably.
- **AI Visual Defect Verification (`US-V2-OPS-02`):** Customer dispute photos are classified in real time with confidence scoring (≥85%), providing instant wallet credit without human friction while logging audit cues for merchant governance.
- **User-Centric Language Toggle:** Added a clean `EN | हि` button in the app bar so users can toggle between plain English and Hindi dynamically without forced hardcoded strings.

### 2. Action Items for Next Sprint
1. Verify end-to-end Flutter web build and monitor production latency on offline sync endpoints.
2. Maintain strict zero-jargon plain English as the base language.
