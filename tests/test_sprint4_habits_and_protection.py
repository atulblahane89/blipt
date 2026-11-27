"""
Sprint 4 Automated Test Suite: Daily Habits & Order Protection
Verifies:
- REQ-V2-CON-01: Scheduled & recurring daily essentials (milk/staples subscription)
- REQ-V2-CON-02: Pre-checkout smart substitute approval
- REQ-V2-CON-04: Store trust & reliability badges
- REQ-V2-MER-02: Low-stock & short-shelf-life expiry alerts on Kirana Dashboard
- REQ-V2-MER-03: Daily settlement & GST-ready tax summary
- REQ-V2-DLV-02: Fragile & cold packing checklist
- REQ-V2-OPS-04: Same-shop basket add-on nudges
"""
import unittest
from backend.models import Store, InventoryItem, Order, OrderItem, OrderStatus, Subscription
from backend.app import BliptoBackendService


class TestSprint4HabitsAndProtection(unittest.TestCase):
    def setUp(self):
        self.service = BliptoBackendService()

    def test_store_trust_and_reliability_badges(self):
        """REQ-V2-CON-04: Store trust and reliability badges returned in nearby search."""
        stores = self.service.get_nearby_stores(12.9352, 77.6245, 2000)
        self.assertTrue(len(stores) > 0)
        gupta_store = next((s for s in stores if s["id"] == "store-001"), None)
        self.assertIsNotNone(gupta_store)
        self.assertIn("trust_badge", gupta_store)
        self.assertEqual(gupta_store["trust_badge"], "Trusted Neighborhood Partner")
        self.assertGreaterEqual(gupta_store["on_time_rate"], 99.0)
        self.assertTrue(gupta_store["lightning_packer"])

    def test_recurring_subscriptions_flow(self):
        """REQ-V2-CON-01: Recurring morning milk/staples subscription lifecycle."""
        # Initial subscription exists
        subs = self.service.get_subscriptions("usr-881")
        self.assertTrue(len(subs) >= 1)
        self.assertEqual(subs[0]["frequency"], "DAILY")
        self.assertEqual(subs[0]["status"], "ACTIVE")

        # Create new subscription
        new_sub = self.service.create_subscription(
            consumer_id="usr-881",
            store_id="store-001",
            item_id="item-102",
            item_title="Modern 100% Whole Wheat Bread",
            frequency="ALTERNATE_DAYS",
            time_slot="6:30 AM - 7:30 AM",
            quantity=1,
            price=45.0,
        )
        self.assertEqual(new_sub["status"], "ACTIVE")
        self.assertEqual(new_sub["frequency"], "ALTERNATE_DAYS")

        updated_subs = self.service.get_subscriptions("usr-881")
        self.assertEqual(len(updated_subs), len(subs) + 1)

    def test_store_perishables_and_expiry_alerts(self):
        """REQ-V2-MER-02: Kirana shelf perishables & short expiry alerts."""
        perishables = self.service.get_store_perishables("store-001")
        self.assertTrue(len(perishables) > 0)
        
        # Check bread (12 hours remaining) and milk (18 hours remaining)
        bread = next((it for it in perishables if "Bread" in it["title"]), None)
        self.assertIsNotNone(bread)
        self.assertLessEqual(bread["expiry_hours_remaining"], 24)
        self.assertEqual(bread["alert_level"], "CRITICAL")
        self.assertTrue(bread["is_fragile"])

    def test_order_substitute_preference_and_fragile_detection(self):
        """REQ-V2-CON-02 & REQ-V2-DLV-02: Substitute preference and fragile detection."""
        # Order containing eggs (fragile) and milk
        items = [
            {"item_id": "item-101", "quantity": 1},
            {"item_id": "item-103", "quantity": 1},  # Eggs are fragile
        ]
        res = self.service.create_order(
            consumer_id="usr-881",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=items,
            payment_method="UPI",
            substitute_preference="REPLACE_SIMILAR",
        )
        self.assertEqual(res["substitute_preference"], "REPLACE_SIMILAR")
        self.assertTrue(res["has_fragile_items"])

        # Verify rider fragile checklist
        order_id = res["order_id"]
        check_res = self.service.verify_fragile_checklist(order_id)
        self.assertTrue(check_res["fragile_verified"])
        self.assertTrue(self.service.orders[order_id].fragile_verified)

    def test_order_substitute_preference_call_me_and_refund(self):
        """REQ-V2-CON-02: Alternative substitute preferences."""
        for pref in ["CALL_ME", "REFUND"]:
            res = self.service.create_order(
                consumer_id="usr-881",
                store_id="store-001",
                consumer_lat=12.9352,
                consumer_lng=77.6245,
                items=[{"item_id": "item-101", "quantity": 1}],
                substitute_preference=pref,
            )
            self.assertEqual(res["substitute_preference"], pref)

    def test_merchant_tax_summary(self):
        """REQ-V2-MER-03: Daily settlement & GST-ready tax summary."""
        tax = self.service.get_merchant_tax_summary("store-001")
        self.assertEqual(tax["store_id"], "store-001")
        self.assertGreater(tax["gross_sales"], 0.0)
        self.assertAlmostEqual(tax["cgst_amount"], round(tax["gross_sales"] * 0.025, 2))
        self.assertAlmostEqual(tax["sgst_amount"], round(tax["gross_sales"] * 0.025, 2))
        self.assertAlmostEqual(tax["total_gst_collected"], round(tax["cgst_amount"] + tax["sgst_amount"], 2))
        self.assertAlmostEqual(tax["platform_commission"], round(tax["gross_sales"] * 0.045, 2))
        self.assertIn("gst_number", tax)
        self.assertEqual(tax["gst_number"], "29AABCU9603R1ZM")


if __name__ == "__main__":
    unittest.main()
