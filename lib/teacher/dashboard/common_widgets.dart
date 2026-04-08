import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildLabel(BuildContext context, String text) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withOpacity(0.9),
      ),
    ),
  );
}

Widget buildTextField(BuildContext context, TextEditingController controller, String hint, {bool isPassword = false, IconData? prefixIcon}) {
  final theme = Theme.of(context);
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    style: theme.textTheme.bodyMedium,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
    ),
  );
}

Widget buildDateField(BuildContext context, TextEditingController controller, String hint) {
  final theme = Theme.of(context);
  return TextFormField(
    controller: controller,
    readOnly: true,
    style: theme.textTheme.bodyMedium,
    decoration: InputDecoration(
      hintText: hint,
      suffixIcon: Icon(Icons.calendar_today, size: 18, color: theme.colorScheme.primary),
    ),
    onTap: () async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
      }
    },
  );
}

Widget buildDropdown(BuildContext context, List<String> items, String? selectedValue, ValueChanged<String?> onChanged, {String hint = "Select"}) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: theme.inputDecorationTheme.fillColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.colorScheme.outline),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        value: selectedValue,
        hint: Text(hint, style: theme.inputDecorationTheme.hintStyle),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        dropdownColor: theme.colorScheme.surface,
        items: items.map((item) => DropdownMenuItem(
          value: item, 
          child: Text(item, style: theme.textTheme.bodyMedium)
        )).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

Widget buildFilterCard(BuildContext context, {required List<Widget> children}) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}

Widget buildActionButton(BuildContext context, String label, VoidCallback onPressed, {bool isPrimary = true}) {
  final theme = Theme.of(context);
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
      foregroundColor: isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
      minimumSize: const Size(double.infinity, 48),
    ),
    child: Text(label),
  );
}
