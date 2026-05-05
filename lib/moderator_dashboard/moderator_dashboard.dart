import 'package:eduphin/moderator_dashboard/dashboard_cards/role_distribution.dart';
import 'package:eduphin/moderator_dashboard/notification.dart';
import 'package:eduphin/moderator_dashboard/profile.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'all_review.dart';
import 'dashboard_data_provider.dart';
import 'dashboard_models.dart';
import 'skeleton_widgets.dart';

class ModeratorDashboardPage extends StatefulWidget {
  const ModeratorDashboardPage({super.key});

  @override
  State<ModeratorDashboardPage> createState() => _ModeratorDashboardPageState();
}

class _ModeratorDashboardPageState extends State<ModeratorDashboardPage> {
  String? selectedValue = "Last 30 Days";
  String? selectedValue2 = "All Institutes";

  late Future<DashboardData> _dashboardDataFuture;
  final DashboardDataProvider _dataProvider = DashboardDataProvider();
  DashboardData? _cachedData;

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _dataProvider.fetchDashboardData();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    final cached = await _dataProvider.getCachedData();
    if (mounted) {
      setState(() {
        _cachedData = cached;
        _dashboardDataFuture = _dataProvider.fetchDashboardData();
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _dashboardDataFuture = _dataProvider.fetchDashboardData(bypassCache: true);
    });
    await _dashboardDataFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Dashboard Overview",
          style: TextStyle(fontSize: context.font(18)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Download started... (placeholder)')),
              );
            },
            icon: Icon(Icons.download, size: context.scale(24)),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()));
            },
            icon: Icon(Icons.notifications, size: context.scale(24)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<DashboardData>(
          future: _dashboardDataFuture,
          builder: (context, snapshot) {
            return ModeratorLoadingWrapper<DashboardData>(
              snapshot: snapshot,
              cachedData: _cachedData,
              skeleton: const DashboardSkeleton(),
              onRefresh: _refreshData,
              builder: (data) => _buildDashboardBody(data),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = context.theme;
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: context.font(18),
      ),
    );
  }

  Widget _buildDashboardBody(DashboardData data) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    final pieChartColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
    ];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const ModeratorProfilePage())).then((_) => _refreshData()),
                child: ProfileAvatar(
                  imageUrl: data.userPhoto.isNotEmpty
                      ? ApiService.getStorageUrl(data.userPhoto)
                      : null,
                  radius: context.scale(24),
                ),
              ),
              SizedBox(width: context.spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome back, ${data.userName}!",
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: context.scale(4)),
                    Text(
                      "Here is the information about your moderator dashboard.",
                      maxLines: 2,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing),
          Container(
            height: context.scale(48),
            padding: EdgeInsets.symmetric(horizontal: context.spacing),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(context.scale(30)),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: context.scale(20)),
                SizedBox(width: context.spacing / 2),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search accounts, institutes...",
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.spacing),
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth < 480) {
              return Column(
                children: [
                  _buildDropdown(selectedValue, (newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  }, ['Last 7 Days', 'Last 30 Days', 'Last 60 Days']),
                  SizedBox(height: context.spacing / 2),
                  _buildDropdown(selectedValue2, (newValue) {
                    setState(() {
                      selectedValue2 = newValue;
                    });
                  }, [
                    'All Institutes',
                    'Active Institutes',
                    'Inactive Institutes'
                  ]),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                      child: _buildDropdown(selectedValue, (newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                      }, ['Last 7 Days', 'Last 30 Days', 'Last 60 Days'])),
                  SizedBox(width: context.spacing / 2),
                  Expanded(
                      child: _buildDropdown(selectedValue2, (newValue) {
                        setState(() {
                          selectedValue2 = newValue;
                        });
                      }, [
                        'All Institutes',
                        'Active Institutes',
                        'Inactive Institutes'
                      ])),
                ],
              );
            }
          }),
          SizedBox(height: context.spacing),
          _buildSectionHeader("Dashboard Overview"),
          SizedBox(height: context.scale(12)),
          LayoutBuilder(builder: (context, constraints) {
            int crossAxisCount;
            double childAspectRatio;

            if (constraints.maxWidth > 1200) {
              crossAxisCount = 5;
              childAspectRatio = 1.2;
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 4;
              childAspectRatio = 1.1;
            } else if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
              childAspectRatio = 1.0;
            } else {
              crossAxisCount = 2;
              childAspectRatio = 0.95;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.gridItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: context.spacing / 2,
                mainAxisSpacing: context.spacing / 2,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                final item = data.gridItems[index];
                return DashboardCard(
                  icon: item.icon,
                  title: item.title,
                  value: item.value,
                  percentage: item.percentage,
                  isPositive: item.isPositive,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => item.page),
                    );
                  },
                );
              },
            );
          }),
          SizedBox(height: context.spacing),
          _buildSectionHeader("User Role Distribution"),
          SizedBox(height: context.scale(12)),
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(14))),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RoleDistributionPage())),
              child: Padding(
                padding:
                EdgeInsets.all(context.spacing),
                child: Column(
                  children: [
                    SizedBox(
                      height: context.scale(180),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: context.scale(4),
                              centerSpaceRadius: context.scale(50),
                              startDegreeOffset: -90,
                              sections: List.generate(data.gridItems.length, (index) {
                                final item = data.gridItems[index];
                                return PieChartSectionData(
                                  value: double.tryParse(item.value) ?? 0.0,
                                  color: pieChartColors[index % pieChartColors.length],
                                  radius: context.scale(40),
                                  title: '',
                                );
                              }),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(data.gridItems.fold<int>(0, (sum, item) => sum + (int.tryParse(item.value) ?? 0)).toString(),
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              SizedBox(height: context.scale(4)),
                              Text("Total Users",
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.spacing),
                    ...List.generate(data.gridItems.length, (index) {
                      final item = data.gridItems[index];
                      return LegendRow(
                        title: item.title,
                        value: int.tryParse(item.value) ?? 0,
                        color: pieChartColors[index % pieChartColors.length],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: context.spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader("Recent Reviews"),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AllReviewsPage())),
                child: Text("View All",
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: context.scale(12)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.reviews.length,
            itemBuilder: (context, index) {
              final review = data.reviews[index];
              return ReviewCard(
                name: review.name,
                school: review.school,
                rating: review.rating,
                review: review.review,
                avatarUrl: review.avatarUrl,
              );
            },
          ),
          SizedBox(height: context.spacing),
          _buildSectionHeader("Database Status"),
          SizedBox(height: context.scale(12)),
          Row(
            children: [
              Expanded(
                  child: StatCard(
                      title: "Databases", value: data.databaseCount)),
              SizedBox(width: context.spacing / 2),
              Expanded(
                  child:
                  StatCard(title: "Data Usage", value: data.dataUsage)),
            ],
          ),
          SizedBox(height: context.spacing / 2),
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
            child: Padding(
              padding: EdgeInsets.all(context.spacing),
              child: Row(
                children: [
                  Icon(Icons.cloud_done, color: theme.colorScheme.primary),
                  SizedBox(width: context.spacing),
                  Expanded(
                      child: Text("System Uptime",
                          style: theme.textTheme.bodyMedium)),
                  Text(data.systemUptime,
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          SizedBox(height: context.spacing),
          _buildSectionHeader("Recent Activities"),
          SizedBox(height: context.scale(12)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.recentActivities.length,
            itemBuilder: (context, index) {
              final activity = data.recentActivities[index];
              return ActivityTile(
                icon: activity.icon,
                color: activity.color,
                text: activity.text,
                time: activity.time,
              );
            },
          ),
          SizedBox(height: context.scale(40)),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String? value, ValueChanged<String?> onChanged, List<String> items) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: context.scale(44),
      padding: EdgeInsets.symmetric(horizontal: context.spacing),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(22)),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: colorScheme.surfaceContainerLow,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: colorScheme.onSurface, size: context.scale(18)),
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child:
              Text(value, style: theme.textTheme.bodyMedium),
            );
          }).toList(),
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final double percentage;
  final bool isPositive;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
    required this.percentage,
    required this.isPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final color = isPositive ? colorScheme.primary : colorScheme.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.scale(14)),
      child: Container(
        padding: EdgeInsets.all(context.spacing),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(context.scale(14)),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: context.scale(20),
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
              child: Icon(icon, color: colorScheme.primary, size: context.scale(20)),
            ),
            SizedBox(height: context.scale(8)),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.scale(4)),
            Text(
              title,
              style: theme.textTheme.bodySmall,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: color,
                  size: context.scale(16),
                ),
                SizedBox(width: context.scale(4)),
                Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.bodySmall),
            SizedBox(height: context.scale(4)),
            Text(value,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String name;
  final String school;
  final double rating;
  final String review;
  final String? avatarUrl;

  const ReviewCard({
    super.key,
    required this.name,
    required this.school,
    required this.rating,
    required this.review,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(14)),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.only(bottom: context.spacing / 2),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileAvatar(
              imageUrl: avatarUrl,
              radius: context.scale(24),
            ),
            SizedBox(width: context.spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text("⭐ $rating",
                          style: const TextStyle(color: Color(0xFFFFC857), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: context.scale(4)),
                  Text(school,
                      style: theme.textTheme.bodySmall),
                  SizedBox(height: context.scale(8)),
                  Text(review,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LegendRow extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const LegendRow(
      {super.key,
        required this.title,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scale(4)),
      child: Row(
        children: [
          Container(
              width: context.scale(12),
              height: context.scale(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: context.spacing / 2),
          Text(title, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(value.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String time;

  const ActivityTile({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.only(bottom: context.spacing / 2),
      child: Padding(
        padding: EdgeInsets.all(context.spacing / 1.5),
        child: Row(
          children: [
            Icon(icon, color: color, size: context.scale(20)),
            SizedBox(width: context.spacing / 2),
            Expanded(
              child: Text(text, style: theme.textTheme.bodyMedium),
            ),
            Text(time, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

