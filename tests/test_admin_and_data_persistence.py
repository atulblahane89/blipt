"""
QA Verification Suite: App Owner Admin Dashboard & Master Data Persistence (REQ-ADM-01, REQ-ADM-02, REQ-ADM-03)
"""
import unittest
import json
from backend.app import BliptoBackendService


class TestAdminAndDataPersistence(unittest.TestCase):
    def setUp(self):
        self.svc = BliptoBackendService()

    def test_admin_overview_metrics(self):
        # Place sample order
        order_res = self.svc.create_order(
            consumer_id="usr-881",
            store_id="store-001",
            consumer_lat=12.9352,
            consumer_lng=77.6245,
            items=[{"barcode": "8901030383821", "quantity": 2}],
        )
        total = order_res["total_amount"]

        overview = self.svc.get_admin_overview()
        self.assertIn("platform_gmv", overview)
        self.assertIn("platform_revenue", overview)
        self.assertIn("escrow_locked_funds", overview)
        self.assertIn("active_stores_count", overview)

        self.assertGreaterEqual(overview["platform_gmv"], total)
        # Platform fee 4.5%
        self.assertAlmostEqual(overview["platform_revenue"], round(overview["platform_gmv"] * 0.045, 2))
        self.assertGreaterEqual(overview["escrow_locked_funds"], total)
        self.assertEqual(overview["active_stores_count"], 3)

    def test_master_database_export_data_persistence(self):
        # Verify master export has all necessary tables for owner to save data
        dump = self.svc.export_all_data()

        self.assertIn("export_timestamp", dump)
        self.assertIn("stores", dump)
        self.assertIn("inventory", dump)
        self.assertIn("orders", dump)
        self.assertIn("disputes", dump)
        self.assertIn("escrow_ledger", dump)

        self.assertEqual(len(dump["stores"]), 3)
        self.assertIn("store-001", dump["inventory"])

        # Test JSON serialization integrity
        serialized = json.dumps(dump)
        deserialized = json.loads(serialized)
        self.assertEqual(len(deserialized["stores"]), len(dump["stores"]))

    def test_owner_adjust_store_radius(self):
        res = self.svc.adjust_store_radius("store-001", 2200)
        self.assertEqual(res["delivery_radius_meters"], 2200)

        store = next(s for s in self.svc.stores if s.id == "store-001")
        self.assertEqual(store.delivery_radius_meters, 2200)


if __name__ == "__main__":
    unittest.main()
