import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/moderator_dashboard/institute/institute_model.dart' as moderator_institute;

class AddInstituteScreen extends StatefulWidget {
  final moderator_institute.Institute? institute;
  const AddInstituteScreen({super.key, this.institute});

  @override
  State<AddInstituteScreen> createState() => _AddInstituteScreenState();
}

class _AddInstituteScreenState extends State<AddInstituteScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _yearController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _chairmanController = TextEditingController();
  final _affiliationController = TextEditingController();
  final _gstController = TextEditingController();
  final _panController = TextEditingController();

  String _status = "Active";
  File? _logoFile;
  Uint8List? _webLogo;
  String? _fileName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.institute != null) {
      final inst = widget.institute!;
      _nameController.text = inst.name;
      _codeController.text = inst.code;
      _yearController.text = inst.establishedYear.toString();
      _addressController.text = inst.address;
      _cityController.text = inst.city;
      _stateController.text = inst.state;
      _pincodeController.text = inst.pincode;
      _emailController.text = inst.contactEmail;
      _phoneController.text = inst.contactPhone;
      _websiteController.text = inst.website ?? "";
      _chairmanController.text = inst.chairmanName;
      _affiliationController.text = inst.affiliationDetails ?? "";
      _gstController.text = inst.gstNumber ?? "";
      _panController.text = inst.panNumber ?? "";
      _status = inst.status;
    }
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _fileName = result.files.first.name;
        if (kIsWeb) {
          _webLogo = result.files.first.bytes;
        } else {
          _logoFile = File(result.files.first.path!);
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'established_year': _yearController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'contact_email': _emailController.text.trim(),
      'contact_phone': _phoneController.text.trim(),
      'website': _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      'chairman_name': _chairmanController.text.trim(),
      'affiliation_details': _affiliationController.text.trim(),
      'gst_number': _gstController.text.trim(),
      'pan_number': _panController.text.trim(),
      'status': _status,
    };

    try {
      if (widget.institute == null) {
        await ApiService.storeSuperAdminInstitute(data, logo: _logoFile, logoBytes: _webLogo, fileName: _fileName);
      } else {
        await ApiService.updateSuperAdminInstitute(widget.institute!.id.toString(), data, logo: _logoFile, logoBytes: _webLogo, fileName: _fileName);
      }
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.institute == null ? "Institute added" : "Institute updated")));
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.institute == null ? "Add Institute" : "Edit Institute")),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(context.scale(16)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSection(context, title: "Basic Details", icon: Icons.info_outline, children: [
                      _buildTextField(context, "Institute Name *", "Name", Icons.business, _nameController),
                      _buildTextField(context, "Institute Code *", "Code", Icons.qr_code, _codeController),
                      _buildDatePickerField(context, "Established Year *", "YYYY", Icons.calendar_today, _yearController),
                    ]),
                    _buildSection(context, title: "Contact Information", icon: Icons.contact_page_outlined, children: [
                      _buildTextField(
                        context,
                        "Contact Email *",
                        "Email",
                        Icons.email,
                        _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return "Required";
                          if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(v.trim())) {
                            return "Invalid email format";
                          }
                          return null;
                        },
                      ),
                      _buildTextField(context, "Contact Phone *", "Phone", Icons.phone, _phoneController, keyboardType: TextInputType.phone),
                      _buildTextField(
                        context,
                        "Website",
                        "URL (e.g., https://example.com)",
                        Icons.language,
                        _websiteController,
                        validator: (v) {
                          if (v != null && v.isNotEmpty && !v.trim().startsWith("http")) {
                            return "URL must start with http:// or https://";
                          }
                          return null;
                        },
                      ),
                      _buildTextField(context, "Chairman Name *", "Name", Icons.person, _chairmanController),
                    ]),
                    _buildSection(context, title: "Location Details", icon: Icons.location_on_outlined, children: [
                      _buildTextField(context, "Address *", "Address", Icons.home, _addressController, maxLines: 2),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(context, "City *", "City", Icons.location_city, _cityController)),
                          SizedBox(width: context.scale(12)),
                          Expanded(child: _buildTextField(context, "State *", "State", Icons.map, _stateController)),
                        ],
                      ),
                      _buildTextField(context, "Pincode *", "6-digit pincode", Icons.pin_drop, _pincodeController, keyboardType: TextInputType.number),
                    ]),
                    _buildSection(context, title: "Legal & Other", icon: Icons.gavel_outlined, children: [
                      _buildTextField(context, "GST Number *", "GST No.", Icons.description, _gstController),
                      _buildTextField(context, "PAN Number *", "PAN No.", Icons.badge, _panController),
                      _buildTextField(context, "Affiliation Details", "Details", Icons.history_edu, _affiliationController),
                      _buildStatusDropdown(context),
                      _buildFilePicker(context, "Institute Logo"),
                    ]),
                    SizedBox(height: context.scale(24)),
                    SizedBox(
                      width: double.infinity,
                      height: context.scale(50),
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        ),
                        child: Text(widget.institute == null ? "SAVE INSTITUTE" : "UPDATE INSTITUTE", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    final theme = context.theme;
    return Card(
      margin: EdgeInsets.only(bottom: context.scale(20)),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: context.scale(20), color: theme.colorScheme.primary),
                SizedBox(width: context.scale(8)),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            Divider(height: context.scale(24)),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, String label, String hint, IconData icon, TextEditingController controller) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
          SizedBox(height: context.scale(8)),
          TextFormField(
            controller: controller,
            readOnly: true,
            style: TextStyle(fontSize: context.font(14)),
            validator: (v) => v == null || v.isEmpty ? "Required" : null,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1800),
                lastDate: DateTime.now(),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                setState(() {
                  controller.text = picked.year.toString();
                });
              }
            },
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: context.scale(18)),
              contentPadding: EdgeInsets.all(context.scale(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, String hint, IconData icon, TextEditingController controller, {int maxLines = 1, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
          SizedBox(height: context.scale(8)),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: context.font(14)),
            validator: validator ?? (v) => v == null || v.isEmpty ? "Required" : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: context.scale(18)),
              contentPadding: EdgeInsets.all(context.scale(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Institute Status", style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
          SizedBox(height: context.scale(8)),
          DropdownButtonFormField<String>(
            value: _status,
            style: TextStyle(fontSize: context.font(14), color: theme.textTheme.bodyMedium?.color),
            items: ["Active", "Inactive"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _status = v!),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.check_circle_outline, size: context.scale(18)),
              contentPadding: EdgeInsets.all(context.scale(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(BuildContext context, String label) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    String displayText = _fileName ?? "No Logo Chosen";

    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
          SizedBox(height: context.scale(8)),
          InkWell(
            onTap: _pickLogo,
            borderRadius: BorderRadius.circular(context.scale(12)),
            child: Container(
              height: context.scale(56),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(context.scale(12)),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: context.scale(120),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(context.scale(12)), bottomLeft: Radius.circular(context.scale(12))),
                    ),
                    alignment: Alignment.center,
                    child: Text("Choose Logo", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(13))),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: context.scale(12)),
                      child: Text(displayText, 
                          style: TextStyle(color: theme.hintColor, fontSize: context.font(13)),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
