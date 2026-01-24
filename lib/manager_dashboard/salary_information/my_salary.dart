import 'package:flutter/material.dart';

// --- DATA MODELS ---

class SalaryDetails {
  final String bankAccount;
  final String ifsc;
  final String bankName;
  final String employerBranch;
  final String zone;

  SalaryDetails({
    required this.bankAccount,
    required this.ifsc,
    required this.bankName,
    required this.employerBranch,
    required this.zone,
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

// --- MAIN WIDGET ---

class MySalaryPage extends StatefulWidget {
  const MySalaryPage({super.key});

  @override
  State<MySalaryPage> createState() => _MySalaryPageState();
}

class _MySalaryPageState extends State<MySalaryPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  SalaryDetails? _salaryDetails;
  final List<PastSalaryRecord> _pastRecords = [];

  // Text editing controllers for the form fields
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _employerBranchController = TextEditingController();
  final _zoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSalaryData();
  }

  @override
  void dispose() {
    _bankAccountController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _employerBranchController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchSalaryData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    final details = SalaryDetails(
      bankAccount: "111122223333",
      ifsc: "UN11100010",
      bankName: "Unity Bank",
      employerBranch: "Unity Branch - Sector 2",
      zone: "Sector 2",
    );

    final records = [
      PastSalaryRecord(monthYear: "May 2024", amount: "75,000", paidOn: "paid on 31 May 2024"),
      PastSalaryRecord(monthYear: "April 2024", amount: "75,000", paidOn: "paid on 30 April 2024"),
      PastSalaryRecord(monthYear: "March 2024", amount: "75,000", paidOn: "paid on 31 Mar 2024"),
    ];

    if (mounted) {
      setState(() {
        _salaryDetails = details;
        _pastRecords.addAll(records);

        _bankAccountController.text = details.bankAccount;
        _ifscController.text = details.ifsc;
        _bankNameController.text = details.bankName;
        _employerBranchController.text = details.employerBranch;
        _zoneController.text = details.zone;

        _isLoading = false;
      });
    }
  }

  Future<void> _saveSalaryData() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    final updatedDetails = SalaryDetails(
      bankAccount: _bankAccountController.text,
      ifsc: _ifscController.text,
      bankName: _bankNameController.text,
      employerBranch: _employerBranchController.text,
      zone: _zoneController.text,
    );

    print('Saving data for account: ${updatedDetails.bankAccount}');

    if (!mounted) return;

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Banking details updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Salary and Bank Details"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isLoading ? null : _buildSaveButton(theme),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(builder: (context, constraints) {
              // Use a different layout for wider screens
              if (constraints.maxWidth > 800) {
                return _buildWideLayout();
              } else {
                return _buildNarrowLayout();
              }
            }),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: _isSaving ? null : _saveSalaryData,
          label: _isSaving
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
              : Text("Save Changes", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
        ),
      ),
    );
  }

  // --- LAYOUTS ---

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      child: Column(
        children: [
          _buildBankingInfoSection(),
          const SizedBox(height: 16),
          _buildPastSalariesSection(),
          const SizedBox(height: 80), // Padding for FAB
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(child: _buildBankingInfoSection()),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(child: _buildPastSalariesSection()),
          ),
        ],
      ),
    );
  }

  // --- SECTIONS ---

  Widget _buildBankingInfoSection() {
    return SectionCard(
      title: "Banking Information",
      icon: Icons.account_balance,
      children: [
        CustomTextField(label: "Bank Account Number", controller: _bankAccountController, editable: true),
        CustomTextField(label: "IFSC Code", controller: _ifscController, editable: true),
        CustomTextField(label: "Bank Name", controller: _bankNameController, editable: true),
        const Divider(height: 24),
        CustomTextField(label: "Employer Branch", controller: _employerBranchController, editable: true),
        CustomTextField(label: "Zone / Sector", controller: _zoneController, editable: true),
      ],
    );
  }

  Widget _buildPastSalariesSection() {
    return SectionCard(
      title: "Past Salary Record",
      icon: Icons.history,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pastRecords.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildSalaryRecordCard(_pastRecords[index]);
          },
        )
      ],
    );
  }

  Widget _buildSalaryRecordCard(PastSalaryRecord record) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // Use theme color
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(record.monthYear, style: theme.textTheme.titleMedium),
              Row(
                children: [
                  Icon(Icons.currency_rupee, size: 20, color: Colors.green.shade400),
                  Text(record.amount, style: theme.textTheme.titleMedium?.copyWith(color: Colors.green.shade400)),
                ],
              )
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(record.paidOn, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              Text("View Details", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SectionCard({super.key, required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Use theme color
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.secondary),
              const SizedBox(width: 10),
              Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
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

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.editable = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 6),
          TextFormField(
            enabled: editable,
            controller: controller,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              filled: true,
              fillColor: editable ? theme.scaffoldBackgroundColor : theme.colorScheme.surface.withAlpha(100),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: icon != null ? Icon(icon, color: theme.hintColor) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
