import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SessionProvider extends ChangeNotifier {

  String? currentUserId;

  void login(String uid) {
    currentUserId = uid;
    notifyListeners();
  }

  void logout() {
    currentUserId = null;
    notifyListeners();
  }
}