import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';

class UpcomingEvents extends StatefulWidget {
  const UpcomingEvents({super.key});

  @override
  State<StatefulWidget> createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends State<UpcomingEvents> {
  bool _isLoading = false;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();

  bool isTicked = false;
  bool manager = false;
  bool teachers = false;
  bool students = false;
  bool staff = false;
  bool librarian = false;
  bool counselor = false;
  bool openForAll = false;
  bool accountants = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _ticketPriceController.dispose();
    super.dispose();
  }

  void _updateOpenForAll() {
    openForAll = manager &&
        teachers &&
        students &&
        staff &&
        librarian &&
        accountants &&
        counselor;
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

  Future<void> selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      if (!context.mounted) return;
      final localizations = MaterialLocalizations.of(context);
      final formattedTime = localizations.formatTimeOfDay(pickedTime);
      controller.text = formattedTime;
    }
  }

  void _generateEvent() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call to generate event.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));

    final eventData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'venue': _venueController.text,
      'date': _dateController.text,
      'startTime': _startTimeController.text,
      'endTime': _endTimeController.text,
      'isTicketed': isTicked,
      'ticketPrice': _ticketPriceController.text,
      'attendees': {
        'manager': manager,
        'teachers': teachers,
        'students': students,
        'staff': staff,
        'librarian': librarian,
        'counselor': counselor,
        'accountants': accountants,
        'openForAll': openForAll,
      }
    };

    // For demonstration, we'll just print the data.
    print('Generating event with data: $eventData');


    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event generated successfully!')),
      );
      // You might want to navigate away or clear the controllers after success.
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Generate New Event"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Event Title"),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter Event Title",
                  hintStyle:
                      theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text("Event Poster"),
              const SizedBox(height: 8),
              EventPosterUpload(),
              const SizedBox(height: 16),
              Text("Description"),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter a detailed Description for the event",
                  hintStyle:
                      theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text("Venue"),
              const SizedBox(height: 8),
              TextField(
                controller: _venueController,
                decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.location_on, color: theme.colorScheme.onPrimary),
                  filled: true,
                  fillColor: theme.primaryColor,
                  hintText: "Enter the Venue",
                  hintStyle:
                      theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("Event Date"),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => selectDate(context, _dateController),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month,
                      color: theme.colorScheme.onPrimary),
                  filled: true,
                  fillColor: theme.primaryColor,
                  hintText: "Select Event Date",
                  hintStyle:
                      theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("Event Start Time"),
              const SizedBox(height: 8),
              TextField(
                controller: _startTimeController,
                readOnly: true,
                onTap: () => selectTime(context, _startTimeController),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.access_time_rounded,
                      color: theme.colorScheme.onPrimary),
                  filled: true,
                  fillColor: theme.primaryColor,
                  hintText: "Select Start Time",
                  hintStyle:
                      theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("Event End Time"),
              const SizedBox(height: 8),
              TextField(
                controller: _endTimeController,
                readOnly: true,
                onTap: () => selectTime(context, _endTimeController),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.access_time_rounded,
                      color: theme.colorScheme.onPrimary),
                  filled: true,
                  fillColor: theme.primaryColor,
                  hintText: "Select End Time",
                  hintStyle:
                      theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("Who can attend the event?"),
              const SizedBox(height: 8),
              Row(
                children: [
                  customCheckbox(
                    "Institute Manager",
                    manager,
                    (val) {
                      setState(() {
                        manager = val!;
                        _updateOpenForAll();
                      });
                    },
                  ),
                  Spacer(),
                  SizedBox(width: 16),
                  customCheckbox(
                    "Counselors",
                    counselor,
                    (val) {
                      setState(() {
                        counselor = val!;
                        _updateOpenForAll();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  customCheckbox(
                    "Teacher",
                    teachers,
                    (val) {
                      setState(() {
                        teachers = val!;
                        _updateOpenForAll();
                      });
                    },
                  ),
                  Spacer(),
                  SizedBox(width: 16),
                  customCheckbox(
                    "Students",
                    students,
                    (val) {
                      setState(() {
                        students = val!;
                        _updateOpenForAll();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  customCheckbox(
                    "Librarians",
                    librarian,
                    (val) {
                      setState(() {
                        librarian = val!;
                        _updateOpenForAll();
                      });
                    },
                  ),
                  Spacer(),
                  SizedBox(width: 16),
                  customCheckbox(
                    "Accountants",
                    accountants,
                    (val) {
                      setState(() {
                        accountants = val!;
                        _updateOpenForAll();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  customCheckbox(
                    "Staffs",
                    staff,
                    (val) {
                      setState(() {
                        staff = val!;
                        _updateOpenForAll();
                      });
                    },
                  ),
                  Spacer(),
                  SizedBox(width: 16),
                  customCheckbox(
                    "Open for all",
                    openForAll,
                    (val) {
                      setState(() {
                        openForAll = val!;
                        manager = val;
                        teachers = val;
                        students = val;
                        staff = val;
                        librarian = val;
                        accountants = val;
                        counselor = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Ticketed Event?",style: TextStyle(fontSize: 20,color: Colors.white),),
                value: isTicked,
                onChanged: (val) {
                  setState(() {
                    isTicked = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text("Ticket Price"),
              const SizedBox(height: 8),
              TextField(
                controller: _ticketPriceController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.currency_rupee, color: Colors.white),
                  hintText: "Enter Ticket Price",
                  hintStyle:
                      theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor,
                      ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary),
                        )
                      : Text(
                          "Generate Event",
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary, fontSize: 20),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(onPressed: () { },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Cancel",
                    style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20),
                ),
              ),

              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(onPressed: ()=>showDeleteDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Delete Event",
                    style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget customCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Container(
      height: 60,
      width: 170,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2530),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            activeColor: Colors.blue,
            onChanged: onChanged,
          ),
          Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

class EventPosterUpload extends StatefulWidget {
  const EventPosterUpload({super.key});

  @override
  State<EventPosterUpload> createState() => _EventPosterUploadState();
}

class _EventPosterUploadState extends State<EventPosterUpload> {
  File? image;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pickImage,
      child: DottedBorder(
        color: Colors.grey,
        dashPattern: const [6, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2530),
            borderRadius: BorderRadius.circular(12),
          ),
          child: image == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.upload, color: Colors.white),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Upload Event Poster",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Tap to upload an image from your gallery",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
        ),
      ),
    );
  }
}

class EventDateField extends StatelessWidget {
  final TextEditingController controller;

  const EventDateField({super.key, required this.controller});

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
    return InkWell(
      onTap: () => selectDate(context, controller),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2530),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              controller.text.isEmpty ? "Select a date" : controller.text,
              style: TextStyle(
                color: controller.text.isEmpty ? Colors.grey : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
void showDeleteDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    barrierColor: Color.fromRGBO(0, 0, 0, 0.6),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return const DeleteManagerDialog(
        managerName: "Rajeev K.Malhotra",
      );
    },
  );
}
class DeleteManagerDialog extends StatelessWidget {
  final String managerName;

  const DeleteManagerDialog({
    super.key,
    required this.managerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔹 Blur Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),

          // 🔹 Center Card
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Delete Event",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Are you sure you want to delete this event? "
                        "This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔴 Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5392A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // 🔥 delete logic here
                      },
                      child: const Text(
                        "Yes, Delete",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ⚪ Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF374151),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}