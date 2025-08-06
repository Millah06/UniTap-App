import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Brain extends ChangeNotifier {

  List<Map<String, dynamic>> _transactions = [];

  List<Map<String, dynamic>> get transactions => _transactions;

  Future<bool> canAuthenticate() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }
  String passCode = '';
  String userName = '';
  String accountBalance = '';
  Map accountData = {};
  String pIN = '';
  String imagePath = '';
  bool _isLoading = true;

  String get localPasscode => passCode;
  String get localPIN => pIN;
  bool get isLoading => _isLoading;
  String get image => imagePath;
  String get user => userName;
  Map get userAccount => accountData;


  Future<void> addTransaction(String tranAmount, Map<String, dynamic> newTransaction) async {

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      // Get the current user data
      DocumentSnapshot docSnapshot = await userDoc.get();
      // Get the current balance
      int currentBalance = docSnapshot['balance'];

      userDoc.update({
        'balance': currentBalance - double.parse(tranAmount).toInt()
      });

      if (docSnapshot.exists) {
        // Get the current transaction list or create an empty one
        List<dynamic> transactions = docSnapshot['transactions'] ?? [];

        // Add the new transaction
        transactions.insert(0, newTransaction);

        // Update the user document
        await userDoc.update({'transactions': transactions});

        print("✅ Transaction added successfully");
      } else {
        print("❌ User not found");
      }
    } catch (e) {
      print("Error adding transaction: $e");
    }
  }



  Future<void> getData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final prefs = await SharedPreferences.getInstance();
    passCode  = prefs.getString('loginPassCode')!;
    pIN = prefs.getString('transactionPIN')!;
    imagePath = prefs.getString('imagePath')!;
    try {
      final doc = await FirebaseFirestore.instance.collection('users')
          .doc(userId).get();

      userName = await doc['name'];
      accountData = await doc['va'];
      await doc['balance'];
      notifyListeners();
    }
    catch (e) {
      print('Error fetching username: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        // Get the transactions list or an empty list if it doesn't exist
        List<dynamic> transactions = snapshot.data()?['transactions'] ?? [];

        // Assign it to your local _transactions variable
        _transactions = transactions.cast<Map<String, dynamic>>().toList();

        print(_transactions);

        notifyListeners();
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  // Future<void> fetchTransactions() async {
  //   final userId = FirebaseAuth.instance.currentUser?.uid;
  //   if (userId == null) return;
  //
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('transaction')
  //       .where('userId', isEqualTo: userId)
  //       .orderBy('date', descending: true).get();
  //
  //   _transactions = snapshot.docs.map((doc) => doc.data()).toList();
  //   notifyListeners();
  // }

  Future<void> updateImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imagePath = File(pickedFile.path).path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('imagePath', imagePath);
    }
    notifyListeners();
  }
}