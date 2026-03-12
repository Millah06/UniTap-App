
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class FirebaseConstant {
  static const users = 'users';
  static const phoneNumber = 'phoneNumber';
  static const availableBalance = 'availableBalance';
  static const rewardBalance = 'rewardBalance';
  static const lockedBalance = 'lockedBalance';
  static const transactionsCollection = 'transactions';
  static const chatRoomsCollection = 'chat_rooms';
  static const transferCollection = 'transfer';
  static const messages = 'messages';
  static const virtualAccount = 'va';

  static String generateTransactionId() {

    final now = DateTime.now().toUtc().add(const Duration(hours: 1));

    final dateTimePart = DateFormat('yyyyMMddHHmm').format(now);

    final random = Random();
    String uuidPart = '';
    for (int i = 0; i < 6; i ++) {
      uuidPart += random.nextInt(10).toString();
    }

    return '$dateTimePart$uuidPart';
  }

  static String clientRequestId() {
    return Uuid().v4();
  }
}