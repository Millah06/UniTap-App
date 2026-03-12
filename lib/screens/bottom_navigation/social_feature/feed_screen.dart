import 'package:flutter/material.dart';

// lib/screens/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/feed_provider.dart';
import '../../../providers/reward_provider.dart';
import '../../../widgets/leaderboard_section.dart';
import '../../../widgets/post_card.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadFeed(refresh: true);
      context.read<RewardProvider>().loadLeaderboard();
      context.read<RewardProvider>().loadCreatorStats();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedProvider>().loadFeed();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Feed',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePostScreen(),
                ),
              );

              if (result == true) {
                context.read<FeedProvider>().loadFeed(refresh: true);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<FeedProvider>().loadFeed(refresh: true);
          await context.read<RewardProvider>().loadLeaderboard();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Leaderboard Section
            const SliverToBoxAdapter(
              child: LeaderboardSection(),
            ),

            // Creator Stats Card
            SliverToBoxAdapter(
              child: Consumer<RewardProvider>(
                builder: (context, rewardProvider, _) {
                  final stats = rewardProvider.stats;

                  if (stats == null) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[700]!, Colors.blue[500]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                stats.levelName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Level ${stats.level}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatItem(
                              label: 'Reward Points',
                              value: stats.totalRewardPoints.toStringAsFixed(0),
                              icon: Icons.stars,
                            ),
                            _StatItem(
                              label: 'Earned',
                              value: '₦${stats.totalEarnedNaira.toStringAsFixed(0)}',
                              icon: Icons.account_balance_wallet,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Posts List
            Consumer<FeedProvider>(
              builder: (context, feedProvider, _) {
                if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (feedProvider.error != null && feedProvider.posts.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load feed',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => feedProvider.loadFeed(refresh: true),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (feedProvider.posts.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.feed_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No posts yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to share something!',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index < feedProvider.posts.length) {
                        return PostCard(post: feedProvider.posts[index]);
                      } else if (feedProvider.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              "You've reached the end",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        );
                      }
                    },
                    childCount: feedProvider.posts.length +
                        (feedProvider.hasMore ? 1 : 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
