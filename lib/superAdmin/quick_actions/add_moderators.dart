import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/material.dart';

class AddModeratorsQuickAction extends StatefulWidget {
  const AddModeratorsQuickAction({super.key});

  @override
  State<AddModeratorsQuickAction> createState() => _AddModeratorsQuickActionState();
}

class _AddModeratorsQuickActionState extends State<AddModeratorsQuickAction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register New Moderator"),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildSection(
                  context,
                  title: "Account Information",
                  subtitle: "Set up login credentials for the moderator.",
                  children: [
                    _buildTextField(context, "User Name *", "e.g., john.doe", Icons.person_outline),
                    _buildTextField(context, "Email *", "e.g., john.doe@example.com", Icons.email_outlined),
                    _buildTextField(context, "Password *", "Enter Password", Icons.lock_outline),
                  ],
                ),
                _buildSection(
                  context,
                  title: "Personal Information",
                  subtitle: "Provide the moderator's personal details.",
                  children: [
                    _buildResponsiveRow(context, [
                      _buildDropdown(context, "Gender *", "Select Gender"),
                      _buildTextField(context, "Date of Birth *", "dd-mm-yyyy", Icons.calendar_today),
                    ]),
                    _buildResponsiveRow(context, [
                      _buildTextField(context, "Phone *", "8976451230", Icons.phone_android),
                      _buildTextField(context, "Email", "Default", Icons.email),
                    ]),
                    _buildTextField(context, "Alternate Phone", "e.g., Single Address", Icons.phone),
                    _buildFilePicker(context, "Moderator Photo"),
                  ],
                ),
                _buildSection(
                  context,
                  title: "Address Information",
                  subtitle: "Provide the moderator's physical address.",
                  children: [
                    _buildTextField(context, "Address *", "Enter Full Address", Icons.location_on_outlined),
                    _buildResponsiveRow(context, [
                      _buildTextField(context, "City *", "e.g., Jaipur", Icons.location_city),
                      _buildTextField(context, "State *", "e.g., Rajasthan", Icons.map_outlined),
                    ]),
                    _buildTextField(context, "Pincode *", "e.g., 302001", Icons.pin_drop_outlined),
                  ],
                ),
                _buildSection(
                  context,
                  title: "Employment Information",
                  subtitle: "Details about the moderator's employment.",
                  children: [
                    _buildResponsiveRow(context, [
                      _buildTextField(context, "Position *", "e.g., Senior Moderator", Icons.work_outline),
                      _buildDropdown(context, "Employment Type *", "Select"),
                    ]),
                    _buildResponsiveRow(context, [
                      _buildTextField(context, "Joining Date *", "dd-mm-yyyy", Icons.calendar_today),
                      _buildTextField(context, "Experience *", "e.g., 5", Icons.history_edu),
                    ]),
                    _buildTextField(context, "Salary", "e.g., 50000", Icons.payments_outlined),
                    _buildTextField(context, "Reference", "Safe reference info", Icons.person_search),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text("SAVE MODERATOR DETAILS"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("BACK"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String subtitle, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
    );
  }

  Widget _buildTextField(BuildContext context, String label, String hint, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            hint: Text(value, style: const TextStyle(fontSize: 13)),
            items: const [],
            onChanged: (v) {},
            decoration: const InputDecoration(prefixIcon: Icon(Icons.list, size: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(BuildContext context, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                  ),
                  alignment: Alignment.center,
                  child: Text("Choose File", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Text("No file chosen", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
