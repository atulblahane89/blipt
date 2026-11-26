"""
Adversarial QA Suite: Escrow Settlement, OTP Verification & Dispute Governance (REQ-MER-04, REQ-CON-05, REQ-OPS-02)
"""
import unittest
from backend.app import BliptoBackendService


class TestEscrowAndDisputes(unittest.TestCase):
    def setUp(self):
        self.svc = BliptoBackendService()

    def test_order_lifecycle_and_otp_escrow_release(self):
        # 1. Place order: funds should lock in Escrow
        order_res = self.svc.create_order(
            consumer_id="usr-881",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"barcode": "8901030383821", "quantity": 1}],
        )
        order_id = order_res["order_id"]
        fulfilling_store = order_res["fulfilling_store_id"]
        total = order_res["total_amount"]
        otp = order_res["delivery_otp"]

        self.assertGreaterEqual(self.svc.escrow.escrow_balances[fulfilling_store], total)

        # 2. Doorstep OTP Verification
        verify_res = self.svc.verify_delivery(order_id, otp=otp)
        self.assertEqual(verify_res["status"], "DELIVERED")
        self.assertEqual(verify_res["method"], "OTP_VERIFIED")

        # Escrow must be unlocked into settled balance
        self.assertGreaterEqual(self.svc.escrow.settled_balances[fulfilling_store], total)

    def test_invalid_otp_rejection(self):
        # Bad OTP must NOT release escrow funds
        order_res = self.svc.create_order(
            consumer_id="usr-881",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"barcode": "8901030383821", "quantity": 1}],
        )
        order_id = order_res["order_id"]
        res = self.svc.verify_delivery(order_id, otp="0000")
        self.assertEqual(res["status"], "REJECTED")

    def test_automated_photo_dispute_instant_refund_and_strike_governance(self):
        # Deliver order first
        order_res = self.svc.create_order(
            consumer_id="usr-881",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"barcode": "8901030383821", "quantity": 1}],
        )
        order_id = order_res["order_id"]
        self.svc.verify_delivery(order_id, otp=order_res["delivery_otp"])

        # File defect photo dispute
        disp_res = self.svc.file_dispute(
            order_id=order_id,
            item_id="item-101",
            reason="Spoiled / Curdled Milk",
            photo_base64="data:image/jpeg;base64,samplephoto...",
        )
        self.assertEqual(disp_res["status"], "AUTO_RESOLVED")
        self.assertEqual(disp_res["refund_credited_to_wallet"], 32.0)
        self.assertEqual(disp_res["merchant_strike_count"], 1)

        # Verify wallet credited
        self.assertEqual(self.svc.escrow.consumer_wallets["usr-881"], 32.0)


if __name__ == "__main__":
    unittest.main()
