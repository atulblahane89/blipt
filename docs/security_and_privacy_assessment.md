# 🛡️ Blipto: Security, Privacy & Fraud Impact Assessment

## 1. Zero-Trust Escrow Settlement Framework
- **Escrow Segregation:** Consumer checkout payments are held in a digital escrow ledger. Funds are strictly released to the store partner ledger only upon:
  1. Valid 4-digit consumer OTP verification entered by delivery personnel, OR
  2. Geotagged doorstep proof photo verified by the governance engine.
- **Immediate Reversal:** When an automated photo dispute is submitted within 15 minutes of delivery, disputed item funds are automatically redirected to the consumer wallet while freezing that order's payout to the merchant.

---

## 2. Fraud Prevention & Anti-Abuse Controls

### 2.1 Consumer Anti-Abuse (Phantom Refund Prevention)
- **Metadata Inspection:** Customer dispute photos are checked for client-side timestamp freshness ($\le 15\text{ mins}$ from delivery) and EXIF geolocation proximity to the registered delivery address.
- **Trust Score Weighting:** Users who submit refund requests on $>20\%$ of lifetime orders have automated instant refunds disabled, requiring store partner counter-evidence review before reimbursement.

### 2.2 Merchant Quality & 3-Strike Rule
- **Chronic Quality Defect Monitoring:** Every verified customer photo dispute registers an infraction against the fulfilling merchant.
- **Automated 3-Strike Penalty:**
  - *Strike 1:* Automated notification and warning on Merchant Hub with photo evidence.
  - *Strike 2:* Required manual packing checklist photograph before dispatch.
  - *Strike 3:* 7-day de-platforming / suspension of store from consumer discovery.

---

## 3. Privacy & Data Minimization
- **Phone Number Masking:** Delivery boys and consumers communicate via virtual masked numbers or in-app VoIP; raw phone numbers are never exposed.
- **Geo-Radius Obfuscation:** Store discovery searches calculate bounding boxes without storing persistent background tracking of consumers.
