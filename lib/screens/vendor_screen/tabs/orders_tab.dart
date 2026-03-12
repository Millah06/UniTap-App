import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constraints/vendor_theme.dart';
import '../../../models/order_model.dart';
import '../../../providers/order_provider.dart';
import '../order_detail_page.dart';
import '../pages/order_detail_page.dart';
import '../widgets/shared_widgets.dart';


class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderListProvider>().fetchOrders();
    });
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Text('My Orders',
                      style: TextStyle(color: VendorTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.read<OrderListProvider>().fetchOrders(),
                    child: const Icon(Icons.refresh, color: VendorTheme.textMuted),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabs,
              indicatorColor: VendorTheme.primary,
              indicatorWeight: 2,
              labelColor: VendorTheme.primary,
              unselectedLabelColor: VendorTheme.textMuted,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Ongoing'),
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
                Tab(text: 'Appealed'),
              ],
            ),
            Expanded(
              child: Consumer<OrderListProvider>(
                builder: (context, p, _) {
                  if (p.loading) return const Center(child: CircularProgressIndicator(color: VendorTheme.primary));
                  if (p.error != null) return VErrorState(message: p.error!, onRetry: p.fetchOrders);
                  return TabBarView(
                    controller: _tabs,
                    children: [
                      _OrderList(orders: p.ongoing, emptyTitle: 'No ongoing orders'),
                      _OrderList(orders: p.completed, emptyTitle: 'No completed orders'),
                      _OrderList(orders: p.cancelled, emptyTitle: 'No cancelled orders'),
                      _OrderList(orders: p.appealed, emptyTitle: 'No appealed orders'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final String emptyTitle;
  const _OrderList({required this.orders, required this.emptyTitle});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return VEmptyState(icon: Icons.receipt_long_outlined, title: emptyTitle);
    }
    return RefreshIndicator(
      color: VendorTheme.primary,
      backgroundColor: VendorTheme.surface,
      onRefresh: () => context.read<OrderListProvider>().fetchOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: orders.length,
        itemBuilder: (_, i) => _OrderCard(order: orders[i]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

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

  @override
  Widget build(BuildContext context) {
    final p = context.read<OrderListProvider>();
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailPage(order: order,))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: VendorTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: VendorTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(order.vendorName,
                      style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                VStatusBadge(label: order.status.label, color: _statusColor),
              ],
            ),
            const SizedBox(height: 4),
            Text(order.branchName, style: const TextStyle(color: VendorTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              order.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: VendorTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('₦${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(color: VendorTheme.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                Text('${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                    style: const TextStyle(color: VendorTheme.textMuted, fontSize: 11)),
              ],
            ),
            if (order.status.canConfirm || order.status.canAppeal) ...[
              const SizedBox(height: 10),
              const Divider(color: VendorTheme.divider, height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (order.status.canConfirm)
                    Expanded(
                      child: VButton(
                        label: 'Confirm Delivery',
                        color: VendorTheme.accent,
                        onTap: () async {
                          final ok = await p.confirmDelivery(order.id);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(p.error ?? 'Failed'), backgroundColor: VendorTheme.error),
                            );
                          }
                        },
                      ),
                    ),
                  if (order.status.canConfirm && order.status.canAppeal) const SizedBox(width: 8),
                  if (order.status.canAppeal)
                    Expanded(
                      child: VButton(
                        label: 'Appeal',
                        color: VendorTheme.error,
                        onTap: () => _showAppealDialog(context, p),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAppealDialog(BuildContext context, OrderListProvider p) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: VendorTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Open Appeal',
                  style: TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              const Text('Describe the issue. Escrow will be frozen until admin resolves.',
                  style: TextStyle(color: VendorTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 14),
              VTextField(controller: ctrl, label: 'Reason', maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: VButton(
                      label: 'Cancel',
                      color: VendorTheme.surfaceVariant,
                      textColor: VendorTheme.textSecondary,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: VButton(
                      label: 'Submit',
                      color: VendorTheme.error,
                      onTap: () async {
                        Navigator.pop(context);
                        final ok = await p.appealOrder(order.id, ctrl.text.trim());
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(p.error ?? 'Failed'), backgroundColor: VendorTheme.error),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}