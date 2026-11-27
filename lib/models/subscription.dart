class Subscription {
  final String id;
  final String consumerId;
  final String storeId;
  final String itemId;
  final String itemTitle;
  final String frequency; // DAILY, ALTERNATE_DAYS, WEEKDAYS
  final String timeSlot; // 6:30 AM - 7:30 AM
  final int quantity;
  final double price;
  String status; // ACTIVE, PAUSED
  final DateTime createdAt;

  Subscription({
    required this.id,
    required this.consumerId,
    required this.storeId,
    required this.itemId,
    required this.itemTitle,
    this.frequency = "DAILY",
    this.timeSlot = "6:30 AM - 7:30 AM",
    this.quantity = 1,
    this.price = 32.0,
    this.status = "ACTIVE",
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isActive => status == "ACTIVE";

  String get frequencyDisplay {
    switch (frequency) {
      case "ALTERNATE_DAYS":
        return "Every Alternate Day";
      case "WEEKDAYS":
        return "Monday to Friday";
      case "DAILY":
      default:
        return "Daily Morning Delivery";
    }
  }
}
