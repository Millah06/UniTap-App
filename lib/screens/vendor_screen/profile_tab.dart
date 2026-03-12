// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../constraints/vendor_theme.dart';
// import '../../providers/vendor_center_provider.dart';
//
// // ─── TAB 4: PROFILE ──────────────────────────────────────────────────────────
//
// class ProfileTab extends StatelessWidget {
//   const ProfileTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: VendorTheme.background,
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: VendorTheme.background,
//       ),
//       body: Consumer<VendorCenterProvider>(
//         builder: (context, provider, _) {
//           final vendor = provider.myVendor;
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 if (vendor != null && vendor.status == 'approved') ...[
//                   _VendorProfileHeader(vendor: vendor),
//                   const SizedBox(height: 20),
//                   _StatsRow(
//                     completedOrders: vendor.totalCompletedOrders,
//                     completionRate: vendor.completionRate,
//                     rating: vendor.rating,
//                   ),
//                   const SizedBox(height: 20),
//                   const _SectionTitle('Branches'),
//                   const SizedBox(height: 8),
//                   ...vendor.branches.map(
//                         (branch) => _BranchCard(
//                       branch: branch,
//                       onEdit: () {},
//                       onDelete: () {},
//                       onAddZone: () {},
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _AddBranchButton(
//                     onTap: () {},
//                   ),
//                 ] else ...[
//                   const _GuestProfile(),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _VendorProfileHeader extends StatelessWidget {
//   final vendor;
//   const _VendorProfileHeader({required this.vendor});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: VendorTheme.surface,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(14),
//             child: Image.network(
//               vendor.logo,
//               width: 64,
//               height: 64,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(
//                 width: 64,
//                 height: 64,
//                 color: VendorTheme.surfaceVariant,
//                 child: const Icon(Icons.storefront,
//                     color: VendorTheme.textMuted),
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(vendor.name,
//                         style: const TextStyle(
//                             color: VendorTheme.textPrimary,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16)),
//                     if (vendor.verified) ...[
//                       const SizedBox(width: 6),
//                       const Icon(Icons.verified,
//                           color: VendorTheme.accent, size: 16),
//                     ],
//                   ],
//                 ),
//                 Text(vendor.vendorType.label,
//                     style: const TextStyle(
//                         color: VendorTheme.primary, fontSize: 13)),
//                 Text(vendor.description,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                         color: VendorTheme.textSecondary, fontSize: 12)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatsRow extends StatelessWidget {
//   final int completedOrders;
//   final double completionRate;
//   final double rating;
//
//   const _StatsRow({
//     required this.completedOrders,
//     required this.completionRate,
//     required this.rating,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: _StatBox(
//             label: 'Rating',
//             value: rating.toStringAsFixed(1),
//             icon: Icons.star_rounded,
//             iconColor: VendorTheme.gold,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: _StatBox(
//             label: 'Completion',
//             value: '${completionRate.toStringAsFixed(0)}%',
//             icon: Icons.check_circle_outline,
//             iconColor: VendorTheme.accent,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: _StatBox(
//             label: 'Orders',
//             value: '$completedOrders',
//             icon: Icons.shopping_bag_outlined,
//             iconColor: VendorTheme.primary,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _StatBox extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color iconColor;
//
//   const _StatBox({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.iconColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: VendorTheme.surface,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: iconColor, size: 20),
//           const SizedBox(height: 4),
//           Text(value,
//               style: const TextStyle(
//                   color: VendorTheme.textPrimary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16)),
//           Text(label,
//               style: const TextStyle(
//                   color: VendorTheme.textMuted, fontSize: 10)),
//         ],
//       ),
//     );
//   }
// }
//
// class _SectionTitle extends StatelessWidget {
//   final String text;
//   const _SectionTitle(this.text);
//
//   @override
//   Widget build(BuildContext context) => Align(
//     alignment: Alignment.centerLeft,
//     child: Text(text,
//         style: const TextStyle(
//             color: VendorTheme.textPrimary,
//             fontWeight: FontWeight.bold,
//             fontSize: 15)),
//   );
// }
//
// class _BranchCard extends StatelessWidget {
//   final branch;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final VoidCallback onAddZone;
//
//   const _BranchCard({
//     required this.branch,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onAddZone,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: VendorTheme.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: VendorTheme.divider),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.location_on_outlined,
//                   color: VendorTheme.primary, size: 16),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(branch.fullAddress,
//                     style: const TextStyle(
//                         color: VendorTheme.textPrimary,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 13)),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.edit_outlined,
//                     color: VendorTheme.textSecondary, size: 18),
//                 onPressed: onEdit,
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//               const SizedBox(width: 8),
//               IconButton(
//                 icon: const Icon(Icons.delete_outline,
//                     color: VendorTheme.error, size: 18),
//                 onPressed: onDelete,
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text('${branch.estimatedDeliveryTime} min delivery',
//               style: const TextStyle(
//                   color: VendorTheme.textMuted, fontSize: 12)),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               Text('${branch.deliveryZones.length} delivery zone(s)',
//                   style: const TextStyle(
//                       color: VendorTheme.textSecondary, fontSize: 12)),
//               const Spacer(),
//               GestureDetector(
//                 onTap: onAddZone,
//                 child: const Text('+ Add Zone',
//                     style: TextStyle(
//                         color: VendorTheme.primary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _AddBranchButton extends StatelessWidget {
//   final VoidCallback onTap;
//   const _AddBranchButton({required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           color: VendorTheme.primary.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//               color: VendorTheme.primary.withOpacity(0.3),
//               style: BorderStyle.solid),
//         ),
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.add, color: VendorTheme.primary, size: 18),
//             SizedBox(width: 6),
//             Text('Add Branch',
//                 style: TextStyle(
//                     color: VendorTheme.primary, fontWeight: FontWeight.w600)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _GuestProfile extends StatelessWidget {
//   const _GuestProfile();
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const SizedBox(height: 40),
//         Container(
//           width: 80,
//           height: 80,
//           decoration: BoxDecoration(
//             color: VendorTheme.surface,
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(Icons.person_outline,
//               color: VendorTheme.textMuted, size: 40),
//         ),
//         const SizedBox(height: 16),
//         const Text('Not signed in',
//             style: TextStyle(
//                 color: VendorTheme.textPrimary,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18)),
//         const SizedBox(height: 4),
//         const Text('Sign in to access your vendor profile',
//             style: TextStyle(color: VendorTheme.textSecondary)),
//       ],
//     );
//   }
// }