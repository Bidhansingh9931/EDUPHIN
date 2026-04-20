import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildLabel(BuildContext context, String text) {
  final theme = context.theme;
  return Padding(
    padding: EdgeInsets.only(top: context.spacing, bottom: context.spacing / 2),
    child: Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
        fontSize: context.font(14),
      ),
    ),
  );
}

Widget buildTextField(BuildContext context, TextEditingController controller, String hint, {bool isPassword = false, IconData? prefixIcon, bool readOnly = false, int maxLines = 1}) {
  final theme = context.theme;
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    readOnly: readOnly,
    maxLines: maxLines,
    style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: context.scale(20)) : null,
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.spacing / 1.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
      ),
    ),
  );
}

Widget buildDateField(BuildContext context, TextEditingController controller, String hint) {
  final theme = context.theme;
  return TextFormField(
    controller: controller,
    readOnly: true,
    style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(Icons.calendar_today_rounded, size: context.scale(18), color: theme.colorScheme.primary),
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.spacing / 1.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
      ),
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

Widget buildDropdown<T>(
  BuildContext context,
  List<T> items,
  T? selectedValue,
  ValueChanged<T?> onChanged, {
  String hint = "Select",
  String Function(T)? itemBuilder,
  String? Function(T?)? validator,
  bool isLoading = false,
}) {
  final theme = context.theme;
  final uniqueItems = items.toSet().toList();
  T? effectiveValue;
  if (selectedValue != null) {
    try {
      effectiveValue = uniqueItems.firstWhere((item) => item == selectedValue);
    } catch (_) {
      effectiveValue = null;
    }
  }

  return DropdownButtonFormField<T?>(
    value: effectiveValue,
    decoration: InputDecoration(
      hintText: isLoading ? "Loading..." : hint,
      prefixIcon: isLoading 
        ? Container(
            padding: const EdgeInsets.all(12),
            width: context.scale(20),
            height: context.scale(20),
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : null,
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.spacing / 1.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
      ),
    ),
    isExpanded: true,
    icon: IgnorePointer(
      child: Icon(Icons.keyboard_arrow_down_rounded, size: context.scale(24), color: theme.colorScheme.primary),
    ),
    disabledHint: Text(isLoading ? "Loading..." : (items.isEmpty ? "No items available" : hint)),
    dropdownColor: theme.colorScheme.surfaceContainerHigh,
    items: isLoading ? null : uniqueItems.map((item) {
      String displayValue = itemBuilder != null ? itemBuilder(item) : item.toString();
      return DropdownMenuItem<T>(
        value: item,
        child: Text(displayValue, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))),
      );
    }).toList(),
    onChanged: isLoading ? null : onChanged,
    validator: validator,
  );
}

Widget buildFilterCard(BuildContext context, {required List<Widget> children}) {
  final theme = context.theme;
  return Card(
    elevation: 0,
    color: theme.colorScheme.surfaceContainerLow,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.symmetric(horizontal: context.pagePadding.left, vertical: context.spacing / 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.scale(20)),
      side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
    ),
    child: Padding(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}


Widget buildResponsiveRow(BuildContext context, List<Widget> children) {
  if (context.isMobile) return Column(children: children);
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children
        .map((c) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: children.indexOf(c) != children.length - 1 ? context.spacing : 0),
                child: c,
              ),
            ))
        .toList(),
  );
}

Widget buildActionButton(BuildContext context, String label, VoidCallback onPressed, {bool isPrimary = true}) {
  final theme = context.theme;
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
      foregroundColor: isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
      minimumSize: Size(double.infinity, context.scale(48)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
    ),
    child: Text(label, style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
  );
}
