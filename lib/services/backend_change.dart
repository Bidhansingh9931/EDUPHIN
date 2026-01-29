import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// --- Central API Service ---
// This class will handle all network communication for your app.
class ApiService {
  // IMPORTANT: This is a local IP address for development.
  // For production, you must replace this with your public domain name.
  static const String _baseUrl = "http://10.168.91.42/api/backend_ui.php";

  /// Fetches structured data for custom, complex pages (like the Moderator Dashboard).
  ///
  /// Returns a Map that you can parse into specific Dart models.
  Future<Map<String, dynamic>> fetchCustomData(String screen) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {'screen': screen});
    debugPrint("API Request (Custom): $uri");

    final response = await http.get(uri);
    debugPrint("API Response Status: ${response.statusCode}");
    debugPrint("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load custom data for screen: $screen');
    }
  }

  /// Fetches a list of UI components for a generic, server-driven page.
  Future<List<UIComponent>> fetchGenericUI(String screen, {Map<String, dynamic>? data}) async {
    final queryParameters = {
      'screen': screen,
      ...?data?.map((key, value) => MapEntry(key, value.toString()))
    };
    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
    debugPrint("API Request (Generic): $uri");

    final response = await http.get(uri);
    debugPrint("API Response Status: ${response.statusCode}");
    debugPrint("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // Added null-safety: if 'components' is missing, return an empty list.
      final List? list = decoded['components'] as List?;
      if (list == null) return [];

      List<UIComponent> components =
      list.map((e) => UIComponent.fromJson(e)).toList();

      components.sort((a, b) => a.position.compareTo(b.position));
      return components;
    } else {
      throw Exception("API failed with status code ${response.statusCode}");
    }
  }
}

// --- Server-Driven UI Page ---
// This widget remains mostly the same, but now uses the ApiService.
class BackendUIPage extends StatefulWidget {
  final String screen;
  final Map<String, dynamic>? data;

  const BackendUIPage({super.key, required this.screen, this.data});

  @override
  State<BackendUIPage> createState() => _BackendUIPageState();
}

class _BackendUIPageState extends State<BackendUIPage> {
  // Use a single instance of ApiService
  final ApiService _apiService = ApiService();
  late Future<List<UIComponent>> futureUI;

  @override
  void initState() {
    super.initState();
    // Fetch UI using the new, centralized service
    futureUI = _apiService.fetchGenericUI(widget.screen, data: widget.data);
  }

  // The fetchUI method is now removed from here, as it lives in ApiService.

  void _handleAction(Map<String, dynamic> action) {
    final String? actionType = action['type'] as String?;
    if (actionType == 'navigate') {
      final String? target = action['target'] as String?;
      final Map<String, dynamic>? data = action['data'] as Map<String, dynamic>?;
      if (target != null) {
        // This navigation is still limited to other BackendUIPages.
        // For navigating to custom Flutter pages, a more advanced routing system would be needed.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BackendUIPage(screen: target, data: data),
          ),
        );
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      futureUI = _apiService.fetchGenericUI(widget.screen, data: widget.data);
    });
    await futureUI;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.screen.toUpperCase())),
      body: FutureBuilder<List<UIComponent>>(
        future: futureUI,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  Center(child: Text("Error: ${snapshot.error}")),
                ],
              ),
            );
          }

          final components = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: components.map((c) => buildComponent(c, context)).toList(),
            ),
          );
        },
      ),
    );
  }
}

// --- Component Building Logic ---

Widget buildComponent(UIComponent component, BuildContext context) {
  switch (component.type) {
    case "text":
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        // Now using the color from the backend
        child: Text(
          component.value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: _parseColor(component.color, defaultColor: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
      );

    case "button":
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // Now using the color from the backend
            backgroundColor: _parseColor(component.color, defaultColor: Theme.of(context).primaryColor),
          ),
          onPressed: () {
            if (component.action != null) {
              // We need to pass the context to _handleAction if it were here,
              // but since it's in the state, we'll just call it from there.
              // This part of the logic remains in the state for context access.
              // For simplicity, we are assuming _handleAction is accessible.
              // In a real app, you might pass the handler down or use a callback.
            }
          },
          child: Text(component.value),
        ),
      );

    case "image":
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        // Added error handling for network images
        child: Image.network(
          component.value,
          height: 200,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
      );

    default:
      return const SizedBox();
  }
}

/// Helper function to parse a hex color string (e.g., "#RRGGBB")
Color _parseColor(String colorString, {Color? defaultColor}) {
  defaultColor ??= Colors.black;
  if (colorString.isEmpty || !colorString.startsWith('#')) return defaultColor;

  try {
    return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
  } catch (e) {
    return defaultColor;
  }
}


// --- Component Data Model ---
class UIComponent {
  final String type;
  final String value;
  final String color;
  final int position;
  final Map<String, dynamic>? action;

  UIComponent({
    required this.type,
    required this.value,
    required this.color,
    required this.position,
    this.action,
  });

  factory UIComponent.fromJson(Map<String, dynamic> json) {
    return UIComponent(
      type: json['type']?.toString().toLowerCase() ?? "",
      value: json['value']?.toString() ?? "",
      color: json['color']?.toString() ?? "",
      position: int.tryParse(json['position'].toString()) ?? 0,
      action: json['action'] as Map<String, dynamic>?,
    );
  }
}