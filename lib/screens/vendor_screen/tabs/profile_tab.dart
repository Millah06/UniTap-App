import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../constraints/vendor_theme.dart';
import '../../../providers/vendor-center-provider.dart';
import '../widgets/shared_widgets.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: VendorTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            const Text('Profile',
                style: TextStyle(color: VendorTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Avatar + name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: VendorTheme.surfaceVariant,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, color: VendorTheme.textMuted, size: 36)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? user?.email ?? 'User',
                    style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (user?.email != null)
                    Text(user!.email!,
                        style: const TextStyle(color: VendorTheme.textMuted, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Vendor section
            Consumer<VendorCenterProvider>(
              builder: (context, p, _) {
                if (p.myVendor == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Vendor Account',
                        style: TextStyle(color: VendorTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: VendorTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: VendorTheme.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_outlined, color: VendorTheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.myVendor!.name,
                                    style: const TextStyle(color: VendorTheme.textPrimary, fontWeight: FontWeight.w600)),
                                Text(p.myVendor!.status,
                                    style: const TextStyle(color: VendorTheme.textMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                          VStatusBadge(
                            label: p.myVendor!.isVisible ? 'Online' : 'Offline',
                            color: p.myVendor!.isVisible ? VendorTheme.accent : VendorTheme.textMuted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
            // Settings section
            const Text('Settings',
                style: TextStyle(color: VendorTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _tile(Icons.notifications_outlined, 'Notifications', () {}),
            _tile(Icons.help_outline, 'Help & Support', () {}),
            _tile(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
            const SizedBox(height: 8),
            _tile(
              Icons.logout,
              'Sign Out',
                  () => _signOut(context),
              color: VendorTheme.error,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap, {Color color = VendorTheme.textPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: VendorTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: VendorTheme.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: color, fontSize: 14)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: VendorTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }
}