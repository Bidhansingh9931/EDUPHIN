import 'dart:math';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/pdf_service.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/student/student_virtual_id_model.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/responsive_helper.dart';

class ViewVirtualIdCard extends StatelessWidget {
  const ViewVirtualIdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentCardPage();
  }
}

class StudentCardPage extends StatefulWidget {
  const StudentCardPage({super.key});

  @override
  State<StudentCardPage> createState() => _StudentCardPageState();
}

class _StudentCardPageState extends State<StudentCardPage> {
  bool isLoading = true;
  String? errorMessage;
  StudentVirtualIdData? idData;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchIdCardData();
  }

  Future<void> _loadCachedData() async {
    final cached = await CacheService.getData('student_id_card');
    if (cached != null && mounted) {
      setState(() {
        idData = StudentVirtualIdData.fromJson(cached);
        isLoading = false;
      });
    }
  }

  Future<void> _fetchIdCardData() async {
    if (idData == null) setState(() => isLoading = true);
    try {
      final data = await ApiService.getStudentVirtualIdCard();
      if (mounted) {
        setState(() {
          idData = data;
          isLoading = false;
        });
        CacheService.saveData('student_id_card', data.toJson());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          ErrorHandler.showError(context, e);
          if (idData == null) errorMessage = ErrorHandler.getMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final student = idData?.student;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Virtual ID Card",
          style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold),
        ),
      ),
      body: LoadingWrapper(
        isLoading: isLoading,
        hasData: idData != null,
        error: errorMessage,
        skeleton: const _IdCardSkeleton(),
        onRetry: () {
          setState(() {
            isLoading = true;
            errorMessage = null;
          });
          _fetchIdCardData();
        },
        onRefresh: _fetchIdCardData,
        child: RefreshIndicator(
          onRefresh: _fetchIdCardData,
          color: theme.colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: context.pagePadding,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    /// TOP CARD (The actual ID Card look)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(20)),
                        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      color: theme.colorScheme.surfaceContainerLow,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(context.scale(28)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(context.scale(20)),
                        ),
                        child: Column(
                          children: [
                            /// Institute Header
                            InstituteLogo(
                              logoUrl: idData?.instituteLogo,
                              size: context.scale(52),
                            ),
                            SizedBox(height: context.md),
                            Text(
                              idData?.instituteName ?? "Indian Institute of Applied Sciences (IIAS)",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: context.font(20),
                              ),
                            ),
                            SizedBox(height: context.xs),
                            Text("Est. 2025", style: TextStyle(fontSize: context.font(11), color: theme.colorScheme.onSurfaceVariant)),
                            Text(idData?.institutePhone ?? "9876543210", style: TextStyle(fontSize: context.font(11), color: theme.colorScheme.onSurfaceVariant)),
                            SizedBox(height: context.xs),
                            Text(
                              idData?.instituteAddress ?? "Plot No. 88, Knowledge Park, Mock Industrial Estate, Delhi, New Delhi 102030",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: context.font(11),
                              ),
                            ),
                            SizedBox(height: context.md),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(6)),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(context.scale(20)),
                              ),
                              child: Text(
                                "Academic Year: ${student?.academicYear ?? "2025"}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: context.font(12),
                                ),
                              ),
                            ),
                            SizedBox(height: context.lg),
                            Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                            SizedBox(height: context.lg),

                            /// Photo
                            ProfileAvatar(
                              imageUrl: ApiService.getStorageUrl(student?.profileImage),
                              radius: context.scale(60),
                            ),
                            SizedBox(height: context.lg),

                            /// Student Details
                            _buildDetail(context, "Name:", "${student?.firstName ?? ""} ${student?.lastName ?? ""}"),
                            _buildDetail(context, "Roll No:", student?.studentRollNo ?? "N/A"),
                            _buildDetail(context, "DOB:", student?.dob ?? "N/A"),
                            _buildDetail(context, "Contact:", student?.mobile ?? "N/A"),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: context.lg),

                    /// STUDENT INFO SECTION
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(20)),
                        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      color: theme.colorScheme.surfaceContainerLow,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(context.scale(16)),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(20))),
                            ),
                            child: Center(
                              child: Text(
                                "Student Information",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(context.scale(24)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(context, "Address"),
                                Text(
                                  "${student?.addressLine1 ?? ""}\n${student?.city ?? ""}, ${student?.state ?? ""} - ${student?.pincode ?? ""}\n${student?.country ?? ""}",
                                  style: TextStyle(fontSize: context.font(14)),
                                ),
                                SizedBox(height: context.lg),
                                _sectionTitle(context, "Guardian Details"),
                                _infoRow(context, "Guardian Name", student?.guardianFirstName ?? "N/A"),
                                _infoRow(context, "Guardian Mobile", student?.guardianMobile ?? "N/A"),
                                SizedBox(height: context.lg),
                                _sectionTitle(context, "Institute Information"),
                                _infoRow(context, "Institute Code", idData?.institutePhone != null ? "IIAS-${idData!.institutePhone!.substring(0, min(4, idData!.institutePhone!.length))}" : "IIAS-MOCK-001"),
                                _infoRow(context, "Website", idData?.instituteWebsite ?? "https://eduphin.com"),
                                _infoRow(context, "Email", idData?.instituteEmail ?? "contact@eduphin.com"),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: context.xl),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        ),
                        onPressed: () {
                          if (idData != null) {
                            PdfService.generateAndPrintIdCard(idData);
                          }
                        },
                        icon: Icon(Icons.download, size: context.scale(20)),
                        label: Text("DOWNLOAD PDF", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                      ),
                    ),
                    SizedBox(height: context.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, String label, String value) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scale(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.scale(100),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: context.font(14),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: context.font(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(8)),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: context.font(14), color: context.theme.colorScheme.onSurface),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            fontSize: context.font(14),
          ),
        ),
        Divider(height: context.scale(20), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ],
    );
  }
}

class _IdCardSkeleton extends StatelessWidget {
  const _IdCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              SkeletonBox(height: context.scale(500), width: double.infinity, borderRadius: context.scale(20)),
              SizedBox(height: context.lg),
              SkeletonBox(height: context.scale(300), width: double.infinity, borderRadius: context.scale(20)),
              SizedBox(height: context.xl),
              SkeletonBox(height: context.scale(55), width: double.infinity, borderRadius: context.scale(12)),
            ],
          ),
        ),
      ),
    );
  }
}
