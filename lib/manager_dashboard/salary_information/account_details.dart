import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- DATA MODELS ---

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

  factory AccountDetails.fromJson(Map<String, dynamic> json) {
    return AccountDetails(
      bankAccount: json['bank_account_number'] as String? ?? 'N/A',
      ifsc: json['ifsc_code'] as String? ?? 'N/A',
      bankName: json['bank_name'] as String? ?? 'N/A',
      employerBranch: json['branch'] as String? ?? 'N/A',
      zone: json['zone'] as String? ?? 'N/A',
      currentSalary: (json['salary'] ?? '0').toString(),
    );
  }
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

  factory PastSalaryRecord.fromJson(Map<String, dynamic> json) {
    return PastSalaryRecord(
      monthYear: "${json['month'] ?? ''} ${json['year'] ?? ''}",
      amount: (json['net_salary'] ?? '0').toString(),
      paidOn: json['created_at'] != null
          ? "paid on ${DateFormat('d MMM yyyy').format(DateTime.parse(json['created_at']))}"
          : "N/A",
    );
  }
}

// --- MAIN WIDGET ---

class AccountDetailsPage extends StatefulWidget {
  final int employeeId;
  const AccountDetailsPage({super.key, required this.employeeId});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  final List<PastSalaryRecord> _pastRecords = [];
  Map<String, dynamic>? _accountDetails; // Store the original account data

  // Text editing controllers for the form fields
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _employerBranchController = TextEditingController();
  final _zoneController = TextEditingController();
  final _currentSalaryController = TextEditingController();

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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get('manager/salary/account/${widget.employeeId}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store the raw account data
        _accountDetails = data['account'] as Map<String, dynamic>?;
        if (_accountDetails == null) {
          throw Exception("Could not retrieve account details.");
        }

        final details = AccountDetails.fromJson(_accountDetails!);
        final records = (data['salaries'] as List)
            .map((record) => PastSalaryRecord.fromJson(record))
            .toList();

        setState(() {
          _pastRecords.clear();
          _pastRecords.addAll(records);

          _bankAccountController.text = details.bankAccount;
          _ifscController.text = details.ifsc;
          _bankNameController.text = details.bankName;
          _employerBranchController.text = details.employerBranch;
          _zoneController.text = details.zone;
          _currentSalaryController.text = details.currentSalary;
        });
      } else {
        throw Exception('Failed to load account details: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAccountDetails() async {
    setState(() => _isSaving = true);

    try {
       if (_accountDetails == null) {
        throw Exception("Cannot save, original account details not loaded.");
      }

      // Create a mutable copy of the original data and update it
      final Map<String, dynamic> body = Map.from(_accountDetails!);
      body['bank_account_number'] = _bankAccountController.text;
      body['ifsc_code'] = _ifscController.text;
      body['bank_name'] = _bankNameController.text;
      body['branch'] = _employerBranchController.text;
      body['zone'] = _zoneController.text;
      body['salary'] = _currentSalaryController.text;

      final response = await ApiService.post('manager/users/${widget.employeeId}', body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account details updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _fetchAccountDetails();
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] ?? 'Failed to save account details';
        throw Exception(message);
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString().replaceFirst("Exception: ", "");
      if (errorMessage.contains("1062") && errorMessage.contains("user_details_bank_account_number_unique")) {
        errorMessage = "Error: This bank account number is already in use by another user.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Account Details"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isLoading ? null : _buildSaveButton(theme),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(builder: (context, constraints) {
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
          onPressed: _isSaving ? null : _saveAccountDetails,
          label: _isSaving
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white))
              : Text("Save Changes",
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onPrimary)),
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
        CustomTextField(
            label: "Bank Account Number",
            controller: _bankAccountController,
            editable: true),
        CustomTextField(
            label: "IFSC Code", controller: _ifscController, editable: true),
        CustomTextField(
            label: "Bank Name", controller: _bankNameController, editable: true),
        const Divider(height: 24),
        CustomTextField(
            label: "Employer Branch",
            controller: _employerBranchController,
            editable: true),
        CustomTextField(
            label: "Zone / Sector", controller: _zoneController, editable: true),
        CustomTextField(
            label: "Current Salary (per month)",
            controller: _currentSalaryController,
            editable: true),
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

  const SectionCard(
      {super.key,
      required this.title,
      required this.icon,
      required this.children});

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
              Text(title,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
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
          Text(label,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 6),
          TextFormField(
            enabled: editable,
            controller: controller,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              filled: true,
              fillColor: editable
                  ? theme.scaffoldBackgroundColor
                  : theme.colorScheme.surface.withAlpha(100),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
