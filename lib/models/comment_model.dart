// lib/models/comment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String commentId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.commentId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Comment(
      commentId: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userAvatar: data['userAvatar'],
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}