// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../constraints/vendor_theme.dart';
// import '../../models/vendor_model.dart';
// import '../../providers/vendor_center_provider.dart';
//
//
// // ─── VENDOR APPLY PAGE ────────────────────────────────────────────────────────
//
// class VendorApplyPage extends StatefulWidget {
//   const VendorApplyPage({super.key});
//
//   @override
//   State<VendorApplyPage> createState() => _VendorApplyPageState();
// }
//
// class _VendorApplyPageState extends State<VendorApplyPage> {
//   final _nameCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _cacCtrl = TextEditingController();
//   VendorType _selectedType = VendorType.restaurant;
//
//   // Branch info
//   String? _branchState;
//   String? _branchLga;
//   String? _branchArea;
//   String? _branchStreet;
//
//   final _lgasByState = <String, List<String>>{
//     'Lagos': ['Ikeja', 'Lagos Island', 'Eti-Osa', 'Alimosho'],
//     'Abuja': ['AMAC', 'Bwari'],
//   };
//
//   final _areasByLga = <String, List<String>>{
//     'Ikeja': ['GRA', 'Allen', 'Oregun'],
//     'Lagos Island': ['Victoria Island', 'Ikoyi'],
//     'Eti-Osa': ['Lekki', 'Ajah'],
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: VendorTheme.background,
//       appBar: AppBar(
//         title: const Text('Apply as Vendor'),
//         backgroundColor: VendorTheme.background,
//       ),
//       body: Consumer<VendorCenterProvider>(
//         builder: (context, provider, _) => SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const _SectionLabel('Business Info'),
//               const SizedBox(height: 12),
//               _Input(controller: _nameCtrl, label: 'Vendor Name'),
//               const SizedBox(height: 8),
//               _DropdownInput<VendorType>(
//                 label: 'Vendor Type',
//                 value: _selectedType,
//                 items: VendorType.values
//                     .map((t) => DropdownMenuItem(
//                     value: t, child: Text(t.label)))
//                     .toList(),
//                 onChanged: (v) => setState(() => _selectedType = v!),
//               ),
//               const SizedBox(height: 8),
//               _Input(
//                   controller: _descCtrl,
//                   label: 'Description',
//                   maxLines: 3),
//               const SizedBox(height: 8),
//               _Input(
//                   controller: _phoneCtrl,
//                   label: 'Phone',
//                   keyboardType: TextInputType.phone),
//               const SizedBox(height: 8),
//               _Input(
//                   controller: _emailCtrl,
//                   label: 'Email',
//                   keyboardType: TextInputType.emailAddress),
//               const SizedBox(height: 8),
//               _Input(controller: _cacCtrl, label: 'CAC Number (Optional)'),
//               const SizedBox(height: 20),
//
//               const _SectionLabel('First Branch Location'),
//               const SizedBox(height: 12),
//               _LocationDropdownInput(
//                 label: 'State',
//                 value: _branchState,
//                 items: _lgasByState.keys.toList(),
//                 onChanged: (v) =>
//                     setState(() => _branchState = v),
//               ),
//               const SizedBox(height: 8),
//               _LocationDropdownInput(
//                 label: 'LGA',
//                 value: _branchLga,
//                 enabled: _branchState != null,
//                 items: _branchState != null
//                     ? _lgasByState[_branchState] ?? []
//                     : [],
//                 onChanged: (v) => setState(() => _branchLga = v),
//               ),
//               const SizedBox(height: 8),
//               _LocationDropdownInput(
//                 label: 'Area',
//                 value: _branchArea,
//                 enabled: _branchLga != null,
//                 items: _branchLga != null
//                     ? _areasByLga[_branchLga] ?? []
//                     : [],
//                 onChanged: (v) => setState(() => _branchArea = v),
//               ),
//               const SizedBox(height: 8),
//               _Input(controller: TextEditingController(), label: 'Street Address'),
//               const SizedBox(height: 28),
//
//               if (provider.error != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: Text(provider.error!,
//                       style: const TextStyle(color: VendorTheme.error)),
//                 ),
//
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: VendorTheme.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: provider.loading ? null : () => _submit(context, provider),
//                   child: provider.loading
//                       ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                           color: Colors.white, strokeWidth: 2))
//                       : const Text('Submit Application',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16)),
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _submit(
//       BuildContext context, VendorCenterProvider provider) async {
//     final application = {
//       'name': _nameCtrl.text,
//       'vendorType': _selectedType.value,
//       'description': _descCtrl.text,
//       'phone': _phoneCtrl.text,
//       'email': _emailCtrl.text,
//       'cac': _cacCtrl.text,
//       'branch': {
//         'state': _branchState,
//         'lga': _branchLga,
//         'area': _branchArea,
//         'street': _branchStreet ?? '',
//       },
//     };
//
//     final success = await provider.applyAsVendor(application);
//     if (success && mounted) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Application submitted! Awaiting approval.'),
//             backgroundColor: VendorTheme.accent),
//       );
//     }
//   }
// }
//
// class _SectionLabel extends StatelessWidget {
//   final String label;
//   const _SectionLabel(this.label);
//
//   @override
//   Widget build(BuildContext context) => Text(label,
//       style: const TextStyle(
//           color: VendorTheme.textPrimary,
//           fontWeight: FontWeight.bold,
//           fontSize: 15));
// }
//
// class _Input extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final int maxLines;
//   final TextInputType? keyboardType;
//
//   const _Input({
//     required this.controller,
//     required this.label,
//     this.maxLines = 1,
//     this.keyboardType,
//   });
//
//   @override
//   Widget build(BuildContext context) => TextField(
//     controller: controller,
//     maxLines: maxLines,
//     keyboardType: keyboardType,
//     style: const TextStyle(color: VendorTheme.textPrimary),
//     decoration: InputDecoration(
//       labelText: label,
//       labelStyle: const TextStyle(color: VendorTheme.textMuted),
//       filled: true,
//       fillColor: VendorTheme.surface,
//       border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none),
//     ),
//   );
// }
//
// class _DropdownInput<T> extends StatelessWidget {
//   final String label;
//   final T value;
//   final List<DropdownMenuItem<T>> items;
//   final ValueChanged<T?> onChanged;
//
//   const _DropdownInput({
//     required this.label,
//     required this.value,
//     required this.items,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//       decoration: BoxDecoration(
//         color: VendorTheme.surface,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<T>(
//           value: value,
//           isExpanded: true,
//           dropdownColor: VendorTheme.surface,
//           style:
//           const TextStyle(color: VendorTheme.textPrimary, fontSize: 14),
//           items: items,
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
// }
//
// class _LocationDropdownInput extends StatelessWidget {
//   final String label;
//   final String? value;
//   final List<String> items;
//   final ValueChanged<String?> onChanged;
//   final bool enabled;
//
//   const _LocationDropdownInput({
//     required this.label,
//     required this.value,
//     required this.items,
//     required this.onChanged,
//     this.enabled = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//       decoration: BoxDecoration(
//         color: VendorTheme.surface,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           hint: Text(label,
//               style: const TextStyle(color: VendorTheme.textMuted, fontSize: 14)),
//           value: value,
//           isExpanded: true,
//           dropdownColor: VendorTheme.surface,
//           style:
//           const TextStyle(color: VendorTheme.textPrimary, fontSize: 14),
//           items: enabled
//               ? items
//               .map((i) => DropdownMenuItem(value: i, child: Text(i)))
//               .toList()
//               : null,
//           onChanged: enabled ? onChanged : null,
//         ),
//       ),
//     );
//   }
// }