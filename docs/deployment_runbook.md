# 🚀 Blipto: Deployment, Play Store & Growth Operations Runbook

## 1. Android Release Build (Google Play Store)

### 1.1 Android App Bundle (AAB) Generation
To build the signed release bundle for the Google Play Store:
```bash
# 1. Clean build artifacts
flutter clean

# 2. Fetch packages
flutter pub get

# 3. Generate Android App Bundle
flutter build appbundle --release
```
The output bundle will be located at:
`build/app/outputs/bundle/release/app-release.aab`

### 1.2 Android APK (Direct Local Testing / Merchant Sideloading)
For immediate local device verification on Android smartphones:
```bash
flutter build apk --release --split-per-abi
```
Outputs: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

---

## 2. Backend Dispatch & Escrow Microservices Deployment

### 2.1 Containerized Execution
```dockerfile
# Dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY backend/ ./backend/
EXPOSE 8080
CMD ["python", "-m", "backend.app"]
```
Run container:
```bash
docker build -t blipto-dispatch-engine:v1.0.0 .
docker run -d -p 8080:8080 --name blipto-backend blipto-dispatch-engine:v1.0.0
```

---

## 3. Merchant Onboarding & 2-Minute Kirana Bring-Up Playbook

1. **Step 1 - Mobile App Installation:** Kirana shopkeeper installs Blipto from Google Play Store or scans store onboarding QR code.
2. **Step 2 - UPI Handle Registration:** Merchant inputs their existing UPI ID (e.g. `shop@okaxis`) for instant digital escrow settlements.
3. **Step 3 - Continuous Barcode Intake (2 mins):** Using the phone camera, merchant scans top 20 high-velocity SKUs (Milk, Bread, Eggs, Oil, Atta).
4. **Step 4 - Go Live:** Merchant flips the toggle to "Fulfilling Live". Nearby consumers within 1.5 km instantly discover the store shelf in real-time.

---

## 4. Growth & Unit Economics Telemetry

- **Phantom Stockout Rate (Target < 0.5%):** Measured via `cancelled_orders_stockout / total_orders`.
- **Spillover Efficiency:** % of orders successfully fulfilled by partner stores when primary store is busy without consumer drop-off.
- **Escrow Settlement Turnaround:** Average time from doorstep handoff to UPI wallet unlock (Target: < 30 seconds).
- **Dispute Resolution Speed:** Average time from customer photo upload to automated wallet refund (Target: < 60 seconds).
