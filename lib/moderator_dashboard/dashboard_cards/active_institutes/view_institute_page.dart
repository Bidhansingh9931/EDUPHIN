import 'dart:async';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../institute/institute_model.dart';

// 1. Data Provider to fetch live institute details
class InstituteDetailProvider {
  Future<Institute> fetchInstituteDetails(String instituteId) async {
    return ApiService.getInstituteDetails(instituteId);
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    Widget buildScaffold(String title, Widget body) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title, style: TextStyle(fontSize: context.font(20))),
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
          return buildScaffold("Error", Padding(
            padding: context.pagePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, color: colorScheme.error, size: context.scale(48)),
                SizedBox(height: context.md),
                Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: colorScheme.error)),
                SizedBox(height: context.lg),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _instituteFuture = _provider.fetchInstituteDetails(widget.instituteId);
                  }),
                  child: const Text("Retry"),
                )
              ],
            ),
          ));
        } else if (!snapshot.hasData) {
          return buildScaffold("Not Found", const Text('Institute not found.'));
        }

        final institute = snapshot.data!;

        final logoUrl = ApiService.getStorageUrl(institute.logo);

        Color getStatusColor(String status) {
          switch (status.toLowerCase()) {
            case 'active':
              return Colors.greenAccent[700]!;
            case 'inactive':
              return colorScheme.error;
            case 'pending':
              return Colors.orangeAccent[700]!;
            default:
              return colorScheme.outline;
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
          appBar: AppBar(
            title: Text(institute.name, style: TextStyle(fontSize: context.font(20))),
            actions: [
              IconButton(
                onPressed: () => Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => const ModeratorDashboardPage())
                ),
                icon: Icon(Icons.home_rounded, size: context.scale(24)),
              ),
              SizedBox(width: context.md),
            ],
          ),
          body: SingleChildScrollView(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: ProfileAvatar(
                        imageUrl: logoUrl,
                        radius: context.scale(60),
                      ),
                    ),
                    SizedBox(height: context.md),
                    Text(
                      institute.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: context.font(24), fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    SizedBox(height: context.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Status: ",
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14)),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(4)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(context.scale(30)),
                            color: getStatusColor(institute.status).withValues(alpha: 0.1),
                            border: Border.all(color: getStatusColor(institute.status).withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            institute.status.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: getStatusColor(institute.status)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.lg),
                    LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: detailItems.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: context.md,
                            mainAxisSpacing: context.md,
                            mainAxisExtent: context.scale(100),
                          ),
                          itemBuilder: (context, index) => detailItems[index],
                        );
                      } else {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: detailItems.length,
                          itemBuilder: (context, index) => detailItems[index],
                          separatorBuilder: (context, index) => SizedBox(height: context.md),
                        );
                      }
                    }),
                    SizedBox(height: context.xl),
                  ],
                ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.scale(16)),
        color: colorScheme.surfaceContainerLow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(context.sm),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.scale(12)),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: context.scale(24),
            ),
          ),
          SizedBox(width: context.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                ),
                SizedBox(height: context.xs),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: context.font(14),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface),
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


