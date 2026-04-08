import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/moderator_dashboard/institute/institute_model.dart';
import 'add_institute.dart';
import 'manage_accounts.dart';

class InstituteDetailsScreen extends StatefulWidget {
  final String instituteId;
  const InstituteDetailsScreen({super.key, required this.instituteId});

  @override
  State<InstituteDetailsScreen> createState() => _InstituteDetailsScreenState();
}

class _InstituteDetailsScreenState extends State<InstituteDetailsScreen> {
  Institute? _institute;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final institute = await ApiService.getSuperAdminInstituteDetails(widget.instituteId);
      if (mounted) {
        setState(() {
          _institute = institute;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_institute != null ? "Details: ${_institute!.name}" : "Institute Details"),
        actions: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                ))
              : _institute == null
                  ? const Center(child: Text("No data found"))
                  : SingleChildScrollView(
                      padding: context.pagePadding,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileHeader(context),
                              const SizedBox(height: 32),
                              _buildDetailsCard(context),
                              const SizedBox(height: 32),
                              _buildActionButtons(context),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: _institute!.logo != null
                      ? NetworkImage("${ApiService.baseImageUrl}/storage/${_institute!.logo}")
                      : null,
                  child: _institute!.logo == null
                      ? Icon(Icons.business, size: 50, color: theme.colorScheme.primary)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(_institute!.name,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(_institute!.code, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, "Established", _institute!.establishedYear.toString()),
            _buildDetailRow(context, "Address", _institute!.address),
            _buildDetailRow(context, "Email", _institute!.contactEmail, isLink: true),
            _buildDetailRow(context, "Phone", _institute!.contactPhone),
            _buildDetailRow(context, "Chairman", _institute!.chairmanName),
            _buildDetailRow(context, "Website", _institute!.website ?? "N/A", isLink: true),
            _buildDetailRow(context, "Affiliation", _institute!.affiliationDetails ?? "N/A"),
            const Divider(height: 32),
            _buildStatusRow(context, "Status", _institute!.status),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isLink = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isLink ? theme.colorScheme.primary : null,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, String status) {
    final theme = Theme.of(context);
    final isGreen = status == "Active";
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: (isGreen ? Colors.green : Colors.red).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: (isGreen ? Colors.green : Colors.red).withValues(alpha: 0.5)),
          ),
          child: Text(status, 
            style: TextStyle(color: isGreen ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ManageAccountsScreen(instituteId: widget.instituteId)));
          },
          icon: const Icon(Icons.manage_accounts, size: 18),
          label: const Text("MANAGE ACCOUNTS"),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddInstituteScreen(institute: _institute)));
            if (result == true) _fetchDetails();
          },
          icon: const Icon(Icons.edit, size: 18),
          label: const Text("EDIT INSTITUTE"),
        ),
      ],
    );
  }
}
