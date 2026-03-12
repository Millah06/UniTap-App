
class TransactionModel {

  final String amount;
  final String type;
  final String subType;
  final Map metaData;
  final DateTime createdAt;
  final bool status;

  TransactionModel({
    required this.amount,
    required this.type,
    required this.subType,
    required this.metaData,
    required this.createdAt,
    required this.status
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
        amount: json['amount'],
        type: json['type'],
        subType: json['subType'],
        metaData: Map<String, dynamic>.from(json['hashtags'] ?? []),
        createdAt: _parseDateTime(json['createAt']) ?? DateTime.now(),
        status: json['status']
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is Map<String, dynamic>) {
      final seconds = value['_seconds'];
      final nanoseconds = value['_nanoseconds'] ?? 0;
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          (seconds * 1000) + (nanoseconds ~/ 1000000),
        );
      }
    }
    return null;
  }

}