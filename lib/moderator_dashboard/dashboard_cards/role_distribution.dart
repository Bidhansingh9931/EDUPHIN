import 'package:flutter/material.dart';

class RoleDistributionPage extends StatelessWidget {
  const RoleDistributionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0E86D4),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),

      body: SafeArea(
        child: Column(
          children: [

            // ---------------- TOP BAR ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "User Distribution",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Icon(Icons.refresh, color: Colors.white),
                ],
              ),
            ),

            // ---------------- PAGE CONTENT ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // ---------- TOTAL USERS CARD ----------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B263B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Total Users",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "24,784",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ----------- USER ROLE LIST -----------
                    ...userRoles.map((role) => UserRoleCard(role)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ------------------ MODEL ------------------
//
class UserRole {
  final IconData icon;
  final String title;
  final int count;
  final double percent;
  final Color color;

  UserRole({
    required this.icon,
    required this.title,
    required this.count,
    required this.percent,
    required this.color,
  });
}

//
// ------------------ DATA ------------------
//
final List<UserRole> userRoles = [
  UserRole(
      icon: Icons.shield,
      title: "Super Admin",
      count: 2,
      percent: 0.01,
      color: Colors.blue),

  UserRole(
      icon: Icons.gavel,
      title: "Moderator",
      count: 5,
      percent: 0.02,
      color: Colors.purple),

  UserRole(
      icon: Icons.home_work,
      title: "Institute Manager",
      count: 25,
      percent: 0.10,
      color: Colors.orange),

  UserRole(
      icon: Icons.people,
      title: "Counselors",
      count: 50,
      percent: 0.20,
      color: Colors.amber),

  UserRole(
      icon: Icons.account_balance_wallet,
      title: "Accountants",
      count: 20,
      percent: 0.08,
      color: Colors.teal),

  UserRole(
      icon: Icons.badge,
      title: "Staffs",
      count: 182,
      percent: 0.73,
      color: Colors.pink),

  UserRole(
      icon: Icons.school,
      title: "Teachers",
      count: 498,
      percent: 2.01,
      color: Colors.green),

  UserRole(
      icon: Icons.person,
      title: "Students",
      count: 24000,
      percent: 96.84,
      color: Colors.lightBlue),

  UserRole(
      icon: Icons.menu_book,
      title: "Librarians",
      count: 2,
      percent: 0.01,
      color: Colors.deepPurpleAccent),
];

//
// ------------------ USER ROLE CARD ------------------
//
class UserRoleCard extends StatelessWidget {
  final UserRole role;

  const UserRoleCard(this.role, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: role.color.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(role.icon, color: role.color, size: 28),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  role.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Text(
                role.count.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: role.percent / 100,
              minHeight: 8,
              backgroundColor: Colors.white12,
              color: role.color,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "${role.percent.toStringAsFixed(2)}%",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
