import 'dart:async';
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/institutes.dart';
import 'package:flutter/material.dart';

// 1. Data Provider to fetch institute details
class InstituteDetailProvider {
  // In the future, you will replace this with your actual API call
  Future<Institute> fetchInstituteDetails(String instituteId) async {
    // Simulate a network delay to mimic an API call
    await Future.delayed(const Duration(seconds: 2));

    // This is where you would fetch your data from an API based on the instituteId.
    // For now, we are returning a mock Institute object.
    return Institute(
      name: "Greenwood High International",
      chairman: "Dr. Ramesh Sharma",
      code: instituteId, // Using instituteId as the code for mock data
      address: "123 Education Lane, Knowledge City",
      email: "contact@greenwood.edu",
      phone: "+91 98765 43210",
      website: "www.greenwood.edu",
      affiliation: "Central Board of Secondary Education",
      pan: "ABCDE1234F",
    );
  }
}

// 2. Updated StatefulWidget to be dynamic
class ViewInstitutePage extends StatefulWidget {
  // The page now takes an ID to fetch data instead of the whole object.
  final String instituteId;

  const ViewInstitutePage({super.key, required this.instituteId});

  @override
  State<ViewInstitutePage> createState() => _ViewInstitutePageState();
}

class _ViewInstitutePageState extends State<ViewInstitutePage> {
  final InstituteDetailProvider _provider = InstituteDetailProvider();
  late Future<Institute> _instituteFuture;

  @override
  void initState() {
    super.initState();
    // Fetch institute details when the page first loads
    _instituteFuture = _provider.fetchInstituteDetails(widget.instituteId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }
    
    // Consistent dark theme for loading/error states
    Widget buildScaffold(String title, Widget body) {
        return Scaffold(
            backgroundColor: const Color(0xFF0D1B2A),
            appBar: AppBar(
                backgroundColor: const Color(0xFF0D1B2A),
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(title, style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(18)))),
            body: Center(child: body),
        );
    }


    // 3. Use FutureBuilder to handle loading and displaying data
    return FutureBuilder<Institute>(
      future: _instituteFuture,
      builder: (context, snapshot) {
        // Show a loading indicator while data is being fetched
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildScaffold("Loading...", const CircularProgressIndicator());
        }
        // Show an error message if something went wrong
        else if (snapshot.hasError) {
          return buildScaffold("Error", Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
        }
        // Show a message if no data is available
        else if (!snapshot.hasData) {
          return buildScaffold("Not Found", const Text('Institute not found.', style: TextStyle(color: Colors.white70)));
        }

        // If data is available, build the full page UI
        final institute = snapshot.data!;
        
        final detailItems = [
          DetailCard(icon: Icons.person_outline_sharp, label: "Chairman", value: institute.chairman),
          DetailCard(icon: Icons.book_outlined, label: "Institute Code", value: institute.code),
          DetailCard(icon: Icons.location_on_outlined, label: "Address", value: institute.address),
          DetailCard(icon: Icons.email_outlined, label: "Email", value: institute.email),
          DetailCard(icon: Icons.phone_outlined, label: "Phone Number", value: institute.phone),
          DetailCard(icon: Icons.web_outlined, label: "Website", value: institute.website),
          DetailCard(icon: Icons.corporate_fare_outlined, label: "Affiliation", value: institute.affiliation),
          DetailCard(icon: Icons.credit_card_outlined, label: "Pan", value: institute.pan),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D1B2A),
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    institute.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(18)),
                  ),
                ),
                InkWell(
                    onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ModeratorDashboardPage())),
                    child: const Icon(
                      Icons.home_sharp,
                      size: 30,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 16, screenWidth * 0.04, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        height: screenWidth * 0.25,
                        width: screenWidth * 0.25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1B263B),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Icon(
                          Icons.school_outlined,
                          size: screenWidth * 0.15,
                           color: Colors.white70,
                        )),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(institute.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: responsiveFontSize(22),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Status: ",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: responsiveFontSize(14),
                            fontWeight: FontWeight.bold)),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.green,
                          ),
                          child: Text("Active",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsiveFontSize(12),
                                      color: Colors.white))),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  LayoutBuilder(builder: (context, constraints) {
                    if (constraints.maxWidth > 700) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: detailItems.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3.5, // Adjust for content
                        ),
                        itemBuilder: (context, index) => detailItems[index],
                      );
                    } else {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: detailItems.length,
                        itemBuilder: (context, index) => detailItems[index],
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                      );
                    }
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1B263B),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF0E86D4),
            size: responsiveFontSize(28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(13)),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveFontSize(15),
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
