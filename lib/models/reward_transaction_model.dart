// lib/models/reward_transaction_model.dart

class RewardTransaction {
  final String transactionId;
  final String senderId;
  final String creatorId;
  final String? postId;
  final double amount;
  final double platformFee;
  final double pointsAwarded;
  final String type;
  final String status;
  final DateTime createdAt;

  RewardTransaction({
    required this.transactionId,
    required this.senderId,
    required this.creatorId,
    this.postId,
    required this.amount,
    required this.platformFee,
    required this.pointsAwarded,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  factory RewardTransaction.fromJson(Map<String, dynamic> json) {
    return RewardTransaction(
      transactionId: json['transactionId'] ?? '',
      senderId: json['senderId'] ?? '',
      creatorId: json['creatorId'] ?? '',
      postId: json['postId'],
      amount: (json['amount'] ?? 0).toDouble(),
      platformFee: (json['platformFee'] ?? 0).toDouble(),
      pointsAwarded: (json['pointsAwarded'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}