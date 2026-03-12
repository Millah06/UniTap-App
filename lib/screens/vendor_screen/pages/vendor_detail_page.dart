import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constraints/vendor_theme.dart';
import '../../../models/vendor_model.dart';
import '../../../providers/vendor_provider.dart';
import '../widgets/navigation.dart';
import '../widgets/shared_widgets.dart';
import 'checkout_page.dart';

class VendorDetailPage extends StatefulWidget {
  final String vendorId;
  const VendorDetailPage({super.key, required this.vendorId});

  @override
  State<VendorDetailPage> createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends State<VendorDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorDetailProvider>().loadVendor(widget.vendorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VendorDetailProvider, CartProvider>(
      builder: (context, detail, cart, _) {
        if (detail.loading) {
          return const Scaffold(
            backgroundColor: VendorTheme.background,
            body: Center(child: CircularProgressIndicator(color: VendorTheme.primary)),
          );
        }
        if (detail.error != null || detail.vendor == null) {
          return Scaffold(
            backgroundColor: VendorTheme.background,
            appBar: AppBar(backgroundColor: VendorTheme.background, elevation: 0),
            body: VErrorState(
              message: detail.error ?? 'Vendor not found',
              onRetry: () => detail.loadVendor(widget.vendorId),
            ),
          );
        }
        final vendor = detail.vendor!;
        return Scaffold(
          backgroundColor: VendorTheme.background,
          body: CustomScrollView(
            slivers: [
              _sliverAppBar(vendor),
              SliverToBoxAdapter(child: _vendorInfo(vendor)),
              SliverToBoxAdapter(child: _branchSelector(vendor, detail)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Row(
                    children: [
                      const Text('Menu',
                          style: TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      Text('${detail.menuItems.length} items',
                          style: const TextStyle(color: VendorTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              detail.menuItems.isEmpty
                  ? const SliverFillRemaining(
                  child: VEmptyState(icon: Icons.restaurant_menu, title: 'No menu items yet'))
                  : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => _MenuItemTile(
                      item: detail.menuItems[i],
                      vendor: vendor,
                      branchId: detail.selectedBranchId!,
                    ),
                    childCount: detail.menuItems.length,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: cart.isEmpty || cart.vendorId != widget.vendorId
              ? null
              : _cartBar(cart),
        );
      },
    );
  }

  Widget _cartBar(CartProvider cart) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: VendorTheme.surface,
        border: Border(top: BorderSide(color: VendorTheme.divider)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: VendorTheme.surfaceVariant, borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${cart.totalItems} item${cart.totalItems == 1 ? '' : 's'}',
                    style: const TextStyle(color: VendorTheme.textMuted, fontSize: 11)),
                Text('₦${cart.subtotal.toStringAsFixed(0)}',
                    style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: VButton(
              label: 'Proceed to Checkout',
              onTap: () => vendorPush(context, CheckoutPage())),
            ),
        ],
      ),
    );
  }

  SliverAppBar _sliverAppBar(VendorModel vendor) {
    return SliverAppBar(
      backgroundColor: VendorTheme.background,
      expandedHeight: 200,
      pinned: true,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: vendor.logo.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: vendor.logo,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: VendorTheme.surface),
          errorWidget: (_, __, ___) => Container(color: VendorTheme.surface),
        )
            : Container(
          color: VendorTheme.surface,
          child: const Icon(Icons.storefront, color: VendorTheme.textMuted, size: 60),
        ),
      ),
    );
  }

  Widget _vendorInfo(VendorModel vendor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(vendor.name,
                    style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              if (vendor.verified) const Icon(Icons.verified, color: VendorTheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text(vendor.description, style: const TextStyle(color: VendorTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _badge(Icons.star_rounded, const Color(0xFFFFD700), vendor.rating.toStringAsFixed(1)),
              _badge(Icons.check_circle_outline, VendorTheme.accent, '${vendor.completionRate.toStringAsFixed(0)}% completion'),
              _badge(Icons.shopping_bag_outlined, VendorTheme.textMuted, '${vendor.totalCompletedOrders} orders'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: VendorTheme.surface, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: VendorTheme.textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _branchSelector(VendorModel vendor, VendorDetailProvider detail) {
    if (vendor.branches.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Select Branch',
              style: TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vendor.branches.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final branch = vendor.branches[i];
              final sel = detail.selectedBranchId == branch.id;
              return GestureDetector(
                onTap: () => detail.selectBranch(branch.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 160,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: sel ? VendorTheme.primary.withOpacity(0.15) : VendorTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? VendorTheme.primary : VendorTheme.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${branch.area}, ${branch.lga}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: sel ? VendorTheme.primary : VendorTheme.textPrimary,
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text('~${branch.estimatedDeliveryTime} min',
                          style: const TextStyle(color: VendorTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItemModel item;
  final VendorModel vendor;
  final String branchId;

  const _MenuItemTile({required this.item, required this.vendor, required this.branchId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final qty = cart.quantityOf(item.id);
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 72, height: 72, fit: BoxFit.cover,
                  placeholder: (_, __) => _placeholder(),
                  errorWidget: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 3),
                    Text(item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: VendorTheme.textMuted, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('₦${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(color: VendorTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                        if (!item.isAvailable) ...[
                          const SizedBox(width: 8),
                          const Text('Unavailable', style: TextStyle(color: VendorTheme.error, fontSize: 11)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (item.isAvailable)
                qty == 0
                    ? GestureDetector(
                  onTap: () => cart.add(item, vendor.id, branchId),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: VendorTheme.primary, borderRadius: BorderRadius.circular(9)),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                )
                    : Row(
                  children: [
                    _qtyBtn(Icons.remove, VendorTheme.surfaceVariant, () => cart.decrement(item.id)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('$qty',
                          style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    _qtyBtn(Icons.add, VendorTheme.primary, () => cart.add(item, vendor.id, branchId)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _qtyBtn(IconData icon, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 72, height: 72,
    color: VendorTheme.surfaceVariant,
    child: const Icon(Icons.fastfood_outlined, color: VendorTheme.textMuted),
  );
}