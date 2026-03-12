import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constraints/vendor_theme.dart';
import '../../../models/order_model.dart';
import '../../../providers/order_provider.dart';
import '../widgets/shared_widgets.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;
  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VendorTheme.background,
      appBar: AppBar(
        backgroundColor: VendorTheme.background,
        elevation: 0,
        title: Text('Order #${widget.order.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: VendorTheme.textPrimary),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: VendorTheme.primary,
          labelColor: VendorTheme.primary,
          unselectedLabelColor: VendorTheme.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'Details'), Tab(text: 'Chat')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _DetailsTab(order: widget.order),
          _ChatTab(order: widget.order),
        ],
      ),
    );
  }
}

// ─── Details Tab ──────────────────────────────────────────────────────────────

class _DetailsTab extends StatelessWidget {
  final OrderModel order;
  const _DetailsTab({required this.order});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status
        _card(
          child: Row(
            children: [
              const Text('Status', style: TextStyle(color: VendorTheme.textMuted, fontSize: 13)),
              const Spacer(),
              VStatusBadge(label: order.status.label, color: _statusColor),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Vendor
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vendor', style: TextStyle(color: VendorTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              Text(order.vendorName,
                  style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              Text(order.branchName, style: const TextStyle(color: VendorTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Items
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Items', style: TextStyle(color: VendorTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 10),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: VendorTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text('${item.quantity}x',
                          style: const TextStyle(color: VendorTheme.textMuted, fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.name,
                          style: const TextStyle(color: VendorTheme.textPrimary, fontSize: 13)),
                    ),
                    Text('₦${item.total.toStringAsFixed(0)}',
                        style: const TextStyle(color: VendorTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              )),
              const Divider(color: VendorTheme.divider),
              _row('Subtotal', '₦${order.subtotal.toStringAsFixed(0)}'),
              const SizedBox(height: 4),
              _row('Delivery fee', '₦${order.deliveryFee.toStringAsFixed(0)}'),
              const SizedBox(height: 4),
              _row('Transaction fee', '₦${order.transactionFee.toStringAsFixed(0)}'),
              const Divider(color: VendorTheme.divider),
              _row('Total', '₦${order.totalAmount.toStringAsFixed(0)}',
                  bold: true, valueColor: VendorTheme.primary),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Delivery address
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Delivery Address', style: TextStyle(color: VendorTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              Text(order.deliveryAddress.full,
                  style: const TextStyle(color: VendorTheme.textPrimary, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Escrow
        _card(
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: VendorTheme.warning, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Escrow',
                        style: TextStyle(color: VendorTheme.textMuted, fontSize: 12)),
                    Text(
                      order.escrowStatus == 'held'
                          ? 'Payment is held in escrow'
                          : order.escrowStatus == 'released'
                          ? 'Payment released to vendor'
                          : order.escrowStatus == 'appealed'
                          ? 'Escrow frozen — appeal in progress'
                          : 'Refunded to you',
                      style: const TextStyle(color: VendorTheme.textPrimary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.pending:        return VendorTheme.warning;
      case OrderStatus.confirmed:      return VendorTheme.primary;
      case OrderStatus.preparing:      return const Color(0xFFF97316);
      case OrderStatus.outForDelivery: return VendorTheme.accent;
      case OrderStatus.delivered:      return VendorTheme.accent;
      case OrderStatus.completed:      return VendorTheme.accent;
      case OrderStatus.cancelled:      return VendorTheme.error;
      case OrderStatus.appealed:       return VendorTheme.warning;
    }
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VendorTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VendorTheme.divider),
      ),
      child: child,
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color valueColor = VendorTheme.textSecondary}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: VendorTheme.textMuted, fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

// ─── Chat Tab ─────────────────────────────────────────────────────────────────

class _ChatTab extends StatefulWidget {
  final OrderModel order;
  const _ChatTab({required this.order});

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.read<OrderChatProvider>();
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessageModel>>(
            stream: chat.messageStream(widget.order.id),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: VendorTheme.primary));
              }
              final msgs = snap.data ?? [];
              if (msgs.isEmpty) {
                return const VEmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'No messages yet',
                  subtitle: 'Start the conversation with the vendor',
                );
              }
              _scrollToBottom();
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: msgs.length,
                itemBuilder: (_, i) => _MessageBubble(
                  msg: msgs[i],
                  isMe: msgs[i].senderId == _myUid,
                ),
              );
            },
          ),
        ),
        Consumer<OrderChatProvider>(
          builder: (context, chat, _) => Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
            decoration: const BoxDecoration(
              color: VendorTheme.surface,
              border: Border(top: BorderSide(color: VendorTheme.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: const TextStyle(color: VendorTheme.textPrimary, fontSize: 14),
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: VendorTheme.textMuted),
                      filled: true,
                      fillColor: VendorTheme.surfaceVariant,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: chat.sending
                      ? null
                      : () async {
                    final text = _msgCtrl.text.trim();
                    if (text.isEmpty) return;
                    if (chat.containsPhone(text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Phone numbers are not allowed'),
                          backgroundColor: VendorTheme.error,
                        ),
                      );
                      return;
                    }
                    _msgCtrl.clear();
                    await chat.sendMessage(widget.order.id, text, 'Customer');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: chat.sending ? VendorTheme.textMuted : VendorTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: chat.sending
                        ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel msg;
  final bool isMe;

  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (msg.isAdmin) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: VendorTheme.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: VendorTheme.warning.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.support_agent, color: VendorTheme.warning, size: 14),
                const SizedBox(width: 6),
                Text('Support: ${msg.message}',
                    style: const TextStyle(color: VendorTheme.warning, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: VendorTheme.surfaceVariant, shape: BoxShape.circle),
              child: const Icon(Icons.storefront, color: VendorTheme.textMuted, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(msg.senderName,
                      style: const TextStyle(color: VendorTheme.textMuted, fontSize: 11)),
                ),
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? VendorTheme.primary : VendorTheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  border: isMe ? null : Border.all(color: VendorTheme.divider),
                ),
                child: Text(msg.message,
                    style: TextStyle(
                        color: isMe ? Colors.white : VendorTheme.textPrimary,
                        fontSize: 13)),
              ),
              const SizedBox(height: 3),
              Text(
                msg.createdAt != null
                    ? '${msg.createdAt!.hour.toString().padLeft(2, '0')}:${msg.createdAt!.minute.toString().padLeft(2, '0')}'
                    : '',
                style: const TextStyle(color: VendorTheme.textMuted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}