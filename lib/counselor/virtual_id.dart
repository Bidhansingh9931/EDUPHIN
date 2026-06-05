import 'dart:math';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/pdf_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/caching_service.dart';
import 'counselor_models.dart';

class VirtualIdCardPage extends StatefulWidget {
  const VirtualIdCardPage({super.key});

  @override
  State<VirtualIdCardPage> createState() => _VirtualIdCardPageState();
}

class _VirtualIdCardPageState extends State<VirtualIdCardPage> {
  bool _isLoading = true;
  CounselorVirtualIdCardData? _idData;
  bool _isFront = true;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchIdData();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData('counselor_virtual_id');
    if (cachedData != null && mounted) {
      setState(() {
        _idData = CounselorVirtualIdCardData.fromJson(cachedData);
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchIdData() async {
    if (!mounted) return;
    if (_idData == null) {
      setState(() => _isLoading = true);
    }
    try {
      final json = await ApiService.getCounselorVirtualIdCard();
      await CachingService.saveData('counselor_virtual_id', json);
      final data = CounselorVirtualIdCardData.fromJson(json);
      if (mounted) {
        setState(() {
          _idData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleFlip() {
    setState(() {
      _isFront = !_isFront;
      _rotation = _isFront ? 0 : pi;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            "Digital ID Card",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return LoadingWrapper(
            isLoading: _isLoading,
            hasData: _idData != null,
            skeleton: _buildSkeleton(context, constraints),
            onRefresh: _fetchIdData,
            child: _idData == null
                ? const Center(child: Text("No data found"))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: context.pagePadding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 800,
                          minHeight: constraints.maxHeight - (context.spacing * 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: context.scale(10)),
                            
                            // 3D Flip Animation
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: _rotation),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutBack,
                                builder: (context, value, child) {
                                  final isBack = value > (pi / 2);
                                  return Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001) // Perspective
                                      ..rotateY(value),
                                    alignment: Alignment.center,
                                    child: isBack
                                        ? Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.identity()..rotateY(pi),
                                            child: _buildBackSide(context),
                                          )
                                        : _buildFrontSide(context),
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: context.scale(30)),
                            _buildActionButtons(context),
                            SizedBox(height: context.scale(20)),
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

  Widget _buildSkeleton(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight - (context.spacing * 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Skeleton(
                width: context.scale(320),
                height: context.scale(500),
                borderRadius: context.scale(24),
              ),
              SizedBox(height: context.scale(40)),
              Skeleton(height: context.scale(50), borderRadius: context.scale(12)),
              SizedBox(height: context.scale(16)),
              Skeleton(height: context.scale(50), borderRadius: context.scale(12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontSide(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final data = _idData!;

    return Container(
      width: context.scale(320),
      height: context.scale(500),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.scale(24)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.9)],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -context.scale(20),
            top: -context.scale(20),
            child: Icon(Icons.security, size: context.scale(150), color: colorScheme.onPrimary.withValues(alpha: 0.05)),
          ),
          
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.scale(24), vertical: context.scale(16)),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(24))),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.scale(6)),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(context.scale(8)),
                      ),
                      child: InstituteLogo(
                        logoUrl: data.instituteLogo,
                        size: context.scale(24),
                      ),
                    ),
                    SizedBox(width: context.scale(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.instituteName ?? "EDUPHIN ACADEMY",
                            style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w900, fontSize: context.font(14), letterSpacing: 1),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "COUNSELOR IDENTIFICATION",
                              style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.7), fontSize: context.font(9), fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.scale(12)),

              ProfileAvatar(
                imageUrl: data.photoUrl != null && data.photoUrl!.isNotEmpty
                    ? ApiService.getStorageUrl(data.photoUrl)
                    : null,
                radius: context.scale(60),
              ),

              SizedBox(height: context.scale(8)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.scale(16)),
                child: Text(
                  data.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: context.font(20), letterSpacing: 0.5),
                ),
              ),
              SizedBox(height: context.scale(4)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(4)),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(context.scale(20)),
                ),
                child: Text(
                  (data.position ?? "COUNSELOR").toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: context.font(11), letterSpacing: 1.5),
                ),
              ),

              const Spacer(),

              Container(
                margin: EdgeInsets.symmetric(horizontal: context.scale(24), vertical: context.scale(8)),
                padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(8)),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(context.scale(16)),
                  border: Border.all(color: colorScheme.onPrimary.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    _buildIdRow(context, "EMPLOYEE ID", data.employeeId ?? "N/A", "GENDER", data.gender ?? "N/A"),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: context.scale(8)),
                      child: Divider(color: colorScheme.onPrimary.withValues(alpha: 0.2), height: 1),
                    ),
                    _buildIdRow(context, "JOINING DATE", data.joiningDate ?? "N/A", "STATUS", data.status ?? "Active"),
                  ],
                ),
              ),
              
              SizedBox(height: context.scale(8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackSide(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final data = _idData!;
    
    return Container(
      width: context.scale(320),
      height: context.scale(500),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.scale(24)),
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [colorScheme.primaryContainer, colorScheme.primary],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: context.scale(24)),
          Text("TERMS & CONDITIONS", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: context.font(14), letterSpacing: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.scale(32), vertical: context.scale(16)),
            child: Text(
              "This card is the property of ${data.instituteName ?? 'Eduphin Academy'}. If found, please return it to the nearest administration office.\n\nUnauthorized use or duplication of this document is a punishable offense under institutional policy.",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.7), fontSize: context.font(11), height: 1.6),
            ),
          ),
          const Spacer(),
          
          Container(
            padding: EdgeInsets.all(context.scale(12)),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(context.scale(12)),
            ),
            child: Icon(Icons.qr_code_2_rounded, size: context.scale(80), color: colorScheme.primary),
          ),
          
          const Spacer(),
          
          Text("EMERGENCY CONTACT", style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.9), fontWeight: FontWeight.bold, fontSize: context.font(11), letterSpacing: 1)),
          SizedBox(height: context.scale(4)),
          Text(data.emergencyContactPhone ?? data.institutePhone ?? "N/A", style: TextStyle(color: colorScheme.onPrimary, fontSize: context.font(16), fontWeight: FontWeight.bold)),
          
          SizedBox(height: context.scale(24)),
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: context.scale(16)),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(context.scale(24))),
            ),
            child: Center(
              child: Text(data.instituteWebsite ?? "www.eduphin.com", style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.5), fontSize: context.font(12), letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdRow(BuildContext context, String label1, String value1, String label2, String value2) {
    final colorScheme = context.theme.colorScheme;
    return Row(
      children: [
        Expanded(child: _buildInfoItem(context, label1, value1)),
        SizedBox(width: context.scale(12)),
        Container(width: 1, height: context.scale(30), color: colorScheme.onPrimary.withValues(alpha: 0.2)),
        SizedBox(width: context.scale(12)),
        Expanded(child: _buildInfoItem(context, label2, value2)),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    final colorScheme = context.theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.7), fontSize: context.font(9), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        SizedBox(height: context.scale(2)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: TextStyle(color: colorScheme.onPrimary, fontSize: context.font(12), fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _toggleFlip,
            icon: Icon(Icons.flip_camera_android_rounded, size: context.scale(20)),
            label: FittedBox(child: Text(_isFront ? "VIEW BACK SIDE" : "VIEW FRONT SIDE")),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              padding: EdgeInsets.symmetric(vertical: context.scale(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
            ),
          ),
        ),
        SizedBox(height: context.scale(16)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => PdfService.generateAndPrintIdCard(_idData!),
            icon: Icon(Icons.download, size: context.scale(20)),
            label: FittedBox(child: Text("DOWNLOAD ID", style: TextStyle(fontSize: context.font(14)))),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: context.scale(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
            ),
          ),
        ),
      ],
    );
  }
}


