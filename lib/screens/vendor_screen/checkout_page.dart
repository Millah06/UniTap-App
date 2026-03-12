// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../constraints/vendor_theme.dart';
// import '../../models/order_model.dart';
// import '../../providers/order_provider.dart';
// import '../../providers/vendor_provider.dart';
//
//
// // ─── CHECKOUT PAGE ────────────────────────────────────────────────────────────
//
// class CheckoutPage extends StatefulWidget {
//   const CheckoutPage({super.key});
//
//   @override
//   State<CheckoutPage> createState() => _CheckoutPageState();
// }
//
// class _CheckoutPageState extends State<CheckoutPage> {
//   String? _state;
//   String? _lga;
//   String? _area;
//   String? _street;
//   double _deliveryFee = 0;
//
//   // TODO: Load from API /locations/hierarchy
//   final Map<String, List<String>> _lgasByState = {
//     'Lagos': ['Ikeja', 'Lagos Island', 'Eti-Osa', 'Alimosho'],
//     'Abuja': ['AMAC', 'Bwari', 'Gwagwalada'],
//   };
//
//   final Map<String, List<String>> _areasByLga = {
//     'Ikeja': ['GRA', 'Allen', 'Oregun'],
//     'Lagos Island': ['Victoria Island', 'Ikoyi', 'Lagos Island'],
//     'Eti-Osa': ['Lekki', 'Ajah', 'Sangotedo'],
//   };
//
//   final Map<String, List<String>> _streetsByArea = {
//     'GRA': ['Adeniyi Jones Ave', 'Isaac John St', 'Alausa'],
//     'Lekki': ['Admiralty Way', 'Freedom Way', 'Chevron Drive'],
//     'Victoria Island': ['Ahmadu Bello Way', 'Adeola Odeku', 'Sanusi Fafunwa'],
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: VendorTheme.background,
//       appBar: AppBar(
//         title: const Text('Checkout'),
//         backgroundColor: VendorTheme.background,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: VendorTheme.textPrimary),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Consumer2<CartProvider, CheckoutProvider>(
//         builder: (context, cart, checkout, _) {
//           final subtotal = cart.subtotal;
//           final txFee = checkout.transactionFeeFor(subtotal, 2);
//           final total = subtotal + _deliveryFee + txFee;
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Cart items
//                 _SectionTitle('Order Summary'),
//                 const SizedBox(height: 8),
//                 ...cart.items.map((item) => _CartItemRow(item: item)),
//                 const Divider(color: VendorTheme.divider, height: 24),
//
//                 // Delivery address
//                 _SectionTitle('Delivery Address'),
//                 const SizedBox(height: 12),
//                 _LocationDropdown(
//                   label: 'State',
//                   value: _state,
//                   items: _lgasByState.keys.toList(),
//                   onChanged: (v) => setState(() {
//                     _state = v;
//                     _lga = null;
//                     _area = null;
//                     _street = null;
//                   }),
//                 ),
//                 const SizedBox(height: 8),
//                 _LocationDropdown(
//                   label: 'LGA',
//                   value: _lga,
//                   enabled: _state != null,
//                   items: _state != null ? (_lgasByState[_state] ?? []) : [],
//                   onChanged: (v) => setState(() {
//                     _lga = v;
//                     _area = null;
//                     _street = null;
//                   }),
//                 ),
//                 const SizedBox(height: 8),
//                 _LocationDropdown(
//                   label: 'Area',
//                   value: _area,
//                   enabled: _lga != null,
//                   items: _lga != null ? (_areasByLga[_lga] ?? []) : [],
//                   onChanged: (v) {
//                     setState(() {
//                       _area = v;
//                       _street = null;
//                     });
//                     _lookupDeliveryFee(cart.branchId, v);
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 _LocationDropdown(
//                   label: 'Street',
//                   value: _street,
//                   enabled: _area != null,
//                   items: _area != null ? (_streetsByArea[_area] ?? []) : [],
//                   onChanged: (v) => setState(() => _street = v),
//                 ),
//                 const Divider(color: VendorTheme.divider, height: 24),
//
//                 // Price breakdown
//                 _SectionTitle('Price Breakdown'),
//                 const SizedBox(height: 8),
//                 _PriceLine(label: 'Subtotal', amount: subtotal),
//                 _PriceLine(label: 'Delivery Fee', amount: _deliveryFee),
//                 _PriceLine(
//                   label: 'Transaction Fee',
//                   amount: txFee,
//                   note: txFee == 0 ? '(Free)' : null,
//                 ),
//                 const Divider(color: VendorTheme.divider, height: 16),
//                 _PriceLine(
//                   label: 'Total',
//                   amount: total,
//                   isBold: true,
//                   color: VendorTheme.primary,
//                 ),
//                 const SizedBox(height: 24),
//
//                 if (checkout.error != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: Text(checkout.error!,
//                         style: const TextStyle(color: VendorTheme.error)),
//                   ),
//
//                 // Place order button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: VendorTheme.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     onPressed: checkout.loadingLocation  ? null : () => _placeOrder(context, cart, checkout),
//                     child: checkout. loadingLocation
//                         ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                           color: Colors.white, strokeWidth: 2),
//                     )
//                         : const Text('Place Order',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16)),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _lookupDeliveryFee(String? branchId, String? area) {
//     // TODO: look up from branch delivery zones
//     // For now, mock it
//     setState(() => _deliveryFee = 500);
//   }
//
//   Future<void> _placeOrder(
//       BuildContext context, CartProvider cart, CheckoutProvider checkout) async {
//     if (_state == null || _lga == null || _area == null || _street == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please complete your delivery address'),
//             backgroundColor: VendorTheme.error),
//       );
//       return;
//     }
//
//     // checkout.setDeliveryAddress(
//     //   DeliveryAddress(
//     //       state: _state!,
//     //       lga: _lga!,
//     //       area: _area!,
//     //       street: _street!),
//     //   _deliveryFee,
//     // );
//
//     final success = await checkout.placeOrder(
//       vendorId: cart.vendorId!,
//       branchId: cart.branchId!,
//       items: cart.items.toList(),
//     );
//
//     if (success && mounted) {
//       cart.clear();
//       checkout.reset();
//       Navigator.popUntil(context, (r) => r.isFirst);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Order placed successfully!'),
//             backgroundColor: VendorTheme.accent),
//       );
//     }
//   }
// }
//
// class _SectionTitle extends StatelessWidget {
//   final String title;
//   const _SectionTitle(this.title);
//
//   @override
//   Widget build(BuildContext context) => Text(
//     title,
//     style: const TextStyle(
//         color: VendorTheme.textPrimary,
//         fontWeight: FontWeight.bold,
//         fontSize: 15),
//   );
// }
//
// class _CartItemRow extends StatelessWidget {
//   final CartItem item;
//   const _CartItemRow({required this.item});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Text('${item.quantity}x',
//               style: const TextStyle(
//                   color: VendorTheme.primary, fontWeight: FontWeight.w600)),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(item.menuItem.name,
//                 style: const TextStyle(color: VendorTheme.textPrimary)),
//           ),
//           Text('₦${item.total.toStringAsFixed(0)}',
//               style: const TextStyle(color: VendorTheme.textSecondary)),
//         ],
//       ),
//     );
//   }
// }
//
// class _LocationDropdown extends StatelessWidget {
//   final String label;
//   final String? value;
//   final List<String> items;
//   final ValueChanged<String?> onChanged;
//   final bool enabled;
//
//   const _LocationDropdown({
//     required this.label,
//     required this.value,
//     required this.items,
//     required this.onChanged,
//     this.enabled = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//       decoration: BoxDecoration(
//         color: VendorTheme.surface,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: VendorTheme.divider),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           hint: Text(label,
//               style: const TextStyle(color: VendorTheme.textMuted, fontSize: 14)),
//           value: value,
//           isExpanded: true,
//           dropdownColor: VendorTheme.surface,
//           style: const TextStyle(color: VendorTheme.textPrimary, fontSize: 14),
//           disabledHint: Text(label,
//               style: const TextStyle(
//                   color: VendorTheme.textMuted, fontSize: 14)),
//           items: enabled
//               ? items
//               .map((item) => DropdownMenuItem(
//             value: item,
//             child: Text(item),
//           ))
//               .toList()
//               : null,
//           onChanged: enabled ? onChanged : null,
//         ),
//       ),
//     );
//   }
// }
//
// class _PriceLine extends StatelessWidget {
//   final String label;
//   final double amount;
//   final bool isBold;
//   final Color? color;
//   final String? note;
//
//   const _PriceLine({
//     required this.label,
//     required this.amount,
//     this.isBold = false,
//     this.color,
//     this.note,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final style = TextStyle(
//       color: color ?? (isBold ? VendorTheme.textPrimary : VendorTheme.textSecondary),
//       fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//       fontSize: isBold ? 16 : 14,
//     );
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Text(label, style: style),
//           if (note != null) ...[
//             const SizedBox(width: 4),
//             Text(note!,
//                 style: const TextStyle(
//                     color: VendorTheme.accent, fontSize: 12)),
//           ],
//           const Spacer(),
//           Text('₦${amount.toStringAsFixed(0)}', style: style),
//         ],
//       ),
//     );
//   }
// }