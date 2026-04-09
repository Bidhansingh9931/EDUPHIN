import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/responsive_helper.dart';
import '../staff/staff_dashboard/staff_models.dart';

class LibrarianVirtualIdCardPage extends StatefulWidget {
  const LibrarianVirtualIdCardPage({super.key});

  @override
  State<LibrarianVirtualIdCardPage> createState() => _LibrarianVirtualIdCardPageState();
}

class _LibrarianVirtualIdCardPageState extends State<LibrarianVirtualIdCardPage> {
  late Future<StaffVirtualIdCardData> _idCardFuture;

  @override
  void initState() {
    super.initState();
    _idCardFuture = ApiService.getLibrarianVirtualIdCard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Virtual ID Card")),
      body: FutureBuilder<StaffVirtualIdCardData>(
        future: _idCardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No ID card data found"));
          }

          final data = snapshot.data!;
          final user = data.user;
          final detail = data.userDetail;

          return Center(
            child: SingleChildScrollView(
              padding: context.pagePadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: theme.colorScheme.primary,
                        child: const Column(
                          children: [
                            Icon(Icons.school, color: Colors.white, size: 50),
                            SizedBox(height: 10),
                            Text(
                              "EDUPHIN ACADEMY",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Profile Info
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              backgroundImage: detail.photo != null ? NetworkImage("${ApiService.baseImageUrl}/storage/${detail.photo}") : null,
                              child: detail.photo == null ? Icon(Icons.person, size: 60, color: theme.colorScheme.primary) : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.name,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "LIBRARIAN",
                              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, letterSpacing: 2),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(Icons.badge, "Employee ID", "LIB-${user.id.toString().padLeft(4, '0')}"),
                            _buildInfoRow(Icons.email, "Email", user.email),
                            _buildInfoRow(Icons.phone, "Phone", detail.phone ?? "N/A"),
                            _buildInfoRow(Icons.location_on, "Address", detail.address ?? "N/A"),
                          ],
                        ),
                      ),

                      // Footer/Barcode Placeholder
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Column(
                          children: [
                             Icon(Icons.qr_code_2, size: 60, color: theme.colorScheme.onSurfaceVariant),
                             const SizedBox(height: 4),
                             Text("LIB-${user.id.toString().padLeft(4, '0')}", style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
