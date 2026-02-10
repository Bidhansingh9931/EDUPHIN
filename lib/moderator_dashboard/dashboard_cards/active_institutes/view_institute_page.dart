import 'dart:async';
import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/institutes.dart';
import 'package:flutter/material.dart';

// 1. Data Provider to fetch live institute details
class InstituteDetailProvider {
  Future<Institute> fetchInstituteDetails(String instituteId) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/moderator/institutes/$instituteId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        // Uses the same Institute model from institutes.dart
        return Institute.fromJson(responseBody['data']);
      } else {
        throw Exception('Failed to parse institute data from API.');
      }
    } else {
      throw Exception('Failed to load institute details. Status code: ${response.statusCode}');
    }
  }
}

// 2. StatefulWidget to be dynamic
class ViewInstitutePage extends StatefulWidget {
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

    Widget buildScaffold(String title, Widget body) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1B2A),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(title, style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(18))),
        ),
        body: Center(child: body),
      );
    }

    // 3. Use FutureBuilder to handle loading and displaying real data
    return FutureBuilder<Institute>(
      future: _instituteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildScaffold("Loading...", const CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return buildScaffold("Error", Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)));
        } else if (!snapshot.hasData) {
          return buildScaffold("Not Found", const Text('Institute not found.', style: TextStyle(color: Colors.white70)));
        }

        final institute = snapshot.data!;

        // Helper to construct the full image URL
        String? getLogoUrl(String? path) {
          if (path == null || path.isEmpty) return null;
          final baseUrl = ApiService.baseUrl.replaceAll('/api', ''); // Get the root URL
          return '$baseUrl/storage/$path';
        }

        final logoUrl = getLogoUrl(institute.logo);

        Color getStatusColor(String status) {
          switch (status.toLowerCase()) {
            case 'active':
              return Colors.green.shade600;
            case 'inactive':
              return Colors.red.shade600;
            case 'pending':
              return Colors.orange.shade600;
            default:
              return Colors.grey.shade600;
          }
        }

        final detailItems = [
          DetailCard(icon: Icons.person_outline_sharp, label: "Chairman", value: institute.chairmanName),
          DetailCard(icon: Icons.book_outlined, label: "Institute Code", value: institute.code),
          DetailCard(icon: Icons.calendar_today_outlined, label: "Established", value: institute.establishedYear.toString()),
          DetailCard(icon: Icons.location_on_outlined, label: "Address", value: '${institute.address}, ${institute.city}, ${institute.state} - ${institute.pincode}'),
          DetailCard(icon: Icons.email_outlined, label: "Email", value: institute.contactEmail),
          DetailCard(icon: Icons.phone_outlined, label: "Phone Number", value: institute.contactPhone),
          DetailCard(icon: Icons.web_outlined, label: "Website", value: institute.website ?? 'N/A'),
          DetailCard(icon: Icons.corporate_fare_outlined, label: "Affiliation", value: institute.affiliationDetails ?? 'N/A'),
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
                      context, MaterialPageRoute(builder: (context) => const ModeratorDashboardPage())),
                  child: const Icon(Icons.home_sharp, size: 30, color: Colors.white),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 16, screenWidth * 0.04, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: screenWidth * 0.25,
                      width: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1B263B),
                        border: Border.all(color: Colors.white24),
                        image: logoUrl != null 
                            ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      child: logoUrl == null
                          ? Icon(Icons.school_outlined, size: screenWidth * 0.15, color: Colors.white70)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    institute.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(22), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Status: ",
                        style: TextStyle(color: Colors.white70, fontSize: responsiveFontSize(14)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: getStatusColor(institute.status),
                        ),
                        child: Text(
                          institute.status.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: responsiveFontSize(12), color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                          childAspectRatio: 4, // Adjust for content
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
