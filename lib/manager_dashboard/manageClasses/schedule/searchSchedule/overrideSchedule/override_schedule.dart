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
    if (_reasonController.text.isEmpty || _selectedDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason and a date for the override.')),
      );
      return;
    }

    // Capture context-dependent objects before async gap
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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

    // Use captured objects after async gap
    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Schedule overridden successfully!')),
    );
    navigator.pop();
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
      "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,115),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
              const Text("Reason to Override"),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.withAlpha(20),
                  hintText: "Enter reason here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Date of Override"),
              const SizedBox(height: 8),
              TextField(
                controller: _selectedDateController,
                readOnly: true,
                onTap: () => selectDate(context, _selectedDateController),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month,
                      color: theme.colorScheme.onPrimary),
                  filled: true,
                  fillColor: theme.primaryColor,
                  hintText: "Select Date",
                  hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Note (optional)"),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.withAlpha(20),
                  hintText: "Enter optional note...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _isSaving ? null : _overrideSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSaving
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : const Text("Override",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),)
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withAlpha(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ), child: const Text("Cancel",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),)
                ),
              ),

            ],
          )
        ),
      ),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text(title,style: const TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
            const SizedBox(height: 16),
            const Text("Class Name",style: TextStyle(fontSize: 12,color: Colors.white60),),
            const SizedBox(height: 5),
            Text(className,style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Subject",style: TextStyle(fontSize: 12,color: Colors.white60),),
            const SizedBox(height: 5),
            Text(subject,style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),),
            const SizedBox(height: 16),
            const Text("Teacher",style: TextStyle(fontSize: 12,color: Colors.white60),),
            const SizedBox(height: 5),
            Text(teacher,style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),),
            const SizedBox(height: 16),
            const Text("Time (From - To)",style: TextStyle(fontSize: 12,color: Colors.white60),),
            const SizedBox(height: 5),
            Text(time,style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
