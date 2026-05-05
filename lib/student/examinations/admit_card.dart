import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
  static const String _cacheKey = 'student_admit_cards';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchAdmitCards();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _registrations = cachedData as List? ?? [];
        if (_registrations.isNotEmpty) {
          _isLoading = false;
        }
      });
    }
  }

  Future<void> _fetchAdmitCards() async {
    if (_registrations.isEmpty) setState(() => _isLoading = true);
    try {
      final data = await ApiService.getAdmitCards();
      if (mounted) {
        setState(() {
          _registrations = data;
          _isLoading = false;
        });
        CacheService.saveData(_cacheKey, data);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _fetchAdmitCardDetails(dynamic registration) async {
    final theme = context.theme;
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
        ErrorHandler.showError(context, e);
      }
    }
  }

  void _handlePrintAdmitCard(dynamic details) {
    if (details == null) return;
    PdfService.generateAdmitCardPdf(details);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Admit Cards",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontSize: context.font(20),
          ),
        ),
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _registrations.isNotEmpty,
        skeleton: const _AdmitCardSkeleton(),
        onRefresh: _fetchAdmitCards,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: _registrations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.badge_outlined, size: context.scale(64), color: colorScheme.outlineVariant),
                        SizedBox(height: context.scale(16)),
                        Text("No registered exams found",
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(16))),
                      ],
                    ),
                  )
                : context.responsive(
                    ListView.separated(
                      padding: context.pagePadding,
                      itemCount: _registrations.length,
                      separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
                      itemBuilder: (context, index) => _buildItem(index),
                    ),
                    tablet: GridView.builder(
                      padding: context.pagePadding,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: context.scale(20),
                        mainAxisSpacing: context.scale(20),
                        mainAxisExtent: context.scale(550),
                      ),
                      itemCount: _registrations.length,
                      itemBuilder: (context, index) => _buildItem(index),
                    ),
                    desktop: GridView.builder(
                      padding: context.pagePadding,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: context.scale(24),
                        mainAxisSpacing: context.scale(24),
                        mainAxisExtent: context.scale(600),
                      ),
                      itemCount: _registrations.length,
                      itemBuilder: (context, index) => _buildItem(index),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
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
  }

  Widget _buildExamCard(dynamic registration, dynamic exam, bool open, VoidCallback onTap) {
    if (exam == null) return const SizedBox.shrink();
    final theme = context.theme;

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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: open ? theme.colorScheme.primary : theme.colorScheme.outlineVariant),
        boxShadow: [
          if (open) BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(context.scale(16)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(16)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam['name'] ?? 'Exam Name',
                          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(16)),
                        ),
                        SizedBox(height: context.scale(4)),
                        Text(
                          exam['type'] ?? "Written Examination",
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.scale(12)),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(context.scale(6)),
                        ),
                        child: Text(
                          formattedRange,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: context.font(9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: context.scale(2)),
                      Icon(
                        open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: context.scale(18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// DETAILS
          if (open)
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(context.scale(20), 0, context.scale(20), context.scale(20)),
                child: loadingDetails
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: context.scale(32.0)),
                        child: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
                      )
                    : details == null
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: context.scale(20.0)),
                            child: Center(child: Text("Failed to load details", style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14)))),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(color: theme.colorScheme.outlineVariant, height: 1),
                              SizedBox(height: context.scale(16)),
                              if (details['institute'] != null) ...[
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        details['institute']['name']?.toString().toUpperCase() ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(15), fontWeight: FontWeight.w800),
                                      ),
                                      SizedBox(height: context.scale(4)),
                                      Text(
                                        details['institute']['address'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11)),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: context.scale(20)),
                              ],

                              _buildInfoSection("Student Information", [
                                _buildDetailRow("Student Name", details['student']?['user']?['name']),
                                _buildDetailRow("Roll Number", details['student']?['roll_no']),
                                _buildDetailRow("Class / Section", "${details['student']?['class']?['name'] ?? ''} - ${details['student']?['section']?['name'] ?? ''}"),
                              ]),

                              SizedBox(height: context.scale(24)),

                              /// PAPER SCHEDULE
                              Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
                                  SizedBox(width: context.scale(10)),
                                  Text(
                                    "Paper Schedule",
                                    style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(14)),
                                  )
                                ],
                              ),
                              SizedBox(height: context.scale(16)),

                              /// TABLE
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(context.scale(12)),
                                  border: Border.all(color: theme.colorScheme.outlineVariant),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                    /// TABLE HEADER
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(12)),
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      child: Row(
                                        children: [
                                          Expanded(flex: 2, child: Text("Subject", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(11), fontWeight: FontWeight.bold))),
                                          Expanded(flex: 1, child: Text("Date", textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(11), fontWeight: FontWeight.bold))),
                                          Expanded(flex: 2, child: Text("Time", textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(11), fontWeight: FontWeight.bold))),
                                          Expanded(flex: 1, child: Text("Venue", textAlign: TextAlign.right, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(11), fontWeight: FontWeight.bold))),
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
                                        padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(12)),
                                        decoration: BoxDecoration(
                                          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(flex: 2, child: Text(subject, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(10), fontWeight: FontWeight.w500))),
                                            Expanded(flex: 1, child: Text(date, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(10)))),
                                            Expanded(flex: 2, child: Text(time, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(10)))),
                                            Expanded(flex: 1, child: Text(venue, textAlign: TextAlign.right, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(10)))),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),

                              SizedBox(height: context.scale(24)),

                              /// PRINT BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: context.scale(50),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                    elevation: 0,
                                  ),
                                  onPressed: () => _handlePrintAdmitCard(details),
                                  icon: Icon(Icons.file_download_outlined, size: context.scale(20)),
                                  label: Text(
                                    "DOWNLOAD ADMIT CARD",
                                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: context.font(14)),
                                  ),
                                ),
                              )
                            ],
                          ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(12), letterSpacing: 1),
        ),
        SizedBox(height: context.scale(12)),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
          ),
          SizedBox(width: context.scale(16)),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              textAlign: TextAlign.right,
              style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: context.font(13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdmitCardSkeleton extends StatelessWidget {
  const _AdmitCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: context.pagePadding,
      itemCount: 4,
      separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
      itemBuilder: (context, index) => Container(
        padding: EdgeInsets.all(context.scale(20)),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(context.scale(16)),
          border: Border.all(color: context.theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: context.scale(150), height: context.scale(16), borderRadius: context.scale(4)),
                  SizedBox(height: context.scale(8)),
                  SkeletonBox(width: context.scale(120), height: context.scale(12), borderRadius: context.scale(4)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonBox(width: context.scale(80), height: context.scale(16), borderRadius: context.scale(4)),
                SizedBox(height: context.scale(8)),
                Icon(Icons.keyboard_arrow_down, color: context.theme.colorScheme.outlineVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
