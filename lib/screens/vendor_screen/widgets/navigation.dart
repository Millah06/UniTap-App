

// Use this instead of Navigator.push anywhere inside VendorEngineRoot.
// It re-injects all providers into the new route so they are available
// on every page, no matter how deep the navigation goes.

import 'package:provider/provider.dart';

import '../../../providers/order_provider.dart';
import '../../../providers/vendor-center-provider.dart';
import '../../../providers/vendor_provider.dart';
import "package:flutter/material.dart";

Future<T?> vendorPush<T>(BuildContext context, Widget page) {
  // Capture all providers from the current context before pushing
  final cart          = context.read<CartProvider>();
  final vendorList    = context.read<VendorListProvider>();
  final vendorDetail  = context.read<VendorDetailProvider>();
  final checkout      = context.read<CheckoutProvider>();
  final orderList     = context.read<OrderListProvider>();
  final vendorCenter  = context.read<VendorCenterProvider>();

  return Navigator.push<T>(
    context,
    MaterialPageRoute(
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: cart),
          ChangeNotifierProvider.value(value: vendorList),
          ChangeNotifierProvider.value(value: vendorDetail),
          ChangeNotifierProvider.value(value: checkout),
          ChangeNotifierProvider.value(value: orderList),
          ChangeNotifierProvider.value(value: vendorCenter),
        ],
        child: page,
      ),
    ),
  );
}
