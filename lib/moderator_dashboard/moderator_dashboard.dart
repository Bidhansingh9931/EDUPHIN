
// moderator_dashboard.dart
import 'package:eduphin/moderator_dashboard/dashboard_cards/accounts.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/events.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/role_distribution.dart';
import 'package:eduphin/moderator_dashboard/notification.dart';
import 'package:eduphin/moderator_dashboard/profile.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'all_review.dart';
import 'dashboard_cards/classes.dart';
import 'dashboard_cards/exam_types.dart';
import 'dashboard_cards/active_institutes/institutes.dart';
import 'dashboard_cards/students.dart';

class ModeratorDashboardPage extends StatefulWidget {
  const ModeratorDashboardPage({super.key});

  @override
  State<ModeratorDashboardPage> createState() => _ModeratorDashboardPageState();
}

class _ModeratorDashboardPageState extends State<ModeratorDashboardPage> {
  String? selectedValue = "Last 30 Days";
  String? selectedValue2 = "All Institutes";

  late Future<Map<String, dynamic>> _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _fetchDashboardData();
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // This is where you would fetch your data from an API
    return {
      "gridItems": [
        {
          "tag": "total-accounts",
          "icon": Icons.people_alt_outlined,
          "value": "2,450",
          "title": "Total Accounts",
          "percentage": 2.5,
          "isPositive": true,
          "page": const AccountsPage(),
        },
        {
          "tag": "active-institutes",
          "icon": Icons.school_outlined,
          "value": "150",
          "title": "Active Institutes",
          "percentage": 5.0,
          "isPositive": true,
          "page": const InstitutesPage(),
        },
        {
          "tag": 'total-students',
          "icon": Icons.person_outline,
          "value": "18,300",
          "title": "Total Students",
          "percentage": 10.0,
          "isPositive": true,
          "page": const StudentsPage(),
        },
        {
          "tag": "total-classes",
          "icon": Icons.book_outlined,
          "value": "1,200",
          "title": "Total Classes",
          "percentage": 3.0,
          "isPositive": false,
          "page": const ClassesPage(),
        },
        {
          "tag": "total-events",
          "icon": Icons.event_available_outlined,
          "value": "210",
          "title": "Total Events",
          "percentage": 5.5,
          "isPositive": true,
          "page": const EventsPage(),
        },
        {
          "tag": "exam-types",
          "icon": Icons.laptop_chromebook_outlined,
          "value": "15",
          "title": "Exam Types",
          "percentage": 3.5,
          "isPositive": false,
          "page": const ExamTypesPage(),
        },
      ],
      "accountants": 744,
      "staff": 372,
      "others": 124,
      "reviews": [
        {
          "name": "Jane Doe",
          "school": "Greenwood High",
          "rating": 4.5,
          "review":
              "The platform is incredibly intuitive and has streamlined our school's operations.",
          "avatarAsset": "assets/images/women_image.png",
        },
        {
          "name": "John Smith",
          "school": "Oakridge Academy",
          "rating": 5.0,
          "review":
              "A game-changer for administrative tasks. Support is responsive and helpful.",
          "avatarAsset": "assets/images/women_image.png",
        },
      ],
      "databaseCount": "12",
      "dataUsage": "87%",
      "systemUptime": "99.98%",
      "recentActivities": [
        {
          "icon": Icons.check_circle,
          "color": const Color(0xFF2ECF7E),
          "text": "System backup completed successfully.",
          "time": "2m ago"
        },
        {
          "icon": Icons.warning_amber_rounded,
          "color": const Color(0xFFFFC107),
          "text": "High memory usage detected on DB-03.",
          "time": "15m ago"
        },
        {
          "icon": Icons.check_circle,
          "color": const Color(0xFF2ECF7E),
          "text": "Scheduled maintenance completed.",
          "time": "1h ago"
        },
      ]
    };
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
          "Moderator Dashboard Overview",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Placeholder for download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download started... (placeholder)')),
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

      // BODY
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child:
                    Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final gridItems = data['gridItems'] as List<Map<String, dynamic>>;
            final accountants = data['accountants'] as int;
            final staff = data['staff'] as int;
            final others = data['others'] as int;
            final total = accountants + staff + others;
            final pieChartColors = [
              const Color(0xFF2E6CFF),
              const Color(0xFF2ECF7E),
              const Color(0xFF8A63FF),
            ];
            final reviews = data['reviews'] as List<Map<String, dynamic>>;
            final recentActivities =
                data['recentActivities'] as List<Map<String, dynamic>>;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 8, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------------------
                  // TOP SECTION (YOUR DESIGN)
                  // ---------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ModeratorProfilePage())),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset(
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
                          children: const [
                            Text("Welcome back, Sarah!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 3),
                            Text(
                              "Here is the information about your moderator dashboard.",
                              maxLines: 2,
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13232E),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: const [
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

                  const SizedBox(height: 15),

                  // Filters Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13232E),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedValue,
                              dropdownColor: const Color(0xFF13232E),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white, size: 18),
                              items: <String>[
                                'Last 7 Days',
                                'Last 30 Days',
                                'Last 60 Days'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedValue = newValue!;
                                });
                              },
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13232E),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedValue2,
                              dropdownColor: const Color(0xFF13232E),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white, size: 18),
                              items: <String>[
                                'All Institutes',
                                'Active Institutes',
                                'Inactive Institutes'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedValue2 = newValue!;
                                });
                              },
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ---------------------------
                  // GRID CARDS
                  // ---------------------------
                  const Text("Dashboard Overview",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gridItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final item = gridItems[index];
                      return DashboardCard(
                        icon: item['icon'],
                        title: item['title'],
                        value: item['value'],
                        percentage: item['percentage'],
                        isPositive: item['isPositive'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => item['page']),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // ---------------------------
                  // PIE CHART
                  // ---------------------------
                  const Text("User Role Distribution",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),

                  Card(
                    color: const Color(0xFF10202A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RoleDistributionPage())),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16),
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
                                      sections: [
                                        PieChartSectionData(
                                            value: accountants.toDouble(),
                                            color: pieChartColors[0],
                                            radius: 40,
                                            title: ''),
                                        PieChartSectionData(
                                            value: staff.toDouble(),
                                            color: pieChartColors[1],
                                            radius: 40,
                                            title: ''),
                                        PieChartSectionData(
                                            value: others.toDouble(),
                                            color: pieChartColors[2],
                                            radius: 40,
                                            title: ''),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // This will center the text
                                    children: [
                                      Text(total.toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      const Text("Total Users",
                                          style: TextStyle(
                                              color: Colors.white60)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            LegendRow(
                                title: "Accountants",
                                value: accountants,
                                color: pieChartColors[0]),
                            LegendRow(
                                title: "Staff",
                                value: staff,
                                color: pieChartColors[1]),
                            LegendRow(
                                title: "Others",
                                value: others,
                                color: pieChartColors[2]),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------------------
                  // RECENT REVIEWS
                  // ---------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recent Reviews",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AllReviewsPage())),
                        child: const Text("View All",
                            style: TextStyle(color: Color(0xFF2E6CFF))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return ReviewCard(
                        name: review['name'],
                        school: review['school'],
                        rating: review['rating'],
                        review: review['review'],
                        avatarAsset: review['avatarAsset'],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ---------------------------
                  // DATABASE STATUS
                  // ---------------------------
                  const Text("Database Status",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                          child: StatCard(
                              title: "Databases",
                              value: data['databaseCount'])),
                      const SizedBox(width: 12),
                      Expanded(
                          child: StatCard(
                              title: "Data Usage", value: data['dataUsage'])),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Card(
                    color: const Color(0xFF10202A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_done,
                              color: Color(0xFF2ECF7E)),
                          const SizedBox(width: 12),
                          const Expanded(
                              child: Text("System Uptime",
                                  style: TextStyle(color: Colors.white))),
                          Text(data['systemUptime'],
                              style: const TextStyle(
                                  color: Color(0xFF2ECF7E),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------------------
                  // RECENT ACTIVITIES
                  // ---------------------------
                  const Text("Recent Activities",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentActivities.length,
                    itemBuilder: (context, index) {
                      final activity = recentActivities[index];
                      return ActivityTile(
                        icon: activity['icon'],
                        color: activity['color'],
                        text: activity['text'],
                        time: activity['time'],
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          } else {
            return const Center(
                child:
                    Text('No data available', style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }
}

// ----------------------------------------------------------------------
// REUSABLE WIDGETS
// ----------------------------------------------------------------------

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
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
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
                  style:
                      TextStyle(color: color, fontWeight: FontWeight.w500),
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
    return Card(
      color: const Color(0xFF10202A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
                          style:
                              const TextStyle(color: Color(0xFFFFC857))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(school,
                      style: const TextStyle(color: Colors.white60)),
                  const SizedBox(height: 8),
                  Text(review,
                      style:
                          const TextStyle(color: Colors.white70),
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
            Text(time,
                style:
                    const TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}
