import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/api_service.dart';
import '../../services/pdf_service.dart';
import 'staff_models.dart';

class StaffVirtualIdCard extends StatefulWidget {
  const StaffVirtualIdCard({super.key});

  @override
  State<StaffVirtualIdCard> createState() => _StaffVirtualIdCardState();
}

class _StaffVirtualIdCardState extends State<StaffVirtualIdCard> {
  late Future<StaffVirtualIdCardData> _idCardFuture;
  bool _isFront = true;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _idCardFuture = ApiService.getStaffVirtualIdCard();
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Staff ID Card"),
      ),
      body: FutureBuilder<StaffVirtualIdCardData>(
        future: _idCardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colorScheme.primary));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: context.pagePadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.error, size: context.scale(48)),
                    SizedBox(height: context.scale(16)),
                    Text('Failed to load ID card details', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14))),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found', style: TextStyle(color: colorScheme.onSurfaceVariant)));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    SizedBox(height: context.scale(20)),
                    
                    // 3D Flip Animation
                    TweenAnimationBuilder<double>(
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
                                  child: _buildBackSide(context, data),
                                )
                              : _buildFrontSide(context, data),
                        );
                      },
                    ),

                    SizedBox(height: context.scale(40)),
                    _buildActionButtons(context, data),
                    SizedBox(height: context.scale(40)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide(BuildContext context, StaffVirtualIdCardData data) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final user = data.user;
    final detail = data.userDetail;
    final imageUrl = ApiService.getStorageUrl(detail.photo);

    return Container(
      width: context.scale(320),
      height: context.scale(550),
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
                padding: EdgeInsets.all(context.scale(24)),
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
                          Text(data.instituteName ?? "EDUPHIN ACADEMY", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w900, fontSize: context.font(14), letterSpacing: 1)),
                          Text(data.instituteAddress ?? "STAFF IDENTIFICATION", style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.7), fontSize: context.font(9), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.scale(30)),

              ProfileAvatar(
                imageUrl: imageUrl,
                radius: context.scale(70),
              ),

              SizedBox(height: context.scale(24)),

              Text(
                user.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: context.font(20), letterSpacing: 0.5),
              ),
              SizedBox(height: context.scale(4)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(4)),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(context.scale(20)),
                ),
                child: Text(
                  (data.roleName ?? "STAFF MEMBER").toUpperCase(),
                  style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: context.font(11), letterSpacing: 1.5),
                ),
              ),

              const Spacer(),

              Container(
                margin: EdgeInsets.all(context.scale(24)),
                padding: EdgeInsets.all(context.scale(20)),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(context.scale(16)),
                  border: Border.all(color: colorScheme.onPrimary.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    _buildRowInfo(context, "STAFF ID", "STF-${user.id.toString().padLeft(4, '0')}", "GENDER", detail.gender ?? "N/A"),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                      child: Divider(color: colorScheme.onPrimary.withValues(alpha: 0.2), height: 1),
                    ),
                    _buildRowInfo(context, "JOIN DATE", detail.dateOfJoining ?? "N/A", "PHONE", detail.phone ?? "N/A"),
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

  Widget _buildBackSide(BuildContext context, StaffVirtualIdCardData data) {
    final colorScheme = context.theme.colorScheme;
    
    return Container(
      width: context.scale(320),
      height: context.scale(550),
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
          SizedBox(height: context.scale(40)),
          Text("TERMS & CONDITIONS", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: context.font(14), letterSpacing: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.scale(32), vertical: context.scale(24)),
            child: Text(
              "This card is the property of ${data.instituteName ?? 'the Academy'}. If found, please return it to the nearest administration office.\n\nUnauthorized use or duplication of this document is a punishable offense under institutional policy.",
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
            child: Icon(Icons.qr_code_2_rounded, size: context.scale(100), color: colorScheme.primary),
          ),
          
          const Spacer(),
          
          Text("EMERGENCY CONTACT", style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.9), fontWeight: FontWeight.bold, fontSize: context.font(11), letterSpacing: 1)),
          SizedBox(height: context.scale(4)),
          Text(data.institutePhone ?? "+1 234 567 890", style: TextStyle(color: colorScheme.onPrimary, fontSize: context.font(16), fontWeight: FontWeight.bold)),
          
          SizedBox(height: context.scale(40)),
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: context.scale(24)),
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

  Widget _buildRowInfo(BuildContext context, String label1, String value1, String label2, String value2) {
    final colorScheme = context.theme.colorScheme;
    return Row(
      children: [
        Expanded(child: _buildInfoItem(context, label1, value1)),
        Container(width: 1, height: context.scale(30), color: colorScheme.onPrimary.withValues(alpha: 0.2)),
        SizedBox(width: context.scale(16)),
        Expanded(child: _buildInfoItem(context, label2, value2)),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    final colorScheme = context.theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.7), fontSize: context.font(9), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        SizedBox(height: context.scale(2)),
        Text(value, style: TextStyle(color: colorScheme.onPrimary, fontSize: context.font(12), fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, StaffVirtualIdCardData data) {
    final colorScheme = context.theme.colorScheme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _toggleFlip,
            icon: Icon(Icons.flip_camera_android_rounded, size: context.scale(20)),
            label: Text(_isFront ? "VIEW BACK SIDE" : "VIEW FRONT SIDE"),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              padding: EdgeInsets.symmetric(vertical: context.scale(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
            ),
          ),
        ),
        SizedBox(height: context.scale(16)),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => PdfService.generateAndPrintIdCard(data),
                icon: Icon(Icons.download_for_offline_rounded, size: context.scale(20)),
                label: const Text("DOWNLOAD"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.outline),
                  padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
              ),
            ),
            SizedBox(width: context.scale(12)),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.share_rounded, size: context.scale(20)),
                label: const Text("SHARE"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.outline),
                  padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
