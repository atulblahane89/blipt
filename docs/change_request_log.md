# 📝 Blipto: Change Request (CR) Audit Log

This document provides a human-readable audit trail of every **Change Request (CR)** executed against the project, detailing the prompt, blast radius, code/document impacts, and release tags.

---

## Change Request: `CR-001`
- **Date:** 2026-11-26
- **Prompt:** *"Integrate dedicated App Owner Admin Dashboard with Master Data Persistence & clean persona screen flows"*
- **Rationale:** The app founder needs exclusive command over the platform to monitor GMV, inspect store radius geofences, audit disputes, and export the database.
- **Impacted Requirements:** `REQ-ADM-01`, `REQ-ADM-02`, `REQ-ADM-03`, `REQ-CON-01`, `REQ-MER-02`, `REQ-DLV-01`
- **Files Modified:**
  - `admin/index.html` (New Owner Dashboard web interface)
  - `backend/app.py` (Added `/admin`, `/v1/admin/overview`, `/v1/admin/export-data`, `/v1/admin/stores/{id}/radius`)
  - `docs/system_design_document.md`
  - `docs/RTM.md`
- **Tests Added:** `tests/test_admin_and_data_persistence.py`
- **Release Tag:** `v1.1.0-admin`
- **Outcome:** **Verified & Merged**.

---

## Change Request: `CR-002`
- **Date:** 2026-11-26
- **Prompt:** *"Replace technical supply-chain jargon with natural, human-relatable language across consumer, merchant, delivery, and owner flows"*
- **Rationale:** Everyday kirana shopkeepers, neighborhood customers, and delivery boys should never have to search for a dictionary to understand what a button does.
- **Impacted Requirements:** `REQ-UX-01`
- **Files Modified:**
  - `lib/screens/role_switcher_bar.dart`
  - `lib/screens/consumer/consumer_home_screen.dart`
  - `lib/screens/consumer/cart_screen.dart`
  - `lib/screens/consumer/order_tracking_screen.dart`
  - `lib/screens/consumer/store_detail_screen.dart`
  - `lib/screens/consumer/dispute_screen.dart`
  - `lib/screens/merchant/merchant_hub_screen.dart`
  - `lib/screens/merchant/escrow_ledger_screen.dart`
  - `lib/screens/merchant/barcode_intake_screen.dart`
  - `lib/screens/delivery/delivery_task_screen.dart`
  - `admin/index.html`
- **Release Tag:** `v1.2.0-natural-ux`
- **Outcome:** **Verified & Merged**.

---

## Change Request: `CR-004`
- **Date:** 2026-11-27
- **Sprint:** Sprint 3
- **Prompt:** *"Implement Multi-Mode Payment through UPI, Credit and Debit Cards, and Blipto Wallet balance"*
- **Rationale:** Customers require flexible, instant digital payments without being forced into physical cash on delivery, while retaining escrow protections.
- **Impacted Requirements:** `REQ-PAY-01`, `REQ-CON-03`, `REQ-ADM-01`
- **Files Modified:**
  - `docs/user_stories.md`
  - `docs/RTM.md`
  - `backend/models.py`
  - `backend/app.py`
  - `lib/models/order.dart`
  - `lib/state/app_state.dart`
  - `lib/screens/consumer/cart_screen.dart`
  - `admin/index.html`
- **Tests Added:** `tests/test_payments.py`
- **Release Tag:** `v1.3.0-payments`
- **Outcome:** **Verified & Merged**.

---

## Change Request: `CR-005`
- **Date:** 2026-11-27
- **Sprint:** Sprint 4 (Daily Habits & Order Protection)
- **Prompt:** *"Implement Scheduled recurring daily essentials, pre-checkout smart substitute preferences, same-shop cart add-on nudges, store trust badges, merchant expiry alerts, daily GST summary, and fragile delivery checklist"*
- **Rationale:** Drive habit-forming repeat daily orders (milk/bread), protect small stores from cancellations when one brand runs out, and avoid item breakage during delivery.
- **Impacted Requirements:** `REQ-V2-CON-01`, `REQ-V2-CON-02`, `REQ-V2-CON-04`, `REQ-V2-MER-02`, `REQ-V2-MER-03`, `REQ-V2-DLV-02`, `REQ-V2-OPS-04`
- **Files Modified:**
  - `backend/models.py`
  - `backend/app.py`
  - `lib/models/inventory_item.dart`
  - `lib/models/order.dart`
  - `lib/state/app_state.dart`
  - `lib/screens/consumer/cart_screen.dart`
  - `lib/screens/consumer/consumer_home_screen.dart`
  - `lib/screens/consumer/store_detail_screen.dart`
  - `lib/screens/merchant/merchant_hub_screen.dart`
  - `lib/screens/merchant/escrow_ledger_screen.dart`
  - `lib/screens/delivery/delivery_task_screen.dart`
  - `admin/index.html`
- **Tests Added:** `tests/test_sprint4_habits_and_protection.py`
- **Release Tag:** `v1.4.0-sprint4-habits`
- **Outcome:** **Verified & Merged**.

---

## Change Request: `CR-006`
- **Date:** 2026-11-27
- **Sprint:** Sprint 5 (Dynamic Scale & Seller Efficiency)
- **Prompt:** *"Implement Multi-shop split cart, Voice-to-stock & shelf photo catalog intake, Neighborhood unfulfilled demand signals, Multi-order route batching along same street, Peer-to-peer overflow routing telemetry, and Automated seller strike appeal workflow"*
- **Rationale:** Enable consumers to combine groceries across specialty shops in one drop, cut catalog intake friction for non-tech-savvy kiranas, and prevent unfair penalties through owner strike appeal desks.
- **Impacted Requirements:** `REQ-V2-CON-03`, `REQ-V2-MER-01`, `REQ-V2-MER-04`, `REQ-V2-DLV-01`, `REQ-V2-OPS-01`, `REQ-V2-OPS-03`
- **Files Impacted:**
  - `backend/models.py`
  - `backend/app.py`
  - `admin/index.html`
  - `lib/models/order.dart`
  - `lib/state/app_state.dart`
  - `lib/screens/consumer/cart_screen.dart`
  - `lib/screens/merchant/barcode_intake_screen.dart`
  - `lib/screens/merchant/merchant_hub_screen.dart`
  - `lib/screens/merchant/escrow_ledger_screen.dart`
  - `lib/screens/delivery/delivery_task_screen.dart`
- **Tests Planned:** `tests/test_sprint5_scale_and_efficiency.py` (5 automated tests, 100% pass)
- **Release Tag:** `v1.5.0-sprint5-scale`
- **Outcome:** **Verified & Merged**.

---

## Change Request: `CR-003`
- **Date:** 2026-11-26
- **Prompt:** *"Add always-visible My Orders & Delivery Tracking card to customer feed and prominent Track Order button in AppBar"*
- **Rationale:** On wide monitors, the top-right icon was pushed far to the edge; users need an unmistakable card in the center of their feed.
- **Impacted Requirements:** `REQ-UX-02`
- **Files Modified:**
  - `lib/screens/consumer/consumer_home_screen.dart`
  - `lib/screens/consumer/order_tracking_screen.dart`
- **Release Tag:** `v1.2.0-natural-ux`
- **Outcome:** **Verified & Merged**.

---

## Change Request: `CR-004`
- **Date:** 2026-11-27
- **Sprint:** Sprint 3
- **Prompt:** *"Implement Multi-Mode Payment through UPI, Credit and Debit Cards, and Blipto Wallet balance"*
- **Rationale:** Customers require flexible, instant digital payments without being forced into physical cash on delivery, while retaining escrow protections.
- **Impacted Requirements:** `REQ-PAY-01`, `REQ-CON-03`, `REQ-ADM-01`
- **Files Modified:**
  - `docs/user_stories.md`
  - `docs/RTM.md`
  - `backend/models.py`
  - `backend/app.py`
  - `lib/models/order.dart`
  - `lib/state/app_state.dart`
  - `lib/screens/consumer/cart_screen.dart`
  - `admin/index.html`
- **Tests Added:** `tests/test_payments.py`
- **Release Tag:** `v1.3.0-payments`
- **Outcome:** **Verified & Merged**.

---

## Change Request: `CR-005`
- **Date:** 2026-11-27
- **Sprint:** Sprint 4 (Daily Habits & Order Protection)
- **Prompt:** *"Implement Scheduled recurring daily essentials, pre-checkout smart substitute preferences, same-shop cart add-on nudges, store trust badges, merchant expiry alerts, daily GST summary, and fragile delivery checklist"*
- **Rationale:** Drive habit-forming repeat daily orders (milk/bread), protect small stores from cancellations when one brand runs out, and avoid item breakage during delivery.
- **Impacted Requirements:** `REQ-V2-CON-01`, `REQ-V2-CON-02`, `REQ-V2-CON-04`, `REQ-V2-MER-02`, `REQ-V2-MER-03`, `REQ-V2-DLV-02`, `REQ-V2-OPS-04`
- **Files Modified:**
  - `backend/models.py`
  - `backend/app.py`
  - `lib/models/inventory_item.dart`
  - `lib/models/order.dart`
  - `lib/state/app_state.dart`
  - `lib/screens/consumer/cart_screen.dart`
  - `lib/screens/consumer/consumer_home_screen.dart`
  - `lib/screens/consumer/store_detail_screen.dart`
  - `lib/screens/merchant/merchant_hub_screen.dart`
  - `lib/screens/merchant/escrow_ledger_screen.dart`
  - `lib/screens/delivery/delivery_task_screen.dart`
  - `admin/index.html`
- **Tests Added:** `tests/test_sprint4_habits_and_protection.py`
- **Release Tag:** `v1.4.0-sprint4-habits`
- **Outcome:** **Verified & Merged**.

---

## Change Request: `CR-006`
- **Date:** 2026-11-27
- **Sprint:** Sprint 5 (Dynamic Scale & Seller Efficiency)
- **Prompt:** *"Implement Multi-shop split cart, Voice-to-stock & shelf photo catalog intake, Neighborhood unfulfilled demand signals, Multi-order route batching along same street, Peer-to-peer overflow routing telemetry, and Automated seller strike appeal workflow"*
- **Rationale:** Enable consumers to combine groceries across specialty shops in one drop, cut catalog intake friction for non-tech-savvy kiranas, and prevent unfair penalties through owner strike appeal desks.
- **Impacted Requirements:** `REQ-V2-CON-03`, `REQ-V2-MER-01`, `REQ-V2-MER-04`, `REQ-V2-DLV-01`, `REQ-V2-OPS-01`, `REQ-V2-OPS-03`
- **Files Impacted:**
  - `backend/models.py`
  - `backend/app.py`
  - `admin/index.html`
  - `lib/models/order.dart`
  - `lib/state/app_state.dart`
  - `lib/screens/consumer/cart_screen.dart`
  - `lib/screens/merchant/barcode_intake_screen.dart`
  - `lib/screens/merchant/merchant_hub_screen.dart`
  - `lib/screens/merchant/escrow_ledger_screen.dart`
  - `lib/screens/delivery/delivery_task_screen.dart`
- **Tests Planned:** `tests/test_sprint5_scale_and_efficiency.py` (5 automated tests, 100% pass)
- **Release Tag:** `v1.5.0-sprint5-scale`
- **Outcome:** **Verified & Merged**.
