import 'package:flutter/material.dart';

class UiHelper {
  static Widget customTextField(
    BuildContext context,
    TextEditingController controller,
    String text,
    IconData prefixIconData,
    bool toHide, {
    IconData? suffixIcon,
    VoidCallback? onSuffixPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: toHide,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIconData),
          hintText: text,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon),
                  onPressed: onSuffixPressed,
                )
              : null,
        ),
      ),
    );
  }

  static Widget customButton(BuildContext context, VoidCallback voidCallback, String text) {
    return ElevatedButton(
      onPressed: voidCallback,
      child: Text(text),
    );
  }
}
