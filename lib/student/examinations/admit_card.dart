import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class AdmitCardPage extends StatefulWidget {
  const AdmitCardPage({super.key});

  @override
  State<AdmitCardPage> createState() => _AdmitCardPageState();
}

class _AdmitCardPageState extends State<AdmitCardPage> {
  List<dynamic> _registrations = [];
  bool _isLoading = true;
  final Map<dynamic, bool> _expandedRegistrations = {};
  final Map<dynamic, dynamic> _admitCardDetails = {};
  final Map<dynamic, bool> _isLoadingDetails = {};

  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);
  final Color _headerRow = const Color(0xff2A3450);

  @override
  void initState() {
    super.initState();
    _fetchAdmitCards();
  }

  Future<void> _fetchAdmitCards() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getAdmitCards();
      setState(() {
        _registrations = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching registered exams: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _fetchAdmitCardDetails(dynamic registration) async {
    final dynamic regId = registration['id'];
    if (regId == null) return;
    if (_admitCardDetails.containsKey(regId)) return;

    // Use plain ID as the backend no longer expects encrypted hashes
    final String idToFetch = regId.toString();

    setState(() => _isLoadingDetails[regId] = true);
    try {
      final details = await ApiService.getAdmitCardDetails(idToFetch);
      setState(() {
        _admitCardDetails[regId] = details;
        _isLoadingDetails[regId] = false;
      });
    } catch (e) {
      setState(() => _isLoadingDetails[regId] = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching admit card details: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handlePrintAdmitCard(dynamic details) {
    if (details == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Download Admit Card", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Would you like to download the Admit Card as PDF?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Downloading Admit Card PDF...")),
              );
            },
            child: Text("DOWNLOAD", style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Admit Cards",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : _registrations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.badge_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      const Text("No registered exams found",
                          style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAdmitCards,
                  color: _primary,
                  backgroundColor: _card,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _registrations.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final registration = _registrations[index];
                      final exam = registration['exam'];
                      final dynamic regId = registration['id'];
                      final bool isOpen = _expandedRegistrations[regId] ?? false;

                      return _buildExamCard(registration, exam, isOpen, () {
                        setState(() {
                          _expandedRegistrations[regId] = !isOpen;
                        });
                        if (!isOpen) {
                          _fetchAdmitCardDetails(registration);
                        }
                      });
                    },
                  ),
                ),
    );
  }

  Widget _buildExamCard(dynamic registration, dynamic exam, bool open, VoidCallback onTap) {
    if (exam == null) return const SizedBox.shrink();

    final startDateStr = exam['start_date'];
    final endDateStr = exam['end_date'];
    String formattedRange = "N/A";
    if (startDateStr != null && endDateStr != null) {
      try {
        DateTime start = DateTime.parse(startDateStr);
        DateTime end = DateTime.parse(endDateStr);
        formattedRange = "${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}";
      } catch (_) {}
    }

    final dynamic regId = registration['id'];
    final details = _admitCardDetails[regId];
    final bool loadingDetails = _isLoadingDetails[regId] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: open ? _primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          if (open) BoxShadow(color: _primary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam['name'] ?? 'Exam Name',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exam['type'] ?? "Written Examination",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          formattedRange,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Icon(
                        open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// DETAILS
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: loadingDetails
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: CircularProgressIndicator(color: _primary)),
                    )
                  : details == null
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: Text("Failed to load details", style: TextStyle(color: Colors.redAccent))),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Colors.white12, height: 1),
                            const SizedBox(height: 16),
                            if (details['institute'] != null) ...[
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      details['institute']['name']?.toString().toUpperCase() ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      details['institute']['address'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            
                            _buildInfoSection("Student Information", [
                              _buildDetailRow("Student Name", details['student']?['user']?['name']),
                              _buildDetailRow("Roll Number", details['student']?['roll_no']),
                              _buildDetailRow("Class / Section", "${details['student']?['class']?['name'] ?? ''} - ${details['student']?['section']?['name'] ?? ''}"),
                            ]),

                            const SizedBox(height: 24),

                            /// PAPER SCHEDULE
                            Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, color: _primary, size: 20),
                                const SizedBox(width: 10),
                                const Text(
                                  "Paper Schedule",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),

                            /// TABLE
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  /// TABLE HEADER
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    color: _headerRow,
                                    child: const Row(
                                      children: [
                                        Expanded(flex: 2, child: Text("Subject", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                                        Expanded(flex: 1, child: Text("Date", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                                        Expanded(flex: 2, child: Text("Time", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                                        Expanded(flex: 1, child: Text("Venue", textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                                      ],
                                    ),
                                  ),

                                  /// TABLE ROWS
                                  ...(details['papers'] as List? ?? []).map((paper) {
                                    final subject = paper['subject']?['name'] ?? 'N/A';
                                    final date = paper['date'] != null
                                        ? DateFormat('dd MMM').format(DateTime.parse(paper['date']))
                                        : 'N/A';
                                    final time = "${paper['start_time'] ?? ''}\n${paper['end_time'] ?? ''}";
                                    final venue = paper['venue'] ?? 'N/A';

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(flex: 2, child: Text(subject, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500))),
                                          Expanded(flex: 1, child: Text(date, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10))),
                                          Expanded(flex: 2, child: Text(time, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10))),
                                          Expanded(flex: 1, child: Text(venue, textAlign: TextAlign.right, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10))),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            /// PRINT BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                onPressed: () => _handlePrintAdmitCard(details),
                                icon: const Icon(Icons.file_download_outlined, size: 20),
                                label: const Text(
                                  "DOWNLOAD ADMIT CARD",
                                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ),
                            )
                          ],
                        ),
            )
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
          ),
          Text(
            value?.toString() ?? 'N/A',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
