import 'package:everywhere/screens/vendor_screen/vendor_engine_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../providers/vendor-center-provider.dart';
import '../../providers/vendor_provider.dart';
import '../../services/api_service.dart';

class VendorEngineEntry extends StatelessWidget {
  const VendorEngineEntry({super.key});

  @override
  Widget build(BuildContext context) {

    final api = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => VendorListProvider(api: api)..fetchVendors()),
        ChangeNotifierProvider(create: (_) => VendorDetailProvider(api: api)),
        ChangeNotifierProvider(create: (_) => CheckoutProvider(api: api)..loadStates()),
        ChangeNotifierProvider(create: (_) => OrderListProvider(api: api)..fetchOrders()),
        ChangeNotifierProvider(create: (_) => OrderChatProvider(api: api)),
        ChangeNotifierProvider(create: (_) => VendorCenterProvider(api: api)..init()),
      ],

      child: const VendorEngineShell(),
    );
  }
}