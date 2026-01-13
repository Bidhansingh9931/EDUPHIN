import 'package:flutter/material.dart';

class UiHelper {
  static customTextField(
    BuildContext context,
    TextEditingController controller,
    String text,
    IconData prefixIconData,
    bool toHide, {
    IconData? suffixIcon,
    VoidCallback? onSuffixPressed,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: toHide,
        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          prefixIcon: Icon(
            prefixIconData,
            color: theme.hintColor,
          ),
          hintText: text,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: theme.hintColor),
                  onPressed: onSuffixPressed,
                )
              : null,
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.dividerColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.dividerColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  static customButton(BuildContext context, VoidCallback voidCallback, String text) {
    final theme = Theme.of(context);
    return SizedBox(
        height: 50,
        width: double.infinity, // Make button width responsive
        child: ElevatedButton(
            onPressed: () {
              voidCallback();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
            )));
  }
}
