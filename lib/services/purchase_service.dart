import 'dart:math';

import 'package:dio/dio.dart';
import 'package:everywhere/constraints/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';


import 'package:intl/intl.dart';

import 'brain.dart';

class PurchaseItems {

  BuildContext context;

  PurchaseItems({required this.context});

  final dio = Dio();

  bool _isLoading = true;

  bool get isLoading => _isLoading;



  String? getBaseURL() {
    final pov = Provider.of<Brain>(context, listen: false);
    String? baseURL = pov.baseURL;
    return baseURL;
  }


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

  Future<Map<String, dynamic>> checkTransactionStatus(String transactionId) async {
    final idToken = await getIdToken();
    final dio = Dio();

    try {
      final response = await dio.get(
        "${getBaseURL()}/transactions/status/$transactionId",
        options: Options(headers: {
          "Authorization": "Bearer $idToken",
          "Content-Type": "application/json",
        }),
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response.data);
      }

      return {
        'status': false,
        'message': 'No response from server',
        'transaction_id': transactionId,
        'date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to fetch transaction',
        'transaction_id': transactionId,
        'date': DateTime.now().toIso8601String(),
      };
    }
  }



  Future<Map<String, dynamic>?> purchaseJamb(String profileCode, String phoneNumber, String variationCode, String amount) async {
    final dio = Dio();
    final idToken = await getIdToken();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try{
      final response = await dio.post(
          "${getBaseURL()}/electricity/purchaseElectric",
          data: {
            'requestID': requestID,
            'serviceID': 'jamb',
            'phoneNumber' : phoneNumber,
            'amount': amount,
            // 'meterNumber': profileCode,
            'meterNumber' : profileCode,
            'meterType': variationCode
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
          'status': response.data['response']['content']['transactions']['status'] == 'delivered',
          'token' : response.data['response']['purchased_code'].split(' : ')[1],
          'amount' : response.data['response']['amount'],
          'transaction_ID' : transactionID,
          "requestID": requestID,
          'date' : DateTime.now(),
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

  Future<Map<String, dynamic>?> purchaseWaecRegistration(String phoneNumber, String variationCode, String amount, int quantity) async {
    final dio = Dio();
    final idToken = await getIdToken();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try{
      final response = await dio.post(
          "${getBaseURL()}/electricity/purchaseElectric",
          data: {
            'requestID': requestID,
            'serviceID': 'waec-registration',
            'phoneNumber' : phoneNumber,
            'amount': amount,
            'meterType': variationCode,
            'quantity' : quantity
          },
          options: Options(
              headers: {
                "Authorization": "Bearer $idToken",
                "Content-Type": "application/json",
              }
          )
      );
      print(response.data);
      if (response.data != null) {
        print(requestID);
        print(response.data);
        result = {
          'status': response.data['response']['content']['transactions']['status'] == 'delivered',
          if (quantity == 1)
          'token' : response.data['response']['purchased_code'].split(":")[1],
          if (quantity > 1)
          'tokens' : jsonEncode(response.data['response']['tokens']),
          'amount' : response.data['response']['amount'],
          'transaction_ID' : transactionID,
          "requestID": requestID,
          'date' : DateTime.now(),
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

  Future<Map<String, dynamic>?> purchaseWaecResultPin(int quantity, String phoneNumber, String variationCode, String amount) async {
    final dio = Dio();
    final idToken = await getIdToken();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try{
      final response = await dio.post(
          "${getBaseURL()}/electricity/purchaseElectric",
          data: {
            'requestID': requestID,
            'serviceID': 'waec',
            'phoneNumber' : phoneNumber,
            'amount': amount,
            'meterType': variationCode,
            'quantity' : quantity
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
        print(jsonEncode(response.data));
        String pin = response.data['response']['purchased_code'].split(",")[1].split(':')[1];
        String serial = response.data['response']['purchased_code'].split(",")[0].split(':')[1];
        result = {
          'status': response.data['response']['content']['transactions']['status'] == 'delivered',
          if (quantity == 1)
          'token' : 'PIN : $pin',
          if (quantity == 1)
          'serial' : 'Serial : $serial',
          if (quantity > 1)
          'tokens' : jsonEncode(response.data['response']['cards']),
          'amount' : response.data['response']['amount'],
          'transaction_ID' : transactionID,
          "requestID": requestID,
          'date' : DateTime.now(),
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


  Future<Map<String, String>?> createVa(String phone, String email, String name) async {
    final idToken = await getIdToken();
    final dio = Dio();
    Map<String, String> ? accountData;
    try {
      var response = await dio.post(
        "${getBaseURL() ?? "https://everywhere-data-app.onrender.com"}/wallet/createVA",
        data: {
          "phone" : phone,
          "email": email,
          "name": name,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json",
          },
        ),
      );
      if (response.data != null) {
        print(response.data);
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

  Future<Map<String, dynamic>?> purchaseAirtime(
      {
    required String clientRequestId,
    required String humanRef,
    required String phone,
    required String serviceId,
    required bool isRecharge,
    required useReward,
    required String amount}
      ) async {

    final idToken = await getIdToken();
    final dio = Dio();
    String requestID = generateRequestId();
    Map<String, dynamic>? result;
    try {
      var response = await dio.post(
        "${getBaseURL()}/airtime/sendAirtime",
        data: {
          "requestID" : requestID,
          "network": serviceId,
          "phoneNumber": phone,
          "amount": amount,
          "useReward": useReward,
          "isRecharge": isRecharge,
          "humanRef": humanRef,
          "clientRequestId": clientRequestId,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json",
          },
        ),
      );
      if (response.data != null) {
        result = response.data;
        print(result);
      }
      else {
        print(response.headers);
      }
      print(result);
      return result;
    }
    catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> purchaseRechargePin(String network, String networkAmount, String quantity, String nameCard) async {
    final idToken = await getIdToken();
    final dio = Dio();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try {
      var response = await dio.post(
        "${getBaseURL()}/airtime/sendRecharge",
        data: {
          "network" : network == 'MTN' ? '1' : network == 'GLO' ? '2' : network == '9MOBILE' ? '3' : '4',
          "network_amount": networkAmount,
          "quantity": quantity,
          "name_on_card": nameCard,
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
          'status': response.data['status'] == 'success',
          'pin' : response.data['response'],
          'transaction_ID' : transactionID,
          "requestID": requestID,
          'date' : DateTime.now(),
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
  }

  Future<Map<String, dynamic>?> purchaseData(
      {
        required String variationCode,
        required String clientRequestId,
        required String humanRef,
        required String phone,
        required String network,
        required bool isRecharge,
        required useReward,
        required String amount,
        required String plan
      }
      ) async {
    final idToken = await getIdToken();
    final dio = Dio();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try{
      var response = await dio.post(
        "${getBaseURL()}/data/buyData",
        data: {
          "requestID": requestID,
          "network": "${network.toLowerCase()}-data",
          "variationCode" : variationCode,
          "phoneNumber" : phone,
          "plan": plan,
          "amount": amount,
          "useReward": useReward,
          "isRecharge": isRecharge,
          "humanRef": humanRef,
          "clientRequestId": clientRequestId,
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
          'status': response.data['response']['content']
          ['transactions']['status'] == 'delivered',
          'phoneNumber' : response.data['response']['content']
          ['transactions']['unique_element'],
          'amount' : response.data['response']['amount'],
          'transaction_ID' : transactionID,
          "requestID": requestID,
          'date' : DateTime.now(),
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

  Future<Map<String, dynamic>?> purchaseTV(
      {
        required String variationCode,
        required String serviceID,
        required String phoneNumber,
        required String cableNumber,
        required String clientRequestId,
        required String humanRef,
        required bool isRecharge,
        required useReward,
        required String amount,
      }
      ) async {
    final dio = Dio();
    final idToken = await getIdToken();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try{
      var response = await dio.post(
          "${getBaseURL()}/cable/purchaseTV",
          data: {
            'requestID': requestID,
            'serviceID': serviceID.toLowerCase(),
            'phoneNumber' : phoneNumber,
            'subscriptionType': 'change',
            'variationCode': variationCode,
            'smartCard': cableNumber,
            "amount": amount,
            "useReward": useReward,
            "isRecharge": isRecharge,
            "humanRef": humanRef,
            "clientRequestId": clientRequestId,
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
          'transaction_ID' : transactionID,
          "requestID": requestID,
          'date' : DateTime.now(),
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
          "${getBaseURL()}/electricity/purchaseElectric",
          data: {
            'requestID': requestID,
            'serviceID': '${provider.split(' ').first.toLowerCase()}-electric',
            'phoneNumber' : phoneNumber,
            'amount': amount,
            'meterNumber': meterNumber,
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
          result = {
          'status': response.data['response']['content']['transactions']['status'] == 'delivered' ?
          true : false,
          'message' : response.data['response']['content']['transactions']
          ['product_name'],
          'token' : response.data['response']['Token'],
          'amount' : response.data['response']['amount'],
          'transaction_ID' : transactionID,
            "requestID": requestID,
          'date' : DateTime.now(),
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

  Future<Map<String, dynamic>?> purchaseSmile(String accountID, variationCode, String phoneNumber) async {
    final dio = Dio();
    final idToken = await getIdToken();
    String requestID = generateRequestId();
    String transactionID = generateTransactionId();
    Map<String, dynamic>? result;
    try{
      final response = await dio.post(
          "${getBaseURL()}/data/purchaseSmile",
          data: {
            'requestID': requestID,
            'serviceID': 'smile-direct',
            'accountID' : accountID,
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
        print(requestID);
        print(response.data);
        result = {
          'status': response.data['response']['content']['transactions']['status'] == 'delivered',
          'message' : response.data['response']['content']['transactions']['product_name'],
          'amount' : response.data['response']['amount'],
          'transaction_ID' : transactionID,
          "requestID": requestID,
          'date' : DateTime.now(),
        };
      }
      else {

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
          '${getBaseURL()}/cable/verifyMerchant',
          data: {
            "smartCard": smileEmail,
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
    Map<String, dynamic>? result;
    try{
      var response = await dio.post(
        '${getBaseURL()}/cable/verifyMerchant',
        data: {
          "smartCard": smartCardNumber,
          "serviceID": serviceID.toLowerCase()
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json",
          },
        )
      );
      if (response.data != null && !response.data['response']['content'].containsKey('error')) {
        print(response.data);
        result = {
          'name' : response.data['response']['content']['Customer_Name'],
          'status' : response.data['response']['content']['Status'],
          'provider': response.data['response']['content']['Customer_Type'],
          'Date': response.data['response']['content']['Due_Date'].split('T').first.toString()
        };
      }
      else {
        print(response.data);
        print(result);
        result = {};
      }
      return result;
    }
    catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> verifyMeter({required String meterType,
    required String meterNumber, required String selectedProvider}) async {
    final idToken = await getIdToken();
    final dio = Dio();
    Map<String, dynamic>? result;

    try{
      var response = await dio.post(
          '${getBaseURL()}/electricity/verifyMeter',
          data: {
            'meterType': meterType,
            "serviceID": '${selectedProvider.split(' ')[0].toLowerCase()}-electric',
            "meterNumber": meterNumber,
          },
          options: Options(
            headers: {
              "Authorization": "Bearer $idToken",
              "Content-Type": "application/json",
            },
          )
      );
      if (response.data != null && !response.data['response']['content'].containsKey('error')) {
        result = {
          'name' : response.data['response']['content']['Customer_Name'],
          'address' : response.data['response']['content']['Address'],
          'minimumPurchase': response.data['response']['content']['Min_Purchase_Amount'],
          'meterType': response.data['response']['content']['Meter_Type']
        };
      }
      else {
        result = {};
      }
      return result;
    }
    catch (e) {
      rethrow;
    }
  }

  Future<String?> verifyJambCandidate(String serviceType, String profileCode) async {
    final idToken = await getIdToken();
    final dio = Dio();
    try{
      var response = await dio.post(
          '${getBaseURL()}/electricity/verifyMeter',
          data: {
            'meterType': serviceType,
            "serviceID": 'jamb',
            "meterNumber": profileCode,
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
      return response.data['response']['content']['Customer_Name'];
    }
    catch (e) {
      print(e);
    }
    _isLoading = false;
    return null;
  }

}