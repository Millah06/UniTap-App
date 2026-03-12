// lib/screens/settings_screen.dart - NEW

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../privacy_policy.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          const _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.person,
            title: 'Edit Profile',
            onTap: () {
              // Navigate to edit profile
            },
          ),
          _SettingsTile(
            icon: Icons.verified_user,
            title: 'KYC Verification',
            subtitle: 'Verify your identity',
            onTap: () {
              // Navigate to KYC
            },
          ),

          const SizedBox(height: 24),

          // Privacy Section
          const _SectionHeader(title: 'Privacy & Security'),
          _SettingsTile(
            icon: Icons.lock,
            title: 'Privacy Settings',
            subtitle: 'Control who can see your content',
            onTap: () {
              _showPrivacySettings(context);
            },
          ),
          _SettingsTile(
            icon: Icons.block,
            title: 'Blocked Accounts',
            onTap: () {
              // Navigate to blocked accounts
            },
          ),

          const SizedBox(height: 24),

          // Preferences Section
          const _SectionHeader(title: 'Preferences'),
          _SettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              // Navigate to notification settings
            },
          ),
          _SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              // Show language picker
            },
          ),

          const SizedBox(height: 24),

          // Support Section
          const _SectionHeader(title: 'Support'),
          _SettingsTile(
            icon: Icons.help,
            title: 'Help Center',
            onTap: () {
              // Open help center
            },
          ),
          _SettingsTile(
            icon: Icons.email,
            title: 'Contact Us',
            subtitle: 'support@everywhere.app',
            onTap: () {
              // Open email
            },
          ),
          _SettingsTile(
            icon: Icons.feedback,
            title: 'Feed Back',
            onTap: () {
              // Open email
            },
          ),

          _SettingsTile(
            icon: Icons.share,
            title: 'Share App',
            onTap: () {
              Share.share(
                'Join me on Everywhere! https://everywhere.app',
              );
            },
          ),
          _SettingsTile(
            icon: Icons.rate_review,
            title: 'Rate Us',
            onTap: () {
              // Open email
            },
          ),
          _SettingsTile(
            icon: Icons.group,
            title: 'Join our Community',
            onTap: () {
              // Open email
            },
          ),

          const SizedBox(height: 24),

          // About Section
          const _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info,
            title: 'App Version',
            subtitle: _appVersion,
            onTap: null,
          ),
          _SettingsTile(
            icon: Icons.article,
            title: 'Terms of Service',
            onTap: () {
              // Open terms
            },
          ),
          _SettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              // Open privacy policy
              Navigator.push(context, MaterialPageRoute(builder: (context)=>
                  PrivacyPolicyPage()));
            },
          ),

          const SizedBox(height: 32),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _PrivacySettingsSheet(),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF177E85),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF177E85)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle!,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        )
            : null,
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _PrivacySettingsSheet extends StatefulWidget {
  const _PrivacySettingsSheet();

  @override
  State<_PrivacySettingsSheet> createState() => _PrivacySettingsSheetState();
}

class _PrivacySettingsSheetState extends State<_PrivacySettingsSheet> {
  bool _isPrivate = false;
  bool _allowFollowersToMessage = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            SwitchListTile(
              value: _isPrivate,
              onChanged: (value) {
                setState(() => _isPrivate = value);
                // TODO: Update in backend
              },
              title: const Text(
                'Private Account',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Only approved followers can see your posts',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              activeColor: const Color(0xFF177E85),
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              value: _allowFollowersToMessage,
              onChanged: (value) {
                setState(() => _allowFollowersToMessage = value);
                // TODO: Update in backend
              },
              title: const Text(
                'Allow Followers to Message',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Let your followers send you messages',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              activeColor: const Color(0xFF177E85),
            ),
          ],
        ),
      ),
    );
  }
}