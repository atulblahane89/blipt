"""
Adversarial QA Suite: Dispatch & Dynamic Spillover (REQ-OPS-01, REQ-MER-03, REQ-CON-01)
"""
import unittest
from backend.models import Store, InventoryItem
from backend.spillover_engine import SpilloverDispatcher, haversine_distance_meters


class TestDispatchAndSpillover(unittest.TestCase):
    def setUp(self):
        self.store1 = Store(
            id="store-1",
            name="Primary Kirana",
            address="400m away",
            latitude=12.9352,
            longitude=77.6245,
            is_busy=False,
            max_active_orders=3,
            active_orders_count=0,
        )
        self.store2 = Store(
            id="store-2",
            name="Partner Supermarket",
            address="700m away",
            latitude=12.9380,
            longitude=77.6290,
            is_busy=False,
            max_active_orders=5,
            active_orders_count=0,
        )
        self.inventory = {
            "store-1": [InventoryItem("i1", "store-1", "BAR-01", "Milk", "Dairy", 30.0, 10)],
            "store-2": [InventoryItem("i2", "store-2", "BAR-01", "Milk", "Dairy", 30.0, 20)],
        }
        self.dispatcher = SpilloverDispatcher([self.store1, self.store2], self.inventory)

    def test_haversine_accuracy(self):
        # 12.9352, 77.6245 to 12.9380, 77.6290 is ~580m
        dist = haversine_distance_meters(12.9352, 77.6245, 12.9380, 77.6290)
        self.assertGreater(dist, 500)
        self.assertLess(dist, 700)

    def test_normal_fulfillment_primary_store(self):
        # When primary store is idle and has stock, fulfillment stays with primary
        store, is_spill, referral = self.dispatcher.resolve_fulfillment_store(
            primary_store_id="store-1",
            consumer_lat=12.9350,
            consumer_lng=77.6240,
            required_items=[("BAR-01", 2)],
        )
        self.assertEqual(store.id, "store-1")
        self.assertFalse(is_spill)
        self.assertEqual(referral, 0.0)

    def test_busy_mode_triggers_spillover(self):
        # When primary store toggles Busy Mode, order dynamically spills to Store 2
        self.store1.is_busy = True
        store, is_spill, referral = self.dispatcher.resolve_fulfillment_store(
            primary_store_id="store-1",
            consumer_lat=12.9350,
            consumer_lng=77.6240,
            required_items=[("BAR-01", 2)],
        )
        self.assertEqual(store.id, "store-2")
        self.assertTrue(is_spill)
        self.assertGreater(referral, 0.0)

    def test_capacity_saturation_triggers_spillover(self):
        # When primary store reaches max concurrent delivery runs (e.g. 3/3), order spills to partner
        self.store1.active_orders_count = 3
        self.assertTrue(self.store1.is_at_capacity)

        store, is_spill, referral = self.dispatcher.resolve_fulfillment_store(
            primary_store_id="store-1",
            consumer_lat=12.9350,
            consumer_lng=77.6240,
            required_items=[("BAR-01", 2)],
        )
        self.assertEqual(store.id, "store-2")
        self.assertTrue(is_spill)


if __name__ == "__main__":
    unittest.main()
