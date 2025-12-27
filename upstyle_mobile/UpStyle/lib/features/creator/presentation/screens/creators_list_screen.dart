import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/chat/presentation/screens/creator_profile_screen.dart';
import '../provider/creators_provider.dart';

class CreatorsListScreen extends StatefulWidget {
  const CreatorsListScreen({super.key});

  @override
  State<CreatorsListScreen> createState() => _CreatorsListScreenState();
}

class _CreatorsListScreenState extends State<CreatorsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load creators on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreatorsProvider>().loadCreators();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more when near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<CreatorsProvider>().loadMoreCreators();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Find Creators',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search creators...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<CreatorsProvider>()
                              .loadCreators(refresh: true);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  context.read<CreatorsProvider>().loadCreators(refresh: true);
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<CreatorsProvider>().searchCreators(value);
                }
              },
            ),
          ),

          // Creators list
          Expanded(
            child: Consumer<CreatorsProvider>(
              builder: (context, provider, child) {
                if (provider.status == CreatorsStatus.loading &&
                    provider.creators.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.status == CreatorsStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage ?? 'An error occurred',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadCreators(refresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.creators.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No creators found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadCreators(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        provider.creators.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at bottom if loading more
                      if (index == provider.creators.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final creator = provider.creators[index];
                      return _CreatorCard(creator: creator);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorCard extends StatelessWidget {
  final dynamic creator; // UserModel type

  const _CreatorCard({required this.creator});

  @override
  Widget build(BuildContext context) {
    final creatorInfo = creator.creatorInfo;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreatorProfileScreen(creatorId: creator.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundImage: creator.profileImageUrl != null
                    ? NetworkImage(creator.profileImageUrl!)
                    : null,
                child: creator.profileImageUrl == null
                    ? Text(
                        creator.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      creator.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Rating & Items Helped
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${creatorInfo?.rating.toStringAsFixed(1) ?? "0.0"}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${creatorInfo?.itemsHelped ?? 0} helped',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Bio
                    if (creatorInfo?.bio != null && creatorInfo!.bio.isNotEmpty)
                      Text(
                        creatorInfo.bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Specializations
                    if (creatorInfo?.specializations != null &&
                        creatorInfo!.specializations.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: creatorInfo.specializations
                            .take(3)
                            .map<Widget>((spec) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    spec,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
