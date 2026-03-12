// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Check if current user liked a post
  Future<bool> hasLikedPost(String postId) async {
    if (currentUserId == null) return false;

    final doc = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(currentUserId)
        .get();

    return doc.exists;
  }

  // Stream posts (alternative to API)
  Stream<List<Post>> streamPosts({int limit = 20}) {
    return _firestore
        .collection('posts')
        .orderBy('isBoosted', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <Post>[];

      for (var doc in snapshot.docs) {
        final isLiked = await hasLikedPost(doc.id);
        posts.add(Post.fromFirestore(doc, isLiked: isLiked));
      }

      return posts;
    });
  }

  // Stream comments for a post
  Stream<List<Comment>> streamComments(String postId, {int limit = 20}) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
    });
  }

  // Get single post
  Future<Post?> getPost(String postId) async {
    final doc = await _firestore.collection('posts').doc(postId).get();

    if (!doc.exists) return null;

    final isLiked = await hasLikedPost(postId);
    return Post.fromFirestore(doc, isLiked: isLiked);
  }

  // Listen to post updates (for real-time like/comment counts)
  Stream<Post> streamPost(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) throw Exception('Post not found');

      final isLiked = await hasLikedPost(postId);
      return Post.fromFirestore(doc, isLiked: isLiked);
    });
  }
}