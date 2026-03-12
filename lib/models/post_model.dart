// lib/models/post_model.dart - COMPLETE VERSION

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String text;
  final String? imageUrl;
  final List<String> hashtags;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final int rewardCount;
  final double rewardPointsTotal;
  final bool isBoosted;
  final DateTime? boostExpiresAt;
  final bool isRepost;
  final String? originalPostId;
  final String? originalUserName;
  final double score;
  bool isLikedByCurrentUser;
  bool isFollowing;
  bool isSaved;
  int repostCount;

  Post({
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    this.imageUrl,
    this.hashtags = const [],
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    this.viewCount = 0,
    required this.rewardCount,
    required this.rewardPointsTotal,
    required this.isBoosted,
    this.boostExpiresAt,
    this.isRepost = false,
    this.originalPostId,
    this.originalUserName,
    this.score = 0,
    this.isLikedByCurrentUser = false,
    this.isFollowing = false,
    this.isSaved = false,
    this.repostCount = 0,
  });

  factory Post.fromFirestore(DocumentSnapshot doc, {bool isLiked = false}) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      postId: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userAvatar: data['userAvatar'],
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      hashtags: List<String>.from(data['hashtags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      viewCount: data['viewCount'] ?? 0,
      rewardCount: data['rewardCount'] ?? 0,
      rewardPointsTotal: (data['rewardPointsTotal'] ?? 0).toDouble(),
      isBoosted: data['isBoosted'] ?? false,
      boostExpiresAt: (data['boostExpiresAt'] as Timestamp?)?.toDate(),
      isRepost: data['isRepost'] ?? false,
      originalPostId: data['originalPostId'],
      originalUserName: data['originalUserName'],
      score: (data['algorithmScore'] ?? 0).toDouble(),
      isLikedByCurrentUser: isLiked,
      isFollowing: false,
      isSaved: false,
      repostCount: 0,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userAvatar: json['userAvatar'],
      text: json['text'] ?? '',
      imageUrl: json['imageUrl'],
      hashtags: List<String>.from(json['hashtags'] ?? []),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      rewardCount: json['rewardCount'] ?? 0,
      rewardPointsTotal: (json['rewardPointsTotal'] ?? 0).toDouble(),
      isBoosted: json['isBoosted'] ?? false,
      boostExpiresAt: _parseDateTime(json['boostExpiresAt']),
      isRepost: json['isRepost'] ?? false,
      originalPostId: json['originalPostId'],
      originalUserName: json['originalUserName'],
      score: (json['algorithmScore'] ?? 0).toDouble(),
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
      isFollowing: json['isFollowing'] ?? false,
      isSaved: json['isSaved'] ?? false,
      repostCount: json['repostCount'] ?? 0,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is Map<String, dynamic>) {
      final seconds = value['_seconds'];
      final nanoseconds = value['_nanoseconds'] ?? 0;
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          (seconds * 1000) + (nanoseconds ~/ 1000000),
        );
      }
    }
    return null;
  }

  Post copyWith({
    int? likeCount,
    int? commentCount,
    int? viewCount,
    int? rewardCount,
    double? rewardPointsTotal,
    bool? isLikedByCurrentUser,
    bool? isBoosted,
    bool? isFollowing,
    bool? isSaved,
    int? repostCount,
  }) {
    return Post(
      postId: postId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      text: text,
      imageUrl: imageUrl,
      hashtags: hashtags,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      rewardCount: rewardCount ?? this.rewardCount,
      rewardPointsTotal: rewardPointsTotal ?? this.rewardPointsTotal,
      isBoosted: isBoosted ?? this.isBoosted,
      boostExpiresAt: boostExpiresAt,
      isRepost: isRepost,
      originalPostId: originalPostId,
      originalUserName: originalUserName,
      score: score,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isFollowing: isFollowing ?? this.isFollowing,
      isSaved: isSaved ?? this.isSaved,
      repostCount: repostCount ?? this.repostCount,
    );
  }

  bool get isBoostActive {
    if (!isBoosted || boostExpiresAt == null) return false;
    return DateTime.now().isBefore(boostExpiresAt!);
  }
}

