import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eduphin/services/api_service.dart';

// --- DATA MODELS ---

class SalaryDetails {
  final String bankAccount;
  final String ifsc;
  final String bankName;
  final String employerBranch;
  final String zone;

  const SalaryDetails({
    required this.bankAccount,
    required this.ifsc,
    required this.bankName,
    required this.employerBranch,
    required this.zone,
  });

  factory SalaryDetails.fromJson(Map<String, dynamic> json) {
    return SalaryDetails(
      bankAccount: json['bank_account_number'] ?? '',
      ifsc: json['ifsc_code'] ?? '',
      bankName: json['bank_name'] ?? '',
      employerBranch: json['branch'] ?? '',
      zone: json['zone'] ?? '',
    );
  }
}

class PastSalaryRecord {
  final String monthYear;
  final String amount;
  final String paidOn;
  final int id;

  const PastSalaryRecord({
    required this.monthYear,
    required this.amount,
    required this.paidOn,
    required this.id,
  });

  factory PastSalaryRecord.fromJson(Map<String, dynamic> json) {
    final numberFormat = NumberFormat.currency(locale: 'en_IN', symbol: '');
    final double netSalary = double.tryParse(json['net_salary']?.toString() ?? '0.0') ?? 0.0;
    
    String formattedDate = 'N/A';
    if(json['created_at'] != null) {
      try {
        formattedDate = 'paid on ${DateFormat('d MMM yyyy').format(DateTime.parse(json['created_at']))}';
      } catch (e) {
        // Do nothing if date parsing fails
      }
    }

    return PastSalaryRecord(
      id: json['id'] ?? 0,
      monthYear: '${json['month'] ?? ''} ${json['year'] ?? ''}',
      amount: numberFormat.format(netSalary),
      paidOn: formattedDate,
    );
  }
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
  final List<PastSalaryRecord> _pastRecords = [];
  Map<String, dynamic>? _accountDetails;

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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('Token not found');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/manager/my-salary'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        _accountDetails = data['account'] as Map<String, dynamic>?;
        if (_accountDetails == null) {
          throw Exception("Could not retrieve account details.");
        }

        final details = SalaryDetails.fromJson(_accountDetails!);
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

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load salary data: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveSalaryData() async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('Token not found');

      if (_accountDetails == null) {
        throw Exception('Cannot save, user details not loaded.');
      }
      
      final Map<String, dynamic> updatedDetails = Map.from(_accountDetails!);
      updatedDetails['bank_account_number'] = _bankAccountController.text;
      updatedDetails['ifsc_code'] = _ifscController.text;
      updatedDetails['bank_name'] = _bankNameController.text;
      updatedDetails['branch'] = _employerBranchController.text;
      updatedDetails['zone'] = _zoneController.text;

      // Remove fields that are not being updated to avoid validation errors.
      updatedDetails.remove('photo');
      updatedDetails.remove('resume');
      
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/manager/profile/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedDetails),
      );
      
      if (!mounted) return;
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Banking details updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to save details');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
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
        title: const Text("Salary and Bank Details"),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        children: [
          _buildBankingInfoSection(),
          const SizedBox(height: 16),
          _buildPastSalariesSection(),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
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
        if (_pastRecords.isEmpty)
          const Center(child: Text("No records found."))
        else
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
        color: theme.scaffoldBackgroundColor,
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
        color: theme.colorScheme.surface,
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
