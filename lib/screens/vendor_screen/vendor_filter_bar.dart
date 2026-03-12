// import 'package:flutter/material.dart';
//
// import '../../constraints/vendor_theme.dart';
// import '../../models/vendor_model.dart';
//
// // ─── VENDOR CARD ──────────────────────────────────────────────────────────────
//
// class VendorCard extends StatelessWidget {
//   final VendorModel vendor;
//   final VoidCallback onTap;
//
//   const VendorCard({super.key, required this.vendor, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     final branch = vendor.branches.isNotEmpty ? vendor.branches.first : null;
//     final deliveryTime = branch?.estimatedDeliveryTime;
//     final startingFee = branch?.deliveryZones.isNotEmpty == true
//         ? branch!.deliveryZones
//         .map((z) => z.deliveryFee)
//         .reduce((a, b) => a < b ? a : b)
//         : null;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: VendorTheme.surface,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: VendorTheme.divider),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Top row: logo, name, badge
//               Row(
//                 children: [
//                   _Logo(url: vendor.logo),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 vendor.name,
//                                 style: const TextStyle(
//                                   color: VendorTheme.textPrimary,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 15,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             if (vendor.verified) ...[
//                               const SizedBox(width: 4),
//                               const _VerifiedBadge(),
//                             ],
//                           ],
//                         ),
//                         const SizedBox(height: 2),
//                         Row(
//                           children: [
//                             _TypeChip(vendorType: vendor.vendorType),
//                             if (vendor.branches.length > 1) ...[
//                               const SizedBox(width: 6),
//                               _BranchCount(count: vendor.branches.length),
//                             ],
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 10),
//
//               // Description
//               Text(
//                 vendor.description,
//                 style: const TextStyle(
//                   color: VendorTheme.textSecondary,
//                   fontSize: 12,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//
//               const SizedBox(height: 12),
//
//               // Stats row
//               Row(
//                 children: [
//                   _Stat(
//                     icon: Icons.star_rounded,
//                     iconColor: VendorTheme.gold,
//                     value: vendor.rating.toStringAsFixed(1),
//                   ),
//                   const SizedBox(width: 16),
//                   _Stat(
//                     icon: Icons.check_circle_outline,
//                     iconColor: VendorTheme.accent,
//                     value: '${vendor.completionRate.toStringAsFixed(0)}%',
//                     label: 'completion',
//                   ),
//                   const SizedBox(width: 16),
//                   _Stat(
//                     icon: Icons.shopping_bag_outlined,
//                     iconColor: VendorTheme.textMuted,
//                     value: _formatOrders(vendor.totalCompletedOrders),
//                     label: 'orders',
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 12),
//
//               // Delivery info row
//               Row(
//                 children: [
//                   if (deliveryTime != null) ...[
//                     const Icon(Icons.schedule,
//                         size: 13, color: VendorTheme.textMuted),
//                     const SizedBox(width: 4),
//                     Text(
//                       '$deliveryTime min',
//                       style: const TextStyle(
//                           color: VendorTheme.textSecondary, fontSize: 12),
//                     ),
//                     const SizedBox(width: 16),
//                   ],
//                   if (startingFee != null) ...[
//                     const Icon(Icons.delivery_dining,
//                         size: 13, color: VendorTheme.textMuted),
//                     const SizedBox(width: 4),
//                     Text(
//                       'From ₦${startingFee.toStringAsFixed(0)}',
//                       style: const TextStyle(
//                           color: VendorTheme.textSecondary, fontSize: 12),
//                     ),
//                   ],
//                   const Spacer(),
//                   const Icon(Icons.chevron_right,
//                       color: VendorTheme.textMuted, size: 18),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatOrders(int count) {
//     if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
//     return count.toString();
//   }
// }
//
// class _Logo extends StatelessWidget {
//   final String url;
//   const _Logo({required this.url});
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: Image.network(
//         url,
//         width: 56,
//         height: 56,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => Container(
//           width: 56,
//           height: 56,
//           color: VendorTheme.surfaceVariant,
//           child: const Icon(Icons.storefront,
//               color: VendorTheme.textMuted, size: 28),
//         ),
//       ),
//     );
//   }
// }
//
// class _VerifiedBadge extends StatelessWidget {
//   const _VerifiedBadge();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: VendorTheme.accent.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: const Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.verified, size: 10, color: VendorTheme.accent),
//           SizedBox(width: 2),
//           Text('Verified',
//               style: TextStyle(color: VendorTheme.accent, fontSize: 10)),
//         ],
//       ),
//     );
//   }
// }
//
// class _TypeChip extends StatelessWidget {
//   final VendorType vendorType;
//   const _TypeChip({required this.vendorType});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: VendorTheme.primary.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         vendorType.label,
//         style:
//         const TextStyle(color: VendorTheme.primary, fontSize: 10),
//       ),
//     );
//   }
// }
//
// class _BranchCount extends StatelessWidget {
//   final int count;
//   const _BranchCount({required this.count});
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       '$count branches',
//       style: const TextStyle(color: VendorTheme.textMuted, fontSize: 10),
//     );
//   }
// }
//
// class _Stat extends StatelessWidget {
//   final IconData icon;
//   final Color iconColor;
//   final String value;
//   final String? label;
//
//   const _Stat({
//     required this.icon,
//     required this.iconColor,
//     required this.value,
//     this.label,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 13, color: iconColor),
//         const SizedBox(width: 3),
//         Text(
//           label != null ? '$value $label' : value,
//           style: const TextStyle(
//             color: VendorTheme.textSecondary,
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }