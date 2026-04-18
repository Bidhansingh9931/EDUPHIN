import 'package:eduphin/services/common_widgets.dart';
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

  bool _isLoading = true;
  AccountantVirtualIdCardData? _cardData;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    _fetchCardData();
  }

  Future<void> _fetchCardData() async {
    try {
      final data = await ApiService.getAccountantVirtualIdCard();
      if (mounted) {
        setState(() {
          _cardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching card: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgColor : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : theme.colorScheme.onSurface, size: context.scale(20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Generate Virtual Card",
          style: TextStyle(color: isDark ? Colors.white : theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(18)),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cardData == null
              ? Center(child: Text("No data available", style: TextStyle(color: isDark ? Colors.white : theme.colorScheme.onSurface)))
              : SingleChildScrollView(
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
                              // Switch the content at the 90-degree point (pi/2)
                              final content = value <= pi / 2
                                  ? _buildIdCardFront()
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()..rotateY(pi), // Mirror back
                                      child: _buildIdCardBack(),
                                    );

                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001) // Perspective effect
                                  ..rotateY(value),
                                child: content,
                              );
                            },
                          ),
                          SizedBox(height: context.scale(30)),
                          _buildActionButtons(),
                          SizedBox(height: context.scale(40)),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildIdCardFront() {
    return Container(
      width: double.infinity,
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
                      logoUrl: _cardData!.instituteLogo,
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
                    children: [
                      Text(
                        _cardData!.instituteName ?? "EDUPHIN ACADEMY",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: context.font(14)),
                      ),
                      SizedBox(height: context.scale(4)),
                      Text(
                        _cardData!.instituteAddress ?? "Campus Identification Card",
                        style: TextStyle(color: Colors.white70, fontSize: context.font(10), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "ACCOUNTANT ID",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: context.font(16)),
          ),
          SizedBox(height: context.scale(15)),
          ProfileAvatar(
            radius: context.scale(50),
            imageUrl: ApiService.getStorageUrl(_cardData!.photoUrl),
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
                Text(
                  _cardData!.name,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: context.font(18)),
                ),
                SizedBox(height: context.scale(15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem("Position", _cardData!.position ?? 'N/A'),
                    _buildInfoItem("Employee ID", _cardData!.employeeId ?? 'N/A'),
                  ],
                ),
                SizedBox(height: context.scale(15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem("Employment", _cardData!.employmentType ?? 'N/A'),
                    _buildInfoItem("Joining", _cardData!.joiningDate ?? 'N/A'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.scale(15)),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: context.scale(20)),
            padding: EdgeInsets.symmetric(vertical: context.scale(12)),
            decoration: BoxDecoration(
              color: const Color(0xFF4A556E),
              borderRadius: BorderRadius.circular(context.scale(10)),
            ),
            child: Center(
              child: Text(
                "Authorized Signature",
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: context.font(13)),
              ),
            ),
          ),
          SizedBox(height: context.scale(20)),
        ],
      ),
    );
  }

  Widget _buildIdCardBack() {
    return Container(
      width: double.infinity,
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
          Icon(Icons.qr_code_2_rounded, size: context.scale(150), color: Colors.white),
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
                _buildBackInfoItem(Icons.phone, "Phone", _cardData!.phone ?? 'N/A'),
                SizedBox(height: context.scale(12)),
                _buildBackInfoItem(Icons.email, "Email", _cardData!.email ?? 'N/A'),
                SizedBox(height: context.scale(12)),
                _buildBackInfoItem(Icons.location_on, "Address", _cardData!.fullAddress ?? 'N/A'),
                SizedBox(height: context.scale(12)),
                _buildBackInfoItem(Icons.contact_emergency, "Emergency Contact", "${_cardData!.emergencyContactName ?? 'N/A'} (${_cardData!.emergencyContactPhone ?? ''})"),
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
      children: [
        Icon(icon, color: Colors.white54, size: context.scale(16)),
        SizedBox(width: context.scale(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white54, fontSize: context.font(10))),
              Text(value, style: TextStyle(color: Colors.white, fontSize: context.font(12), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: context.font(11), fontWeight: FontWeight.w500),
        ),
        SizedBox(height: context.scale(4)),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: context.font(13), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.scale(24)),
      child: Row(
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                elevation: 0,
              ),
              child: Text(
                "FLIP CARD",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: context.font(14)),
              ),
            ),
          ),
          SizedBox(width: context.scale(16)),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => PdfService.generateAndPrintIdCard(_cardData),
              icon: Icon(Icons.picture_as_pdf_rounded, size: context.scale(20)),
              label: Text(
                "DOWNLOAD",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8D3F5),
                foregroundColor: const Color(0xFF3F61ED),
                padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
