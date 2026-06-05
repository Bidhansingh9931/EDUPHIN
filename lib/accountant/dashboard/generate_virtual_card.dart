import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/pdf_service.dart';
import 'accountant_dashboard_model.dart';
import 'dart:math' show pi;

class GenerateVirtualCard extends StatefulWidget {
  const GenerateVirtualCard({super.key});

  @override
  State<GenerateVirtualCard> createState() => _GenerateVirtualCardState();
}

class _GenerateVirtualCardState extends State<GenerateVirtualCard> {
  static const Color bgColor = Color(0xFF0F1630);
  static const Color idCardBg = Color(0xFF2C3550);

  late Stream<AccountantVirtualIdCardData> _cardStream;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    _cardStream = ApiService.getAccountantVirtualIdCardStream();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<AccountantVirtualIdCardData>(
      stream: _cardStream,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: isDark ? bgColor : theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  size: context.scale(20)),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Generate Virtual Card",
                  style: TextStyle(
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(18)),
                ),
              ),
            ),
            centerTitle: true,
          ),
          body: LoadingWrapper<AccountantVirtualIdCardData>(
            snapshot: snapshot,
            skeleton: _buildSkeleton(context),
            onRetry: () => setState(() => _cardStream = ApiService.getAccountantVirtualIdCardStream()),
            builder: (data) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.scale(400)),
                  child: Column(
                    children: [
                      SizedBox(height: context.scale(10)),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: isFront ? 0 : pi),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          final content = value <= pi / 2
                              ? _buildIdCardFront(data)
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _buildIdCardBack(data),
                                );

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(value),
                            child: content,
                          );
                        },
                      ),
                      SizedBox(height: context.scale(30)),
                      _buildActionButtons(data),
                      SizedBox(height: context.scale(40)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(400)),
          child: Column(
            children: [
              SizedBox(height: context.scale(10)),
              Skeleton(
                height: context.scale(450),
                width: context.scale(350),
                borderRadius: context.scale(20),
              ),
              SizedBox(height: context.scale(30)),
              Row(
                children: [
                  Expanded(child: Skeleton(height: context.scale(50), borderRadius: 12)),
                  SizedBox(width: context.scale(16)),
                  Expanded(child: Skeleton(height: context.scale(50), borderRadius: 12)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdCardFront(AccountantVirtualIdCardData data) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: context.scale(350)),
      decoration: BoxDecoration(
        color: idCardBg,
        borderRadius: BorderRadius.circular(context.scale(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: context.scale(20),
            offset: Offset(0, context.scale(10)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.scale(50),
                  height: context.scale(50),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.scale(8)),
                    child: InstituteLogo(
                      logoUrl: data.instituteLogo,
                      size: context.scale(30),
                      fallbackIcon: Icons.school,
                      fallbackColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: context.scale(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          data.instituteName ?? "EDUPHIN ACADEMY",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: context.font(14)),
                        ),
                      ),
                      SizedBox(height: context.scale(4)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          data.instituteAddress ?? "Campus Identification Card",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: context.font(10),
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "ACCOUNTANT ID",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: context.font(16)),
            ),
          ),
          SizedBox(height: context.scale(15)),
          ProfileAvatar(
            radius: context.scale(50),
            imageUrl: ApiService.getStorageUrl(data.photoUrl),
          ),
          SizedBox(height: context.scale(20)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: context.scale(20)),
            padding: EdgeInsets.all(context.scale(20)),
            decoration: BoxDecoration(
              color: const Color(0xFF3D4763),
              borderRadius: BorderRadius.circular(context.scale(16)),
            ),
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    data.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: context.font(18)),
                  ),
                ),
                SizedBox(height: context.scale(15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _buildInfoItem("Position", data.position ?? 'N/A'),
                      ),
                    ),
                    SizedBox(width: context.scale(24)),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: _buildInfoItem("Employee ID", data.employeeId ?? 'N/A', isRight: true),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.scale(15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _buildInfoItem("Employment", data.employmentType ?? 'N/A'),
                      ),
                    ),
                    SizedBox(width: context.scale(24)),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: _buildInfoItem("Joining", data.joiningDate ?? 'N/A', isRight: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.scale(15)),
          Container(
            constraints: BoxConstraints(maxWidth: context.scale(310)),
            margin: EdgeInsets.symmetric(horizontal: context.scale(20)),
            padding: EdgeInsets.symmetric(vertical: context.scale(12), horizontal: context.scale(8)),
            decoration: BoxDecoration(
              color: const Color(0xFF4A556E),
              borderRadius: BorderRadius.circular(context.scale(10)),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Authorized Signature",
                  style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: context.font(13)),
                ),
              ),
            ),
          ),
          SizedBox(height: context.scale(20)),
        ],
      ),
    );
  }

  Widget _buildIdCardBack(AccountantVirtualIdCardData data) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: context.scale(350)),
      decoration: BoxDecoration(
        color: idCardBg,
        borderRadius: BorderRadius.circular(context.scale(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: context.scale(20),
            offset: Offset(0, context.scale(10)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: context.scale(30)),
          Icon(Icons.qr_code_2_rounded,
              size: context.scale(150), color: Colors.white),
          SizedBox(height: context.scale(30)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: context.scale(20)),
            padding: EdgeInsets.all(context.scale(20)),
            decoration: BoxDecoration(
              color: const Color(0xFF3D4763),
              borderRadius: BorderRadius.circular(context.scale(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackInfoItem(Icons.phone, "Phone", data.phone ?? 'N/A'),
                SizedBox(height: context.scale(12)),
                _buildBackInfoItem(Icons.email, "Email", data.email ?? 'N/A'),
                SizedBox(height: context.scale(12)),
                _buildBackInfoItem(
                    Icons.location_on, "Address", data.fullAddress ?? 'N/A'),
                SizedBox(height: context.scale(12)),
                _buildBackInfoItem(
                    Icons.contact_emergency,
                    "Emergency Contact",
                    "${data.emergencyContactName ?? 'N/A'} (${data.emergencyContactPhone ?? ''})"),
              ],
            ),
          ),
          SizedBox(height: context.scale(30)),
        ],
      ),
    );
  }

  Widget _buildBackInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: context.scale(16)),
        SizedBox(width: context.scale(12)),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: Colors.white54, fontSize: context.font(10))),
                Text(value,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: context.font(12),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.white70,
              fontSize: context.font(11),
              fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: context.scale(4)),
        Text(
          value,
          style: TextStyle(
              color: Colors.white,
              fontSize: context.font(13),
              fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: isRight ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildActionButtons(AccountantVirtualIdCardData data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.scale(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isFront = !isFront;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F61ED),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.scale(12))),
                elevation: 0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "FLIP CARD",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: context.font(14)),
                ),
              ),
            ),
          ),
          SizedBox(width: context.scale(12)),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => PdfService.generateAndPrintIdCard(data),
              icon: Icon(Icons.picture_as_pdf_rounded, size: context.scale(20)),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "DOWNLOAD",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: context.font(13)),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8D3F5),
                foregroundColor: const Color(0xFF3F61ED),
                padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.scale(12))),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
