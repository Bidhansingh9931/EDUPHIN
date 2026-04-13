import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'counselor_models.dart';

class VirtualIdCardPage extends StatefulWidget {
  const VirtualIdCardPage({super.key});

  @override
  State<VirtualIdCardPage> createState() => _VirtualIdCardPageState();
}

class _VirtualIdCardPageState extends State<VirtualIdCardPage> {
  bool _isLoading = true;
  UserDetail? _userDetail;

  @override
  void initState() {
    super.initState();
    _fetchIdData();
  }

  Future<void> _fetchIdData() async {
    if (!mounted) return;
    try {
      final response = await ApiService.get('counselor/virtual-id-card');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _userDetail = UserDetail.fromJson(data['userDetail']);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital ID Card"),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.primaryContainer],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.school, color: Colors.white, size: 40),
                            const SizedBox(height: 12),
                            const Text(
                              "IIAS",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 2),
                            ),
                            Text(
                              "Indian Institute of Applied Sciences",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              backgroundImage: const AssetImage('assets/images/girl_image.webp'),
                              foregroundImage: _userDetail?.photo != null && _userDetail!.photo!.isNotEmpty
                                  ? NetworkImage(ApiService.getStorageUrl(_userDetail!.photo))
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(_userDetail?.fullName ?? "Counselor Name", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                            Text((_userDetail?.position ?? "Counselor").toUpperCase(), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                            const SizedBox(height: 24),
                            _buildInfoRow(context, "Employee ID", _userDetail?.employeeId ?? "N/A"),
                            _buildInfoRow(context, "Joining Date", _userDetail?.joiningDate ?? "N/A"),
                            _buildInfoRow(context, "Status", _userDetail?.status ?? "Active", isLast: true),
                            const SizedBox(height: 24),
                            Container(
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.qr_code_2, size: 40, color: theme.hintColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text("DOWNLOAD ID"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.print),
                        label: const Text("PRINT CARD"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isLast = false}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.hintColor, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
