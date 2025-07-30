import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everywhere/services/purchase_service.dart';
import 'package:everywhere/services/transaction_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Authentication {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  get signUp =>  userSignUp;

  Future<User?> userSignUp(String email, String password, String name, String phoneNumber) async {
    UserCredential ? result;
    try {
       result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
       final userId = _auth.currentUser?.uid;
      await _firestore.collection('users').doc(userId).set({
        'name' : name,
        'email' : email,
        'balance' : 0.0,
        'phoneNumber' : phoneNumber,
        'transactions' : [],
        'createdAt' : FieldValue.serverTimestamp()
      });
      PurchaseItems().createVa(phoneNumber, email, name);
      return result.user;

    }
    catch(e) {
      rethrow;
    }
  }

  Future<User?> userSignIn(String email, String password,) async {
    UserCredential ? result;
    try {
      result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    }
    catch(e) {
      rethrow;
    }
  }


}