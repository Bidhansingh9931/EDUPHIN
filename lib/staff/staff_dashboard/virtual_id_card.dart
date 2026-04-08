import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/api_service.dart';
import 'staff_models.dart';

class StaffVirtualIdCard extends StatefulWidget {
  const StaffVirtualIdCard({super.key});

  @override
  State<StaffVirtualIdCard> createState() => _StaffVirtualIdCardState();
}

class _StaffVirtualIdCardState extends State<StaffVirtualIdCard> {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color bgColor = Color(0xFF0F1630);
  
  late Future<StaffVirtualIdCardData> _idCardFuture;
  bool _isFront = true;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _idCardFuture = ApiService.getStaffVirtualIdCard();
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "${ApiService.baseUrl}/storage/$cleanPath";
  }

  void _toggleFlip() {
    setState(() {
      _isFront = !_isFront;
      _rotation = _isFront ? 0 : pi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Staff ID Card",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<StaffVirtualIdCardData>(
        future: _idCardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found', style: TextStyle(color: Colors.white70)));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // 3D Flip Animation
                Center(
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
                                child: _buildBackSide(data),
                              )
                            : _buildFrontSide(data),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 50),
                _buildActionButtons(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide(StaffVirtualIdCardData data) {
    final user = data.user;
    final detail = data.userDetail;
    final imageUrl = _getImageUrl(detail.photo);

    return Container(
      width: 310,
      height: 480,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E3A59), Color(0xFF161D33)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background icon
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.security, size: 150, color: Colors.white.withValues(alpha: 0.03)),
          ),
          
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/icon/app_icon.png', width: 35, height: 35, errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Colors.white, size: 30)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("EDUPHIN ACADEMY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                          Text("Staff Identification", style: TextStyle(color: Colors.white.withValues(alpha: 0.54), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Profile Image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor, width: 3),
                  boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)],
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: const Color(0xFF0F1630),
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty ? const Icon(Icons.person, size: 70, color: Colors.white24) : null,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                user.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              const Text(
                "STAFF MEMBER",
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 2),
              ),

              const Spacer(),

              // Details Grid
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildRowInfo("STAFF ID", "STF-${user.id.toString().padLeft(4, '0')}", "GENDER", detail.gender ?? "N/A"),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.white12, height: 1),
                    ),
                    _buildRowInfo("DOB", detail.dateOfBirth ?? "N/A", "PHONE", detail.phone ?? "N/A"),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackSide(StaffVirtualIdCardData data) {
    return Container(
      width: 310,
      height: 480,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [Color(0xFF161D33), Color(0xFF2E3A59)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text("TERMS & CONDITIONS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Text(
              "This card is the property of Eduphin Academy. If found, please return it to the nearest administration office.\n\nUnauthorized use or duplication of this document is a punishable offense under institutional policy.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.6),
            ),
          ),
          const Spacer(),
          
          // QR Code Placeholder
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2_rounded, size: 100, color: Color(0xFF0F1630)),
          ),
          
          const Spacer(),
          
          const Text("EMERGENCY CONTACT", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 5),
          const Text("+1 234 567 890", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          
          const SizedBox(height: 30),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: const Center(
              child: Text("www.eduphin.com", style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowInfo(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(child: _buildInfoItem(label1, value1)),
        Container(width: 1, height: 30, color: Colors.white10),
        const SizedBox(width: 15),
        Expanded(child: _buildInfoItem(label2, value2)),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _toggleFlip,
              icon: const Icon(Icons.flip_camera_android_rounded),
              label: Text(_isFront ? "VIEW BACK SIDE" : "VIEW FRONT SIDE", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 8,
                shadowColor: primaryColor.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_for_offline_rounded, size: 20),
                  label: const Text("DOWNLOAD"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: const Text("SHARE"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
