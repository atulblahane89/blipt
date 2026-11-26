"""
Blipto Dynamic Peak-Load Spillover Engine (REQ-OPS-01)
Automatically reroutes orders to nearest qualified partner kirana within 1.2km
when primary merchant reaches capacity or enters Busy Mode.
"""
import math
from typing import List, Optional, Tuple
from .models import Store, InventoryItem


def haversine_distance_meters(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculates great-circle distance between two GPS coordinates in meters."""
    R = 6371000.0  # Earth radius in meters
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = math.sin(delta_phi / 2.0) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return R * c


class SpilloverDispatcher:
    def __init__(self, stores: List[Store], inventory_map: dict):
        self.stores = stores
        self.inventory_map = inventory_map  # store_id -> List[InventoryItem]

    def resolve_fulfillment_store(
        self,
        primary_store_id: str,
        consumer_lat: float,
        consumer_lng: float,
        required_items: List[Tuple[str, int]],  # (barcode_or_item_id, qty)
        max_spillover_radius_meters: float = 1200.0,
    ) -> Tuple[Store, bool, float]:
        """
        Determines the fulfilling store.
        Returns (fulfilling_store, is_spillover, referral_commission).
        """
        primary_store = next((s for s in self.stores if s.id == primary_store_id), None)
        if not primary_store:
            raise ValueError(f"Primary store {primary_store_id} not found")

        # Check if primary store has capacity and is not busy
        if primary_store.can_fulfill:
            # Verify primary store has sufficient stock for all requested items
            if self._has_stock(primary_store_id, required_items):
                return primary_store, False, 0.0

        # Primary store is busy, over capacity, or stockout: Trigger Dynamic Spillover!
        candidate_partners = []
        for store in self.stores:
            if store.id == primary_store_id:
                continue
            if not store.can_fulfill:
                continue

            dist = haversine_distance_meters(consumer_lat, consumer_lng, store.latitude, store.longitude)
            if dist <= max_spillover_radius_meters:
                if self._has_stock(store.id, required_items):
                    candidate_partners.append((store, dist))

        if candidate_partners:
            # Sort by proximity to consumer
            candidate_partners.sort(key=lambda x: x[1])
            selected_partner = candidate_partners[0][0]
            # 1.5% micro-commission to originating store for routing session
            referral_fee = 6.00  # ₹6 flat referral credit
            return selected_partner, True, referral_fee

        # If no partner found within 1.2km, fallback to primary store with queue wait
        return primary_store, False, 0.0

    def _has_stock(self, store_id: str, required_items: List[Tuple[str, int]]) -> bool:
        catalog = self.inventory_map.get(store_id, [])
        item_dict = {it.barcode: it for it in catalog}
        item_dict.update({it.id: it for it in catalog})

        for key, qty in required_items:
            it = item_dict.get(key)
            if not it or it.stockQuantity if hasattr(it, 'stockQuantity') else getattr(it, 'stock_quantity', 0) < qty:
                return False
        return True
