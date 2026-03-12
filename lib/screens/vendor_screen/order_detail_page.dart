// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../constraints/vendor_theme.dart';
// import '../../providers/order_provider.dart';
//
//
// // ─── ORDER DETAIL PAGE (with chat) ───────────────────────────────────────────
//
// class OrderDetailPage extends StatefulWidget {
//   final String orderId;
//   const OrderDetailPage({super.key, required this.orderId});
//
//   @override
//   State<OrderDetailPage> createState() => _OrderDetailPageState();
// }
//
// class _OrderDetailPageState extends State<OrderDetailPage>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabs;
//   final _chatController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _tabs = TabController(length: 2, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // context.read<OrderChatProvider>().loadChat(widget.orderId);
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabs.dispose();
//     _chatController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrderListProvider>(
//       builder: (context, orderProvider, _) {
//         final order =
//             orderProvider.orders.where((o) => o.id == widget.orderId).firstOrNull;
//
//         return Scaffold(
//           backgroundColor: VendorTheme.background,
//           appBar: AppBar(
//             title: Text(
//               order != null ? '#${order.id.substring(0, 8).toUpperCase()}' : 'Order',
//               style: const TextStyle(color: VendorTheme.textPrimary),
//             ),
//             backgroundColor: VendorTheme.background,
//             bottom: TabBar(
//               controller: _tabs,
//               indicatorColor: VendorTheme.primary,
//               labelColor: VendorTheme.primary,
//               unselectedLabelColor: VendorTheme.textMuted,
//               tabs: const [Tab(text: 'Details'), Tab(text: 'Chat')],
//             ),
//           ),
//           body: TabBarView(
//             controller: _tabs,
//             children: [
//               if (order == null)
//                 const Center(
//                   child: Text('Order not found',
//                       style: TextStyle(color: VendorTheme.textSecondary)),
//                 )
//               else
//                 _DetailsTab(order: order),
//               _ChatTab(
//                 orderId: widget.orderId,
//                 chatController: _chatController,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _DetailsTab extends StatelessWidget {
//   final order;
//   const _DetailsTab({required this.order});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Items
//           const Text('Items',
//               style: TextStyle(
//                   color: VendorTheme.textPrimary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15)),
//           const SizedBox(height: 8),
//           ...order.items.map(
//                 (item) => Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               child: Row(
//                 children: [
//                   Text('${item.quantity}x',
//                       style: const TextStyle(
//                           color: VendorTheme.primary,
//                           fontWeight: FontWeight.w600)),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(item.name,
//                         style: const TextStyle(color: VendorTheme.textPrimary)),
//                   ),
//                   Text('₦${item.total.toStringAsFixed(0)}',
//                       style: const TextStyle(color: VendorTheme.textSecondary)),
//                 ],
//               ),
//             ),
//           ),
//           const Divider(color: VendorTheme.divider, height: 24),
//
//           // Delivery
//           const Text('Delivery',
//               style: TextStyle(
//                   color: VendorTheme.textPrimary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15)),
//           const SizedBox(height: 8),
//           Text(order.deliveryAddress.full,
//               style: const TextStyle(color: VendorTheme.textSecondary)),
//           const Divider(color: VendorTheme.divider, height: 24),
//
//           // Pricing
//           const Text('Payment',
//               style: TextStyle(
//                   color: VendorTheme.textPrimary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15)),
//           const SizedBox(height: 8),
//           _Row('Subtotal', '₦${order.subtotal.toStringAsFixed(0)}'),
//           _Row('Delivery Fee', '₦${order.deliveryFee.toStringAsFixed(0)}'),
//           _Row('Transaction Fee', '₦${order.transactionFee.toStringAsFixed(0)}'),
//           const Divider(color: VendorTheme.divider, height: 16),
//           _Row(
//             'Total',
//             '₦${order.totalAmount.toStringAsFixed(0)}',
//             bold: true,
//             valueColor: VendorTheme.primary,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _Row extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool bold;
//   final Color? valueColor;
//
//   const _Row(this.label, this.value, {this.bold = false, this.valueColor});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Text(label,
//               style: TextStyle(
//                   color: VendorTheme.textSecondary,
//                   fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
//           const Spacer(),
//           Text(value,
//               style: TextStyle(
//                   color: valueColor ?? VendorTheme.textPrimary,
//                   fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
//         ],
//       ),
//     );
//   }
// }
//
// class _ChatTab extends StatelessWidget {
//   final String orderId;
//   final TextEditingController chatController;
//
//   const _ChatTab({required this.orderId, required this.chatController});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrderChatProvider>(
//       builder: (context, provider, _) {
//         return Column(
//           children: [
//             // Expanded(
//             //   child: provider.loading
//             //       ? const Center(
//             //       child: CircularProgressIndicator(
//             //           color: VendorTheme.primary))
//             //       : ListView.builder(
//             //     padding: const EdgeInsets.all(16),
//             //     itemCount: provider.messages.length,
//             //     itemBuilder: (context, i) {
//             //       final msg = provider.messageStream(orderId);
//             //       final isMe = msg.senderId == 'current_user'; // replace with actual userId
//             //       return _ChatBubble(message: msg, isMe: isMe);
//             //     },
//             //   ),
//             // ),
//             _ChatInput(
//               controller: chatController,
//               sending: provider.sending,
//               onSend: () async {
//                 final text = chatController.text.trim();
//                 if (text.isEmpty) return;
//
//                 // if (provider.containsPhoneNumber(text)) {
//                 //   ScaffoldMessenger.of(context).showSnackBar(
//                 //     const SnackBar(
//                 //       content: Text('Phone numbers are not allowed in chat'),
//                 //       backgroundColor: VendorTheme.error,
//                 //     ),
//                 //   );
//                 //   return;
//                 // }
//
//                 final sent = await provider.sendMessage(orderId, text, '');
//                 if (sent) chatController.clear();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _ChatBubble extends StatelessWidget {
//   final message;
//   final bool isMe;
//
//   const _ChatBubble({required this.message, required this.isMe});
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.7,
//         ),
//         decoration: BoxDecoration(
//           color: isMe ? VendorTheme.primary : VendorTheme.surface,
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(12),
//             topRight: const Radius.circular(12),
//             bottomLeft: Radius.circular(isMe ? 12 : 0),
//             bottomRight: Radius.circular(isMe ? 0 : 12),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment:
//           isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             if (message.isAdmin)
//               const Text('Admin',
//                   style: TextStyle(
//                       color: VendorTheme.warning,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold)),
//             Text(message.message,
//                 style: const TextStyle(color: Colors.white, fontSize: 13)),
//             const SizedBox(height: 2),
//             Text(
//               '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
//               style: TextStyle(
//                   color: Colors.white.withOpacity(0.6), fontSize: 10),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ChatInput extends StatelessWidget {
//   final TextEditingController controller;
//   final bool sending;
//   final VoidCallback onSend;
//
//   const _ChatInput(
//       {required this.controller, required this.sending, required this.onSend});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//       color: VendorTheme.surface,
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: controller,
//               style: const TextStyle(color: VendorTheme.textPrimary),
//               decoration: InputDecoration(
//                 hintText: 'Type a message...',
//                 hintStyle: const TextStyle(color: VendorTheme.textMuted),
//                 filled: true,
//                 fillColor: VendorTheme.surfaceVariant,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: sending ? null : onSend,
//             child: Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: sending ? VendorTheme.textMuted : VendorTheme.primary,
//                 shape: BoxShape.circle,
//               ),
//               child: sending
//                   ? const Padding(
//                 padding: EdgeInsets.all(10),
//                 child: CircularProgressIndicator(
//                     color: Colors.white, strokeWidth: 2),
//               )
//                   : const Icon(Icons.send, color: Colors.white, size: 20),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }