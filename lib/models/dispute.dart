class Dispute {
  final String id;
  final String orderId;
  final String itemId;
  final String itemTitle;
  final String reason;
  final double refundAmount;
  final DateTime filedAt;
  final String photoPath;
  final String status; // 'AUTO_REFUNDED', 'IN_REVIEW', 'RESOLVED'

  Dispute({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.itemTitle,
    required this.reason,
    required this.refundAmount,
    required this.filedAt,
    required this.photoPath,
    this.status = 'AUTO_REFUNDED',
  });
}
