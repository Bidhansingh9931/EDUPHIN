import 'package:flutter/material.dart';

// --- Data Model for original schedule details ---
class OriginalScheduleDetails {
  final String className;
  final String subject;
  final String teacher;
  final String time;

  const OriginalScheduleDetails({
    required this.className,
    required this.subject,
    required this.teacher,
    required this.time,
  });
}


class OverrideSchedulePage extends StatefulWidget{
  final OriginalScheduleDetails scheduleDetails;

  const OverrideSchedulePage({
    super.key,
    // Use a default value for demonstration
    this.scheduleDetails = const OriginalScheduleDetails(
      className: "Class X - A",
      subject: "Mathematics",
      teacher: "Mr. John Smith",
      time: "09:00 AM - 10:00 AM",
    ),
  });

  @override
  State<StatefulWidget> createState() => _OverrideSchedulePageState();
}

class _OverrideSchedulePageState extends State<OverrideSchedulePage>{
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _noteController = TextEditingController();
  final _selectedDateController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _noteController.dispose();
    _selectedDateController.dispose();
    super.dispose();
  }

  Future<void> _overrideSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final overrideData = {
      'original_schedule': {
        'class_name': widget.scheduleDetails.className,
        'subject': widget.scheduleDetails.subject,
        'teacher': widget.scheduleDetails.teacher,
        'time': widget.scheduleDetails.time,
      },
      'reason': _reasonController.text,
      'date_of_override': _selectedDateController.text,
      'note': _noteController.text,
    };

    print('Overriding schedule with data: $overrideData');

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule overridden successfully!')),
    );
    Navigator.of(context).pop();
  }


  Future<void> selectDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (!context.mounted) return;
      controller.text =
      "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Override Schedule"),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
             Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(color: theme.dividerColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _overrideSchedule,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Override"),
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
            child: Form(
              key: _formKey,
              child: constraints.maxWidth > 700
                  ? _buildWideLayout(theme)
                  : _buildNarrowLayout(theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomContainer(
          title: "Original Schedule Details",
          className: widget.scheduleDetails.className,
          subject: widget.scheduleDetails.subject,
          teacher: widget.scheduleDetails.teacher,
          time: widget.scheduleDetails.time,
        ),
        const SizedBox(height: 16),
        _buildFormFields(theme),
        const SizedBox(height: 80), // Padding for FAB
      ],
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: CustomContainer(
            title: "Original Schedule Details",
            className: widget.scheduleDetails.className,
            subject: widget.scheduleDetails.subject,
            teacher: widget.scheduleDetails.teacher,
            time: widget.scheduleDetails.time,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _buildFormFields(theme),
        ),
      ],
    );
  }

  Widget _buildFormFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reason to Override", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reasonController,
          maxLines: 5,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            hintText: "Enter reason here...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Please provide a reason' : null,
        ),
        const SizedBox(height: 16),
        Text("Date of Override", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _selectedDateController,
          readOnly: true,
          onTap: () => selectDate(context, _selectedDateController),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_month),
            filled: true,
            fillColor: theme.colorScheme.surface,
            hintText: "Select Date",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Please select a date' : null,
        ),
        const SizedBox(height: 16),
        Text("Note (optional)", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            hintText: "Enter optional note...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomContainer extends StatelessWidget{
  final String title;
  final String className;
  final String subject;
  final String teacher;
  final String time;

  const CustomContainer({
    super.key,
    required this.title,
    required this.className,
    required this.subject,
    required this.teacher,
    required this.time,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDetailRow(theme, "Class Name", className),
          const SizedBox(height: 16),
          _buildDetailRow(theme, "Subject", subject),
          const SizedBox(height: 16),
          _buildDetailRow(theme, "Teacher", teacher),
          const SizedBox(height: 16),
          _buildDetailRow(theme, "Time (From - To)", time),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
