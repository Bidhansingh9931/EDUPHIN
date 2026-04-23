import 'dart:convert';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
  Object? _error;

  // Text editing controllers for the form fields
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _employerBranchController = TextEditingController();
  final _zoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
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

  Future<void> _loadCacheAndFetch() async {
    final cachedData = await CacheService.getCache('manager_my_salary');
    if (cachedData != null && mounted) {
      _processData(cachedData);
      setState(() => _isLoading = false);
    }
    _fetchSalaryData();
  }

  void _processData(Map<String, dynamic> data) {
    _accountDetails = data['account'] as Map<String, dynamic>?;
    if (_accountDetails != null) {
      final details = SalaryDetails.fromJson(_accountDetails!);
      final records = (data['salaries'] as List)
          .map((record) => PastSalaryRecord.fromJson(record))
          .toList();

      if (mounted) {
        setState(() {
          _pastRecords.clear();
          _pastRecords.addAll(records);

          _bankAccountController.text = details.bankAccount;
          _ifscController.text = details.ifsc;
          _bankNameController.text = details.bankName;
          _employerBranchController.text = details.employerBranch;
          _zoneController.text = details.zone;
        });
      }
    }
  }

  Future<void> _fetchSalaryData() async {
    if (!mounted) return;
    if (_accountDetails == null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

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
        await CacheService.setCache('manager_my_salary', data);
        _processData(data);
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load salary data: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = _accountDetails == null;
        _error = e;
      });
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
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Salary and Bank Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: context.font(18),
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _isLoading && _accountDetails == null
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(context.scale(16), context.scale(8), context.scale(16), context.scale(24)),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSalaryData,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                  ),
                  child: _isSaving
                      ? SizedBox(height: context.scale(20), width: context.scale(20), child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                      : Text("Save Changes", style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold)),
                ),
              ),
            ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _accountDetails != null,
        error: _error,
        onRetry: _fetchSalaryData,
        skeleton: _buildSkeleton(),
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.scale(1000)),
              child: context.responsive(
                _buildNarrowLayout(),
                tablet: _buildWideLayout(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(1000)),
          child: Column(
            children: [
              SkeletonBox(height: context.scale(350), borderRadius: context.scale(16)),
              SizedBox(height: context.scale(24)),
              SkeletonBox(height: context.scale(400), borderRadius: context.scale(16)),
            ],
          ),
        ),
      ),
    );
  }


  // --- LAYOUTS ---

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildBankingInfoSection(),
        SizedBox(height: context.scale(24)),
        _buildPastSalariesSection(),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildBankingInfoSection(),
        ),
        SizedBox(width: context.scale(24)),
        Expanded(
          flex: 3,
          child: _buildPastSalariesSection(),
        ),
      ],
    );
  }

  // --- SECTIONS ---

  Widget _buildBankingInfoSection() {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(20)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: theme.colorScheme.primary, size: context.scale(20)),
              SizedBox(width: context.scale(10)),
              Text("Banking Information", style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            ],
          ),
          SizedBox(height: context.scale(20)),
          CustomTextField(label: "Bank Account Number", controller: _bankAccountController, editable: true),
          CustomTextField(label: "IFSC Code", controller: _ifscController, editable: true),
          CustomTextField(label: "Bank Name", controller: _bankNameController, editable: true),
          Divider(height: context.scale(32), color: theme.colorScheme.outlineVariant),
          CustomTextField(label: "Employer Branch", controller: _employerBranchController, editable: true),
          CustomTextField(label: "Zone / Sector", controller: _zoneController, editable: true),
        ],
      ),
    );
  }

  Widget _buildPastSalariesSection() {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(20)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: theme.colorScheme.primary, size: context.scale(20)),
              SizedBox(width: context.scale(10)),
              Text("Past Salary Record", style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            ],
          ),
          SizedBox(height: context.scale(20)),
          if (_pastRecords.isEmpty)
            Center(child: Padding(padding: EdgeInsets.all(context.scale(20)), child: Text("No records found.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant))))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pastRecords.length,
              separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
              itemBuilder: (context, index) {
                return _buildSalaryRecordCard(_pastRecords[index]);
              },
            )
        ],
      ),
    );
  }

  Widget _buildSalaryRecordCard(PastSalaryRecord record) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(record.monthYear, style: TextStyle(fontSize: context.font(15), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Row(
                children: [
                  Text("₹", style: TextStyle(fontSize: context.font(14), color: Colors.green, fontWeight: FontWeight.bold)),
                  Text(record.amount, style: TextStyle(fontSize: context.font(15), fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              )
            ],
          ),
          SizedBox(height: context.scale(4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(record.paidOn, style: TextStyle(fontSize: context.font(12), color: theme.colorScheme.onSurfaceVariant)),
              Text("View Details", style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---

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
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          SizedBox(height: context.scale(6)),
          TextFormField(
            enabled: editable,
            controller: controller,
            style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.scale(10)), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(context.scale(10)), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(context.scale(10)), borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(context.scale(10)), borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
              prefixIcon: icon != null ? Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: context.scale(20)) : null,
            ),
          ),
        ],
      ),
    );
  }
}


