import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'staff_models.dart';

class StaffFeeStructurePage extends StatefulWidget {
  const StaffFeeStructurePage({super.key});

  @override
  State<StaffFeeStructurePage> createState() => _StaffFeeStructurePageState();
}

class _StaffFeeStructurePageState extends State<StaffFeeStructurePage> {
  static const Color bgColor = Color(0xFF0F1630);
  static const Color cardColor = Color(0xFF1D2645);

  late Future<List<Fee>> _feesFuture;

  @override
  void initState() {
    super.initState();
    _loadFees();
  }

  void _loadFees() {
    setState(() {
      _feesFuture = ApiService.getStaffFees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Fees Structure", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadFees(),
        child: FutureBuilder<List<Fee>>(
          future: _feesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No fee structure available", style: TextStyle(color: Colors.white38)));
            }

            final fees = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: fees.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final fee = fees[index];
                return _buildFeeCard(fee.name, "₹${fee.amount}", fee.description ?? "");
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeeCard(String name, String amount, String desc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              Text(amount, style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
