import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

import 'add_reviews.dart';
import 'all_review_model.dart';
import 'all_review_provider.dart';
import 'moderator_dashboard.dart';

class AllReviewsPage extends StatefulWidget {
  const AllReviewsPage({super.key});

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  late Future<List<ReviewDetail>> _reviewsFuture;
  final AllReviewProvider _provider = AllReviewProvider();

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _provider.fetchAllReviews();
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _reviewsFuture = _provider.fetchAllReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Institute Reviews'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ModeratorDashboardPage()),
              (route) => false,
            ),
            icon: const Icon(Icons.dashboard_rounded),
            tooltip: "Dashboard",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReviews,
        child: FutureBuilder<List<ReviewDetail>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Error loading reviews', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: _refreshReviews, child: const Text("Retry")),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(theme);
            }

            final reviews = snapshot.data!;

            return SingleChildScrollView(
              padding: context.pagePadding,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.responsive(1, tablet: 2, desktop: 2),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 220,
                    ),
                    itemBuilder: (context, index) {
                      return _buildReviewCard(context, reviews[index]);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReviewsPage()),
          );
        },
        label: const Text('Write Review'),
        icon: const Icon(Icons.rate_review_rounded),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, ReviewDetail review) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  backgroundImage: review.avatarAsset.isNotEmpty ? AssetImage(review.avatarAsset) : null,
                  child: review.avatarAsset.isEmpty ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        review.designation,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const Text(" 5.0", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                review.reviewText,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: theme.hintColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text("No reviews yet", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Be the first to share your experience", style: TextStyle(color: theme.hintColor)),
        ],
      ),
    );
  }
}
