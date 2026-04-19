import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/theme_service.dart';
import 'package:eduphin/services/common_widgets.dart';
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
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_institute != null ? "Details: ${_institute!.name}" : "Institute Details", 
            style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, size: context.scale(24))),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Padding(
                  padding: EdgeInsets.all(context.scale(24.0)),
                  child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
                ))
              : _institute == null
                  ? Center(child: Text("No data found", style: TextStyle(fontSize: context.font(14))))
                  : SingleChildScrollView(
                      padding: context.pagePadding,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileHeader(context),
                              SizedBox(height: context.scale(32)),
                              _buildDetailsCard(context),
                              SizedBox(height: context.scale(32)),
                              _buildActionButtons(context),
                              SizedBox(height: context.scale(40)),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(24.0)),
        child: Column(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(context.scale(4)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary, width: context.scale(2)),
                ),
                child: ProfileAvatar(
                  radius: context.scale(50),
                  imageUrl: _institute!.logo != null
                      ? ApiService.getStorageUrl(_institute!.logo)
                      : null,
                  borderWidth: 0,
                ),
              ),
            ),
            SizedBox(height: context.scale(20)),
            Text(_institute!.name,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(24)), textAlign: TextAlign.center),
            Text(_institute!.code, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, fontStyle: FontStyle.italic, fontSize: context.font(14))),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(24.0)),
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
            Divider(height: context.scale(32)),
            _buildStatusRow(context, "Status", _institute!.status),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isLink = false}) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.scale(120),
            child: Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold, fontSize: context.font(12))),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: context.font(14),
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
    final theme = context.theme;
    final isGreen = status == "Active";
    return Row(
      children: [
        SizedBox(
          width: context.scale(120),
          child: Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold, fontSize: context.font(12))),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(4)),
          decoration: BoxDecoration(
            color: (isGreen ? Colors.green : Colors.red).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.scale(6)),
            border: Border.all(color: (isGreen ? Colors.green : Colors.red).withValues(alpha: 0.5)),
          ),
          child: Text(status,
            style: TextStyle(color: isGreen ? Colors.green : Colors.red, fontSize: context.font(11), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = context.theme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ManageAccountsScreen(instituteId: widget.instituteId)));
            },
            icon: Icon(Icons.manage_accounts, size: context.scale(18)),
            label: Text("MANAGE ACCOUNTS", style: TextStyle(fontSize: context.font(14))),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              padding: EdgeInsets.symmetric(vertical: context.scale(12)),
            ),
          ),
        ),
        SizedBox(height: context.scale(12)),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddInstituteScreen(institute: _institute)));
              if (result == true) _fetchDetails();
            },
            icon: Icon(Icons.edit, size: context.scale(18)),
            label: Text("EDIT INSTITUTE", style: TextStyle(fontSize: context.font(14))),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: context.scale(12)),
            ),
          ),
        ),
      ],
    );
  }
}
