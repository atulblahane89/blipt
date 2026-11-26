class InventoryItem {
  final String id;
  final String storeId;
  final String barcode;
  final String title;
  final String category;
  final double price;
  int stockQuantity;
  final int lowStockThreshold;
  final String iconEmoji;
  final String unit;
  final bool isActive;

  InventoryItem({
    required this.id,
    required this.storeId,
    required this.barcode,
    required this.title,
    required this.category,
    required this.price,
    required this.stockQuantity,
    this.lowStockThreshold = 1,
    required this.iconEmoji,
    required this.unit,
    this.isActive = true,
  });

  bool get isOutOfStock => stockQuantity <= 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= lowStockThreshold;

  InventoryItem copyWith({
    int? stockQuantity,
    double? price,
    bool? isActive,
  }) {
    return InventoryItem(
      id: id,
      storeId: storeId,
      barcode: barcode,
      title: title,
      category: category,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold,
      iconEmoji: iconEmoji,
      unit: unit,
      isActive: isActive ?? this.isActive,
    );
  }
}
