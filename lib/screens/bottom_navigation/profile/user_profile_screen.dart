// lib/screens/user_profile_screen.dart - COMPLETE VERSION

import 'package:everywhere/screens/bottom_navigation/profile/settings_screeen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/post_model.dart';
import '../../../providers/feed_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../widgets/post_card_last.dart';
import '../../../widgets/verification_badge.dart';
import '../promotion.dart';


class UserProfileScreen extends StatefulWidget {
  final String userId;
  final bool isOwnProfile;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.isOwnProfile = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // context.read<FeedProvider>().loadFeed(refresh: true);
    _tabController = TabController(
      length: widget.isOwnProfile ? 4 : 2,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      profileProvider.loadUserProfile(widget.userId);
      profileProvider.loadUserPosts(widget.userId);
      if (widget.isOwnProfile) {
        profileProvider.loadSavedPosts();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant UserProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      final profileProvider = context.read<ProfileProvider>();

      profileProvider.loadUserProfile(widget.userId);
      profileProvider.loadUserPosts(widget.userId);

      if (widget.isOwnProfile) {
        profileProvider.loadSavedPosts();

      }

      // Recreate TabController if ownership changed
      if (oldWidget.isOwnProfile != widget.isOwnProfile) {
        _tabController.dispose();
        _tabController = TabController(
          length: widget.isOwnProfile ? 4 : 2,
          vsync: this,
        );
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          if (profileProvider.isLoadingProfile) {

            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF177E85)),
            );
          }

          if (profileProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load profile',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => profileProvider.loadUserProfile(widget.userId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF177E85),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = profileProvider.profile;
          if (profile == null) {
            return const Center(
              child: Text('Profile not found', style: TextStyle(color: Colors.white)),
            );
          }

          // Check if profile is private and user is not following
          final isPrivateAndNotFollowing = profile.isPrivate &&
              !profile.isFollowing &&
              !widget.isOwnProfile;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // App Bar
                // lib/screens/user_profile_screen.dart - UPDATE AppBar

                SliverAppBar(
                  expandedHeight: 0,
                  pinned: true,
                  backgroundColor: const Color(0xFF1E293B),
                  leading: widget.isOwnProfile
                      ? null // No back button for own profile
                      : IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  automaticallyImplyLeading: !widget.isOwnProfile, // Important!
                  actions: widget.isOwnProfile
                      ? [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ]
                      : null,
                  flexibleSpace: FlexibleSpaceBar(
                    background:   SizedBox.shrink()
                  ),
                ),

                // Profile Header


                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Cover Image
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: _buildCoverImage(profile.coverImage, widget.isOwnProfile),
                      ),

                      // Profile Header ABOVE cover
                      Positioned(
                        top: 110, // 200 - (half avatar size)
                        child:  widget.isOwnProfile ?
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:  Colors.white,
                                      width: 3
                                  )
                              ),
                              child:Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF0F172A),
                                    width: 4,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[700],
                                  backgroundImage: profile.avatar != null
                                      ? CachedNetworkImageProvider(profile.avatar!)
                                      : null,
                                  child: profile.avatar == null
                                      ? Text(
                                    profile.username[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                      : null,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 90, left: 80),
                              child: GestureDetector(
                                // onTap: pov.updateImage,
                                onTap: () {

                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF177E85),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(FontAwesomeIcons.plusCircle,
                                    size: 20, color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                            : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0F172A),
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[700],
                            backgroundImage: profile.avatar != null
                                ? CachedNetworkImageProvider(profile.avatar!)
                                : null,
                            child: profile.avatar == null
                                ? Text(
                              profile.username[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                                : null,
                          ),
                        ),
                      ),


                    ],
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _ProfileHeader(
                        profile: profile,
                        isOwnProfile: widget.isOwnProfile,
                      ),
                      const SizedBox(height: 16),
                      _ProfileStats(profile: profile),
                      const SizedBox(height: 16),

                    ],
                  ),
                ),

                // Tabs
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF177E85),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF177E85),
                      tabs: widget.isOwnProfile
                          ? const [
                        Tab(text: 'Posts'),
                        Tab(text: 'Saved'),
                        Tab(text: 'Earnings'),
                        Tab(text: 'About'),
                      ]
                          : const [
                        Tab(text: 'Posts'),
                        Tab(text: 'About'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: isPrivateAndNotFollowing
                ? _buildPrivateAccountView()
                : TabBarView(
              controller: _tabController,
              children: widget.isOwnProfile
                  ? [
                _PostsTab(posts: profileProvider.userPosts, userProfile: profileProvider),
                _SavedTab(posts: profileProvider.savedPosts, userProfile: profileProvider,),
                _EarningsTab(profile: profile),
                _AboutTab(profile: profile),
              ]
                  : [
                _PostsTab(posts: profileProvider.userPosts, userProfile: profileProvider),
                _AboutTab(profile: profile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoverImage(String? coverImage, bool isOwner) {
    if (coverImage != null && isOwner) {
     return  Stack(
        children: [
          CachedNetworkImage(
            imageUrl: coverImage,
            fit: BoxFit.cover,
            width: double.infinity,
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFF1E293B),
            ),
          ),
          Positioned(
            bottom: 8,
              right: 8,
              child: IconButton(onPressed: () {}, icon: Icon(Icons.camera_alt, size: 30,)))
        ],
      ) ;

    }
    else {
      if (isOwner ) {
        return  Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF177E85).withOpacity(0.3),
                    const Color(0xFF0F172A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
                bottom: 10,
                right: 10,
                child: IconButton(onPressed: () {}, icon: Icon(Icons.camera_alt, size: 40,)))
          ],
        );
      } else { return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF177E85).withOpacity(0.3),
              const Color(0xFF0F172A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );}
    }
  }

  Widget _buildPrivateAccountView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 24),
          Text(
            'This Account is Private',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow to see their posts',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// lib/screens/user_profile_screen.dart - UPDATE _ProfileHeader
class _ProfileHeader extends StatelessWidget {
  final profile;
  final bool isOwnProfile;

  const _ProfileHeader({
    required this.profile,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // // Avatar
          // Container(
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     border: Border.all(
          //       color: const Color(0xFF0F172A),
          //       width: 4,
          //     ),
          //   ),
          //   child: CircleAvatar(
          //     radius: 50,
          //     backgroundColor: Colors.grey[700],
          //     backgroundImage: profile.avatar != null
          //         ? CachedNetworkImageProvider(profile.avatar!)
          //         : null,
          //     child: profile.avatar == null
          //         ? Text(
          //       profile.username[0].toUpperCase(),
          //       style: const TextStyle(
          //         fontSize: 32,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.white,
          //       ),
          //     )
          //         : null,
          //   ),
          // ),
          // const SizedBox(height: 16),
          // Avatar - FIXED POSITIONING
          // Stack(
          //   alignment: Alignment.center,
          //   children: [
          //     // White background circle
          //     Container(
          //       width: 108,
          //       height: 108,
          //       decoration: const BoxDecoration(
          //         color: Color(0xFF0F172A),
          //         shape: BoxShape.circle,
          //       ),
          //     ),
          //     // Avatar
          //     Container(
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         border: Border.all(
          //           color: const Color(0xFF0F172A),
          //           width: 4,
          //         ),
          //       ),
          //       child: CircleAvatar(
          //         radius: 50,
          //         backgroundColor: Colors.grey[700],
          //         backgroundImage: profile.avatar != null
          //             ? CachedNetworkImageProvider(profile.avatar!)
          //             : null,
          //         child: profile.avatar == null
          //             ? Text(
          //           profile.username[0].toUpperCase(),
          //           style: const TextStyle(
          //             fontSize: 32,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.white,
          //           ),
          //         )
          //             : null,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),

          // Username with badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              VerificationBadge(userId: profile.userId),
            ],
          ),

          // Username handle
          Text(
            '@${profile.username}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),

          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              profile.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],

          // Location & Website
          if (profile.location != null || profile.website != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (profile.location != null) ...[
                  Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    profile.location!,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  if (profile.website != null) const SizedBox(width: 16),
                ],
                if (profile.website != null) ...[
                  Icon(Icons.link, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    profile.website!,
                    style: TextStyle(
                      color: const Color(0xFF177E85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isOwnProfile) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.read<ProfileProvider>().toggleFollow(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: profile.isFollowing
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF177E85),
                      foregroundColor: Colors.white,
                      side: profile.isFollowing
                          ? BorderSide(color: Colors.grey[700]!)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      profile.isFollowing ? 'Following' : 'Follow',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // Navigate to messages
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to edit profile
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[700]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // Share profile
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 20),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final profile;

  const _ProfileStats({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            label: 'Posts',
            value: _formatCount(profile.postCount),
          ),
          _StatItem(
            label: 'Followers',
            value: _formatCount(profile.followerCount),
          ),
          _StatItem(
            label: 'Following',
            value: _formatCount(profile.followingCount),
          ),
          if (profile.totalNairaEarned > 0)
            _StatItem(
              label: 'Earned',
              value: '₦${_formatCount(profile.totalNairaEarned.toInt())}',
            ),
        ],
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
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF1E293B),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

// Posts Tab
class _PostsTab extends StatelessWidget {
  final List<Post> posts;
  final ProfileProvider userProfile;
   

  const _PostsTab({required this.posts, required this.userProfile});

  @override
  Widget build(BuildContext context) {

    print(posts);
    
    if (userProfile.isLoadingPosts) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF177E85)),
      );
    }

    if (posts.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.grid_on, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(
                'No posts yet',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) => PostCard(post: posts[index]),
    );
  }
}

// Saved Tab
class _SavedTab extends StatelessWidget {
  final List<Post> posts;
  final ProfileProvider userProfile;

  const _SavedTab({required this.posts, required this.userProfile});

  @override
  Widget build(BuildContext context) {

    if (userProfile.isLoadingSaved) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF177E85)),
      );
    }
    
    if (posts.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No saved posts',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Save posts to view them later',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) => PostCard(
          post: posts[index],
        isInProfile: true,
      ),

    );
  }
}

// Earnings Tab
class _EarningsTab extends StatelessWidget {
  final profile;

  const _EarningsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF177E85),
                  const Color(0xFF177E85).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Earnings',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₦${profile.totalNairaEarned.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reward Points',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          profile.totalRewardPointsEarned.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'This Week',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '₦${profile.weeklyPoints.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Breakdown
          const Text(
            'Earnings Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _EarningCard(
            title: 'From Rewards',
            amount: profile.totalNairaEarned,
            icon: Icons.card_giftcard,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _EarningCard(
            title: 'Pending Points',
            amount: profile.totalRewardPointsEarned - profile.totalNairaEarned,
            icon: Icons.pending,
            color: Colors.orange,
          ),

          const SizedBox(height: 24),

          // Convert button (if has points)
          if (profile.totalRewardPointsEarned > 1000)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Show convert dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF177E85),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Convert Points to Cash',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EarningCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _EarningCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₦${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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

// About Tab
class _AboutTab extends StatelessWidget {
  final profile;

  const _AboutTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile.email != null) ...[
            _InfoSection(
              title: 'Email',
              content: profile.email!,
              icon: Icons.email,
            ),
            const SizedBox(height: 20),
          ],
          if (profile.phoneNumber != null) ...[
            _InfoSection(
              title: 'Phone',
              content: profile.phoneNumber!,
              icon: Icons.phone,
            ),
            const SizedBox(height: 20),
          ],
          if (profile.chatTag != null) ...[
            _InfoSection(
              title: 'Chat Tag',
              content: profile.chatTag!,
              icon: Icons.tag,
            ),
            const SizedBox(height: 20),
          ],
          if (profile.transferUID != null) ...[
            _InfoSection(
              title: 'Transfer ID',
              content: profile.transferUID!,
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 20),
          ],

          // Account Info
          _InfoSection(
            title: 'Member Since',
            content: _formatDate(profile.createdAt),
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 20),

          _InfoSection(
            title: 'Last Active',
            content: timeago.format(profile.lastActiveAt),
            icon: Icons.access_time,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _InfoSection({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF177E85), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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