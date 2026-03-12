// ─────────────────────────────────────────────────────────────────────────────
// FILE: lib/features/vendor_engine/vendor_engine_root.dart
//
// This is the single entry point for the entire Vendor Engine.
// In your existing app, navigate here from whatever card the user taps.
//
// Example in your existing app:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => const VendorEngineRoot(),
//   ));
//
// ─────────────────────────────────────────────────────────────────────────────

import 'package:everywhere/screens/vendor_screen/profile_tab.dart';
import 'package:everywhere/screens/vendor_screen/tabs/orders_tab.dart';
import 'package:everywhere/screens/vendor_screen/tabs/profile_tab.dart';
import 'package:everywhere/screens/vendor_screen/tabs/vendor_center_tab.dart';
import 'package:everywhere/screens/vendor_screen/tabs/vendors_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constraints/vendor_theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/vendor-center-provider.dart';
import '../../providers/vendor_provider.dart';
import '../../services/api_service.dart';
import 'orders_tab.dart';

// ─── Change this to your actual backend URL ────────────────────────────────

class VendorEngineShell extends StatefulWidget {
  const VendorEngineShell({super.key});

  @override
  State<VendorEngineShell> createState() => _VendorEngineShellState();
}

class _VendorEngineShellState extends State<VendorEngineShell> {
  int _index = 0;

  final _tabs = const [
    VendorsTab(),
    OrdersTab(),
    VendorCenterTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VendorTheme.background,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: VendorTheme.surface,
          border: Border(top: BorderSide(color: VendorTheme.divider, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          selectedItemColor: VendorTheme.primary,
          unselectedItemColor: VendorTheme.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined),  activeIcon: Icon(Icons.storefront),    label: 'Vendors'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long),  label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined),     activeIcon: Icon(Icons.campaign),      label: 'Vendor Center'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline),        activeIcon: Icon(Icons.person),        label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN.DART INTEGRATION
// ─────────────────────────────────────────────────────────────────────────────
// Your main.dart does NOT need any changes for the Vendor Engine providers.
// All providers are scoped inside VendorEngineRoot above using MultiProvider.
// They are created when the user enters the Vendor Engine and disposed when
// they leave — they do not pollute your global app state.
//
// The only thing your main.dart needs (which you likely already have):
//
//   void main() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     await Firebase.initializeApp();   // already done
//     runApp(const MyApp());
//   }
//
// That is all. Navigate to VendorEngineRoot from anywhere in your app.
// ─────────────────────────────────────────────────────────────────────────────
