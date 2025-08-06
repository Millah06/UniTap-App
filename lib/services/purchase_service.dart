import 'dart:math';

import 'package:dio/dio.dart';
import 'package:everywhere/constraints/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';


import 'package:intl/intl.dart';

class PurchaseItems {

  final dio = Dio();

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  String baseURL = "https://everywhere-data-app.onrender.com";

  Future<String?> getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  String generateRequestId() {

    final now = DateTime.now().toUtc().add(const Duration(hours: 1));

    final dateTimePart = DateFormat('yyyyMMddHHmm').format(now);


    final uuidPart = const Uuid().v4().replaceAll('-', '').substring(0, 12);

    return '$dateTimePart$uuidPart';
  }

  String generateTransactionId() {

    final now = DateTime.now().toUtc().add(const Duration(hours: 1));

    final dateTimePart = DateFormat('yyyyMMddHHmm').format(now);

    final random = Random();
    String uuidPart = '';
    for (int i = 0; i < 6; i ++) {
      uuidPart += random.nextInt(10).toString();
    }

    return '$dateTimePart$uuidPart';
  }

  Future<void> getAvailableJambServices() async {
    final idToken = await getIdToken();
    final dio = Dio();
    try {
      var response = await dio.get(
        "$baseURL/exams/jambServices",
        options: Options(
          headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json",
          }
        )
      );
      print(response.data);
    }
    catch(e) {}
  }

  Future<void> purchaseJamb(String profileCode, String phoneNumber, String variationCode) async {
    final dio = Dio();
    final idToken = await getIdToken();
    String requestID = generateRequestId();
    try{
      final response = await dio.post(
          'https://sandbox.vtpass.com/api/pay',
          data: {
            'requestID': requestID,
            'serviceID': 'jamb',
            'accountID' : profileCode,
            'phoneNumber': phoneNumber,
            'variationCode': variationCode
          },
          options: Options(
              headers: {
                "Authorization": "Bearer $idToken",
                "Content-Type": "application/json",
              }
          )
      );
      if (response.data != null) {
        print(response.data);
      }
      else {
        print(response.headers);
      }
    }
    catch(e){
      print(e);
    }
    _isLoading = false;

  }

  Future<Map<String, String>?> createVa(String phone, String email, String name) async {
    final idToken = await getIdToken();
    final dio = Dio();
    Map<String, String> ? accountData;
    try {
      var response = await dio.post(
        "$baseURL/wallet/createVA",
        data: {
          "phone" : '08111111111',
          "email": 'example@gmail.com',
          "name": 'Abdullahi Aliyu',
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json",
          },
        ),
      );
      if (response.data != null) {
        accountData = {
          'bank_name': response.data['data']['bank']['name'],
          'account_name' : response.data['data']['account_name'],
          'account_number' : response.data['data']['account_number']
        };
      }
      else {

      }
      return accountData;
    }
    catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> purchaseAirtime(String phone, String serviceId, String amount) async {
    final idToken = await getIdToken();
    final dio = Dio();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try {
      var response = await dio.post(
        "$baseURL/airtime/sendAirtime",
        data: {
          "requestID" : requestID,
          "network": serviceId,
          "phoneNumber": '08011111111',
          "amount": amount,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json",
          },
        ),
      );
      if (response.data != null) {
        print(requestID);
        print(response.data);
        result = {
          'status': response.data['response']['content']
          ['transactions']['status'] == 'delivered',
          'message' : response.data['response']['content']['transactions']['product_name'],
          'amount' : response.data['response']['amount'],
          'transaction_ID' : transactionID
        };
      }
      else {
        print(response.headers);
      }
      return result;
    }
    catch (e) {
      print(e);
      rethrow;
    }
    // _isLoading = false;
    // return null;
  }

  Future<Map<String, dynamic>?> purchaseData(String variationCode, String network) async {
    final idToken = await getIdToken();
    final dio = Dio();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try{
      var response = await dio.post(
        "$baseURL/data/buyData",
        data: {
          "requestID": DateTime.now().toString(),
          "network": "${network.toLowerCase()}-data",
          "variationCode" : variationCode,
          "phoneNumber" : '08011111111'
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json",
          }
        )
      );
      if (response.data != null) {
        print(requestID);
        print(response.data);
        print(variationCode);
        result = {
          'status': response.data['status'] == 'success',
          'phoneNumber' : response.data['response']['content']
          ['transactions']['unique_element'],
          'amount' : response.data['response']['amount'],
          'transaction_ID' : transactionID
        };
      }
      else {
        print(response.headers);
      }
      return result;
    }
    catch(e){
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> purchaseTV(String variationCode, String serviceID) async {
    final dio = Dio();
    final idToken = await getIdToken();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try{
      var response = await dio.post(
          "$baseURL/cable/purchaseTV",
          data: {
            'requestID': requestID,
            'serviceID': 'dstv',
            'phoneNumber' : '08087798514',
            'subscriptionType': 'change',
            'variationCode': variationCode,
            'smartCard': '1212121212'
          },
          options: Options(
              headers: {
                "Authorization": "Bearer $idToken",
                "Content-Type": "application/json",
              }
          )
      );
      if (response.data != null) {
        print(requestID);
        print(response.data);
        result = {
          'status': response.data['response']['content']
          ['transactions']['status'] == 'delivered',
          'message' : response.data['response']['content']
          ['transactions']['product_name'],
          'token' : response.data['response']['Token'],
          'amount' : response.data['response']['amount'],
          'transaction_ID' : transactionID
        };
      }
      else {
        print(response.headers);
        print(response.data);
      }
      return result;
    }
    catch(e){
      print(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> purchaseElectric(String provider,
      phoneNumber, meterNumber, meterType, amount ) async {
    final dio = Dio();
    final idToken = await getIdToken();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try{
      final response = await dio.post(
          "$baseURL/electricity/purchaseElectric",
          data: {
            'requestID': requestID,
            'serviceID': '${provider.split(' ').first.toLowerCase()}-electric',
            'phoneNumber' : phoneNumber,
            'amount': amount,
            'meterNumber': '1111111111111',
            'meterType': meterType
          },
          options: Options(
              headers: {
                "Authorization": "Bearer $idToken",
                "Content-Type": "application/json",
              }
          )
      );
      if (response.data != null) {
        print(requestID);
        print(response.data);
        result = {
          'status': response.data['response']['content']['transactions']['status'] == 'delivered' ?
          true : false,
          'message' : response.data['response']['content']['transactions']
          ['product_name'],
          'token' : response.data['response']['Token'],
          'amount' : response.data['response']['amount'],
          'transaction_ID' : transactionID
        };
      }
      else {
        print(response.headers);
      }
      return result;
    }
    catch(e){
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> purchaseSmile(String accountID, variationCode) async {
    final dio = Dio();
    final idToken = await getIdToken();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try{
      final response = await dio.post(
          "$baseURL/data/purchaseSmile",
          data: {
            'requestID': requestID,
            'serviceID': 'smile-direct',
            'accountID' : '08011111111',
            'phoneNumber': '08087798415',
            'variationCode': variationCode
          },
          options: Options(
              headers: {
                "Authorization": "Bearer $idToken",
                "Content-Type": "application/json",
              }
          )
      );
      if (response.data != null) {
        print(requestID);
        print(response.data);
        result = {
          'status': response.data['response']['content']['transactions']['status'] == 'delivered' ?
          true : false,
          'message' : response.data['response']['content']['transactions']['product_name'],
          'amount' : response.data['response']['amount'],
        };
      }
      else {
        print(response.headers);
      }
      return result;
    }
    catch(e){
       rethrow;
    }
  }

  Future<void> purchaseSpectra() async {}

  Future<Map<String, String>?> verifySmile(String smileEmail) async {
    final idToken = await getIdToken();
    final dio = Dio();
    try{
      var response = await dio.post(
          '$baseURL/cable/verifyMerchant',
          data: {
            "smartCard": "tester@sandbox.com",
            "serviceID": 'smile-direct'
          },
          options: Options(
            headers: {
              "Authorization": "Bearer $idToken",
              "Content-Type": "application/json",
            },
          )
      );
      if (response.data != null) {
        print(response.data);
      }
      else {
      }
      return {
        'name' : response.data['response']['content']['Customer_Name'],
        'accountID' : response.data['response']['content']
        ['AccountList']['Account'][0]['AccountId'],
        'numberOfAccounts': response.data['response']['content']
        ['AccountList']['NumberOfAccounts'].toString(),
      };
    }
    catch (e) {
      print(e);
    }
    _isLoading = false;
    return null;
  }

  Future<Map<String, dynamic>?> verifyCable(String smartCardNumber, String serviceID) async {
    final idToken = await getIdToken();
    final dio = Dio();
    try{
      var response = await dio.post(
        '$baseURL/cable/verifyMerchant',
        data: {
          "smartCard": "1212121212",
          "serviceID": serviceID.toLowerCase()
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json",
          },
        )
      );
      if (response.data != null) {
        print(response.data);
      }
      else {
      }
      return {
        'name' : response.data['response']['content']['Customer_Name'],
        'status' : response.data['response']['content']['Status'],
        'provider': response.data['response']['content']['Customer_Type'],
        'Date': response.data['response']['content']['Due_Date'].split('T').first.toString()
      };
    }
    catch (e) {
      print(e);
    }
    _isLoading = false;
    return null;
  }

  Future<Map<String, dynamic>?> verifyMeter({required String meterType, required String meterNumber, required String serviceID}) async {
    final idToken = await getIdToken();
    final dio = Dio();
    try{
      var response = await dio.post(
          '$baseURL/electricity/verifyMeter',
          data: {
            'meterType': meterType,
            "serviceID": '${serviceID.split(' ')[0].toLowerCase()}-electric',
            "meterNumber": "1111111111111",
          },
          options: Options(
            headers: {
              "Authorization": "Bearer $idToken",
              "Content-Type": "application/json",
            },
          )
      );
      if (response.data != null) {
        print(response.data);
      }
      else {
      }
      return {
        'name' : response.data['response']['content']['Customer_Name'],
        'address' : response.data['response']['content']['Address'],
        'minimumPurchase': response.data['response']['content']['Min_Purchase_Amount'],
        'meterType': response.data['response']['content']['Meter_Type']
      };
    }
    catch (e) {
      print(e);
    }
    _isLoading = false;
    return null;
  }

  Future<String?> verifyJambCandidate(String serviceType, String profileCode) async {
    final idToken = await getIdToken();
    final dio = Dio();
    try{
      var response = await dio.post(
          '$baseURL/electricity/verifyMeter',
          data: {
            'meterType': serviceType,
            "serviceID": 'jamb',
            "meterNumber": "0123456789",
          },
          options: Options(
            headers: {
              "Authorization": "Bearer $idToken",
              "Content-Type": "application/json",
            },
          )
      );
      if (response.data != null) {
        print(response.data);
      }
      else {
      }
      return response.data['content']['Customer_Name'];
    }
    catch (e) {
      print(e);
    }
    _isLoading = false;
    return null;
  }

}