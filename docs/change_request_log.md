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
