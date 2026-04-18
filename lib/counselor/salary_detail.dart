import 'dart:convert';
import 'package:eduphin/services/pdf_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'counselor_models.dart';

class SalaryDetailPage extends StatefulWidget {
  final int salaryId;
  const SalaryDetailPage({super.key, required this.salaryId});

  @override
  State<SalaryDetailPage> createState() => _SalaryDetailPageState();
}

class _SalaryDetailPageState extends State<SalaryDetailPage> {
  bool _isLoading = true;
  Salary? _salary;
  String? _amountInWords;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get('counselor/salaries/${widget.salaryId}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _salary = Salary.fromJson(data['salary']);
          _amountInWords = data['amount_in_words'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = ApiService.errorMessage(response, 'Failed to load salary details');
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(title: const Text("Salary Payslip")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: context.pagePadding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: theme.colorScheme.error, size: context.scale(48)),
                        SizedBox(height: context.md),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14)),
                        ),
                        SizedBox(height: context.lg),
                        FilledButton.icon(
                          onPressed: _fetchDetails,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        )
                      ],
                    ),
                  ),
                )
              : _salary == null
              ? const Center(child: Text("Salary details not found"))
              : SingleChildScrollView(
                  padding: context.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Card(
                        elevation: 0,
                        color: context.theme.colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.scale(16)),
                          side: BorderSide(color: context.theme.colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(context.spacing * 1.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "SALARY SLIP",
                                      style: TextStyle(
                                        fontSize: context.font(20),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: context.scale(4)),
                                    Text(
                                      "For the month of ${_salary!.month}",
                                      style: TextStyle(color: context.theme.hintColor, fontSize: context.font(14)),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: context.scale(40), thickness: 1, color: context.theme.colorScheme.outlineVariant),
                              _buildRow(context, "Basic Salary", "₹${_salary!.amount}"),
                              _buildRow(context, "Status", _salary!.status.toUpperCase()),
                              _buildRow(context, "Payment Date", _salary!.paymentDate),
                              Divider(height: context.scale(40), thickness: 1, color: context.theme.colorScheme.outlineVariant),
                              Text(
                                "TOTAL NET SALARY",
                                style: TextStyle(
                                  fontSize: context.font(12),
                                  fontWeight: FontWeight.bold,
                                  color: context.theme.hintColor,
                                ),
                              ),
                              SizedBox(height: context.scale(4)),
                              Text(
                                "₹${_salary!.amount}",
                                style: TextStyle(
                                  fontSize: context.font(32),
                                  fontWeight: FontWeight.bold,
                                  color: context.theme.colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: context.scale(12)),
                              Text(
                                "Amount in words:",
                                style: TextStyle(fontSize: context.font(11), color: context.theme.hintColor, fontStyle: FontStyle.italic),
                              ),
                              Text(
                                _amountInWords ?? "",
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: context.font(14)),
                              ),
                              SizedBox(height: context.scale(40)),
                              SizedBox(
                                width: double.infinity,
                                height: context.scale(48),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (_salary != null) {
                                      PdfService.generateSalaryPdf(_salary!, _amountInWords);
                                    }
                                  },
                                  icon: const Icon(Icons.download),
                                  label: const Text("DOWNLOAD PDF"),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(context.scale(12)),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scale(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: context.theme.hintColor, fontSize: context.font(14))),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
        ],
      ),
    );
  }
}
