// lib/widgets/post_card.dart - COMPLETE WITH ALL FEATURES

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../providers/feed_provider.dart';
import '../screens/bottom_navigation/profile/user_profile_screen.dart';
import '../services/social_api_service.dart';
import '../widgets/reward_bottom_sheet.dart';
import '../widgets/boost_dialog.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/follow_button.dart';
import '../widgets/verification_badge.dart';
import '../widgets/post_options_menu.dart';


class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _hasIncrementedView = false;

  @override
  void initState() {
    super.initState();
    _incrementView();
  }

  Future<void> _incrementView() async {
    if (_hasIncrementedView) return;

    try {
      final apiService = SocialApiService();
      await apiService.incrementPostView(widget.post.postId);
      _hasIncrementedView = true;
    } catch (e) {
      // Silently fail - not critical
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnPost = currentUserId == widget.post.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: widget.post.isBoostActive
            ? Border.all(color: Colors.amber, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Repost indicator
          if (widget.post.isRepost)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12),
              child: Row(
                children: [
                  const Icon(Icons.repeat, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Reposted from @${widget.post.originalUserName}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToProfile(context),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[700],
                    backgroundImage: widget.post.userAvatar != null
                        ? CachedNetworkImageProvider(widget.post.userAvatar!)
                        : null,
                    child: widget.post.userAvatar == null
                        ? Text(
                      widget.post.userName[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _navigateToProfile(context),
                            child: Text(
                              widget.post.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          VerificationBadge(userId: widget.post.userId),
                          if (widget.post.isBoostActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.rocket_launch,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Boosted',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        timeago.format(widget.post.createdAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Follow button or options menu
                if (!isOwnPost && !widget.post.isFollowing)
                  FollowButton(
                    userId: widget.post.userId,
                    isFollowing: widget.post.isFollowing,
                    onToggle: () => context.read<FeedProvider>().toggleFollow(widget.post.userId),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => _showOptionsMenu(context),
                  ),
              ],
            ),
          ),

          // Caption with hashtags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCaptionWithHashtags(widget.post.text, widget.post.hashtags),
          ),

          // Image
          if (widget.post.imageUrl != null) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 600,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF177E85),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (widget.post.viewCount > 0) ...[
                  Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(widget.post.viewCount),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (widget.post.rewardPointsTotal > 0) ...[
                  const Icon(Icons.stars, size: 16, color: Color(0xFFFFD700)),
                  const SizedBox(width: 4),
                  Text(
                    '₦${widget.post.rewardPointsTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (widget.post.repostCount > 0) ...[
                  Icon(Icons.repeat, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(widget.post.repostCount),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFF0F172A)),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: widget.post.isLikedByCurrentUser
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  label: _formatCount(widget.post.likeCount),
                  color: widget.post.isLikedByCurrentUser
                      ? Colors.red
                      : Colors.grey[400],
                  onTap: () => context.read<FeedProvider>().toggleLike(widget.post.postId),
                ),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: _formatCount(widget.post.commentCount),
                  color: Colors.grey[400],
                  onTap: () => _showComments(context),
                ),
                if (!isOwnPost)
                  _ActionButton(
                    icon: Icons.card_giftcard,
                    label: widget.post.rewardCount > 0
                        ? _formatCount(widget.post.rewardCount)
                        : 'Reward',
                    color: const Color(0xFF177E85),
                    onTap: () => _showRewardSheet(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionWithHashtags(String text, List<String> hashtags) {
    final textSpans = <TextSpan>[];
    final words = text.split(' ');

    for (var word in words) {
      if (word.startsWith('#')) {
        textSpans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(
              color: Color(0xFF177E85),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        textSpans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.white),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, height: 1.4),
        children: textSpans,
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _navigateToProfile(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userId: widget.post.userId,
          isOwnProfile: currentUserId == widget.post.userId,
        ),
      ),
    );
  }

  void _showRewardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RewardBottomSheet(post: widget.post),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(post: widget.post),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PostOptionsMenu(post: widget.post),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey[400]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color ?? Colors.grey[400],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}