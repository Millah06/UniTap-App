// import 'package:everywhere/screens/vendor_screen/vendoer_filter_bar.dart';
// import 'package:everywhere/screens/vendor_screen/vendor_card.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../constraints/vendor_theme.dart';
// import '../../models/vendor_model.dart';
// import '../../providers/vendor_provider.dart';
//
// import 'vendor_detail_page.dart';
//
// // ─── TAB 1: VENDORS ───────────────────────────────────────────────────────────
//
// class VendorsTab extends StatelessWidget {
//   const VendorsTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: VendorTheme.background,
//       appBar: AppBar(
//         title: const Text('Vendors'),
//         backgroundColor: VendorTheme.background,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search, color: VendorTheme.textPrimary),
//             onPressed: () => _showSearch(context),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           const VendorFilterBar(),
//           const Expanded(child: _VendorList()),
//         ],
//       ),
//     );
//   }
//
//   void _showSearch(BuildContext context) {
//     showSearch(
//       context: context,
//       delegate: _VendorSearchDelegate(context.read<VendorListProvider>()),
//     );
//   }
// }
//
// class _VendorList extends StatelessWidget {
//   const _VendorList();
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<VendorListProvider>(
//       builder: (context, provider, _) {
//         if (provider.loading) {
//           return const Center(
//             child: CircularProgressIndicator(color: VendorTheme.primary),
//           );
//         }
//
//         if (provider.error != null) {
//           return _ErrorView(
//             message: provider.error!,
//             onRetry: provider.fetchVendors,
//           );
//         }
//
//         if (provider.vendors.isEmpty) {
//           return const _EmptyView();
//         }
//
//         return RefreshIndicator(
//           color: VendorTheme.primary,
//           backgroundColor: VendorTheme.surface,
//           onRefresh: provider.fetchVendors,
//           child: ListView.separated(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//             itemCount: provider.vendors.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (context, i) {
//               final vendor = provider.vendors[i];
//               return VendorCard(
//                 vendor: vendor,
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => VendorDetailPage(vendorId: vendor.id),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _ErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;
//   const _ErrorView({required this.message, required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.error_outline, color: VendorTheme.error, size: 48),
//           const SizedBox(height: 12),
//           Text(message,
//               style: const TextStyle(color: VendorTheme.textSecondary)),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: onRetry,
//             style: ElevatedButton.styleFrom(backgroundColor: VendorTheme.primary),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _EmptyView extends StatelessWidget {
//   const _EmptyView();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.storefront_outlined,
//               color: VendorTheme.textMuted, size: 64),
//           SizedBox(height: 12),
//           Text('No vendors found',
//               style: TextStyle(
//                   color: VendorTheme.textSecondary, fontSize: 16)),
//           SizedBox(height: 4),
//           Text('Try adjusting your filters',
//               style: TextStyle(color: VendorTheme.textMuted, fontSize: 13)),
//         ],
//       ),
//     );
//   }
// }
//
// class _VendorSearchDelegate extends SearchDelegate<VendorModel?> {
//   final VendorListProvider provider;
//   _VendorSearchDelegate(this.provider);
//
//   @override
//   ThemeData appBarTheme(BuildContext context) => ThemeData(
//     scaffoldBackgroundColor: VendorTheme.background,
//     appBarTheme: const AppBarTheme(backgroundColor: VendorTheme.surface),
//     inputDecorationTheme: const InputDecorationTheme(
//       hintStyle: TextStyle(color: VendorTheme.textMuted),
//       border: InputBorder.none,
//     ),
//     textTheme: const TextTheme(
//       titleLarge: TextStyle(color: VendorTheme.textPrimary),
//     ),
//   );
//
//   @override
//   List<Widget> buildActions(BuildContext context) => [
//     IconButton(
//       icon: const Icon(Icons.clear, color: VendorTheme.textSecondary),
//       onPressed: () => query = '',
//     ),
//   ];
//
//   @override
//   Widget buildLeading(BuildContext context) => IconButton(
//     icon: const Icon(Icons.arrow_back, color: VendorTheme.textPrimary),
//     onPressed: () => close(context, null),
//   );
//
//   @override
//   Widget buildResults(BuildContext context) {
//     provider.setSearch(query);
//     return _buildList(context);
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) => _buildList(context);
//
//   Widget _buildList(BuildContext context) {
//     final results = provider.vendors
//         .where((v) => v.name.toLowerCase().contains(query.toLowerCase()))
//         .toList();
//
//     return Container(
//       color: VendorTheme.background,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: results.length,
//         itemBuilder: (context, i) => VendorCard(
//           vendor: results[i],
//           onTap: () => close(context, results[i]),
//         ),
//       ),
//     );
//   }
// }