# 🏗️ Blipto: System Design Document (SDD)

## 1. High-Level Architectural Pattern
Blipto employs a **Clean Architecture with Domain-Driven Design (DDD)** on the mobile client and an **Event-Driven Microservices Architecture** for the backend dispatch and settlement layer.

```
┌─────────────────────────────────────────────────────────────┐
│                    Blipto Android App                       │
│  ┌─────────────────┬──────────────────┬──────────────────┐  │
│  │  Consumer Flow  │   Merchant Hub   │  Delivery Feed   │  │
│  └────────┬────────┴────────┬─────────┴────────┬─────────┘  │
│           │                 │                  │            │
│  ┌────────▼─────────────────▼──────────────────▼─────────┐  │
│  │             Unified State Management & BloC           │  │
│  └──────────────────────────┬────────────────────────────┘  │
│  ┌──────────────────────────▼────────────────────────────┐  │
│  │     Data Layer (REST API + WebSocket / SSE Client)    │  │
│  └──────────────────────────┬────────────────────────────┘  │
└─────────────────────────────┼───────────────────────────────┘
                              │ HTTPS / WSS
┌─────────────────────────────▼───────────────────────────────┐
│                    Blipto Platform Backend                  │
│  ┌─────────────────┬──────────────────┬──────────────────┐  │
│  │ Store Discovery │ Realtime Catalog │ Dispatch & Spill │  │
│  │  & Geo-Spatial  │  & Sync Engine   │      Engine      │  │
│  ├─────────────────┼──────────────────┼──────────────────┤  │
│  │  Escrow Ledger  │ Dispute AI Gate  │ Push Notification│  │
│  │  & Instant UPI  │  & Quality Rules │     Service      │  │
│  └─────────────────┴──────────────────┴──────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Database Layer: PostgreSQL + PostGIS (Geo) + Redis    │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Component Design & Responsibilities

### 2.1 Mobile Layer (Android)
- **Role Switching Controller:** Seamlessly switches the single app between:
  - `Consumer Mode` (Browse stores, live cart, order tracking, photo dispute)
  - `Merchant Hub` (Live orders audio chime, barcode scanner, busy toggle, escrow payouts)
  - `Delivery Partner` (Active local drops, map navigation, OTP / photo verify)
- **Local Cache & Offline Resilience:** SQLite / Hive store for immediate barcode lookup and offline draft states.
- **Hardware Integrations:**
  - Camera Barcode Scanner (ZXing / ML Kit Barcode Scanning)
  - High-Accuracy GPS (Geolocator)
  - Loud Audio Chime (AudioPlayers / SoundPool for kitchen/kirana environments)

### 2.2 Backend & Dispatch Engine
- **Geo-Radius Calculation:** Haversine / PostGIS index computing distance $D \le 2000\text{m}$.
- **Spillover Routing Engine:**
  ```python
  if store.is_busy or len(store.active_orders) >= store.max_capacity:
      alternate_stores = find_partner_stores(
          geo_point=consumer.location,
          radius_km=1.2,
          sku_list=order.skus,
          available_capacity=True
      )
      if alternate_stores:
          dispatch_to(alternate_stores[0], referral_credit_store=store)
  ```
- **Digital Escrow State Machine:**
  - `CREATED` $\rightarrow$ `FUNDS_HELD_IN_ESCROW`
  - `DELIVERED_VERIFIED` $\rightarrow$ `RELEASED_TO_MERCHANT_LEDGER`
  - `DISPUTE_CLAIMED_PHOTO` $\rightarrow$ `AUTOMATED_REFUND_TO_CONSUMER`

---

## 3. Database Schema

### Table: `stores`
- `id` (UUID, PK)
- `name` (VARCHAR)
- `phone` (VARCHAR)
- `latitude` (DOUBLE)
- `longitude` (DOUBLE)
- `delivery_radius_meters` (INT, default 1500)
- `is_busy` (BOOLEAN, default FALSE)
- `max_active_orders` (INT, default 4)
- `active_orders_count` (INT, default 0)
- `trust_rating` (FLOAT, default 5.0)
- `upi_handle` (VARCHAR)

### Table: `catalog_items`
- `id` (UUID, PK)
- `store_id` (UUID, FK -> stores.id)
- `barcode` (VARCHAR, Indexed)
- `title` (VARCHAR)
- `category` (VARCHAR)
- `price` (DECIMAL)
- `stock_quantity` (INT)
- `low_stock_threshold` (INT, default 1)
- `image_url` (VARCHAR)
- `is_active` (BOOLEAN)

### Table: `orders`
- `id` (UUID, PK)
- `consumer_id` (VARCHAR)
- `store_id` (UUID, FK -> stores.id)
- `fulfilling_store_id` (UUID, FK -> stores.id) # for spillover
- `status` (ENUM: `PLACED`, `PACKED`, `OUT_FOR_DELIVERY`, `DELIVERED`, `DISPUTED`, `REFUNDED`)
- `delivery_otp` (VARCHAR(4))
- `delivery_photo_url` (VARCHAR, Nullable)
- `subtotal` (DECIMAL)
- `delivery_fee` (DECIMAL)
- `total_amount` (DECIMAL)
- `spillover_referral_fee` (DECIMAL, default 0)
- `created_at` (TIMESTAMP)

### Table: `disputes`
- `id` (UUID, PK)
- `order_id` (UUID, FK -> orders.id)
- `item_id` (UUID, FK -> catalog_items.id)
- `reason` (VARCHAR)
- `photo_evidence_url` (VARCHAR)
- `refund_amount` (DECIMAL)
- `status` (ENUM: `AUTO_RESOLVED`, `REJECTED`, `FLAGGED_AUDIT`)
- `created_at` (TIMESTAMP)

---

## 4. Owner Command Center & Master Data Hub (`/admin`)

The App Owner operates an exclusive desktop command center served directly by the backend at `/admin`:

- **Master Telemetry:** Real-time Gross Merchandise Value (GMV), 4.5% platform revenue, locked escrow funds, settled merchant payouts, and automated dispute refunds.
- **Geofence Radius Control:** Dynamically patch store delivery catchment radii (`PATCH /v1/admin/stores/{id}/radius`).
- **Master Data Persistence:** Complete one-click database export (`GET /v1/admin/export-data`) supporting structured JSON backup and flattened tabular CSV for accounting and disaster recovery.
- **Natural Language Governance:** All user-facing interfaces enforce everyday conversational vocabulary across Customer, Shopkeeper, Delivery Partner, and Owner views.
