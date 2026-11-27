"""
Sprint 6 Automated Test Suite: Offline-Resilient Delivery & AI Photo-Defect Verification
Verifies:
- REQ-V2-DLV-03: Offline-resilient sync for weak signal zones (elevators, basements)
- REQ-V2-OPS-02: Automated AI/OCR photo-defect classification and instant wallet auto-refund
"""
import unittest
from datetime import datetime, timezone
from backend.models import Store, InventoryItem, Order, OrderItem, OrderStatus
from backend.app import BliptoBackendService


class TestSprint6OfflineAndAI(unittest.TestCase):
    def setUp(self):
        self.service = BliptoBackendService()

    def test_ai_photo_defect_verification(self):
        """REQ-V2-OPS-02: AI visual classifier detecting defect cues and auto-approving refund."""
        # Case 1: Cracked egg shell
        result_egg = self.service.ai_verify_photo_defect(
            photo_base64="data:image/jpeg;base64,mockEggDefectBytes",
            item_title="Fresh Country Eggs 6 pcs",
            reason="Two eggs cracked and leaking in carton"
        )
        self.assertEqual(result_egg["defect_classification"], "SHELL_CRACK_DETECTED")
        self.assertGreaterEqual(result_egg["ai_confidence"], 0.85)
        self.assertEqual(result_egg["verdict"], "AUTO_REFUND_APPROVED")
        self.assertTrue(result_egg["is_auto_approved"])
        self.assertGreaterEqual(len(result_egg["detection_cues"]), 2)

        # Case 2: Leaking sunflower oil pouch
        result_oil = self.service.ai_verify_photo_defect(
            photo_base64="data:image/jpeg;base64,mockOilLeakBytes",
            item_title="Fortune Sunlite Refined Sunflower Oil 1 Litre",
            reason="Pouch was torn at corner and leaking oil in bag"
        )
        self.assertEqual(result_oil["defect_classification"], "PHYSICAL_LEAK_CONFIRMED")
        self.assertGreaterEqual(result_oil["ai_confidence"], 0.85)
        self.assertEqual(result_oil["verdict"], "AUTO_REFUND_APPROVED")

    def test_dispute_with_ai_auto_refund_and_wallet_credit(self):
        """REQ-V2-OPS-02: End-to-end dispute with AI verification and instant wallet refund."""
        # 1. Create and fulfill order
        order_resp = self.service.create_order(
            consumer_id="usr-881",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"item_id": "item-101", "quantity": 1, "price": 55.0}],
            payment_method="UPI"
        )
        order_id = order_resp["order_id"]

        # 2. File dispute with defect photo
        dispute_resp = self.service.file_dispute(
            order_id=order_id,
            item_id="item-101",
            reason="Egg was cracked during transit",
            photo_base64="data:image/jpeg;base64,mockCrackedEgg"
        )

        self.assertEqual(dispute_resp["status"], "AUTO_RESOLVED")
        self.assertEqual(dispute_resp["refund_credited_to_wallet"], 32.0)
        self.assertIn("ai_verification", dispute_resp)
        self.assertEqual(dispute_resp["ai_verification"]["defect_classification"], "SHELL_CRACK_DETECTED")
        self.assertGreaterEqual(dispute_resp["ai_verification"]["ai_confidence"], 0.85)

        # Customer wallet must be refunded
        self.assertEqual(self.service.escrow.consumer_wallets["usr-881"], 32.0)

    def test_offline_resilient_delivery_sync(self):
        """REQ-V2-DLV-03: Offline delivery verification in basement/elevator synced on reconnect."""
        # 1. Place an order locked in escrow
        order_resp = self.service.create_order(
            consumer_id="usr-881",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"item_id": "item-101", "quantity": 1, "price": 100.0}],
            payment_method="UPI"
        )
        order_id = order_resp["order_id"]
        otp = order_resp["delivery_otp"]

        store = next(s for s in self.service.stores if s.id == "store-001")
        initial_settled = self.service.escrow.settled_balances.get("store-001", 0.0)

        # 2. Simulate rider verifying OTP offline in elevator at 11:42 AM
        offline_event = {
            "order_id": order_id,
            "otp": otp,
            "completed_at": datetime.now(timezone.utc).isoformat(),
            "verification_method": "OFFLINE_OTP_HASH"
        }

        # 3. Phone reconnects to cellular network and posts batched queue
        sync_result = self.service.sync_offline_deliveries([offline_event])

        self.assertEqual(sync_result["synced_count"], 1)
        self.assertEqual(sync_result["records"][0]["status"], "SYNCED")
        self.assertEqual(sync_result["settled_total"], 42.0)

        # Order must be DELIVERED and escrow released
        order = self.service.orders[order_id]
        self.assertEqual(order.status, OrderStatus.DELIVERED)
        self.assertEqual(self.service.escrow.settled_balances["store-001"], initial_settled + 42.0)

        # Sync record must be in queue
        queue = self.service.get_offline_delivery_queue()
        self.assertTrue(any(q["order_id"] == order_id for q in queue))


if __name__ == "__main__":
    unittest.main()
