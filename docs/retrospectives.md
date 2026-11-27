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
