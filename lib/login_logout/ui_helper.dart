import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UiHelper {
  static Widget customTextField(
    BuildContext context,
    TextEditingController controller,
    String hintText,
    IconData prefixIcon,
    bool isObscure, {
    IconData? suffixIcon,
    VoidCallback? onSuffixPressed,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon, size: 20),
          hintText: hintText,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, size: 20),
                  onPressed: onSuffixPressed,
                )
              : null,
        ),
      ),
    );
  }

  static Widget customButton(
    BuildContext context, 
    VoidCallback onPressed, 
    String text, {
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text),
    );
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
