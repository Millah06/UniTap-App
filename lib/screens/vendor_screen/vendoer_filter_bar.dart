// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../constraints/vendor_theme.dart';
// import '../../models/vendor_model.dart';
// import '../../providers/vendor_provider.dart';
//
//
// // ─── VENDOR FILTER BAR ────────────────────────────────────────────────────────
//
// class VendorFilterBar extends StatelessWidget {
//   const VendorFilterBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<VendorListProvider>(
//       builder: (context, provider, _) {
//         return Column(
//           children: [
//             // Vendor type chips
//             SizedBox(
//               height: 44,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 children: [
//                   _TypeChip(
//                     label: 'All',
//                     selected: provider.selectedVendorType == null,
//                     onTap: provider.clearTypeFilter,
//                   ),
//                   ...VendorType.values.map((type) => _TypeChip(
//                     label: type.label,
//                     selected: provider.selectedVendorType == type.value,
//                     onTap: () =>
//                         provider.setVendorType(type.value),
//                   )),
//                 ],
//               ),
//             ),
//
//             // Sort & location filters
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _SortDropdown(
//                       value: provider.sortBy,
//                       onChanged: (v) => provider.setSortBy(v),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   _FilterButton(
//                     label: provider.selectedState ?? 'State',
//                     onTap: () => _showStateFilter(context, provider),
//                   ),
//                   const SizedBox(width: 8),
//                   _FilterButton(
//                     label: provider.selectedLga ?? 'LGA',
//                     enabled: provider.selectedState != null,
//                     onTap: () => _showLgaFilter(context, provider),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showStateFilter(BuildContext context, VendorListProvider provider) {
//     // TODO: Fetch states from location hierarchy API
//     final states = ['Lagos', 'Abuja', 'Rivers', 'Kano'];
//     _showPicker(context, 'Select State', states,
//             (val) => provider. setState(val));
//   }
//
//   void _showLgaFilter(BuildContext context, VendorListProvider provider) {
//     // TODO: Fetch LGAs based on selected state
//     final lgas = ['Ikeja', 'Lagos Island', 'Lekki'];
//     _showPicker(
//         context, 'Select LGA', lgas, (val) => provider.setLga(val));
//   }
//
//   void _showPicker(BuildContext context, String title, List<String> options,
//       ValueChanged<String> onSelect) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: VendorTheme.surface,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Text(title,
//                 style: const TextStyle(
//                     color: VendorTheme.textPrimary,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16)),
//           ),
//           ...options.map((opt) => ListTile(
//             title: Text(opt,
//                 style: const TextStyle(color: VendorTheme.textPrimary)),
//             onTap: () {
//               onSelect(opt);
//               Navigator.pop(context);
//             },
//           )),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
// }
//
// class _TypeChip extends StatelessWidget {
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;
//
//   const _TypeChip(
//       {required this.label, required this.selected, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//         decoration: BoxDecoration(
//           color: selected ? VendorTheme.primary : VendorTheme.surface,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: selected ? VendorTheme.primary : VendorTheme.surfaceVariant,
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: selected ? Colors.white : VendorTheme.textSecondary,
//             fontSize: 13,
//             fontWeight:
//             selected ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _SortDropdown extends StatelessWidget {
//   final String value;
//   final ValueChanged<String> onChanged;
//
//   const _SortDropdown({required this.value, required this.onChanged});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: VendorTheme.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: VendorTheme.divider),
//       ),
//       child: DropdownButton<String>(
//         value: value,
//         isDense: true,
//         underline: const SizedBox(),
//         dropdownColor: VendorTheme.surface,
//         style: const TextStyle(color: VendorTheme.textPrimary, fontSize: 12),
//         icon:
//         const Icon(Icons.expand_more, color: VendorTheme.textMuted, size: 16),
//         items: const [
//           DropdownMenuItem(value: 'rating', child: Text('By Rating')),
//           DropdownMenuItem(
//               value: 'completionRate', child: Text('By Completion')),
//           DropdownMenuItem(
//               value: 'totalCompletedOrders', child: Text('By Orders')),
//         ],
//         onChanged: (v) {
//           if (v != null) onChanged(v);
//         },
//       ),
//     );
//   }
// }
//
// class _FilterButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   final bool enabled;
//
//   const _FilterButton(
//       {required this.label, required this.onTap, this.enabled = true});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         decoration: BoxDecoration(
//           color: VendorTheme.surface,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: VendorTheme.divider),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: enabled ? VendorTheme.textPrimary : VendorTheme.textMuted,
//                 fontSize: 12,
//               ),
//             ),
//             const SizedBox(width: 4),
//             const Icon(Icons.expand_more,
//                 color: VendorTheme.textMuted, size: 14),
//           ],
//         ),
//       ),
//     );
//   }
// }