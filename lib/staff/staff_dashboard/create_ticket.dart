import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StaffCreateTicketPage extends StatefulWidget {
  const StaffCreateTicketPage({super.key});

  @override
  State<StaffCreateTicketPage> createState() => _StaffCreateTicketPageState();
}

class _StaffCreateTicketPageState extends State<StaffCreateTicketPage> {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color bgColor = Color(0xFF0F1630);
  static const Color cardColor = Color(0xFF1D2645);

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  String _selectedPriority = "low";
  bool _isLoading = false;

  Future<void> _submitTicket() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.createStaffTicket({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'priority': _selectedPriority,
        'category': _categoryController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket created successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text("Create New Support Ticket", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel("Issue Title *"),
              const SizedBox(height: 12),
              _buildTextField(hintText: "Enter title", controller: _titleController),
              const SizedBox(height: 24),
              _buildFieldLabel("Issue Description *"),
              const SizedBox(height: 12),
              _buildTextField(hintText: "Describe your problem", maxLines: 5, controller: _descriptionController),
              const SizedBox(height: 24),
              _buildFieldLabel("Priority *"),
              const SizedBox(height: 12),
              _buildPriorityDropdown(),
              const SizedBox(height: 24),
              _buildFieldLabel("Category (Optional)"),
              const SizedBox(height: 12),
              _buildTextField(hintText: "e.g. , login, technical", controller: _categoryController),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("SUBMIT TICKET", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("BACK", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14));
  }

  Widget _buildTextField({required String hintText, int maxLines = 1, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPriority,
          isExpanded: true,
          dropdownColor: cardColor,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          items: ["low", "medium", "high"].map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
          onChanged: (val) => setState(() => _selectedPriority = val!),
        ),
      ),
    );
  }
}
