// lib/screens/feed_screen.dart - MAJOR UPDATE

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../constraints/constants.dart';
import '../../../providers/feed_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/reward_provider.dart';
import '../../../widgets/compact_leaderboard.dart';
import '../../../widgets/post_card_last.dart';
import '../profile_settings_screen.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadFeed();
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
    final profile =  Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            Padding(
                padding: EdgeInsets.all(10),
                child:
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder:  (context)=> ProfileSettingsScreen()));
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:  Color(0xFFE3E3E3),
                                width: 1
                            )
                        ),
                        child: ClipOval(
                            child:  CircleAvatar()
                        ),
                      ),
                    ),
                  ],
                )
            ),
            Text(
              'Feed',
              style: kTopAppbars.copyWith(
                  fontFamily:  'DejaVu Sans', fontSize: 23),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: ( ) {}, icon: Icon(Icons.search)),
          IconButton(
            icon: const Icon( FontAwesomeIcons.plusCircle, color: Colors.white),
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
      body: Column(
        children: [
          // Feed Type Toggle
          _FeedTypeToggle(),

          // Feed Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<FeedProvider>().forceRefresh();
                await context.read<RewardProvider>().loadLeaderboard();
              },
              color: const Color(0xFF177E85),
              backgroundColor: const Color(0xFF1E293B),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Compact Leaderboard
                  const SliverToBoxAdapter(
                    child: CompactLeaderboard(),
                  ),

                  // Posts List
                  Consumer<FeedProvider>(
                    builder: (context, feedProvider, _) {
                      if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF177E85),
                            ),
                          ),
                        );
                      }

                      if (feedProvider.error != null && feedProvider.posts.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load feed',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => feedProvider.loadFeed(refresh: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF177E85),
                                  ),
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
                                Icon(
                                  Icons.feed_outlined,
                                  size: 64,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  feedProvider.currentFeedType == FeedType.following
                                      ? 'Follow users to see their posts'
                                      : 'No posts yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  feedProvider.currentFeedType == FeedType.following
                                      ? 'Discover creators in For You'
                                      : 'Be the first to share something!',
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
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF177E85),
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }
}

class _FeedTypeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, _) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ToggleButton(
                  label: 'For You',
                  isSelected: feedProvider.currentFeedType == FeedType.forYou,
                  onTap: () => feedProvider.switchFeedType(FeedType.forYou),
                ),
              ),
              Expanded(
                child: _ToggleButton(
                  label: 'Following',
                  isSelected: feedProvider.currentFeedType == FeedType.following,
                  onTap: () => feedProvider.switchFeedType(FeedType.following),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF177E85) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}