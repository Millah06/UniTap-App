// import 'package:everywhere/models/order_model.dart';
// import 'package:everywhere/screens/vendor_screen/share_card_generator.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../constraints/vendor_theme.dart';
// import '../../models/vendor_model.dart';
// import '../../providers/vendor_center_provider.dart';
//
// import 'vendor_apply_page.dart';
//
// // ─── TAB 3: VENDOR CENTER ─────────────────────────────────────────────────────
//
// class VendorCenterTab extends StatelessWidget {
//   const VendorCenterTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<VendorCenterProvider>(
//       builder: (context, provider, _) {
//         if (provider.loading) {
//           return const Scaffold(
//             backgroundColor: VendorTheme.background,
//             body: Center(
//                 child: CircularProgressIndicator(color: VendorTheme.primary)),
//           );
//         }
//
//         if (!provider.isApprovedVendor) {
//           return _NonVendorView(isPending: provider.isPending);
//         }
//
//         return _VendorDashboard(provider: provider);
//       },
//     );
//   }
// }
//
// class _NonVendorView extends StatelessWidget {
//   final bool isPending;
//   const _NonVendorView({required this.isPending});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: VendorTheme.background,
//       appBar: AppBar(
//         title: const Text('Vendor Center'),
//         backgroundColor: VendorTheme.background,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: VendorTheme.primary.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.store_outlined,
//                     size: 48, color: VendorTheme.primary),
//               ),
//               const SizedBox(height: 24),
//               if (isPending) ...[
//                 const Icon(Icons.pending_outlined,
//                     size: 28, color: VendorTheme.warning),
//                 const SizedBox(height: 12),
//                 const Text('Application Under Review',
//                     style: TextStyle(
//                         color: VendorTheme.textPrimary,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18)),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Your vendor application is being reviewed. We\'ll notify you once approved.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: VendorTheme.textSecondary),
//                 ),
//               ] else ...[
//                 const Text('Become a Vendor',
//                     style: TextStyle(
//                         color: VendorTheme.textPrimary,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 22)),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Start selling your products to thousands of customers in your area.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: VendorTheme.textSecondary),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: VendorTheme.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     onPressed: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) => const VendorApplyPage()),
//                     ),
//                     child: const Text('Apply to Become Vendor',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 15)),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _VendorDashboard extends StatefulWidget {
//   final VendorCenterProvider provider;
//   const _VendorDashboard({required this.provider});
//
//   @override
//   State<_VendorDashboard> createState() => _VendorDashboardState();
// }
//
// class _VendorDashboardState extends State<_VendorDashboard> {
//   String? _selectedBranchId;
//
//   @override
//   void initState() {
//     super.initState();
//     final branches = widget.provider.myVendor?.branches;
//     if (branches != null && branches.isNotEmpty) {
//       _selectedBranchId = branches.first.id;
//       widget.provider.loadMenuForBranch(_selectedBranchId!);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = widget.provider;
//     final vendor = provider.myVendor!;
//
//     return Scaffold(
//       backgroundColor: VendorTheme.background,
//       appBar: AppBar(
//         title: const Text('Vendor Center'),
//         backgroundColor: VendorTheme.background,
//         actions: [
//           Switch(
//             value: vendor.isVisible,
//             onChanged: (_) => provider.toggleVisibility(),
//             activeColor: VendorTheme.accent,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Metrics
//             _MetricsGrid(metrics: provider.metrics!),
//             const SizedBox(height: 20),
//
//             // Branch selector
//             if (vendor.branches.length > 1) ...[
//               const Text('Branch',
//                   style: TextStyle(
//                       color: VendorTheme.textPrimary,
//                       fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               DropdownButton<String>(
//                 value: _selectedBranchId,
//                 dropdownColor: VendorTheme.surface,
//                 style:
//                 const TextStyle(color: VendorTheme.textPrimary, fontSize: 14),
//                 underline: const SizedBox(),
//                 items: vendor.branches
//                     .map((b) => DropdownMenuItem(
//                     value: b.id,
//                     child: Text('${b.area}, ${b.lga}')))
//                     .toList(),
//                 onChanged: (v) {
//                   if (v != null) {
//                     setState(() => _selectedBranchId = v);
//                     provider.loadMenuForBranch(v);
//                   }
//                 },
//               ),
//               const SizedBox(height: 12),
//             ],
//
//             // Menu items
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Menu Items',
//                     style: TextStyle(
//                         color: VendorTheme.textPrimary,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15)),
//                 IconButton(
//                   icon: const Icon(Icons.add_circle,
//                       color: VendorTheme.primary),
//                   onPressed: () => _showAddItemDialog(context, provider),
//                 ),
//               ],
//             ),
//
//             ...provider.menuItems.map(
//                   (item) => _MenuManageCard(
//                 item: item,
//                 onEdit: () => _showEditItemDialog(context, provider, item),
//                 onDelete: () => provider.deleteMenuItem(item.id),
//                 onShare: () => _shareItem(context, vendor, item),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showAddItemDialog(BuildContext context, VendorCenterProvider provider) {
//     _showMenuItemDialog(context, provider, null);
//   }
//
//   void _showEditItemDialog(
//       BuildContext context, VendorCenterProvider provider, MenuItemModel item) {
//     _showMenuItemDialog(context, provider, item);
//   }
//
//   void _showMenuItemDialog(BuildContext context, VendorCenterProvider provider,
//       MenuItemModel? existing) {
//     final nameCtrl = TextEditingController(text: existing?.name);
//     final descCtrl = TextEditingController(text: existing?.description);
//     final priceCtrl =
//     TextEditingController(text: existing?.price.toString() ?? '');
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: VendorTheme.surface,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => Padding(
//         padding: EdgeInsets.only(
//             left: 20,
//             right: 20,
//             top: 20,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(existing == null ? 'Add Menu Item' : 'Edit Menu Item',
//                 style: const TextStyle(
//                     color: VendorTheme.textPrimary,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16)),
//             const SizedBox(height: 16),
//             _TextField(controller: nameCtrl, label: 'Item Name'),
//             const SizedBox(height: 8),
//             _TextField(controller: descCtrl, label: 'Description'),
//             const SizedBox(height: 8),
//             _TextField(
//                 controller: priceCtrl,
//                 label: 'Price (₦)',
//                 keyboardType: TextInputType.number),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: VendorTheme.primary),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   final data = {
//                     'name': nameCtrl.text,
//                     'description': descCtrl.text,
//                     'price': double.tryParse(priceCtrl.text) ?? 0,
//                     'isAvailable': true,
//                     'imageUrl': '',
//                   };
//                   if (existing == null) {
//                     provider.addMenuItem(_selectedBranchId!, data);
//                   } else {
//                     provider.updateMenuItem(existing.id, data);
//                   }
//                 },
//                 child: Text(existing == null ? 'Add Item' : 'Save Changes',
//                     style: const TextStyle(color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _shareItem(
//       BuildContext context, VendorModel vendor, MenuItemModel item) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: VendorTheme.background,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => ShareCardGenerator(vendor: vendor, item: item),
//     );
//   }
// }
//
// class _MetricsGrid extends StatelessWidget {
//   final VendorMetrics metrics;
//   const _MetricsGrid({required this.metrics});
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       crossAxisCount: 2,
//       mainAxisSpacing: 12,
//       crossAxisSpacing: 12,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       childAspectRatio: 1.8,
//       children: [
//         _MetricCard(
//           label: 'Completed Orders',
//           value: '${metrics.totalCompletedOrders ?? 0}',
//           icon: Icons.check_circle_outline,
//           color: VendorTheme.accent,
//         ),
//         _MetricCard(
//           label: 'Completion Rate',
//           value: '${metrics.completionRate ?? 0}%',
//           icon: Icons.trending_up,
//           color: VendorTheme.primary,
//         ),
//         _MetricCard(
//           label: 'Total Revenue',
//           value: '₦${metrics.totalRevenue ?? 0}',
//           icon: Icons.payments_outlined,
//           color: VendorTheme.gold,
//         ),
//         _MetricCard(
//           label: 'In Escrow',
//           value: '₦${metrics.pendingEscrow ?? 0}',
//           icon: Icons.lock_outline,
//           color: VendorTheme.warning,
//         ),
//       ],
//     );
//   }
// }
//
// class _MetricCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;
//
//   const _MetricCard({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: VendorTheme.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: VendorTheme.divider),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 20),
//           const Spacer(),
//           Text(value,
//               style: const TextStyle(
//                   color: VendorTheme.textPrimary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16)),
//           Text(label,
//               style: const TextStyle(
//                   color: VendorTheme.textMuted, fontSize: 11)),
//         ],
//       ),
//     );
//   }
// }
//
// class _MenuManageCard extends StatelessWidget {
//   final MenuItemModel item;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final VoidCallback onShare;
//
//   const _MenuManageCard({
//     required this.item,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onShare,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: VendorTheme.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: VendorTheme.divider),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.name,
//                     style: const TextStyle(
//                         color: VendorTheme.textPrimary,
//                         fontWeight: FontWeight.w600)),
//                 Text('₦${item.price.toStringAsFixed(0)}',
//                     style: const TextStyle(
//                         color: VendorTheme.primary, fontSize: 13)),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.share_outlined,
//                 color: VendorTheme.textSecondary, size: 20),
//             onPressed: onShare,
//           ),
//           IconButton(
//             icon: const Icon(Icons.edit_outlined,
//                 color: VendorTheme.textSecondary, size: 20),
//             onPressed: onEdit,
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete_outline,
//                 color: VendorTheme.error, size: 20),
//             onPressed: onDelete,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _TextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final TextInputType? keyboardType;
//
//   const _TextField(
//       {required this.controller, required this.label, this.keyboardType});
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       style: const TextStyle(color: VendorTheme.textPrimary),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: VendorTheme.textMuted),
//         filled: true,
//         fillColor: VendorTheme.surfaceVariant,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }