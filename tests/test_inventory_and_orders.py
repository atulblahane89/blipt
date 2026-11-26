"""
Adversarial QA Suite: Zero-Phantom Inventory & Transparent Billing (REQ-CON-02, REQ-CON-03, REQ-MER-01)
"""
import unittest
from backend.app import BliptoBackendService


class TestInventoryAndOrders(unittest.TestCase):
    def setUp(self):
        self.svc = BliptoBackendService()

    def test_zero_phantom_stockout_filter(self):
        # Ensure zero-quantity items are NEVER listed to consumers
        inv = self.svc.get_store_inventory("store-001")
        for item in inv:
            self.assertGreater(item["stock_quantity"], 0, f"Phantom stockout violation on item {item['title']}")

    def test_barcode_intake_updates_shelf_immediately(self):
        # Adding stock via mobile barcode intake increments count
        init_inv = self.svc.get_store_inventory("store-001")
        init_item = next(it for it in init_inv if it["barcode"] == "8901030383821")
        initial_stock = init_item["stock_quantity"]

        res = self.svc.intake_barcode_item(
            store_id="store-001",
            barcode="8901030383821",
            title="Amul Taaza",
            price=32.0,
            quantity=10,
        )
        self.assertEqual(res["status"], "UPDATED")
        self.assertEqual(res["stock"], initial_stock + 10)

    def test_transparent_billing_zero_surge(self):
        # Order creation must have flat, honest billing with zero surge fee
        order_res = self.svc.create_order(
            consumer_id="usr-881",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"barcode": "8901030383821", "quantity": 2}],
        )
        self.assertEqual(order_res["status"], "PLACED")
        order = self.svc.orders[order_res["order_id"]]
        # Item 32 * 2 = 64 + flat delivery fee 10 = 74
        self.assertEqual(order.subtotal, 64.0)
        self.assertEqual(order.delivery_fee, 10.0)
        self.assertEqual(order.total_amount, 74.0)


if __name__ == "__main__":
    unittest.main()
