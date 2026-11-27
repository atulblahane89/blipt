# 🛡️ Blipto: Failure Log, Mistakes & Anti-Patterns Guardrails

> **Purpose:** When a system, technical approach, architecture decision, or UX design fails, it is formally analyzed here with Root Cause Analysis (RCA) and mapped to an irreversible **Guardrail Rule**. Any future agent, developer, or sprint must check this log before writing code to ensure failed approaches are NEVER repeated.

---

## 🚫 Table of Logged Failures & Enforced Guardrails

| Issue ID | What Failed | Root Cause | Impact | Enforced Guardrail Rule |
| :--- | :--- | :--- | :--- | :--- |
| **FAIL-001** | Academic Supply-Chain Jargon in UI | Engineers named UI widgets after backend algorithms (*Dynamic Spillover Engine, Escrow Ledger, Zero Phantom Stockout*). | Users alienating, confusing, forced to "search for a dictionary". | **Rule: The Kirana & Doorstep Language Rule.** No backend algorithmic jargon on user screens. All labels must use plain, conversational, everyday words. |
| **FAIL-002** | Hiding Key Actions on Ultra-Wide Monitors | Placed the order tracking button as a tiny unlabelled icon in the top-right app bar. | On wide desktop screens (1920px+), the button stretched 1000px away from the user's focus, making it virtually invisible. | **Rule: Center Feed Dominance Rule.** Core user actions (like Order Tracking) must be prominent cards anchored directly in the central feed, never solely relegated to far corners. |
| **FAIL-003** | Treating Blipto as Disjoint Siloed Products | Initial scaffold treated customer, merchant, and delivery as disconnected apps, ignoring the Owner Command Center. | Left the app founder without a centralized command center to oversee data, GMV, and store settings. | **Rule: Unified Commercial Platform Rule.** Blipto is strictly ONE integrated system: 3 mobile persona flows + 1 App Owner Command Center (`/admin`). |
| **FAIL-004** | Windows AppData Sandbox Access Denied | `flutter` and `dart` tried writing to user's restricted `C:\Users\...\AppData\Roaming` during analysis and builds. | Shell crashes with `FileSystemException: Access is denied`. | **Rule: Sandbox Temp Redirection Rule.** Always run Flutter/Dart commands on Windows with `$env:LOCALAPPDATA="d:\blipto\.temp"; $env:APPDATA="d:\blipto\.temp"`. |
| **FAIL-005** | Python HTTPServer Hang on Keep-Alive | Used Python's standard `http.server.HTTPServer` which is single-threaded. | Browser kept an HTTP connection open, causing subsequent API calls to block and hang indefinitely. | **Rule: Threading Server Mandate.** Never run standard `HTTPServer` in dev; always use `http.server.ThreadingHTTPServer`. |
| **FAIL-006** | Git Merge Conflict in Living Pipeline Manifest | Two parallel branches modified `.pipeline/project_manifest.json` independently without deterministic order. | Git merge conflict blocked automated releases. | **Rule: Orchestrator Manifest Merge Rule.** The Living Pipeline Engine script must merge JSON dictionaries deterministically before completing git merges. |

---

## 📋 Detailed Root Cause Analysis (RCA) & Post-Mortems

### Post-Mortem FAIL-001: Academic Supply-Chain Jargon
- **Incident:** During initial testing, screens were packed with engineering terminology:
  - *"Decentralized Micro-Fulfillment Kiranas"*
  - *"Peak-Load Dynamic Spillover Engine"*
  - *"Cryptographic Delivery Verification OTP"*
  - *"Escrow Working Capital Ledger"*
- **Root Cause:** Developers directly mapped backend architecture class names into the UI presentation layer without translating into user empathy.
- **Remediation & Guardrail:**
  1. Every UI string must pass the *"Would a neighborhood kirana uncle or delivery boy understand this instantly?"* test.
  2. The table of approved terms in `docs/user_requirements_specification.md` must be adhered to strictly.

---

### Post-Mortem FAIL-002: Hidden Tracking Button on Ultra-Wide Screens
- **Incident:** When the user opened the app on a wide desktop display, they could not find the "Track Order" button.
- **Root Cause:** The tracking trigger was just an icon button (`receipt_long_outlined`) placed in the AppBar action list. On a 1080p/4K monitor, Flutter stretched the AppBar across the full monitor width, pushing the icon to the extreme edge far outside the natural viewing angle.
- **Remediation & Guardrail:**
  1. Important operational steps (Order Tracking, Checkout, Active Tasks) must have a dedicated, large card anchored right in the middle of the scrollable feed.
  2. The screen must have an empty state with clear text explaining what will appear when an order is created, rather than disappearing completely.

---

### Post-Mortem FAIL-005: Single-Threaded HTTP Server Blocking
- **Incident:** `curl` requests and frontend API calls randomly hung when testing the admin overview.
- **Root Cause:** Standard Python `http.server.HTTPServer` handles requests synchronously on a single thread. When modern web browsers (Chrome, Edge) open keep-alive connections to stream or cache data, the single thread stays busy, locking out any other client until the socket times out.
- **Remediation & Guardrail:**
  1. Backend server in `backend/app.py` must subclass `ThreadingHTTPServer`.
  2. Any future background server scripts must be multi-threaded by default.
