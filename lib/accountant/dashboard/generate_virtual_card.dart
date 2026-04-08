import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'accountant_dashboard_model.dart';

class GenerateVirtualCard extends StatefulWidget {
  const GenerateVirtualCard({super.key});

  @override
  State<GenerateVirtualCard> createState() => _GenerateVirtualCardState();
}

class _GenerateVirtualCardState extends State<GenerateVirtualCard> {
  static const Color primaryColor = Color(0xFF6C63FF);
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
      final detail = await ApiService.getAccountantVirtualIdCard();
      // Since getAccountantVirtualIdCard returns UserDetail, we map it to our Virtual Card Data
      setState(() {
        _cardData = AccountantVirtualIdCardData(
          userDetail: detail,
          name: detail.name,
          photoUrl: detail.photo,
          employeeId: detail.userId.toString(),
          position: detail.position ?? 'Senior Accountant',
          employmentType: detail.employmentType ?? 'Full Time',
          joiningDate: detail.joiningDate ?? 'N/A',
          phone: detail.phone,
          email: detail.email,
          fullAddress: detail.address,
          emergencyContactName: detail.emergencyContactName,
          emergencyContactPhone: detail.emergencyContactNumber,
        );
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching card: $e")));
        setState(() => _isLoading = false);
      }
    }
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
          "Generate Virtual Card",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cardData == null
              ? const Center(child: Text("No data available", style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: isFront ? _buildIdCardFront() : _buildIdCardBack(),
                      ),
                      const SizedBox(height: 30),
                      _buildActionButtons(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildIdCardFront() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: idCardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _cardData!.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network("${ApiService.baseUrl}/storage/${_cardData!.photoUrl}", fit: BoxFit.cover),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cardData!.instituteName ?? "EDUPHIN ACADEMY",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _cardData!.instituteAddress ?? "Campus Identification Card",
                        style: const TextStyle(color: Colors.white70, fontSize: 10, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Text(
            "ACCOUNTANT ID",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFE0E0E0),
              backgroundImage: _cardData!.photoUrl != null ? NetworkImage("${ApiService.baseUrl}/storage/${_cardData!.photoUrl}") : null,
              child: _cardData!.photoUrl == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF3D4763),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _cardData!.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem("Position", _cardData!.position ?? 'N/A'),
                    _buildInfoItem("Employee ID", _cardData!.employeeId ?? 'N/A'),
                  ],
                ),
                const SizedBox(height: 15),
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
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4A556E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                "Authorized Signature",
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIdCardBack() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: idCardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 30),
          const Icon(Icons.qr_code_2_rounded, size: 150, color: Colors.white),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF3D4763),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackInfoItem(Icons.phone, "Phone", _cardData!.phone ?? 'N/A'),
                const SizedBox(height: 12),
                _buildBackInfoItem(Icons.email, "Email", _cardData!.email ?? 'N/A'),
                const SizedBox(height: 12),
                _buildBackInfoItem(Icons.location_on, "Address", _cardData!.fullAddress ?? 'N/A'),
                const SizedBox(height: 12),
                _buildBackInfoItem(Icons.contact_emergency, "Emergency Contact", "${_cardData!.emergencyContactName ?? 'N/A'} (${_cardData!.emergencyContactPhone ?? ''})"),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBackInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
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
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                "FLIP CARD",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
              label: const Text(
                "DOWNLOAD PDF",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8D3F5),
                foregroundColor: const Color(0xFF3F61ED),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
