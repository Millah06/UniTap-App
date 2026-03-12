// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constraints/vendor_theme.dart';
// import '../../models/order_model.dart';
// import '../../providers/order_provider.dart';
// import 'order_detail_page.dart';
//
//
// // ─── TAB 2: ORDERS ────────────────────────────────────────────────────────────
//
// class OrdersTab extends StatefulWidget {
//   const OrdersTab({super.key});
//
//   @override
//   State<OrdersTab> createState() => _OrdersTabState();
// }
//
// class _OrdersTabState extends State<OrdersTab>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: VendorTheme.background,
//       appBar: AppBar(
//         title: const Text('Orders'),
//         backgroundColor: VendorTheme.background,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: VendorTheme.primary,
//           labelColor: VendorTheme.primary,
//           unselectedLabelColor: VendorTheme.textMuted,
//           labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
//           tabs: const [
//             Tab(text: 'Ongoing'),
//             Tab(text: 'Completed'),
//             Tab(text: 'Cancelled'),
//             Tab(text: 'Appealed'),
//           ],
//         ),
//       ),
//       body: Consumer<OrderListProvider>(
//         builder: (context, provider, _) {
//           if (provider.loading) {
//             return const Center(
//               child: CircularProgressIndicator(color: VendorTheme.primary),
//             );
//           }
//
//           return RefreshIndicator(
//             color: VendorTheme.primary,
//             backgroundColor: VendorTheme.surface,
//             onRefresh: provider.fetchOrders,
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _OrderList(orders: provider.ongoing, emptyMessage: 'No ongoing orders'),
//                 _OrderList(orders: provider.completed, emptyMessage: 'No completed orders'),
//                 _OrderList(orders: provider.cancelled, emptyMessage: 'No cancelled orders'),
//                 _OrderList(orders: provider.appealed, emptyMessage: 'No appeals'),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _OrderList extends StatelessWidget {
//   final List<OrderModel> orders;
//   final String emptyMessage;
//
//   const _OrderList({required this.orders, required this.emptyMessage});
//
//   @override
//   Widget build(BuildContext context) {
//     if (orders.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.receipt_long_outlined,
//                 color: VendorTheme.textMuted, size: 48),
//             const SizedBox(height: 12),
//             Text(emptyMessage,
//                 style: const TextStyle(color: VendorTheme.textSecondary)),
//           ],
//         ),
//       );
//     }
//
//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: orders.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 12),
//       itemBuilder: (context, i) => _OrderCard(
//         order: orders[i],
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (_) => OrderDetailPage(orderId: orders[i].id)),
//         ),
//       ),
//     );
//   }
// }
//
// class _OrderCard extends StatelessWidget {
//   final OrderModel order;
//   final VoidCallback onTap;
//
//   const _OrderCard({required this.order, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: VendorTheme.surface,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: VendorTheme.divider),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(
//                     order.vendorLogo,
//                     width: 40,
//                     height: 40,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Container(
//                       width: 40,
//                       height: 40,
//                       color: VendorTheme.surfaceVariant,
//                       child: const Icon(Icons.storefront,
//                           color: VendorTheme.textMuted, size: 20),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(order.vendorName,
//                           style: const TextStyle(
//                               color: VendorTheme.textPrimary,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14)),
//                       Text(order.branchName,
//                           style: const TextStyle(
//                               color: VendorTheme.textMuted, fontSize: 12)),
//                     ],
//                   ),
//                 ),
//                 _StatusBadge(status: order.status),
//               ],
//             ),
//
//             const SizedBox(height: 10),
//
//             // Order ID and address
//             Text('#${order.id.substring(0, 8).toUpperCase()}',
//                 style: const TextStyle(
//                     color: VendorTheme.textMuted, fontSize: 11)),
//             const SizedBox(height: 2),
//             Row(
//               children: [
//                 const Icon(Icons.location_on_outlined,
//                     size: 12, color: VendorTheme.textMuted),
//                 const SizedBox(width: 4),
//                 Expanded(
//                   child: Text(order.deliveryAddress.full,
//                       style: const TextStyle(
//                           color: VendorTheme.textSecondary, fontSize: 12),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 10),
//
//             Row(
//               children: [
//                 Text('₦${order.totalAmount.toStringAsFixed(0)}',
//                     style: const TextStyle(
//                         color: VendorTheme.primary,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15)),
//                 const Spacer(),
//                 // Action buttons
//                 if (order.status.canConfirm)
//                   _ActionButton(
//                     label: 'Confirm',
//                     color: VendorTheme.accent,
//                     onTap: () => _confirmDelivery(context, order.id),
//                   ),
//                 const SizedBox(width: 8),
//                 _ActionButton(
//                   label: 'Message',
//                   color: VendorTheme.surfaceVariant,
//                   textColor: VendorTheme.textPrimary,
//                   onTap: onTap,
//                 ),
//               ],
//             ),
//
//             if (order.status.canAppeal) ...[
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: () => _showAppealDialog(context, order.id),
//                 child: const Text('File Appeal',
//                     style: TextStyle(
//                         color: VendorTheme.warning,
//                         fontSize: 12,
//                         decoration: TextDecoration.underline)),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _confirmDelivery(BuildContext context, String orderId) async {
//     final provider = context.read<OrderListProvider>();
//     final success = await provider.confirmDelivery(orderId);
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(success
//               ? 'Delivery confirmed! Funds released.'
//               : 'Failed to confirm delivery'),
//           backgroundColor: success ? VendorTheme.accent : VendorTheme.error,
//         ),
//       );
//     }
//   }
//
//   void _showAppealDialog(BuildContext context, String orderId) {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: VendorTheme.surface,
//         title: const Text('File Appeal',
//             style: TextStyle(color: VendorTheme.textPrimary)),
//         content: TextField(
//           controller: controller,
//           style: const TextStyle(color: VendorTheme.textPrimary),
//           maxLines: 3,
//           decoration: const InputDecoration(
//             hintText: 'Describe your issue...',
//             hintStyle: TextStyle(color: VendorTheme.textMuted),
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(color: VendorTheme.textSecondary)),
//           ),
//           ElevatedButton(
//             style:
//             ElevatedButton.styleFrom(backgroundColor: VendorTheme.warning),
//             onPressed: () async {
//               Navigator.pop(context);
//               await context
//                   .read<OrderListProvider>()
//                   .appealOrder(orderId, controller.text);
//             },
//             child: const Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatusBadge extends StatelessWidget {
//   final OrderStatus status;
//   const _StatusBadge({required this.status});
//
//   Color get color {
//     switch (status) {
//       case OrderStatus.completed:
//         return VendorTheme.accent;
//       case OrderStatus.cancelled:
//         return VendorTheme.error;
//       case OrderStatus.appealed:
//         return VendorTheme.warning;
//       default:
//         return VendorTheme.primary;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(status.label,
//           style: TextStyle(
//               color: color, fontSize: 11, fontWeight: FontWeight.w600)),
//     );
//   }
// }
//
// class _ActionButton extends StatelessWidget {
//   final String label;
//   final Color color;
//   final Color textColor;
//   final VoidCallback onTap;
//
//   const _ActionButton({
//     required this.label,
//     required this.color,
//     this.textColor = Colors.white,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(label,
//             style: TextStyle(
//                 color: textColor,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600)),
//       ),
//     );
//   }
// }