import 'package:flutter/material.dart';

class AddNewRemarksPage extends StatefulWidget {
  const AddNewRemarksPage({super.key});

  @override
  State<AddNewRemarksPage> createState() => _AddNewRemarksPageState();
}

class _AddNewRemarksPageState extends State<AddNewRemarksPage> {
  String? _selectedRemarkType = 'Positive';
  final _descriptionController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addRemark() async {
    if (_selectedRemarkType == null ||
        _descriptionController.text.isEmpty ||
        _fromDateController.text.isEmpty ||
        _toDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final remarkData = {
      'type': _selectedRemarkType,
      'description': _descriptionController.text,
      'from_date': _fromDateController.text,
      'to_date': _toDateController.text,
    };

    print('Adding remark: $remarkData');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remark added successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Remark"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Remark Type"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRemarkType,
                items: ['Positive', 'Negative'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRemarkType = newValue;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Description"),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Enter remark description...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text("From Date"),
              const SizedBox(height: 8),
              TextField(
                controller: _fromDateController,
                readOnly: true,
                onTap: () => _selectDate(context, _fromDateController),
                decoration: const InputDecoration(
                  hintText: "Select From Date",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 16),
              const Text("To Date"),
              const SizedBox(height: 8),
              TextField(
                controller: _toDateController,
                readOnly: true,
                onTap: () => _selectDate(context, _toDateController),
                decoration: const InputDecoration(
                  hintText: "Select To Date",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addRemark,
                  child: _isLoading
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : const Text("Add Remark"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }
}
