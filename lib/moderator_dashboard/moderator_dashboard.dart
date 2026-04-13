import 'package:eduphin/moderator_dashboard/dashboard_cards/role_distribution.dart';
import 'package:eduphin/moderator_dashboard/notification.dart';
import 'package:eduphin/moderator_dashboard/profile.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'all_review.dart';
import 'dashboard_data_provider.dart';
import 'dashboard_models.dart';

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

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _dataProvider.fetchDashboardData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _dashboardDataFuture = _dataProvider.fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1820),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1820),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Dashboard Overview",
          style: TextStyle(color: Colors.white, fontSize: 18),
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
            icon: const Icon(Icons.download, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()));
            },
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<DashboardData>(
          future: _dashboardDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: An error occurred: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              return _buildDashboardBody(snapshot.data!);
            } else {
              return const Center(
                child: Text(
                  'No data available.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDashboardBody(DashboardData data) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveFontSize(double baseFontSize) {
      if (screenWidth > 1200) {
        return baseFontSize * 1.2;
      } else if (screenWidth > 600) {
        return baseFontSize * 1.1;
      } else {
        return baseFontSize;
      }
    }

    final pieChartColors = [
      const Color(0xFF2E6CFF),
      const Color(0xFF2ECF7E),
      const Color(0xFF8A63FF),
      const Color(0xFFFFC107),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
    ];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: 8),
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
                        const ModeratorProfilePage())),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: data.userPhoto.isNotEmpty
                      ? Image.network(
                          ApiService.getStorageUrl(data.userPhoto),
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/images/girl_image.webp',
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/girl_image.webp',
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome back, ${data.userName}!",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: responsiveFontSize(18),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(
                      "Here is the information about your moderator dashboard.",
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: responsiveFontSize(12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF13232E),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.white54),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search accounts, institutes...",
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth < 480) {
              return Column(
                children: [
                  _buildDropdown(selectedValue, (newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  }, ['Last 7 Days', 'Last 30 Days', 'Last 60 Days']),
                  const SizedBox(height: 10),
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
                  const SizedBox(width: 10),
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
          SizedBox(height: screenHeight * 0.02),
          Text("Dashboard Overview",
              style: TextStyle(
                  color: Colors.white, fontSize: responsiveFontSize(18))),
          const SizedBox(height: 12),
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
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
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
          const SizedBox(height: 18),
          Text("User Role Distribution",
              style: TextStyle(
                  color: Colors.white, fontSize: responsiveFontSize(18))),
          const SizedBox(height: 10),
          Card(
            color: const Color(0xFF10202A),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RoleDistributionPage())),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 42,
                              startDegreeOffset: -90,
                              sections: List.generate(data.gridItems.length, (index) {
                                final item = data.gridItems[index];
                                return PieChartSectionData(
                                  value: double.tryParse(item.value) ?? 0.0,
                                  color: pieChartColors[index % pieChartColors.length],
                                  radius: 40,
                                  title: '',
                                );
                              }),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(data.gridItems.fold<int>(0, (sum, item) => sum + (int.tryParse(item.value) ?? 0)).toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: responsiveFontSize(22),
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text("Total Users",
                                  style: TextStyle(color: Colors.white60)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Reviews",
                  style: TextStyle(
                      color: Colors.white, fontSize: responsiveFontSize(18))),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AllReviewsPage())),
                child: const Text("View All",
                    style: TextStyle(color: Color(0xFF2E6CFF))),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                avatarAsset: review.avatarAsset,
              );
            },
          ),
          SizedBox(height: screenHeight * 0.02),
          Text("Database Status",
              style: TextStyle(
                  color: Colors.white, fontSize: responsiveFontSize(18))),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: StatCard(
                      title: "Databases", value: data.databaseCount)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                  StatCard(title: "Data Usage", value: data.dataUsage)),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF10202A),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.cloud_done, color: Color(0xFF2ECF7E)),
                  const SizedBox(width: 12),
                  const Expanded(
                      child: Text("System Uptime",
                          style: TextStyle(color: Colors.white))),
                  Text(data.systemUptime,
                      style: const TextStyle(
                          color: Color(0xFF2ECF7E),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text("Recent Activities",
              style: TextStyle(
                  color: Colors.white, fontSize: responsiveFontSize(18))),
          const SizedBox(height: 10),
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
          SizedBox(height: screenHeight * 0.05),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String? value, ValueChanged<String?> onChanged, List<String> items) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF13232E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF13232E),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white, size: 18),
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child:
              Text(value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
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
    final color = isPositive ? const Color(0xFF2ECF7E) : const Color(0xFFFF6B6B);
    final screenWidth = MediaQuery.of(context).size.width;

    double responsiveFontSize(double baseFontSize) {
      if (screenWidth > 1200) {
        return baseFontSize * 1.2;
      } else if (screenWidth > 600) {
        return baseFontSize * 1.1;
      } else {
        return baseFontSize;
      }
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF13232E),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white12,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: responsiveFontSize(22),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                  color: Colors.white60, fontSize: responsiveFontSize(12)),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 4),
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
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseFontSize) {
      if (screenWidth > 1200) {
        return baseFontSize * 1.2;
      } else if (screenWidth > 600) {
        return baseFontSize * 1.1;
      } else {
        return baseFontSize;
      }
    }

    return Card(
      color: const Color(0xFF10202A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: Colors.white60,
                    fontSize: responsiveFontSize(14))),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: responsiveFontSize(20),
                    fontWeight: FontWeight.bold)),
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
  final String avatarAsset;

  const ReviewCard({
    super.key,
    required this.name,
    required this.school,
    required this.rating,
    required this.review,
    required this.avatarAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF10202A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (avatarAsset.isNotEmpty)
              ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(avatarAsset,
                      width: 48, height: 48, fit: BoxFit.cover)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text("⭐ $rating",
                          style: const TextStyle(color: Color(0xFFFFC857))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(school,
                      style: const TextStyle(color: Colors.white60)),
                  const SizedBox(height: 8),
                  Text(review,
                      style: const TextStyle(color: Colors.white70),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white)),
          const Spacer(),
          Text(value.toString(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
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
    return Card(
      color: const Color(0xFF10202A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: const TextStyle(color: Colors.white)),
            ),
            Text(time, style: const TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}