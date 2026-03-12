

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everywhere/constraints/firebase_constant.dart';

class ReceiverInfo {
  final String uid;
  final String name;

  ReceiverInfo({required this.uid, required this.name});
}


class TransferService {

  final _db = FirebaseFirestore.instance;

  Future<void> _sendTransferNotification(
      String receiverUid,
      double amount,
      String humanRef,
      ) async {

    final userDoc =
    await _db.collection('users').doc(receiverUid).get();

    final token = userDoc['notificationToken'];
    

    // Call your backend or cloud function here
  }


  Future<ReceiverInfo?> getReceiverInfo({
    required String phoneNumber,
  }) async {
    final normalized = phoneNumber.startsWith('0')
        ? phoneNumber
        : '0$phoneNumber';

    final snapshot = await _db
        .collection('users')
        .where('phoneNumber', isEqualTo: normalized)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;

    return ReceiverInfo(
      uid: doc.id,
      name: doc['name'],
    );
  }

  Future<Map<String, dynamic>?> createWalletTransfer({required String senderUid, required String receiverUid, required double amount, required String clientRequestId,}) async {

    final usersRef = _db.collection('users');
    final transfersRef = _db.collection('transfer');
    final transactionsRef = _db.collection('transactions');

    final transferDoc = transfersRef.doc();

    final humanRef = FirebaseConstant.generateTransactionId();

    try {

      // Idempotency check
      final existing = await transfersRef
          .where('clientRequestId', isEqualTo: clientRequestId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        print('Document exits');
        return {'status' : false};
      };

      await _db.runTransaction((transaction) async {

        final senderDoc = usersRef.doc(senderUid);
        final receiverDoc = usersRef.doc(receiverUid);

        final senderSnap = await transaction.get(senderDoc);
        final receiverSnap = await transaction.get(receiverDoc);


        final senderBalance = senderSnap['wallet']['fiat']['availableBalance'] as num;

        if (senderBalance < amount) {
          print('Insufficient balance');
          throw Exception("Insufficient balance");
        }

        final newSenderBalance = senderBalance - amount;
        final receiverBalance = senderSnap['wallet']['fiat']['availableBalance'] as num;

        final newReceiverBalance = receiverBalance + amount;

        // Update balances
        transaction.update(senderDoc, {
          'wallet.fiat.availableBalance': newSenderBalance,
        });

        transaction.update(receiverDoc, {
          'wallet.fiat.availableBalance': newReceiverBalance,
        });

        // Create transfer doc
        transaction.set(transferDoc, {
          'humanRef': humanRef,
          'clientRequestId': clientRequestId,
          'mode': 'wallet',
          'senderUid': senderUid,
          'receiverUid': receiverUid,
          'amount': amount,
          'status': 'processing',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Sender transaction
        transaction.set(transactionsRef.doc(), {
          'uid': senderUid,
          'humanRef': humanRef,
          'transferId': transferDoc.id,
          'direction': 'debit',
          'amount': amount,
          'balanceBefore': senderBalance,
          'balanceAfter': newSenderBalance,
          'status': 'success',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Receiver transaction
        transaction.set(transactionsRef.doc(), {
          'uid': receiverUid,
          'humanRef': humanRef,
          'transferId': transferDoc.id,
          'direction': 'credit',
          'amount': amount,
          'balanceBefore': receiverBalance,
          'balanceAfter': newReceiverBalance,
          'status': 'success',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      // 2️⃣ Update transfer to success AFTER transaction
      await transferDoc.update({
        'status': 'success',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('updated status');

      // 3️⃣ Send notification
      await _sendTransferNotification(receiverUid, amount, humanRef);

      return {
        'status' : 'true'
      };

    }
    catch (e) {
      // 2️⃣ Update transfer to success AFTER transaction
      // await transferDoc.update({
      //   'status': 'failed',
      //   'updatedAt': FieldValue.serverTimestamp(),
      // });
      print('Transation matsala');
      rethrow;
    }

  }

  Future<void> createChatTransfer({
    required String senderUid,
    required String receiverUid,
    required double amount,
  }) async {

    final usersRef = _db.collection('users');
    final transfersRef = _db.collection('transfers');

    final transferDoc = transfersRef.doc();

    await _db.runTransaction((transaction) async {

      final senderDoc = usersRef.doc(senderUid);
      final senderSnap = await transaction.get(senderDoc);

      final available =
      senderSnap['wallet']['fiat']['available'] as num;

      if (available < amount) {
        throw Exception("Insufficient balance");
      }

      final locked =
      senderSnap['wallet']['fiat']['locked'] as num;

      transaction.update(senderDoc, {
        'wallet.fiat.available': available - amount,
        'wallet.fiat.locked': locked + amount,
      });

      transaction.set(transferDoc, {
        'mode': 'chat',
        'senderUid': senderUid,
        'receiverUid': receiverUid,
        'amount': amount,
        'status': 'pending_acceptance',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> acceptTransfer(String transferId) async {

    final transferRef =
    _db.collection('transfers').doc(transferId);

    await _db.runTransaction((transaction) async {

      final transferSnap = await transaction.get(transferRef);

      if (transferSnap['status'] != 'pending_acceptance') {
        throw Exception("Invalid state");
      }

      final senderUid = transferSnap['senderUid'];
      final receiverUid = transferSnap['receiverUid'];
      final amount = transferSnap['amount'];

      final senderRef =
      _db.collection('users').doc(senderUid);
      final receiverRef =
      _db.collection('users').doc(receiverUid);

      final senderSnap = await transaction.get(senderRef);
      final receiverSnap = await transaction.get(receiverRef);

      final senderLocked =
      senderSnap['wallet']['fiat']['locked'] as num;

      final receiverAvailable =
      receiverSnap['wallet']['fiat']['available'] as num;

      transaction.update(senderRef, {
        'wallet.fiat.locked': senderLocked - amount,
      });

      transaction.update(receiverRef, {
        'wallet.fiat.available':
        receiverAvailable + amount,
      });

      transaction.update(transferRef, {
        'status': 'success',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> rejectTransfer(String transferId) async {

    final transferRef =
    _db.collection('transfers').doc(transferId);

    await _db.runTransaction((transaction) async {

      final transferSnap = await transaction.get(transferRef);

      final senderUid = transferSnap['senderUid'];
      final amount = transferSnap['amount'];

      final senderRef =
      _db.collection('users').doc(senderUid);

      final senderSnap = await transaction.get(senderRef);

      final locked =
      senderSnap['wallet']['fiat']['locked'] as num;
      final available =
      senderSnap['wallet']['fiat']['available'] as num;

      transaction.update(senderRef, {
        'wallet.fiat.locked': locked - amount,
        'wallet.fiat.available': available + amount,
      });

      transaction.update(transferRef, {
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }




}