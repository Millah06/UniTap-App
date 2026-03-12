import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../models/vendor_model.dart';
import '../services/api_service.dart';
import '../services/vendorService/vendor_repository.dart';

// ─── VENDOR CENTER PROVIDER ───────────────────────────────────────────────────

class VendorCenterProvider extends ChangeNotifier {
  final ApiService api;
  VendorCenterProvider({required this.api});

  VendorModel? myVendor;
  VendorMetrics? metrics;
  List<MenuItemModel> menuItems = [];
  bool loading = false;
  String? error;

  bool get isApprovedVendor => myVendor?.status == 'approved';

  bool get isPending => myVendor?.status == 'pending';

  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await api.get('/vendor/me');
      myVendor = VendorModel.fromJson(data);
      if (isApprovedVendor) {
        final m = await api.get('/vendor/metrics');
        metrics = VendorMetrics.fromJson(m);
        if (myVendor!.branches.isNotEmpty) {
          await loadMenuForBranch(myVendor!.branches.first.id);
        }
      }
    } catch (_) {
      myVendor = null; // not a vendor
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMenuForBranch(String branchId) async {
    try {
      final data = await api.get('/branch/$branchId/menu') as List;
      menuItems = data.map((m) => MenuItemModel.fromJson(m)).toList();
      notifyListeners();
    } catch (e) { error = e.toString(); notifyListeners(); }
  }

  Future<bool> addMenuItem(String branchId, Map<String, dynamic> item) async {
    try {
      final data = await api.post('/menu/$branchId/add', item);
      menuItems.add(MenuItemModel.fromJson(data));
      notifyListeners();
      return true;
    } catch (e) { error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> updateMenuItem(String itemId, Map<String, dynamic> updates) async {
    try {
      final data = await api.put('/menu/$itemId/update', updates);
      final updated = MenuItemModel.fromJson(data);
      final i = menuItems.indexWhere((m) => m.id == itemId);
      if (i != -1) { menuItems[i] = updated; notifyListeners(); }
      return true;
    } catch (e) { error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> deleteMenuItem(String itemId) async {
    try {
      await api.delete('/menu/$itemId/delete');
      menuItems.removeWhere((m) => m.id == itemId);
      notifyListeners();
      return true;
    } catch (e) { error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> toggleVisibility() async {
    try {
      final data = await api.put('/vendor/visibility', {});
      if (myVendor != null) {

        myVendor = VendorModel.fromJson({
          ...myVendor!.toJson(),
          'isVisible': data['isVisible'],
        });




        notifyListeners();
      }
      return true;
    } catch (e) { error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> applyAsVendor(Map<String, dynamic> application) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await api.post('/vendor/apply', application);
      await init();
      return true;
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadLogo(File imageFile, String fileCategory) async {
    print('the inner is also called');
    try {
      print('I will start upload');
      final url = await api.upload('vendor/upload/logo', imageFile, fileCategory);
      print(url);
      if (myVendor != null) {
        myVendor = VendorModel.fromJson({...myVendor!.toJson(), 'logo': url});

        notifyListeners();
      }
      return true;
    } catch (e) { error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> uploadMenuItemImage(String itemId, File imageFile,  String fileCategory) async {
    try {
      await api.upload('menu/$itemId/upload-image', imageFile, fileCategory);
      await loadMenuForBranch(myVendor!.branches.first.id);
      return true;
    } catch (e) { error = e.toString(); notifyListeners(); return false; }
  }
}