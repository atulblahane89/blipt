"""
Blipto Core REST API & Dispatch Service
Standard-library compliant REST server implementing OpenAPI 3.0 contract.
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os
import re
import urllib.parse
from datetime import datetime, timezone
import random
from typing import Dict, List, Optional

from .models import Store, InventoryItem, Order, OrderItem, OrderStatus, Dispute
from .spillover_engine import SpilloverDispatcher, haversine_distance_meters
from .escrow_ledger import EscrowLedgerEngine


class BliptoBackendService:
    def __init__(self):
        self.stores: List[Store] = [
            Store(
                id="store-001",
                name="Gupta Kirana & Provisions",
                address="Cross Road 4, Bellandur (450m away)",
                latitude=12.9352,
                longitude=77.6245,
                delivery_radius_meters=1500,
                is_busy=False,
                max_active_orders=4,
                active_orders_count=2,
                trust_rating=4.9,
                upi_id="gupta.kirana@oksbi",
                estimated_minutes=14,
            ),
            Store(
                id="store-002",
                name="Mahadev Daily Supermarket",
                address="Main Market Road, Green Glen (850m away)",
                latitude=12.9380,
                longitude=77.6290,
                delivery_radius_meters=1800,
                is_busy=False,
                max_active_orders=5,
                active_orders_count=1,
                trust_rating=4.8,
                upi_id="mahadev.retail@okaxis",
                estimated_minutes=18,
            ),
            Store(
                id="store-003",
                name="Sri Venkateshwara Fresh & Dairy",
                address="Temple Arch, Sector 2 (1100m away)",
                latitude=12.9310,
                longitude=77.6210,
                delivery_radius_meters=2000,
                is_busy=True,  # Busy Mode
                max_active_orders=3,
                active_orders_count=3,
                trust_rating=4.7,
                upi_id="venkateshwara@icici",
                estimated_minutes=25,
            ),
        ]

        self.inventory: Dict[str, List[InventoryItem]] = {
            "store-001": [
                InventoryItem("item-101", "store-001", "8901030383821", "Amul Taaza Homogenised Milk", "Dairy & Eggs", 32.0, 18, unit="500ml"),
                InventoryItem("item-102", "store-001", "8901491101837", "Modern Whole Wheat Bread", "Bakery", 45.0, 2, unit="400g"),
                InventoryItem("item-103", "store-001", "8901725181222", "Farm Fresh Brown Eggs", "Dairy & Eggs", 55.0, 14, unit="6 pcs"),
            ],
            "store-002": [
                InventoryItem("item-201", "store-002", "8901030383821", "Amul Taaza Homogenised Milk", "Dairy & Eggs", 32.0, 25, unit="500ml"),
                InventoryItem("item-202", "store-002", "8901491101837", "Modern Whole Wheat Bread", "Bakery", 45.0, 12, unit="400g"),
                InventoryItem("item-203", "store-002", "8901725181222", "Farm Fresh Brown Eggs", "Dairy & Eggs", 55.0, 20, unit="6 pcs"),
            ],
        }

        self.orders: Dict[str, Order] = {}
        self.disputes: List[Dispute] = []
        self.escrow = EscrowLedgerEngine()
        self.dispatcher = SpilloverDispatcher(self.stores, self.inventory)

    def get_nearby_stores(self, lat: float, lng: float, radius_meters: int = 1500) -> List[dict]:
        results = []
        for s in self.stores:
            dist = haversine_distance_meters(lat, lng, s.latitude, s.longitude)
            if dist <= radius_meters:
                d = {
                    "id": s.id,
                    "name": s.name,
                    "address": s.address,
                    "latitude": s.latitude,
                    "longitude": s.longitude,
                    "distance_meters": round(dist, 1),
                    "is_busy": s.is_busy,
                    "can_accept_orders": s.can_fulfill,
                    "trust_rating": s.trust_rating,
                    "estimated_minutes": s.estimated_minutes,
                }
                results.append(d)
        results.sort(key=lambda x: x["distance_meters"])
        return results

    def get_store_inventory(self, store_id: str) -> List[dict]:
        items = self.inventory.get(store_id, [])
        return [
            {
                "id": it.id,
                "store_id": it.store_id,
                "barcode": it.barcode,
                "title": it.title,
                "category": it.category,
                "price": it.price,
                "stock_quantity": it.stock_quantity,
                "is_low_stock": it.stock_quantity <= it.low_stock_threshold,
                "is_out_of_stock": it.stock_quantity <= 0,
            }
            for it in items
            if it.stock_quantity > 0  # Zero phantom stockout rule
        ]

    def intake_barcode_item(self, store_id: str, barcode: str, title: str, price: float, quantity: int) -> dict:
        catalog = self.inventory.setdefault(store_id, [])
        match = next((it for it in catalog if it.barcode == barcode), None)
        if match:
            match.stock_quantity += quantity
            match.price = price
            return {"status": "UPDATED", "item_id": match.id, "stock": match.stock_quantity}
        else:
            new_item = InventoryItem(
                id=f"item-{random.randint(1000, 9999)}",
                store_id=store_id,
                barcode=barcode,
                title=title,
                category="General",
                price=price,
                stock_quantity=quantity,
            )
            catalog.append(new_item)
            return {"status": "CREATED", "item_id": new_item.id, "stock": new_item.stock_quantity}

    def set_busy_mode(self, store_id: str, is_busy: bool) -> dict:
        s = next((st for st in self.stores if st.id == store_id), None)
        if not s:
            raise KeyError("Store not found")
        s.is_busy = is_busy
        return {"store_id": s.id, "is_busy": s.is_busy}

    def create_order(self, consumer_id: str, store_id: str, consumer_lat: float, consumer_lng: float, items: list) -> dict:
        req_tuples = [(it["barcode"] if "barcode" in it else it["item_id"], it["quantity"]) for it in items]

        # Dynamic Spillover Resolution
        fulfilling_store, is_spillover, referral_fee = self.dispatcher.resolve_fulfillment_store(
            primary_store_id=store_id,
            consumer_lat=consumer_lat,
            consumer_lng=consumer_lng,
            required_items=req_tuples,
        )

        catalog = self.inventory.get(fulfilling_store.id, [])
        cat_map = {it.barcode: it for it in catalog}
        cat_map.update({it.id: it for it in catalog})

        order_items = []
        subtotal = 0.0

        for key, qty in req_tuples:
            item = cat_map[key]
            item.stock_quantity = max(0, item.stock_quantity - qty)
            oi = OrderItem(item_id=item.id, title=item.title, price=item.price, quantity=qty)
            order_items.append(oi)
            subtotal += oi.price * oi.quantity

        delivery_fee = 10.0 if subtotal > 0 else 0.0
        total_amount = subtotal + delivery_fee
        order_id = f"ORD-{random.randint(1000, 9999)}"
        otp = f"{random.randint(1000, 9999)}"

        order = Order(
            id=order_id,
            consumer_id=consumer_id,
            store_id=store_id,
            fulfilling_store_id=fulfilling_store.id,
            is_spillover=is_spillover,
            items=order_items,
            subtotal=subtotal,
            delivery_fee=delivery_fee,
            total_amount=total_amount,
            delivery_otp=otp,
            status=OrderStatus.PLACED,
            created_at=datetime.now(timezone.utc).isoformat(),
            referral_commission=referral_fee,
        )
        self.orders[order_id] = order

        # Lock funds in Escrow
        self.escrow.lock_funds_in_escrow(fulfilling_store.id, total_amount)
        fulfilling_store.active_orders_count += 1

        return {
            "order_id": order.id,
            "status": order.status.value,
            "is_spillover": order.is_spillover,
            "primary_store_id": order.store_id,
            "fulfilling_store_id": order.fulfilling_store_id,
            "delivery_otp": order.delivery_otp,
            "total_amount": order.total_amount,
            "referral_commission": order.referral_commission,
        }

    def verify_delivery(self, order_id: str, otp: Optional[str] = None, photo_proof: Optional[str] = None) -> dict:
        order = self.orders.get(order_id)
        if not order:
            raise KeyError("Order not found")

        if otp and otp.strip() == order.delivery_otp:
            order.status = OrderStatus.DELIVERED
            self.escrow.release_escrow_to_settled(order.fulfilling_store_id, order.total_amount)
            return {"status": "DELIVERED", "method": "OTP_VERIFIED", "settled_amount": order.total_amount}
        elif photo_proof:
            order.status = OrderStatus.DELIVERED
            order.delivery_photo_url = photo_proof
            self.escrow.release_escrow_to_settled(order.fulfilling_store_id, order.total_amount)
            return {"status": "DELIVERED", "method": "PHOTO_PROOF_VERIFIED", "settled_amount": order.total_amount}
        else:
            return {"status": "REJECTED", "reason": "Invalid OTP or missing photo proof"}

    def file_dispute(self, order_id: str, item_id: str, reason: str, photo_base64: str) -> dict:
        order = self.orders.get(order_id)
        if not order:
            raise KeyError("Order not found")

        matched_item = next((oi for oi in order.items if oi.item_id == item_id), None)
        refund_amount = matched_item.price * matched_item.quantity if matched_item else 30.0

        dispute_id = f"DSP-{random.randint(1000, 9999)}"
        dispute = Dispute(
            id=dispute_id,
            order_id=order_id,
            item_id=item_id,
            reason=reason,
            photo_base64=photo_base64,
            refund_amount=refund_amount,
            created_at=datetime.now(timezone.utc).isoformat(),
        )
        self.disputes.append(dispute)
        order.status = OrderStatus.REFUNDED

        merchant = next((s for s in self.stores if s.id == order.fulfilling_store_id), None)
        self.escrow.process_automated_refund(order.consumer_id, order.fulfilling_store_id, refund_amount, merchant)

        return {
            "dispute_id": dispute_id,
            "status": "AUTO_RESOLVED",
            "refund_credited_to_wallet": refund_amount,
            "merchant_strike_count": merchant.strikes if merchant else 1,
        }

    # --- App Owner Super Admin Operations (REQ-ADM-01, REQ-ADM-02, REQ-ADM-03) ---
    def get_admin_overview(self) -> dict:
        total_gmv = sum(o.total_amount for o in self.orders.values())
        platform_fee = round(total_gmv * 0.045, 2)
        total_escrow_held = sum(self.escrow.escrow_balances.values())
        total_settled = sum(self.escrow.settled_balances.values())
        total_refunded = sum(d.refund_amount for d in self.disputes)

        return {
            "platform_gmv": round(total_gmv, 2),
            "platform_revenue": platform_fee,
            "escrow_locked_funds": round(total_escrow_held, 2),
            "merchant_settled_total": round(total_settled, 2),
            "total_refunds_processed": round(total_refunded, 2),
            "active_stores_count": len([s for s in self.stores if s.strikes < 3]),
            "total_orders_count": len(self.orders),
            "total_disputes_count": len(self.disputes),
        }

    def export_all_data(self) -> dict:
        return {
            "export_timestamp": datetime.now(timezone.utc).isoformat(),
            "stores": [
                {
                    "id": s.id,
                    "name": s.name,
                    "address": s.address,
                    "latitude": s.latitude,
                    "longitude": s.longitude,
                    "delivery_radius_meters": s.delivery_radius_meters,
                    "is_busy": s.is_busy,
                    "max_active_orders": s.max_active_orders,
                    "active_orders_count": s.active_orders_count,
                    "trust_rating": s.trust_rating,
                    "upi_id": s.upi_id,
                    "strikes": s.strikes,
                }
                for s in self.stores
            ],
            "inventory": {
                store_id: [
                    {
                        "id": it.id,
                        "barcode": it.barcode,
                        "title": it.title,
                        "category": it.category,
                        "price": it.price,
                        "stock_quantity": it.stock_quantity,
                    }
                    for it in items
                ]
                for store_id, items in self.inventory.items()
            },
            "orders": [
                {
                    "id": o.id,
                    "consumer_id": o.consumer_id,
                    "store_id": o.store_id,
                    "fulfilling_store_id": o.fulfilling_store_id,
                    "is_spillover": o.is_spillover,
                    "subtotal": o.subtotal,
                    "delivery_fee": o.delivery_fee,
                    "total_amount": o.total_amount,
                    "delivery_otp": o.delivery_otp,
                    "status": o.status.value,
                    "referral_commission": o.referral_commission,
                    "created_at": o.created_at,
                }
                for o in self.orders.values()
            ],
            "disputes": [
                {
                    "id": d.id,
                    "order_id": d.order_id,
                    "item_id": d.item_id,
                    "reason": d.reason,
                    "refund_amount": d.refund_amount,
                    "status": d.status,
                    "created_at": d.created_at,
                }
                for d in self.disputes
            ],
            "escrow_ledger": {
                "escrow_balances": self.escrow.escrow_balances,
                "settled_balances": self.escrow.settled_balances,
                "consumer_wallets": self.escrow.consumer_wallets,
            },
        }

    def adjust_store_radius(self, store_id: str, radius_meters: int) -> dict:
        s = next((st for st in self.stores if st.id == store_id), None)
        if not s:
            raise KeyError("Store not found")
        s.delivery_radius_meters = radius_meters
        return {"store_id": s.id, "delivery_radius_meters": s.delivery_radius_meters}


# Global Service Instance
service = BliptoBackendService()


class BliptoHTTPHandler(BaseHTTPRequestHandler):
    def _send_json(self, status_code: int, data: dict):
        body = json.dumps(data).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PATCH, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()
        self.wfile.write(body)

    def _send_html(self, status_code: int, html_content: str):
        body = html_content.encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self._send_json(200, {"status": "OK"})

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        query = urllib.parse.parse_qs(parsed.query)

        # App Owner Admin Dashboard HTML (REQ-ADM-01)
        if path in ["/admin", "/admin/"]:
            admin_file = os.path.join(os.path.dirname(os.path.dirname(__file__)), "admin", "index.html")
            if os.path.exists(admin_file):
                with open(admin_file, "r", encoding="utf-8") as f:
                    self._send_html(200, f.read())
                return
            else:
                self._send_html(404, "<h1>Admin Dashboard file not found</h1>")
                return

        # App Owner Admin APIs
        elif path == "/v1/admin/overview":
            self._send_json(200, service.get_admin_overview())

        elif path == "/v1/admin/export-data":
            self._send_json(200, service.export_all_data())

        elif path == "/v1/admin/stores":
            self._send_json(200, {"stores": service.export_all_data()["stores"]})

        elif path == "/v1/admin/orders":
            self._send_json(200, {"orders": service.export_all_data()["orders"]})

        elif path == "/v1/admin/disputes":
            self._send_json(200, {"disputes": service.export_all_data()["disputes"]})

        # Consumer / Store Public APIs
        elif path == "/v1/stores/nearby":
            lat = float(query.get("lat", [12.9352])[0])
            lng = float(query.get("lng", [77.6245])[0])
            radius = int(query.get("radius_meters", [1500])[0])
            stores = service.get_nearby_stores(lat, lng, radius)
            self._send_json(200, {"stores": stores})

        elif re.match(r"^/v1/stores/[^/]+/inventory$", path):
            store_id = path.split("/")[3]
            inv = service.get_store_inventory(store_id)
            self._send_json(200, {"store_id": store_id, "inventory": inv})

        else:
            self._send_json(404, {"error": "Not Found"})

    def do_POST(self):
        content_length = int(self.headers.get("Content-Length", 0))
        raw_body = self.rfile.read(content_length).decode("utf-8") if content_length > 0 else "{}"
        body = json.loads(raw_body) if raw_body else {}
        path = urllib.parse.urlparse(self.path).path

        if path == "/v1/orders":
            res = service.create_order(
                consumer_id=body.get("consumer_id", "usr-881"),
                store_id=body.get("store_id", "store-001"),
                consumer_lat=float(body.get("consumer_lat", 12.9352)),
                consumer_lng=float(body.get("consumer_lng", 77.6245)),
                items=body.get("items", []),
            )
            self._send_json(201, res)

        elif re.match(r"^/v1/orders/[^/]+/verify-delivery$", path):
            order_id = path.split("/")[3]
            res = service.verify_delivery(order_id, otp=body.get("otp"), photo_proof=body.get("photo_proof_base64"))
            self._send_json(200, res)

        elif re.match(r"^/v1/orders/[^/]+/dispute$", path):
            order_id = path.split("/")[3]
            res = service.file_dispute(
                order_id=order_id,
                item_id=body.get("item_id", ""),
                reason=body.get("reason", "Damaged"),
                photo_base64=body.get("photo_base64", ""),
            )
            self._send_json(200, res)

        elif re.match(r"^/v1/stores/[^/]+/inventory$", path):
            store_id = path.split("/")[3]
            res = service.intake_barcode_item(
                store_id=store_id,
                barcode=body.get("barcode", ""),
                title=body.get("title", ""),
                price=float(body.get("price", 0.0)),
                quantity=int(body.get("stock_quantity", 1)),
            )
            self._send_json(201, res)

        else:
            self._send_json(404, {"error": "Not Found"})

    def do_PATCH(self):
        path = urllib.parse.urlparse(self.path).path
        content_length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(content_length).decode("utf-8")) if content_length > 0 else {}

        if re.match(r"^/v1/stores/[^/]+/busy-mode$", path):
            store_id = path.split("/")[3]
            res = service.set_busy_mode(store_id, is_busy=body.get("is_busy", False))
            self._send_json(200, res)
        elif re.match(r"^/v1/admin/stores/[^/]+/radius$", path):
            store_id = path.split("/")[4]
            res = service.adjust_store_radius(store_id, radius_meters=int(body.get("delivery_radius_meters", 1500)))
            self._send_json(200, res)
        else:
            self._send_json(404, {"error": "Not Found"})


def run_server(port: int = 8080):
    server_address = ("", port)
    httpd = HTTPServer(server_address, BliptoHTTPHandler)
    print(f"Blipto Dispatch & Escrow Server running on port {port}...")
    httpd.serve_forever()


if __name__ == "__main__":
    run_server(8080)
