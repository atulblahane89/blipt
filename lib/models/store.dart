class Store {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final int deliveryRadiusMeters;
  bool isBusy;
  final int maxActiveOrders;
  int activeOrdersCount;
  final double trustRating;
  final String upiId;
  final int estimatedMinutes;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    this.deliveryRadiusMeters = 1500,
    this.isBusy = false,
    this.maxActiveOrders = 4,
    this.activeOrdersCount = 1,
    this.trustRating = 4.9,
    required this.upiId,
    this.estimatedMinutes = 15,
  });

  bool get isAtCapacity => activeOrdersCount >= maxActiveOrders;
  bool get canAcceptOrders => !isBusy && !isAtCapacity;

  Store copyWith({
    bool? isBusy,
    int? activeOrdersCount,
  }) {
    return Store(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      distanceMeters: distanceMeters,
      deliveryRadiusMeters: deliveryRadiusMeters,
      isBusy: isBusy ?? this.isBusy,
      maxActiveOrders: maxActiveOrders,
      activeOrdersCount: activeOrdersCount ?? this.activeOrdersCount,
      trustRating: trustRating,
      upiId: upiId,
      estimatedMinutes: estimatedMinutes,
    );
  }
}
