"""
Integration and Unit Tests for Multi-Mode Payment & Escrow Split (REQ-PAY-01, US-CON-06)
"""
import unittest
from backend.app import BliptoBackendService
from backend.models import PaymentMethod, OrderStatus


class TestMultiModePayments(unittest.TestCase):
    def setUp(self):
        self.service = BliptoBackendService()

    def test_order_with_upi_payment(self):
        order_res = self.service.create_order(
            consumer_id="usr-test-1",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"item_id": "item-101", "quantity": 1}],
            payment_method="UPI",
        )
        self.assertEqual(order_res["payment_method"], "UPI")
        self.assertEqual(order_res["wallet_amount_used"], 0.0)
        self.assertGreater(order_res["total_amount"], 0)
        self.assertEqual(order_res["paid_amount"], order_res["total_amount"])

    def test_order_with_card_payment(self):
        order_res = self.service.create_order(
            consumer_id="usr-test-2",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"item_id": "item-101", "quantity": 1}],
            payment_method="CARD",
        )
        self.assertEqual(order_res["payment_method"], "CARD")
        self.assertEqual(order_res["paid_amount"], order_res["total_amount"])

    def test_order_with_partial_wallet_and_upi(self):
        # Set up a wallet balance of 20
        self.service.escrow.consumer_wallets["usr-test-3"] = 20.0

        order_res = self.service.create_order(
            consumer_id="usr-test-3",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"item_id": "item-101", "quantity": 1}],
            payment_method="UPI",
            wallet_amount_used=20.0,
        )
        self.assertEqual(order_res["wallet_amount_used"], 20.0)
        expected_paid = order_res["total_amount"] - 20.0
        self.assertEqual(order_res["paid_amount"], expected_paid)
        # Wallet should now be 0
        self.assertEqual(self.service.escrow.consumer_wallets["usr-test-3"], 0.0)

    def test_order_with_cod(self):
        order_res = self.service.create_order(
            consumer_id="usr-test-4",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"item_id": "item-101", "quantity": 1}],
            payment_method="COD",
        )
        self.assertEqual(order_res["payment_method"], "COD")

    def test_admin_overview_payment_breakdown(self):
        # Place one UPI and one Card order
        self.service.create_order(
            consumer_id="usr-test-5",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"item_id": "item-101", "quantity": 1}],
            payment_method="UPI",
        )
        self.service.create_order(
            consumer_id="usr-test-6",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"item_id": "item-101", "quantity": 1}],
            payment_method="CARD",
        )

        overview = self.service.get_admin_overview()
        self.assertIn("payment_counts", overview)
        self.assertIn("payment_volume", overview)
        self.assertGreaterEqual(overview["payment_counts"]["UPI"], 1)
        self.assertGreaterEqual(overview["payment_counts"]["CARD"], 1)


if __name__ == "__main__":
    unittest.main()
