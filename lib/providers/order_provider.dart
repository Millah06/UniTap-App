import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constraints/vendor_theme.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/vendorService/order_repository.dart';


// ─── CheckoutProvider ─────────────────────────────────────────────────────────

class CheckoutProvider extends ChangeNotifier {
  final ApiService api;
  CheckoutProvider({required this.api});

  // Location selection
  LocationState? selectedState;
  LocationLga? selectedLga;
  LocationArea? selectedArea;
  LocationStreet? selectedStreet;
  double deliveryFee = 0;

  List<LocationState> states = [];
  List<LocationLga> lgas = [];
  List<LocationArea> areas = [];
  List<LocationStreet> streets = [];

  bool loadingLocation = false;
  bool placingOrder = false;
  String? error;
  OrderModel? placedOrder;

  bool get canCheckout =>
      selectedState != null && selectedLga != null &&
          selectedArea != null && selectedStreet != null;

  Future<void> loadStates() async {
    loadingLocation = true;
    notifyListeners();
    try {
      final data = await api.get('/location/states') as List;
      states = data.map((s) => LocationState.fromJson(s)).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> pickState(LocationState state) async {
    selectedState = state;
    selectedLga = null;
    selectedArea = null;
    selectedStreet = null;
    lgas = [];
    areas = [];
    streets = [];
    deliveryFee = 0;
    notifyListeners();
    try {
      final data = await api.get('/location/lgas/${state.id}') as List;
      lgas = data.map((l) => LocationLga.fromJson(l)).toList();
    } catch (e) { error = e.toString(); }
    notifyListeners();
  }

  Future<void> pickLga(LocationLga lga) async {
    selectedLga = lga;
    selectedArea = null;
    selectedStreet = null;
    areas = [];
    streets = [];
    deliveryFee = 0;
    notifyListeners();
    try {
      final data = await api.get('/location/areas/${lga.id}') as List;
      areas = data.map((a) => LocationArea.fromJson(a)).toList();
    } catch (e) { error = e.toString(); }
    notifyListeners();
  }

  Future<void> pickArea(LocationArea area, String branchId) async {
    selectedArea = area;
    selectedStreet = null;
    streets = [];
    notifyListeners();
    try {
      final data = await api.get('/location/streets/${area.id}') as List;
      streets = data.map((s) => LocationStreet.fromJson(s)).toList();
      // Get delivery fee for this area from branch zones
      final zones = await api.get('/branch/$branchId/delivery-zones') as List;
      final zone = zones.firstWhere(
            (z) => z['area'] == area.name,
        orElse: () => null,
      );
      deliveryFee = zone != null ? (zone['deliveryFee'] as num).toDouble() : 0;
    } catch (e) { error = e.toString(); }
    notifyListeners();
  }

  void pickStreet(LocationStreet street) {
    selectedStreet = street;
    notifyListeners();
  }

  double transactionFeeFor(double subtotal, double txPercent) => subtotal * (txPercent / 100);

  Future<bool> placeOrder({
    required String vendorId,
    required String branchId,
    required List<CartItem> items,
  }) async {
    if (!canCheckout) { error = 'Please complete your delivery address'; notifyListeners(); return false; }
    placingOrder = true;
    error = null;
    notifyListeners();
    try {
      final data = await api.post('/order/place', {
        'vendorId': vendorId,
        'branchId': branchId,
        'items': items.map((i) => i.toOrderPayload()).toList(),
        'deliveryAddress': {
          'state': selectedState!.name,
          'lga': selectedLga!.name,
          'area': selectedArea!.name,
          'street': selectedStreet!.name,
        },
      });
      placedOrder = OrderModel.fromJson(data);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      placingOrder = false;
      notifyListeners();
    }
  }

  void reset() {
    selectedState = null; selectedLga = null;
    selectedArea = null; selectedStreet = null;
    deliveryFee = 0; placedOrder = null; error = null;
    notifyListeners();
  }
}

// ─── OrderListProvider ────────────────────────────────────────────────────────

class OrderListProvider extends ChangeNotifier {
  final ApiService api;
  OrderListProvider({required this.api});

  List<OrderModel> orders = [];
  bool loading = false;
  String? error;

  List<OrderModel> get ongoing   => orders.where((o) => o.status.isOngoing).toList();
  List<OrderModel> get completed => orders.where((o) => o.status == OrderStatus.completed).toList();
  List<OrderModel> get cancelled => orders.where((o) => o.status == OrderStatus.cancelled).toList();
  List<OrderModel> get appealed  => orders.where((o) => o.status == OrderStatus.appealed).toList();

  Future<void> fetchOrders() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await api.get('/order/mine') as List;
      orders = data.map((o) => OrderModel.fromJson(o)).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmDelivery(String orderId) async {
    try {
      final data = await api.post('/order/$orderId/confirm', {});
      _replace(OrderModel.fromJson(data));
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> appealOrder(String orderId, String reason) async {
    try {
      final data = await api.post('/order/$orderId/appeal', {'reason': reason});
      _replace(OrderModel.fromJson(data));
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _replace(OrderModel updated) {
    final i = orders.indexWhere((o) => o.id == updated.id);
    if (i != -1) { orders[i] = updated; notifyListeners(); }
  }
}

// ─── ChatProvider ─────────────────────────────────────────────────────────────
// Uses Firestore for realtime — no HTTP polling needed.

class OrderChatProvider extends ChangeNotifier {
  final ApiService api;
  OrderChatProvider({required this.api});

  String? _orderId;
  bool sending = false;
  String? error;

  static final _phonePattern = RegExp(r'(\+?\d[\d\s\-]{8,}\d)');

  bool containsPhone(String msg) => _phonePattern.hasMatch(msg);

  // Returns a Firestore stream — plug directly into StreamBuilder in Flutter
  Stream<List<ChatMessageModel>> messageStream(String orderId) {
    _orderId = orderId;
    return FirebaseFirestore.instance
        .collection('orderChats')
        .doc(orderId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ChatMessageModel.fromFirestore(d.data(), d.id, orderId))
        .toList());
  }

  Future<bool> sendMessage(String orderId, String message, String senderName) async {
    if (containsPhone(message)) { error = 'Phone numbers not allowed'; notifyListeners(); return false; }
    sending = true;
    error = null;
    notifyListeners();
    try {
      await api.post('/chat/$orderId/send', {'message': message, 'senderName': senderName});
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      sending = false;
      notifyListeners();
    }
  }
}