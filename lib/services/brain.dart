import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:everywhere/constraints/firebase_constant.dart';
import 'package:everywhere/services/social_api_service.dart';
import 'package:everywhere/services/user_contact_service.dart';
import 'package:everywhere/services/user_match_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'contact_service.dart';

class Brain extends ChangeNotifier {


  List<Map<String, dynamic>> _transactions = [];

  List<Map<String, dynamic>> get transactions => _transactions;

  StreamSubscription<DocumentSnapshot>? _transactionsSubscription;

  String get currentUser => FirebaseAuth.instance.currentUser!.uid;

  bool _contactsLoaded = false;
  bool _contactsLoading = false;
  bool _contactsPermissionDenied = false;

  bool get contactsLoaded => _contactsLoaded;
  bool get contactsLoading => _contactsLoading;
  bool get contactsPermissionDenied => _contactsPermissionDenied;

  Future<void> loadContactsOnce() async {
    // Avoid duplicate work if already running or done
    if (_contactsLoaded || _contactsLoading) return;

    _contactsLoading = true;
    _contactsPermissionDenied = false;
    notifyListeners();

    try {
      debugPrint('🔄 Start loading contacts for chat matching...');

      final contacts = await ContactService().fetchContacts();
      debugPrint('📇 CONTACT COUNT: ${contacts.length}');

      final matchedUsers = await UserMatchService().findMatchedUsers(contacts);

      debugPrint('👤 Saving matched contacts for user $currentUser, count: ${matchedUsers.length}');

      await UserContactService.saveUserContacts(currentUser, matchedUsers);

      _contactsLoaded = true;
    } on ContactPermissionDeniedException catch (e) {
      _contactsPermissionDenied = true;
      debugPrint('⚠️ Contacts permission denied: $e');
    } catch (e, st) {
      debugPrint('❌ Error loading / matching contacts: $e\n$st');
    } finally {
      _contactsLoading = false;
      notifyListeners();
    }
  }



  Future<bool> canAuthenticate() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }
  String passCode = '';
  String userName = '';
  String accountBalance = '0';
  String phoneNumber = '';
  String accountReward = '0';

  double totalMonthlySpent = 0;

  double  airtimePercent = 0;
  String ? baseURL;
  double dataPercent = 0;
  double  cablePercent = 0;
  double  electricPercent = 0;
  double  waecPercent = 0;
  double  jambPercent = 0;
  double fundingFees = 0;
  double  rCPersonalPercent = 0;
  double  rCBusinessPercent = 0;
  double  internetPercent = 0;
  int buildNumberFromFireStore = 0;

  Map<String, bool> cableProviders = {};
  Map<String, bool> electricProviders = {};
  Map<String, bool> dataProviders = {};
  Map<String, bool> airtimeProviders = {};
  List<String> whatIsNew = [];
  bool mandatory = false;
  String versionName = '1.0.0';

  Map accountData = {};
  List<dynamic> availableJambServices = [];
  List<dynamic> availableWaecRegistration = [];
  List<dynamic> availableWaecPin = [];
  String pIN = '';
  String imagePath = '';
  bool _isLoading = true;

  String get localPasscode => passCode;
  String get localPIN => pIN;
  bool get isLoading => _isLoading;
  String get image => imagePath;
  String get user => userName;
  Map get userAccount => accountData;

  Future<String?> getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  String generateUserTransferId() {
    final random = Random.secure();
    return List.generate(11, (_) => random.nextInt(10)).join();
  }

  String generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return 'REF-${List.generate(6, (_) => chars[random.nextInt(chars.length)]).join()}';
  }

  Future<void> migrateUserWallets() async {
    final users = await FirebaseFirestore.instance.collection('users').get();

    // Generate unique transfer UID
    String transferUid = '';
    bool exists = true;

    while (exists) {
      transferUid = generateUserTransferId();
      final check = await FirebaseFirestore.instance
          .collection('users')
          .where('transferUid', isEqualTo: transferUid)
          .limit(1)
          .get();
      exists = check.docs.isNotEmpty;
    }

    final referralCode = generateReferralCode();

    for (var doc in users.docs) {

      await createUserProfile(doc.id, {'transferUID' : doc['transferUid'],
        'email': doc['email'], 'photoURL': doc['userAvatar'], 'displayName': doc['userName']  });
      final data = doc.data();

      if (data['userName'] != null) continue;

      final oldBalance = (data['balance'] ?? 0).toDouble();
      final oldReward = (data['reward'] ?? 0).toDouble();

      await doc.reference.update({
        'transferUid': transferUid,
        'referralCode': referralCode,
        'referredBy': null,

        'kyc': {
          'status': 'not_submitted', // future crypto use
        },

        'wallet': {
          'fiat': {
            'availableBalance': oldBalance,
            'lockedBalance': 0.0,
            'rewardBalance' : oldReward
          },
          'crypto': {
            'usdt': {
              'available': 0.0,
              'locked': 0.0,
            },
            'btc': {
              'available': 0.0,
              'locked': 0.0,
            },
          }
        },
        'userAvatar' : null,
        'userName' : null,
        'bio' : null,
        'chatTag' : null,
      });
    }
  }

  Future<void> createUserProfile(String userId, Map<String, dynamic> userData) async {
    final docRef = FirebaseFirestore.instance.collection('userProfiles').doc(userId);

    await docRef.set({
      'userId': userId,
      'username': userData['displayName'] ?? userData['name'] ?? 'Anonymous',
      'bio': '',
      'chatTag': userData['chatTag'] ?? null,
      'transferUID': userData['transferUID'] ?? null,
      'email': userData['email'] ?? null,
      'avatar': userData['photoURL'] ?? userData['photoUrl'] ?? null,
      'isPrivate': false,
      'allowFollowersToMessage': false,
      'followerCount': 0,
      'followingCount': 0,
      'postCount': 0,
      'badges': [],
      'totalEarned': 0,
      'weeklyEarned': 0,
    });
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

      final bonusDoc = await FirebaseFirestore.instance.collection('bonuses ').doc('reward').get();
      DocumentSnapshot updateSnap = await FirebaseFirestore.instance.collection('bonuses ').doc('updateInfo').get();

      if (updateSnap.exists) {
        whatIsNew = List<String>.from(updateSnap['whatIsNew'].values);
        mandatory = updateSnap['mandatory'] ?? false;
        versionName = updateSnap['versionName'];
      }

      final serviceDoc = await FirebaseFirestore.instance.collection('services').doc('services').get();

      if (bonusDoc.exists) {
        print("Bonus doc data: ${bonusDoc.data()}");
      } else {
        print("No bonus doc found!");
      }

      cableProviders = Map<String, bool>.from(serviceDoc['cableServices']);
      dataProviders =  Map<String, bool>.from(serviceDoc['dataNetwork']);
      airtimeProviders =  Map<String, bool>.from(serviceDoc['airtimeServices']);
      electricProviders = Map<String, bool>.from(serviceDoc['electricProviders']);

      airtimePercent = (bonusDoc['airtime'] as num).toDouble();
      dataPercent = (bonusDoc['data'] as num).toDouble();
      cablePercent = (bonusDoc['cable'] as num).toDouble();
      electricPercent = (bonusDoc['electric'] as num).toDouble();
      rCBusinessPercent = (bonusDoc['rechargeB'] as num).toDouble();
      rCPersonalPercent = (bonusDoc['rechargeP'] as num).toDouble();
      internetPercent = (bonusDoc['internet'] as num).toDouble();
      waecPercent = (bonusDoc['waec'] as num).toDouble();
      jambPercent = (bonusDoc['jamb'] as num).toDouble();
      fundingFees = (bonusDoc['fundingFees'] as num).toDouble();
      buildNumberFromFireStore = (bonusDoc['buildNumber'] as num).toInt();
      baseURL = bonusDoc['baseURL'] ?? {
        print('Base Url not found'),
        "https://everywhere-data-app.onrender.com"
      };


      if (doc.exists)  {
        userName = await doc['name'];
        accountData = await doc['va'];
        accountBalance = doc['wallet']['fiat'][FirebaseConstant.availableBalance].toString();
        accountReward = doc['wallet']['fiat'][FirebaseConstant.rewardBalance].toString();
        phoneNumber = await doc['phoneNumber'];
      }

      notifyListeners();
    }
    catch (e) {
      print('Error fetching username: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  String generateRequestId() {

    final now = DateTime.now().toUtc().add(const Duration(hours: 1));

    final dateTimePart = DateFormat('yyyyMMddHHmm').format(now);


    final uuidPart = const Uuid().v4().replaceAll('-', '').substring(0, 12);

    return '$dateTimePart$uuidPart';
  }

  Future<List> getAvailableJambServices() async {
    final idToken = await getIdToken();
    final dio = Dio();
    try {
      var response = await dio.get(
          "$baseURL/exams/jambServices",
          data: {
            'serviceID' : 'jamb'
          },
          options: Options(
              headers: {
                "Authorization": "Bearer $idToken",
                "Content-Type": "application/json",
              }
          )
      );

      print(response.data);

      return response.data['response']['content']['variations'];

    }
    catch(e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAvailableWaecRegistration() async {
    final idToken = await getIdToken();
    final dio = Dio();
    try {
      var response = await dio.get(
          "$baseURL/exams/jambServices",
          data: {
            'serviceID' : 'waec-registration'
          },
          options: Options(
              headers: {
                "Authorization": "Bearer $idToken",
                "Content-Type": "application/json",
              }
          )
      );

      print(response.data);

      return response.data['response']['content']['variations'];

    }
    catch(e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAvailableWaecPin() async {
    final idToken = await getIdToken();
    final dio = Dio();
    try {
      var response = await dio.get(
          "$baseURL/exams/jambServices",
          data: {
            'serviceID' : 'waec'
          },
          options: Options(
              headers: {
                "Authorization": "Bearer $idToken",
                "Content-Type": "application/json",
              }
          )
      );

      print(response.data);

      return response.data['response']['content']['variations'];

    }
    catch(e) {
      rethrow;
    }
  }



  Future<void> fetchTransactions() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // cancel old listener if any
    if (_transactionsSubscription != null) {
      await _transactionsSubscription!.cancel();
      _transactionsSubscription = null;
    }
    // start listening to the user document for realtime updates
    _transactionsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      try {
        if (snapshot.exists) {
          final data = snapshot.data(); // safe cast
          List<dynamic> transactions = data?['transactions'] ?? [];
          _transactions = transactions.cast<Map<String, dynamic>>().toList();
          final filtered = _transactions.where((tx) {
            final date = (tx['Date'] as Timestamp).toDate();
            return date.year == DateTime.now().year && date.month == DateTime.now().month;
          }).toList();
          totalMonthlySpent = 0;
          for (Map item in filtered) {
             totalMonthlySpent += (item['Paid Amount'] as num).toDouble();
             print(totalMonthlySpent);
          }

          accountBalance = data!['balance'].toString();
          accountReward = data['reward'].toString();
          accountData = data['va'];
        } else {
          _transactions = [];
        }
        print("📌 Transactions updated: $_transactions");
        notifyListeners();
      } catch (e) {
        print("❌ Error parsing transactions from snapshot: $e");
      }
    }, onError: (error) {
      print("❌ Error listening to transactions: $error");
    });
  }

  Future<void> fetchSecureTransaction() async {
    FirebaseFirestore.instance
        .collection("transactions")
        .where("userId", isEqualTo: currentUser)
        .orderBy("createdAt", descending: true)
        .snapshots();

  }


  Future<void> updateImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/profile.png');
      String imgUrl = await SocialApiService().uploadPostImage(savedImage);
      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser);
      await userRef.update({
        'photoURL' : imgUrl,
      });


      // imagePath = File(pickedFile.path).path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('imagePath', savedImage.path);
    }
    notifyListeners();
  }

  void reset() {
    accountBalance = '0';
    _transactions = [];
    phoneNumber = '';
    userName = '';
    accountReward = '0';

    notifyListeners();
  }

  @override
  void dispose() {
    try {
      _transactionsSubscription?.cancel(); // returns a Future we can't await here
    } catch (e) {
      print('Error cancelling subscription in dispose: $e');
    }
    _transactionsSubscription = null;
    super.dispose();
  }

}