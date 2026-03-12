// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../constraints/vendor_theme.dart';
// import '../../models/vendor_model.dart';
// import '../../providers/vendor_provider.dart';
//
// import 'checkout_page.dart';
//
// // ─── VENDOR DETAIL PAGE ───────────────────────────────────────────────────────
//
// class VendorDetailPage extends StatefulWidget {
//   final String vendorId;
//   const VendorDetailPage({super.key, required this.vendorId});
//
//   @override
//   State<VendorDetailPage> createState() => _VendorDetailPageState();
// }
//
// class _VendorDetailPageState extends State<VendorDetailPage> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<VendorDetailProvider>().loadVendor(widget.vendorId);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<VendorDetailProvider>(
//       builder: (context, provider, _) {
//         if (provider.loading) {
//           return const Scaffold(
//             backgroundColor: VendorTheme.background,
//             body: Center(
//               child: CircularProgressIndicator(color: VendorTheme.primary),
//             ),
//           );
//         }
//
//         final vendor = provider.vendor;
//         if (vendor == null) {
//           return const Scaffold(
//             backgroundColor: VendorTheme.background,
//             body: Center(
//               child: Text('Vendor not found',
//                   style: TextStyle(color: VendorTheme.textSecondary)),
//             ),
//           );
//         }
//
//         return Scaffold(
//           backgroundColor: VendorTheme.background,
//           body: CustomScrollView(
//             slivers: [
//               _VendorAppBar(vendor: vendor),
//               SliverToBoxAdapter(
//                 child: _VendorStats(vendor: vendor),
//               ),
//               if (vendor.branches.length > 1)
//                 SliverToBoxAdapter(
//                   child: _BranchSelector(
//                     branches: vendor.branches,
//                     selectedBranchId: provider.selectedBranchId,
//                     onSelect: provider.selectBranch,
//                   ),
//                 ),
//               SliverToBoxAdapter(
//                 child: _MenuSection(
//                   items: provider.menuItems,
//                   vendorId: vendor.id,
//                   branchId: provider.selectedBranchId ?? '',
//                 ),
//               ),
//             ],
//           ),
//           bottomNavigationBar: Consumer<CartProvider>(
//             builder: (context, cart, _) {
//               if (cart.isEmpty || cart.vendorId != vendor.id) {
//                 return const SizedBox.shrink();
//               }
//               return _CartBar(cart: cart, vendor: vendor);
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _VendorAppBar extends StatelessWidget {
//   final VendorModel vendor;
//   const _VendorAppBar({required this.vendor});
//
//   @override
//   Widget build(BuildContext context) {
//     return SliverAppBar(
//       expandedHeight: 200,
//       backgroundColor: VendorTheme.background,
//       pinned: true,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Stack(
//           fit: StackFit.expand,
//           children: [
//             Image.network(
//               vendor.logo,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(
//                 color: VendorTheme.surface,
//                 child: const Icon(Icons.storefront,
//                     color: VendorTheme.textMuted, size: 64),
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     VendorTheme.background.withOpacity(0.9),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         title: Text(vendor.name,
//             style: const TextStyle(
//                 color: VendorTheme.textPrimary, fontWeight: FontWeight.bold)),
//       ),
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: VendorTheme.textPrimary),
//         onPressed: () => Navigator.pop(context),
//       ),
//     );
//   }
// }
//
// class _VendorStats extends StatelessWidget {
//   final VendorModel vendor;
//   const _VendorStats({required this.vendor});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: VendorTheme.surface,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _StatItem(
//               icon: Icons.star_rounded,
//               iconColor: VendorTheme.gold,
//               value: vendor.rating.toStringAsFixed(1),
//               label: 'Rating',
//             ),
//           ),
//           _Divider(),
//           Expanded(
//             child: _StatItem(
//               icon: Icons.check_circle_outline,
//               iconColor: VendorTheme.accent,
//               value: '${vendor.completionRate.toStringAsFixed(0)}%',
//               label: 'Completion',
//             ),
//           ),
//           _Divider(),
//           Expanded(
//             child: _StatItem(
//               icon: Icons.shopping_bag_outlined,
//               iconColor: VendorTheme.primary,
//               value: '${vendor.totalCompletedOrders}',
//               label: 'Orders',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatItem extends StatelessWidget {
//   final IconData icon;
//   final Color iconColor;
//   final String value;
//   final String label;
//
//   const _StatItem({
//     required this.icon,
//     required this.iconColor,
//     required this.value,
//     required this.label,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Icon(icon, color: iconColor, size: 20),
//         const SizedBox(height: 4),
//         Text(value,
//             style: const TextStyle(
//                 color: VendorTheme.textPrimary,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15)),
//         Text(label,
//             style: const TextStyle(color: VendorTheme.textMuted, fontSize: 11)),
//       ],
//     );
//   }
// }
//
// class _Divider extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         width: 1, height: 40, color: VendorTheme.divider);
//   }
// }
//
// class _BranchSelector extends StatelessWidget {
//   final List<BranchModel> branches;
//   final String? selectedBranchId;
//   final ValueChanged<String> onSelect;
//
//   const _BranchSelector({
//     required this.branches,
//     required this.selectedBranchId,
//     required this.onSelect,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
//           child: Text('Select Branch',
//               style: TextStyle(
//                   color: VendorTheme.textPrimary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15)),
//         ),
//         SizedBox(
//           height: 48,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: branches.length,
//             itemBuilder: (context, i) {
//               final branch = branches[i];
//               final selected = branch.id == selectedBranchId;
//               return GestureDetector(
//                 onTap: () => onSelect(branch.id),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   margin: const EdgeInsets.only(right: 8),
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                   decoration: BoxDecoration(
//                     color:
//                     selected ? VendorTheme.primary : VendorTheme.surface,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                         color: selected
//                             ? VendorTheme.primary
//                             : VendorTheme.divider),
//                   ),
//                   child: Text(
//                     '${branch.area}, ${branch.lga}',
//                     style: TextStyle(
//                       color: selected
//                           ? Colors.white
//                           : VendorTheme.textSecondary,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         const SizedBox(height: 8),
//       ],
//     );
//   }
// }
//
// class _MenuSection extends StatelessWidget {
//   final List<MenuItemModel> items;
//   final String vendorId;
//   final String branchId;
//
//   const _MenuSection({
//     required this.items,
//     required this.vendorId,
//     required this.branchId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
//           child: Text('Menu',
//               style: TextStyle(
//                   color: VendorTheme.textPrimary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15)),
//         ),
//         ...items.where((i) => i.isAvailable).map(
//               (item) => _MenuItemTile(
//             item: item,
//             vendorId: vendorId,
//             branchId: branchId,
//           ),
//         ),
//         const SizedBox(height: 100),
//       ],
//     );
//   }
// }
//
// class _MenuItemTile extends StatelessWidget {
//   final MenuItemModel item;
//   final String vendorId;
//   final String branchId;
//
//   const _MenuItemTile({
//     required this.item,
//     required this.vendorId,
//     required this.branchId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CartProvider>(
//       builder: (context, cart, _) {
//         final qty = cart.quantityOf(item.id);
//
//         return Container(
//           margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: VendorTheme.surface,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   item.imageUrl,
//                   width: 72,
//                   height: 72,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     width: 72,
//                     height: 72,
//                     color: VendorTheme.surfaceVariant,
//                     child: const Icon(Icons.fastfood,
//                         color: VendorTheme.textMuted),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(item.name,
//                         style: const TextStyle(
//                             color: VendorTheme.textPrimary,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14)),
//                     const SizedBox(height: 2),
//                     Text(item.description,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                             color: VendorTheme.textSecondary, fontSize: 12)),
//                     const SizedBox(height: 6),
//                     Text('₦${item.price.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                             color: VendorTheme.primary,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14)),
//                   ],
//                 ),
//               ),
//               if (qty == 0)
//                 IconButton(
//                   icon: const Icon(Icons.add_circle_outline,
//                       color: VendorTheme.primary),
//                   onPressed: () =>
//                       cart.add(item, vendorId, branchId),
//                 )
//               else
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.remove_circle_outline,
//                           color: VendorTheme.textSecondary),
//                       onPressed: () => cart.decrement(item.id),
//                     ),
//                     Text('$qty',
//                         style: const TextStyle(
//                             color: VendorTheme.textPrimary,
//                             fontWeight: FontWeight.bold)),
//                     IconButton(
//                       icon: const Icon(Icons.add_circle_outline,
//                           color: VendorTheme.primary),
//                       onPressed: () =>
//                           cart.add(item, vendorId, branchId),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _CartBar extends StatelessWidget {
//   final CartProvider cart;
//   final VendorModel vendor;
//
//   const _CartBar({required this.cart, required this.vendor});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//       decoration: const BoxDecoration(
//         color: VendorTheme.surface,
//         border: Border(top: BorderSide(color: VendorTheme.divider)),
//       ),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: VendorTheme.primary,
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const CheckoutPage()),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text('${cart.totalItems}',
//                   style: const TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.bold)),
//             ),
//             const Text('View Cart',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15)),
//             Text('₦${cart.subtotal.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.w600)),
//           ],
//         ),
//       ),
//     );
//   }
// }