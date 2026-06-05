import 'package:eduphin/services/responsive_helper.dart';
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
    final theme = context.theme;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scale(8.0)),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: context.font(15),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon, size: context.scale(20)),
          hintText: hintText,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, size: context.scale(20)),
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
    return SizedBox(
      width: double.infinity,
      height: context.scale(54),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: context.scale(20),
                width: context.scale(20),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: context.font(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
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
