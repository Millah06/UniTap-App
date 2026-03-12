// lib/widgets/comment_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/firestore_service.dart';
import '../providers/feed_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentSheet extends StatefulWidget {
  final Post post;

  const CommentSheet({Key? key, required this.post}) : super(key: key);

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();

    if (text.isEmpty) return;

    if (text.length > 300) {
      _showError('Comment too long (max 300 characters)');
      return;
    }

    setState(() => _isPosting = true);

    try {
      await context.read<FeedProvider>().addComment(widget.post.postId, text);
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      _showError('Failed to post comment');
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${widget.post.commentCount})',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Comments list
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: _firestoreService.streamComments(widget.post.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading comments'),
                  );
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to comment!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _CommentItem(comment: comment);
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue[700],
                  child: IconButton(
                    icon: _isPosting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _isPosting ? null : _postComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Comment comment;

  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Text(
              comment.userName[0].toUpperCase(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}