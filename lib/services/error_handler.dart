import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

/// Centralized Error Handler for Eduphin
///
/// This class maps technical exceptions and API errors to short,
/// user-friendly messages and provides a standard way to display them.
class ErrorHandler {
  /// Maps any dynamic error/exception to a user-friendly String message.
  static String getMessage(dynamic error) {
    if (error == null) return "An unexpected error occurred.";

    // Handle standard Dart/IO exceptions
    if (error is SocketException) {
      return "No internet connection. Please check your network.";
    } else if (error is TimeoutException) {
      return "Request took too long. Please try again.";
    } else if (error is FormatException) {
      return "Received invalid data from server.";
    } else if (error is NetworkException) {
      return error.message;
    } else if (error is ApiException) {
      return error.message;
    }

    final String errorString = error.toString().toLowerCase();

    // Map common HTTP status codes or error patterns
    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return "Session expired. Please log in again.";
    } else if (errorString.contains('403')) {
      return "You don't have permission for this action.";
    } else if (errorString.contains('404')) {
      return "The requested information could not be found.";
    } else if (errorString.contains('400')) {
      return "Invalid request. Please check your input.";
    } else if (errorString.contains('422')) {
      return "Validation failed. Please check the provided data.";
    } else if (errorString.contains('429')) {
      return "Too many requests. Please wait a moment.";
    } else if (errorString.contains('500') || errorString.contains('server error')) {
      return "Something went wrong. Please try later.";
    } else if (errorString.contains('502') || errorString.contains('503')) {
      return "Server is temporarily unavailable. Please try again soon.";
    } else if (errorString.contains('login failed') || errorString.contains('incorrect email or password')) {
      return "Incorrect email or password.";
    } else if (errorString.contains('connection failed') || errorString.contains('failed to fetch') || errorString.contains('network_error')) {
      return "No internet connection. Please check your network.";
    } else if (errorString.contains('timeout')) {
      return "Request took too long. Try again.";
    }


    // Attempt to extract message from "Exception: Message"
    if (error.toString().startsWith('Exception: ')) {
      return error.toString().replaceFirst('Exception: ', '');
    }

    return "Something went wrong. Please try again.";
  }

  /// Shows a user-friendly error message in a SnackBar.
  ///
  /// Usage: ErrorHandler.showError(context, error);
  static void showError(BuildContext context, dynamic error) {
    if (!context.mounted) return;
    
    final message = getMessage(error);
    log(error); // Log for internal debugging

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// Logs the error for debugging purposes (internal only).
  static void log(dynamic error, [StackTrace? stack]) {
    debugPrint('🚨 [ErrorHandler] Caught: $error');
    if (stack != null) {
      debugPrint('📜 StackTrace: $stack');
    }
  }
}

/// Custom exception for network-related issues.
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = "No internet connection."]);
  @override
  String toString() => message;
}

/// Custom exception for API-related issues.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}
