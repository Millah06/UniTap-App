import 'dart:io';
import 'dart:typed_data';
import 'package:everywhere/components/swicht.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import '../../../constraints/vendor_theme.dart';
import '../../../models/order_model.dart';
import '../../../models/vendor_model.dart';
import '../../../providers/vendor-center-provider.dart';
import '../widgets/navigation.dart';
import '../widgets/shared_widgets.dart';

class VendorCenterTab extends StatelessWidget {
  const VendorCenterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorCenterProvider>(
      builder: (context, p, _) {
        if (p.loading) {
          return const Scaffold(
            backgroundColor: VendorTheme.background,
            body: Center(child: CircularProgressIndicator(color: VendorTheme.primary)),
          );
        }
        if (p.myVendor == null) return const _PreApplyView();
        if (p.isPending) return _PendingView();
        return const _DashboardView();
      },
    );
  }
}

//  Pre Apply

class _PreApplyView extends StatelessWidget {
  const _PreApplyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('Become a Vendor',
                style: TextStyle(
                    color: VendorTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            SizedBox(height: 8),
            Text(
              'Start selling your products to thousands of customers in your area.',
              textAlign: TextAlign.center,
              style: TextStyle(color: VendorTheme.textSecondary),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VendorTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  vendorPush(context, _ApplyView());},
                child: const Text('Apply to Become Vendor',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),

          ],),
        ),
      ),
    );
  }
}


// ─── Apply View ───────────────────────────────────────────────────────────────

class _ApplyView extends StatefulWidget {
  const _ApplyView();



  @override
  State<_ApplyView> createState() => _ApplyViewState();
}

class _ApplyViewState extends State<_ApplyView> {

  final _name        = TextEditingController();
  final _description = TextEditingController();
  final _phone       = TextEditingController();
  final _email       = TextEditingController();
  final _cac         = TextEditingController();
  final _state       = TextEditingController();
  final _lga         = TextEditingController();
  final _area        = TextEditingController();
  final _street      = TextEditingController();
  String _vendorType = 'restaurant';
  int _deliveryTime  = 30;

  @override
  void dispose() {
    for (final c in [_name, _description, _phone, _email, _cac, _state, _lga, _area, _street]) c.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    final p = Provider.of<VendorCenterProvider>(context);

    print(p);

    return Scaffold(
      backgroundColor: VendorTheme.background,
      appBar: AppBar(
        backgroundColor: VendorTheme.background,
        elevation: 0,
        title: const Text('Become a Vendor',
            style: TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Business Information',
              style: TextStyle(color: VendorTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          VTextField(controller: _name, label: 'Business Name'),
          const SizedBox(height: 10),
          VTextField(controller: _description, label: 'Description', maxLines: 2),
          const SizedBox(height: 10),
          VDropdown<String>(
            label: 'Vendor Type',
            value: _vendorType,
            items: ['restaurant', 'grocery', 'drinks', 'retail']
                .map((t) => DropdownMenuItem(
              value: t,
              child: Text(t[0].toUpperCase() + t.substring(1)),
            ))
                .toList(),
            onChanged: (v) { if (v != null) setState(() => _vendorType = v); },
          ),
          const SizedBox(height: 10),
          VTextField(controller: _phone, label: 'Phone Number', keyboardType: TextInputType.phone),
          const SizedBox(height: 10),
          VTextField(controller: _email, label: 'Business Email', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 10),
          VTextField(controller: _cac, label: 'CAC Number'),
          const SizedBox(height: 20),
          const Text('First Branch Location',
              style: TextStyle(color: VendorTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          VTextField(controller: _state, label: 'State'),
          const SizedBox(height: 10),
          VTextField(controller: _lga, label: 'LGA'),
          const SizedBox(height: 10),
          VTextField(controller: _area, label: 'Area'),
          const SizedBox(height: 10),
          VTextField(controller: _street, label: 'Street'),
          const SizedBox(height: 10),
          VDropdown<int>(
            label: 'Estimated Delivery Time',
            value: _deliveryTime,
            items: [15, 20, 30, 45, 60, 90]
                .map((t) => DropdownMenuItem(value: t, child: Text('$t minutes')))
                .toList(),
            onChanged: (v) { if (v != null) setState(() => _deliveryTime = v); },
          ),
          if (p.error != null) ...[
            const SizedBox(height: 12),
            Text(p.error!, style: const TextStyle(color: VendorTheme.error, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          VButton(
            label: 'Submit Application',
            loading: p.loading,
            onTap: () => _submit(p),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _submit(VendorCenterProvider p) async {
    if (_name.text.isEmpty || _description.text.isEmpty) return;
    await p.applyAsVendor({
      'name': _name.text.trim(),
      'vendorType': _vendorType,
      'description': _description.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim(),
      'cac': _cac.text.trim(),
      'branch': {
        'state': _state.text.trim(),
        'lga': _lga.text.trim(),
        'area': _area.text.trim(),
        'street': _street.text.trim(),
        'estimatedDeliveryTime': _deliveryTime,
      },
    });
  }
}

// ─── Pending View ─────────────────────────────────────────────────────────────

class _PendingView extends StatelessWidget {
  const _PendingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: VendorTheme.background,
      body: VEmptyState(
        icon: Icons.hourglass_top_rounded,
        title: 'Application Under Review',
        subtitle: 'Your vendor application is being reviewed. We will notify you once approved.',
      ),
    );
  }
}

// ─── Dashboard View ───────────────────────────────────────────────────────────

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorCenterProvider>(
      builder: (context, p, _) {
        return Scaffold(
          backgroundColor: VendorTheme.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, p),
                TabBar(
                  controller: _tabs,
                  indicatorColor: VendorTheme.primary,
                  labelColor: VendorTheme.primary,
                  unselectedLabelColor: VendorTheme.textMuted,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  tabs: const [Tab(text: 'Overview'), Tab(text: 'Orders'), Tab(text: 'Menu')],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _OverviewTab(p: p),
                      _VendorOrdersTab(p: p),
                      _MenuTab(p: p),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, VendorCenterProvider vendorCenter) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _pickLogo(context, vendorCenter),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: vendorCenter.myVendor!.logo.isNotEmpty
                          ? Image.network(vendorCenter.myVendor!.logo, width: 48, height: 48, fit: BoxFit.cover)
                          : _selectedImage != null ? SizedBox(
                        width: 48, height: 48,
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),

                      ) : Container(
                        width: 48, height: 48,
                        color: VendorTheme.surfaceVariant,
                        child: const Icon(Icons.storefront, color: VendorTheme.textMuted),
                      ),
                    ),
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: VendorTheme.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendorCenter.myVendor!.name,
                        style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(vendorCenter.myVendor!.vendorType.label,
                        style: const TextStyle(color: VendorTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => vendorCenter.toggleVisibility(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: vendorCenter.myVendor!.isVisible ? VendorTheme.accent.withOpacity(0.15) : VendorTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: vendorCenter.myVendor!.isVisible ? VendorTheme.accent : VendorTheme.divider),
                  ),
                  child: Text(
                    vendorCenter.myVendor!.isVisible ? 'Online' : 'Offline',
                    style: TextStyle(
                        color: vendorCenter.myVendor!.isVisible ? VendorTheme.accent : VendorTheme.textMuted,
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: VendorTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: VendorTheme.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Mode'),
                TinySwitch(value: vendorCenter.myVendor!.isVisible, onChanged: (value) {
                  print(vendorCenter.myVendor!.isVisible);
                  vendorCenter.toggleVisibility();
                  value = !value;

                })
                 ]
            ),
          ),
        ],
      ),
    );
  }

  void _pickLogo(BuildContext context, VendorCenterProvider p) async {
    print('pickedlogo is called');
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      print('picked is null');
      return;
    };
    setState(() {
      _selectedImage = File(picked.path);
    });
    await p.uploadLogo(_selectedImage!, 'vendorLogo',);
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final VendorCenterProvider p;
  const _OverviewTab({required this.p});

  @override
  Widget build(BuildContext context) {
    final m = p.metrics;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (m != null) ...[
          _MetricsGrid(metrics: m),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: VendorTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: VendorTheme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Escrow Breakdown',
                  style: TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              _erow('Held in Escrow', m != null ? '₦${m.pendingEscrow.toStringAsFixed(0)}' : '—', VendorTheme.warning),
              const SizedBox(height: 6),
              _erow('Released Earnings', m != null ? '₦${m.releasedEarnings.toStringAsFixed(0)}' : '—', VendorTheme.accent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _erow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: VendorTheme.textMuted, fontSize: 13)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final VendorMetrics metrics;
  const _MetricsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total Revenue', '₦${metrics.totalRevenue.toStringAsFixed(0)}', Icons.payments_outlined, VendorTheme.primary),
      ('Rating', metrics.rating.toStringAsFixed(1), Icons.star_rounded, const Color(0xFFFFD700)),
      ('Completion', '${metrics.completionRate.toStringAsFixed(0)}%', Icons.check_circle_outline, VendorTheme.accent),
      ('Orders Done', '${metrics.totalCompletedOrders}', Icons.shopping_bag_outlined, VendorTheme.textSecondary),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: items.map((item) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: VendorTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: VendorTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.$3, color: item.$4, size: 20),
            const SizedBox(height: 6),
            Text(item.$2,
                style: TextStyle(color: item.$4, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(item.$1, style: const TextStyle(color: VendorTheme.textMuted, fontSize: 11)),
          ],
        ),
      )).toList(),
    );
  }
}

// ─── Vendor Orders Tab ────────────────────────────────────────────────────────

class _VendorOrdersTab extends StatefulWidget {
  final VendorCenterProvider p;
  const _VendorOrdersTab({required this.p});

  @override
  State<_VendorOrdersTab> createState() => _VendorOrdersTabState();
}

class _VendorOrdersTabState extends State<_VendorOrdersTab> {
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await widget.p.api.get('/order/vendor/list') as List;
      setState(() {
        _orders = data.map((o) => OrderModel.fromJson(o)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return VendorTheme.warning;
      case OrderStatus.confirmed: return VendorTheme.primary;
      default: return VendorTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: VendorTheme.primary));
    if (_orders.isEmpty) return const VEmptyState(icon: Icons.receipt_long_outlined, title: 'No incoming orders yet');

    final pending = _orders.where((o) => ['pending', 'confirmed', 'preparing', 'outForDelivery'].contains(o.status.name)).toList();
    final done    = _orders.where((o) => ['completed', 'cancelled', 'appealed'].contains(o.status.name)).toList();

    return RefreshIndicator(
      color: VendorTheme.primary,
      backgroundColor: VendorTheme.surface,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pending.isNotEmpty) ...[
            const Text('Incoming / Active', style: TextStyle(color: VendorTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...pending.map((o) => _VendorOrderCard(order: o, onStatusChanged: _load)),
            const SizedBox(height: 16),
          ],
          if (done.isNotEmpty) ...[
            const Text('Past Orders', style: TextStyle(color: VendorTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...done.map((o) => _VendorOrderCard(order: o, onStatusChanged: _load)),
          ],
        ],
      ),
    );
  }
}

class _VendorOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onStatusChanged;

  const _VendorOrderCard({required this.order, required this.onStatusChanged});

  static const _nextStatus = {
    'pending':        'confirmed',
    'confirmed':      'preparing',
    'preparing':      'outForDelivery',
    'outForDelivery': 'delivered',
  };

  static const _nextLabel = {
    'pending':        'Accept Order',
    'confirmed':      'Start Preparing',
    'preparing':      'Mark Out for Delivery',
    'outForDelivery': 'Mark Delivered',
  };

  @override
  Widget build(BuildContext context) {
    final p = context.read<VendorCenterProvider>();
    final next = _nextStatus[order.status.name];
    final label = _nextLabel[order.status.name];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              Text('#${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              VStatusBadge(label: order.status.label, color: _color(order.status)),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.deliveryAddress.full,
              style: const TextStyle(color: VendorTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Text(order.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: VendorTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('₦${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(color: VendorTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              if (next != null && label != null)
                VSmallButton(
                  label: label,
                  color: VendorTheme.primary,
                  textColor: Colors.white,
                  onTap: () async {
                    await p.api.put('/order/${order.id}/status', {'status': next});
                    onStatusChanged();
                  },
                ),
              if (order.status.name == 'pending') ...[
                const SizedBox(width: 8),
                VSmallButton(
                  label: 'Cancel',
                  color: VendorTheme.error.withOpacity(0.15),
                  textColor: VendorTheme.error,
                  onTap: () async {
                    await p.api.put('/order/${order.id}/status', {'status': 'cancelled'});
                    onStatusChanged();
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _color(OrderStatus s) {
    switch (s) {
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
}

// ─── Menu Tab ─────────────────────────────────────────────────────────────────

class _MenuTab extends StatelessWidget {
  final VendorCenterProvider p;
  const _MenuTab({required this.p});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VendorTheme.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: VendorTheme.primary,
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: p.menuItems.isEmpty
          ? const VEmptyState(
        icon: Icons.restaurant_menu,
        title: 'No menu items yet',
        subtitle: 'Tap + to add your first item',
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: p.menuItems.length,
        itemBuilder: (_, i) => _MenuManageCard(item: p.menuItems[i], p: p),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameCtrl  = TextEditingController();
    final descCtrl  = TextEditingController();
    final priceCtrl = TextEditingController();
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
              const Text('Add Menu Item',
                  style: TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 14),
              VTextField(controller: nameCtrl, label: 'Item Name'),
              const SizedBox(height: 10),
              VTextField(controller: descCtrl, label: 'Description', maxLines: 2),
              const SizedBox(height: 10),
              VTextField(controller: priceCtrl, label: 'Price (₦)', keyboardType: TextInputType.number),
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
                      label: 'Add',
                      onTap: () async {
                        final branchId = p.myVendor!.branches.first.id;
                        Navigator.pop(context);
                        await p.addMenuItem(branchId, {
                          'name': nameCtrl.text.trim(),
                          'description': descCtrl.text.trim(),
                          'price': double.tryParse(priceCtrl.text.trim()) ?? 0,
                        });
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

class _MenuManageCard extends StatelessWidget {
  final MenuItemModel item;
  final VendorCenterProvider p;

  const _MenuManageCard({required this.item, required this.p});

  // Share card key for RepaintBoundary capture
  final GlobalKey _shareKey = const GlobalObjectKey('share');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VendorTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VendorTheme.divider),
      ),
      child: Row(
        children: [
          // Image + upload tap
          GestureDetector(
            onTap: () => _uploadImage(context),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(item.imageUrl, width: 64, height: 64, fit: BoxFit.cover)
                      : Container(
                    width: 64, height: 64,
                    color: VendorTheme.surfaceVariant,
                    child: const Icon(Icons.add_photo_alternate_outlined, color: VendorTheme.textMuted),
                  ),
                ),
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: VendorTheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('₦${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(color: VendorTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          // Action buttons
          Column(
            children: [
              // Toggle availability
              GestureDetector(
                onTap: () => p.updateMenuItem(item.id, {'isAvailable': !item.isAvailable}),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isAvailable ? VendorTheme.accent.withOpacity(0.15) : VendorTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.isAvailable ? 'On' : 'Off',
                    style: TextStyle(
                        color: item.isAvailable ? VendorTheme.accent : VendorTheme.error,
                        fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Share
              GestureDetector(
                onTap: () => _shareCard(context),
                child: const Icon(Icons.share_outlined, color: VendorTheme.textMuted, size: 18),
              ),
              const SizedBox(height: 6),
              // Delete
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: const Icon(Icons.delete_outline, color: VendorTheme.error, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _uploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    await p.uploadMenuItemImage(item.id, File(picked.path), picked.name);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: VendorTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Delete Item?',
                  style: TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Remove "${item.name}" from your menu?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: VendorTheme.textSecondary, fontSize: 13)),
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
                      label: 'Delete',
                      color: VendorTheme.error,
                      onTap: () async {
                        Navigator.pop(context);
                        await p.deleteMenuItem(item.id);
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

  void _shareCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: VendorTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The share card itself — captured by RepaintBoundary
              RepaintBoundary(
                key: _shareKey,
                child: _ShareCard(item: item, vendorName: p.myVendor?.name ?? ''),
              ),
              const SizedBox(height: 20),
              VButton(
                label: 'Share',
                icon: Icons.share,
                onTap: () async {
                  Navigator.pop(context);
                  await _captureAndShare(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureAndShare(BuildContext context) async {
    try {
      final boundary = _shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final uint8 = bytes.buffer.asUint8List();
      await Share.shareXFiles(
        [XFile.fromData(uint8, mimeType: 'image/png', name: '${item.name}.png')],
        text: '${item.name} — ₦${item.price.toStringAsFixed(0)}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share: $e'), backgroundColor: VendorTheme.error),
        );
      }
    }
  }
}

// ─── Share Card Visual ────────────────────────────────────────────────────────

class _ShareCard extends StatelessWidget {
  final MenuItemModel item;
  final String vendorName;

  const _ShareCard({required this.item, required this.vendorName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VendorTheme.primary.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                item.imageUrl,
                width: 280, height: 160, fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 280, height: 160,
              decoration: const BoxDecoration(
                color: Color(0xFF334155),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Icon(Icons.fastfood, color: VendorTheme.textMuted, size: 56),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(item.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₦${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(color: VendorTheme.primary, fontWeight: FontWeight.bold, fontSize: 22)),
                    Text(vendorName,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}