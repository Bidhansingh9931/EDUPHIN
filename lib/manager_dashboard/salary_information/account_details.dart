import 'package:flutter/material.dart';

// Data models
class AccountDetails {
  final String bankAccount;
  final String ifsc;
  final String bankName;
  final String employerBranch;
  final String zone;
  final String currentSalary;

  AccountDetails({
    required this.bankAccount,
    required this.ifsc,
    required this.bankName,
    required this.employerBranch,
    required this.zone,
    required this.currentSalary,
  });
}

class PastSalaryRecord {
  final String monthYear;
  final String amount;
  final String paidOn;

  PastSalaryRecord({
    required this.monthYear,
    required this.amount,
    required this.paidOn,
  });
}


class AccountDetailsPage extends StatefulWidget{
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  bool _isLoading = true;
  bool _isSaving = false;

  AccountDetails? _accountDetails;
  final List<PastSalaryRecord> _pastRecords = [];

  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _employerBranchController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _currentSalaryController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchAccountDetails();
  }

  @override
  void dispose() {
    _bankAccountController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _employerBranchController.dispose();
    _zoneController.dispose();
    _currentSalaryController.dispose();
    super.dispose();
  }

  Future<void> _fetchAccountDetails() async {
    // Simulate API call. Replace with your actual API fetching logic.
    await Future.delayed(const Duration(seconds: 2));

    final details = AccountDetails(
        bankAccount: "111122223333",
        ifsc: "UN11100010",
        bankName: "Unity Bank",
        employerBranch: "Unity Branch - Sector 2",
        zone: "Sector 2",
        currentSalary: "75,000"
    );

    final records = [
      PastSalaryRecord(monthYear: "May 2024", amount: "75,000", paidOn: "paid on 31 May 2024"),
      PastSalaryRecord(monthYear: "April 2024", amount: "75,000", paidOn: "paid on 30 April 2024"),
      PastSalaryRecord(monthYear: "March 2024", amount: "75,000", paidOn: "paid on 31 Mar 2024"),
      PastSalaryRecord(monthYear: "February 2024", amount: "75,000", paidOn: "paid on 29 Feb 2024"),
    ];

    if (mounted) {
      setState(() {
        _accountDetails = details;
        _pastRecords.addAll(records);

        // Populate controllers
        _bankAccountController.text = details.bankAccount;
        _ifscController.text = details.ifsc;
        _bankNameController.text = details.bankName;
        _employerBranchController.text = details.employerBranch;
        _zoneController.text = details.zone;
        _currentSalaryController.text = details.currentSalary;

        _isLoading = false;
      });
    }
  }

  Future<void> _saveAccountDetails() async {
    setState(() {
      _isSaving = true;
    });

    // Simulate API call to save data.
    await Future.delayed(const Duration(seconds: 2));

    final updatedDetails = {
      "bank_account": _bankAccountController.text,
      "ifsc": _ifscController.text,
      "bank_name": _bankNameController.text,
      "employer_branch": _employerBranchController.text,
      "zone": _zoneController.text,
      "current_salary": _currentSalaryController.text,
    };

    // In a real app, you would send this data to your API.
    print('Saving data: $updatedDetails');

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account details updated successfully!')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Details"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_accountDetails != null)
              SectionCard(
                title: "Banking Information",
                icon: Icons.account_balance,
                children: [
                  CustomTextField(label: "Bank Account Number", controller: _bankAccountController, editable: true),
                  CustomTextField(label: "IFSC Code", controller: _ifscController, editable: true),
                  CustomTextField(label: "Bank Name", controller: _bankNameController, editable: true),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  CustomTextField(label: "Employer Branch", controller: _employerBranchController, editable: true),
                  CustomTextField(label: "Zone / Sector", controller: _zoneController, editable: true),
                  CustomTextField(label: "Current Salary(per month)", controller: _currentSalaryController, editable: true),

                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: "Past Salary Record",
                icon: Icons.access_time_sharp,
                children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pastRecords.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final record = _pastRecords[index];
                    return _buildSalaryRecordCard(record);
                    },
                ),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAccountDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text("Save Changes", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryRecordCard(PastSalaryRecord record) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(record.monthYear, style: const TextStyle(fontSize: 16, color: Colors.white)),
              Row(
                children: [
                  const Icon(Icons.currency_rupee, size: 20, color: Colors.green),
                  Text(record.amount, style: const TextStyle(fontSize: 16, color: Colors.green)),
                ],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(record.paidOn, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const Text("View Details", style: TextStyle(fontSize: 14, color: Colors.lightBlue)),
            ],
          ),
        ],
      ),
    );
  }
}
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SectionCard({super.key, required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool editable;
  final IconData? icon;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.editable = true,
    this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: editable ? const Color(0xFF0D1B2A) : Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            enabled: editable,
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
