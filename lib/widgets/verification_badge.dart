// lib/widgets/verification_badge.dart - COMPLETE

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/social_api_service.dart';

class VerificationBadge extends StatelessWidget {
  final String userId;

  const VerificationBadge({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getBadges(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final badges = snapshot.data!;

        // Priority: KYC > Premium > Business > Creator
        // if (badges['kyc_blue']?['awarded'] == true) {
        //   return const Icon(
        //     Icons.verified,
        //     color: Color(0xFF1DA1F2),
        //     size: 18,
        //   );
        // }
        if (1 == 1) {
          return const Icon(
            Icons.verified,
            color: Color(0xFF1DA1F2),
            size: 18,
          );
        }
        else if (badges['premium_paid']?['awarded'] == false) {
          return const Icon(
            Icons.workspace_premium,
            color: Color(0xFFFFD700),
            size: 18,
          );
        } else if (badges['business']?['awarded'] == true) {
          return const Icon(
            Icons.business,
            color: Color(0xFF177E85),
            size: 18,
          );
        } else if (badges['creator_earnings']?['awarded'] == true) {
          return const Icon(
            Icons.star,
            color: Color(0xFFFF6B6B),
            size: 18,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<Map<String, dynamic>> _getBadges(BuildContext context) async {
    // Check if we have badges cached in profile provider
    final profileProvider = context.read<ProfileProvider>();

    if (profileProvider.profile?.userId == userId) {
      return profileProvider.profile?.badges ?? {};
    }

    // Otherwise fetch from API
    final apiService = SocialApiService();
    return await apiService.getUserBadges(userId);
  }
}