import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class RegisteredExamPage extends StatefulWidget {
  const RegisteredExamPage({super.key});

  @override
  State<RegisteredExamPage> createState() => _RegisteredExamPageState();
}

class _RegisteredExamPageState extends State<RegisteredExamPage> {
  List<dynamic> _registrations = [];
  bool _isLoading = true;
  final Map<dynamic, bool> _expandedRegistrations = {};
  final Map<dynamic, dynamic> _admitCardDetails = {};
  final Map<dynamic, bool> _isLoadingDetails = {};

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
          SnackBar(content: Text("Error fetching registered exams: $e")),
        );
      }
    }
  }

  Future<void> _fetchAdmitCardDetails(dynamic registration) async {
    final dynamic regId = registration['id'];
    if (regId == null) return;
    if (_admitCardDetails.containsKey(regId)) return;

    // Try common names for hashed IDs
    final String? hash = registration['id_hash']?.toString() ?? 
                         registration['registration_id_hash']?.toString();
    
    // Fallback to plain ID if hash is missing
    final String idToFetch = hash ?? regId.toString();

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
          SnackBar(content: Text("Error fetching admit card details: $e")),
        );
      }
    }
  }

  void _handlePrintAdmitCard(dynamic details) {
    if (details == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff3c4566),
        title: const Text("Print Admit Card", style: TextStyle(color: Colors.white)),
        content: const Text("Would you like to download the Admit Card as PDF?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Downloading Admit Card PDF...")),
              );
            },
            child: const Text("DOWNLOAD", style: TextStyle(color: Color(0xff2ea44f), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0a1230),
      appBar: AppBar(
        backgroundColor: const Color(0xff0a1230),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Registered Exam",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _registrations.isEmpty
              ? const Center(
                  child: Text("No registered exams found",
                      style: TextStyle(color: Colors.white70)))
              : RefreshIndicator(
                  onRefresh: _fetchAdmitCards,
                  color: const Color(0xff2ea44f),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _registrations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final registration = _registrations[index];
                      final exam = registration['exam'];
                      final dynamic regId = registration['id'];
                      final bool isOpen = _expandedRegistrations[regId] ?? false;

                      return examCard(registration, exam, isOpen, () {
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

  Widget examCard(
      dynamic registration, dynamic exam, bool open, VoidCallback onTap) {
    if (exam == null) return const SizedBox.shrink();

    final startDateStr = exam['start_date'];
    final endDateStr = exam['end_date'];
    String formattedRange = "N/A";
    if (startDateStr != null && endDateStr != null) {
      try {
        DateTime start = DateTime.parse(startDateStr);
        DateTime end = DateTime.parse(endDateStr);
        formattedRange =
            "${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}";
      } catch (_) {}
    }

    final dynamic regId = registration['id'];
    final details = _admitCardDetails[regId];
    final bool loadingDetails = _isLoadingDetails[regId] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff3c4566),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          ListTile(
            title: Text(
              exam['name'] ?? 'Exam Name',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              exam['type'] ?? "Written",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xff5f6a7a),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formattedRange,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 2),
                Icon(
                  open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            onTap: onTap,
          ),

          /// DETAILS
          if (open)
            Padding(
              padding: const EdgeInsets.all(16),
              child: loadingDetails
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : details == null
                      ? const Text("Failed to load details",
                          style: TextStyle(color: Colors.redAccent))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (details['institute'] != null) ...[
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      details['institute']['name']
                                              ?.toString()
                                              .toUpperCase() ??
                                          '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      details['institute']['address'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(color: Colors.white24),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                            const Text(
                              "Admit Card Details",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            detailRow("Student Name",
                                details['student']?['user']?['name']),
                            detailRow("Roll No", details['student']?['roll_no']),
                            detailRow("Class",
                                details['student']?['class']?['name']),
                            detailRow("Section",
                                details['student']?['section']?['name']),
                            const SizedBox(height: 20),

                            /// PAPER SCHEDULE
                            const Row(
                              children: [
                                Icon(Icons.calendar_month,
                                    color: Colors.white70, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  "Paper Schedule",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            const SizedBox(height: 15),

                            /// TABLE HEADER
                            Container(
                              padding: const EdgeInsets.all(10),
                              color: const Color(0xff2f3756),
                              child: const Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text("Subject",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold))),
                                  Expanded(
                                      flex: 1,
                                      child: Text("Date",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold))),
                                  Expanded(
                                      flex: 2,
                                      child: Text("Time",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold))),
                                  Expanded(
                                      flex: 1,
                                      child: Text("Venue",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ),

                            /// TABLE ROWS
                            ...(details['papers'] as List? ?? []).map((paper) {
                              final subject =
                                  paper['subject']?['name'] ?? 'N/A';
                              final date = paper['date'] != null
                                  ? DateFormat('dd MMM yyyy')
                                      .format(DateTime.parse(paper['date']))
                                  : 'N/A';
                              final time =
                                  "${paper['start_time'] ?? ''} - ${paper['end_time'] ?? ''}";
                              final venue = paper['venue'] ?? 'N/A';

                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.white10))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text(subject,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10))),
                                    Expanded(
                                        flex: 1,
                                        child: Text(date,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10))),
                                    Expanded(
                                        flex: 2,
                                        child: Text(time,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10))),
                                    Expanded(
                                        flex: 1,
                                        child: Text(venue,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10))),
                                  ],
                                ),
                              );
                            }).toList(),

                            const SizedBox(height: 20),

                            /// PRINT BUTTON
                            GestureDetector(
                              onTap: () => _handlePrintAdmitCard(details),
                              child: Container(
                                width: double.infinity,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: const Color(0xff2ea44f),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.print,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      "PRINT ADMIT CARD",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
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

  Widget detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
