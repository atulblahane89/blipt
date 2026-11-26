"""
Blipto Escrow & Instant Settlement Ledger (REQ-MER-04, REQ-OPS-02)
Guarantees digital settlement upon OTP / Photo handoff verification
and processes zero-human dispute refunds.
"""
from typing import Dict, Optional
from .models import Store, Order, Dispute, OrderStatus


class EscrowLedgerEngine:
    def __init__(self):
        # store_id -> escrow_balance (held in lock)
        self.escrow_balances: Dict[str, float] = {}
        # store_id -> settled_balance (available for instant UPI withdrawal)
        self.settled_balances: Dict[str, float] = {}
        # consumer_id -> wallet_balance
        self.consumer_wallets: Dict[str, float] = {}

    def lock_funds_in_escrow(self, store_id: str, amount: float):
        """Locks customer order payment into escrow ledger."""
        self.escrow_balances[store_id] = self.escrow_balances.get(store_id, 0.0) + amount

    def release_escrow_to_settled(self, store_id: str, amount: float):
        """Unlocks escrow funds to merchant's settled balance upon verified handoff."""
        held = self.escrow_balances.get(store_id, 0.0)
        release_amount = min(held, amount)
        self.escrow_balances[store_id] = held - release_amount
        self.settled_balances[store_id] = self.settled_balances.get(store_id, 0.0) + release_amount

    def process_automated_refund(
        self,
        consumer_id: str,
        fulfilling_store_id: str,
        refund_amount: float,
        merchant_store: Store,
    ) -> bool:
        """
        Executes instant refund to consumer wallet and logs strike against chronic offenders.
        """
        # 1. Credit consumer wallet immediately
        self.consumer_wallets[consumer_id] = self.consumer_wallets.get(consumer_id, 0.0) + refund_amount

        # 2. Claw back from merchant escrow or settled balance
        if self.escrow_balances.get(fulfilling_store_id, 0.0) >= refund_amount:
            self.escrow_balances[fulfilling_store_id] -= refund_amount
        else:
            self.settled_balances[fulfilling_store_id] = max(
                0.0, self.settled_balances.get(fulfilling_store_id, 0.0) - refund_amount
            )

        # 3. Three-Strike Governance Rule (REQ-OPS-02)
        merchant_store.strikes += 1
        return True

    def withdraw_to_upi(self, store_id: str) -> float:
        """Simulates instant bank transfer over UPI rails."""
        available = self.settled_balances.get(store_id, 0.0)
        self.settled_balances[store_id] = 0.0
        return available
