// lib/screens/profile_screen.dart - NEW

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: Text(
            'Not logged in',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Navigate to UserProfileScreen with current user's ID
    return UserProfileScreen(userId: currentUserId, isOwnProfile: true);
  }
}