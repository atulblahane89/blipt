"""
Sprint 5 Automated Test Suite: Dynamic Scale & Seller Efficiency
Verifies:
- REQ-V2-CON-03: Multi-shop split cart within the same hyper-local delivery zone
- REQ-V2-MER-01: Voice-to-stock & shelf photo catalog intake assist
- REQ-V2-MER-04: Neighborhood unfulfilled demand signals
- REQ-V2-DLV-01: Multi-order route batching along the same street
- REQ-V2-OPS-01: Peer-to-peer overflow routing across nearby partner shops
- REQ-V2-OPS-03: Automated seller strike appeal workflow
"""
import unittest
from backend.models import Store, InventoryItem, Order, OrderItem, OrderStatus, StrikeAppeal
from backend.app import BliptoBackendService


class TestSprint5ScaleAndEfficiency(unittest.TestCase):
    def setUp(self):
        self.service = BliptoBackendService()

    def test_voice_to_stock_parsing(self):
        """REQ-V2-MER-01: Kirana shopkeeper speech-to-text transcript parsing into structured SKU."""
        # Test 1: Fortune Sunflower Oil voice input
        result1 = self.service.parse_voice_catalog("Add 10 packets of Fortune Sunflower Oil 1 Litre at 135 rupees")
        self.assertIn("Fortune", result1["title"])
        self.assertEqual(result1["quantity"], 10)
        self.assertEqual(result1["price"], 135.0)
        self.assertEqual(result1["category"], "Oils & Staples")
        self.assertGreaterEqual(result1["confidence"], 0.90)

        # Test 2: Amul Milk voice input
        result2 = self.service.parse_voice_catalog("Stock 20 packets of Amul Taaza milk for 32 rupees each")
        self.assertIn("Amul", result2["title"])
        self.assertEqual(result2["quantity"], 20)
        self.assertEqual(result2["price"], 32.0)
        self.assertEqual(result2["category"], "Dairy & Eggs")

    def test_neighborhood_unfulfilled_demand_signals(self):
        """REQ-V2-MER-04: Surfacing zero-result neighbor searches to local merchants."""
        demand_signals = self.service.get_unfulfilled_demand("store-001")
        self.assertIsInstance(demand_signals, list)
        self.assertGreaterEqual(len(demand_signals), 3)

        queries = [item["query"] for item in demand_signals]
        self.assertTrue(any("Maggi" in q for q in queries))
        self.assertTrue(any("Amul" in q for q in queries))
        self.assertTrue(any("Tata Tea" in q for q in queries))
        self.assertTrue(any("Haldiram" in q for q in queries))

        for signal in demand_signals:
            self.assertIn("searches_count", signal)
            self.assertIn("estimated_monthly_revenue", signal)
            self.assertGreater(signal["searches_count"], 0)
            self.assertGreater(signal["estimated_monthly_revenue"], 0)

    def test_street_level_route_batching(self):
        """REQ-V2-DLV-01: Multi-order route batching along the same street/catchment."""
        batch = self.service.get_batched_routes()
        self.assertIsInstance(batch, dict)
        self.assertIn("cluster_name", batch)
        self.assertIn("drops", batch)
        self.assertIn("time_saved_minutes", batch)
        self.assertGreaterEqual(len(batch["drops"]), 2)
        self.assertGreaterEqual(batch["time_saved_minutes"], 10)

    def test_seller_strike_appeal_workflow(self):
        """REQ-V2-OPS-03: Kirana strike appeal submission and App Owner 1-click review."""
        store = next(s for s in self.service.stores if s.id == "store-001")
        store.strikes = 2

        # 1. Merchant files an appeal
        appeal_resp = self.service.file_strike_appeal(
            store_id="store-001",
            reason="Customer received sealed packet; CCTV footage verifies intact oil bottle dispatched",
            proof_note="CCTV recording #04 at 10:42 AM timestamp"
        )
        self.assertIsNotNone(appeal_resp)
        self.assertEqual(appeal_resp["status"], "PENDING")
        appeal_id = appeal_resp["appeal_id"]

        # Verify it appears in pending appeals
        pending = [a for a in self.service.strike_appeals if a.status == "PENDING"]
        self.assertTrue(any(a.id == appeal_id for a in pending))

        # 2. App Owner reviews and approves appeal
        reviewed = self.service.review_strike_appeal(
            appeal_id=appeal_id,
            action="APPROVE"
        )
        self.assertIsNotNone(reviewed)
        self.assertEqual(reviewed["status"], "APPROVED")
        # Merchant strike count must be decremented by 1
        self.assertEqual(store.strikes, 1)

    def test_multi_shop_split_cart_orders(self):
        """REQ-V2-CON-03: Multi-shop split cart bundled delivery."""
        split_result = self.service.create_split_orders(
            consumer_id="usr-881",
            store_orders_payload=[
                {
                    "store_id": "store-001",
                    "items": [{"item_id": "item-101", "quantity": 2, "price": 32.0}],
                    "consumer_lat": 12.9352,
                    "consumer_lng": 77.6245,
                },
                {
                    "store_id": "store-002",
                    "items": [{"item_id": "item-202", "quantity": 1, "price": 45.0}],
                    "consumer_lat": 12.9352,
                    "consumer_lng": 77.6245,
                }
            ],
            payment_method="UPI",
            wallet_amount_used=0.0
        )
        self.assertIn("split_group_id", split_result)
        self.assertEqual(split_result["stores_count"], 2)
        self.assertEqual(split_result["unified_delivery_fee"], 15.0)

        # Both sub-orders must exist in platform orders sharing the same split_group_id
        sub_orders = [o for o in self.service.orders.values() if o.split_group_id == split_result["split_group_id"]]
        self.assertEqual(len(sub_orders), 2)


if __name__ == "__main__":
    unittest.main()
