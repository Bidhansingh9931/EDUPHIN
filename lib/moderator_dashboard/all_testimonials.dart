import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'dashboard_data_provider.dart';
import 'dashboard_models.dart';
import 'skeleton_widgets.dart';

class AllTestimonialsPage extends StatefulWidget {
  const AllTestimonialsPage({super.key});

  @override
  State<AllTestimonialsPage> createState() => _AllTestimonialsPageState();
}

class _AllTestimonialsPageState extends State<AllTestimonialsPage> {
  final DashboardDataProvider _provider = DashboardDataProvider();
  late Future<DashboardData> _dashboardDataFuture;
  DashboardData? _cachedData;

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    final cached = await _provider.getCachedData();
    if (mounted) {
      setState(() {
        _cachedData = cached;
        _dashboardDataFuture = _provider.fetchDashboardData();
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _dashboardDataFuture = _provider.fetchDashboardData(bypassCache: true);
    });
    try {
      await _dashboardDataFuture;
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Success Stories',
            style: TextStyle(
                fontSize: context.font(20), fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<DashboardData>(
          future: _dashboardDataFuture,
          builder: (context, snapshot) {
            return ModeratorLoadingWrapper<DashboardData>(
              snapshot: snapshot,
              cachedData: _cachedData,
              skeleton: const TestimonialSkeleton(),
              onRefresh: _refreshData,
              builder: (data) {
                if (data.testimonials.isEmpty) {
                  return const Center(child: Text('No testimonials found.'));
                }
                return _buildTestimonialList(context, data.testimonials);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTestimonialList(BuildContext context, List<Testimonial> testimonials) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: context.pagePadding,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(1000)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("What our users say",
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(24),
                      color: theme.colorScheme.onSurface)),
              SizedBox(height: context.sm),
              Text("Real feedback from our global community",
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: context.font(14))),
              SizedBox(height: context.lg),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: testimonials.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: context.md),
                itemBuilder: (context, index) {
                  final item = testimonials[index];
                  return Card(
                    color: theme.colorScheme.surfaceContainerLow,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.md),
                      side: BorderSide(
                          color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.format_quote_rounded,
                              color: colorScheme.primary,
                              size: context.scale(32)),
                          SizedBox(height: context.md),
                          Text(
                            item.review,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                                fontSize: context.font(16),
                                color: theme.colorScheme.onSurface),
                          ),
                          SizedBox(height: context.lg),
                          Row(
                            children: [
                              ProfileAvatar(
                                imageUrl: item.imageUrl,
                                radius: context.scale(20),
                              ),
                              SizedBox(width: context.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: context.font(15),
                                            color: theme.colorScheme
                                                .onSurface)),
                                    Text(item.school,
                                        style: TextStyle(
                                            color: theme.colorScheme
                                                .onSurfaceVariant,
                                            fontSize: context.font(13))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: context.lg),
            ],
          ),
        ),
      ),
    );
  }
}
