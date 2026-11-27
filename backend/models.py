"""
Blipto Backend Data Models
"""
from dataclasses import dataclass, field, asdict
from typing import List, Optional, Dict
from enum import Enum
import math


class OrderStatus(str, Enum):
    PLACED = "PLACED"
    PACKING = "PACKING"
    OUT_FOR_DELIVERY = "OUT_FOR_DELIVERY"
    DELIVERED = "DELIVERED"
    DISPUTED = "DISPUTED"
    REFUNDED = "REFUNDED"


class PaymentMethod(str, Enum):
    UPI = "UPI"
    CARD = "CARD"
    WALLET = "WALLET"
    COD = "COD"


@dataclass
class Store:
    id: str
    name: str
    address: str
    latitude: float
    longitude: float
    delivery_radius_meters: int = 1500
    is_busy: bool = False
    max_active_orders: int = 4
    active_orders_count: int = 0
    trust_rating: float = 4.9
    upi_id: str = "merchant@upi"
    estimated_minutes: int = 15
    strikes: int = 0
    trust_badge: str = "Trusted Neighborhood Partner"
    on_time_rate: float = 99.2
    lightning_packer: bool = True

    @property
    def is_at_capacity(self) -> bool:
        return self.active_orders_count >= self.max_active_orders

    @property
    def can_fulfill(self) -> bool:
        return not self.is_busy and not self.is_at_capacity and self.strikes < 3


@dataclass
class InventoryItem:
    id: str
    store_id: str
    barcode: str
    title: str
    category: str
    price: float
    stock_quantity: int
    low_stock_threshold: int = 1
    unit: str = "Unit"
    is_active: bool = True
    expiry_hours_remaining: Optional[int] = None
    is_fragile: bool = False

    @property
    def is_available(self) -> bool:
        # Buffer threshold prevents walk-in collisions
        return self.is_active and self.stock_quantity > 0


@dataclass
class OrderItem:
    item_id: str
    title: str
    price: float
    quantity: int


@dataclass
class Order:
    id: str
    consumer_id: str
    store_id: str
    fulfilling_store_id: str
    is_spillover: bool
    items: List[OrderItem]
    subtotal: float
    delivery_fee: float
    total_amount: float
    delivery_otp: str
    status: OrderStatus = OrderStatus.PLACED
    created_at: str = ""
    delivery_photo_url: Optional[str] = None
    referral_commission: float = 0.0
    payment_method: str = "UPI"
    wallet_amount_used: float = 0.0
    paid_amount: float = 0.0
    substitute_preference: str = "REPLACE_SIMILAR"
    is_subscription_drop: bool = False
    has_fragile_items: bool = False
    fragile_verified: bool = False


@dataclass
class Subscription:
    id: str
    consumer_id: str
    store_id: str
    item_id: str
    item_title: str
    frequency: str = "DAILY"  # DAILY, ALTERNATE_DAYS, WEEKDAYS
    time_slot: str = "6:30 AM - 7:30 AM"
    quantity: int = 1
    price: float = 32.0
    status: str = "ACTIVE"
    created_at: str = ""


@dataclass
class Dispute:
    id: str
    order_id: str
    item_id: str
    reason: str
    photo_base64: str
    refund_amount: float
    status: str = "AUTO_RESOLVED"
    created_at: str = ""
