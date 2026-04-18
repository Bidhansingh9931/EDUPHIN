import 'package:eduphin/services/common_widgets.dart';
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
    final theme = context.theme;
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
            icon: Icon(Icons.dashboard_rounded, size: context.scale(24)),
            tooltip: "Dashboard",
          ),
          SizedBox(width: context.spacing / 2),
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
                    Icon(Icons.error_outline_rounded, size: context.scale(48), color: colorScheme.error),
                    SizedBox(height: context.spacing),
                    Text('Error loading reviews', style: theme.textTheme.titleMedium),
                    SizedBox(height: context.spacing),
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
                  constraints: BoxConstraints(maxWidth: context.scale(1000)),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.responsive(1, tablet: 2, desktop: 2),
                      crossAxisSpacing: context.spacing,
                      mainAxisSpacing: context.spacing,
                      mainAxisExtent: context.scale(220),
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
        icon: Icon(Icons.rate_review_rounded, size: context.scale(24)),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, ReviewDetail review) {
    final theme = context.theme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatar(
                  imageUrl: review.imageUrl,
                  radius: context.scale(24),
                ),
                SizedBox(width: context.spacing),
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
                Icon(Icons.star_rounded, color: Colors.amber, size: context.scale(20)),
                Text(" 5.0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
              ],
            ),
            SizedBox(height: context.spacing),
            const Divider(),
            SizedBox(height: context.spacing / 2),
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
          Icon(Icons.rate_review_outlined, size: context.scale(64), color: theme.hintColor.withValues(alpha: 0.3)),
          SizedBox(height: context.spacing),
          Text("No reviews yet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16))),
          SizedBox(height: context.spacing / 2),
          Text("Be the first to share your experience", style: TextStyle(color: theme.hintColor, fontSize: context.font(14))),
        ],
      ),
    );
  }
}
