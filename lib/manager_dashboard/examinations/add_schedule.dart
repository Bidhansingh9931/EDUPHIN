import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddScheduleScreen extends StatefulWidget {
  final int examId;

  const AddScheduleScreen({super.key, required this.examId});

  @override
  _AddScheduleScreenState createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _venueController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  int? _selectedClassId;
  int? _selectedSectionId;
  int? _selectedSubjectId;

  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  List<dynamic> _classes = [];
  List<dynamic> _sections = [];
  List<dynamic> _subjects = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      final response = await ApiService.get('manager/classes');
      if (response.statusCode == 200) {
        setState(() {
          _classes = json.decode(response.body)['data'];
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _fetchSections(int classId) async {
    try {
      final response = await ApiService.get('manager/classes/$classId/sections');
      if (response.statusCode == 200) {
        setState(() {
          _sections = json.decode(response.body)['data'];
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _fetchSubjects(int classId) async {
    // Assuming subjects are tied to a class. This might need adjustment.
    try {
      final response = await ApiService.get('manager/classes/$classId/subjects');
      if (response.statusCode == 200) {
        setState(() {
          _subjects = json.decode(response.body)['data'];
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? _selectedStartTime ?? TimeOfDay.now()
          : _selectedEndTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
          _startTimeController.text = picked.format(context);
        } else {
          _selectedEndTime = picked;
          _endTimeController.text = picked.format(context);
        }
      });
    }
  }

  Future<void> _addSchedule() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final body = {
          'exam_id': widget.examId.toString(),
          'class_id': _selectedClassId.toString(),
          'section_id': _selectedSectionId.toString(),
          'subject_id': _selectedSubjectId.toString(),
          'paper_date': _dateController.text,
          'start_time': _selectedStartTime != null ? '''${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}:00''' : '',
          'end_time': _selectedEndTime != null ? '''${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}:00''' : '',
          'venue': _venueController.text,
        };
        final response = await ApiService.post('manager/exam-papers', body);

        if (response.statusCode == 201 || response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule added successfully!')),
          );
          Navigator.pop(context, true); // Pop with result
        } else {
           if (!mounted) return;
          final error = json.decode(response.body)['message'] ?? 'Failed to add schedule.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error. Status: ${response.statusCode}')),
          );
        }
      } catch (e) {
         if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exam Schedule'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedClassId,
                      decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                      items: _classes.map((c) {
                        return DropdownMenuItem<int>(
                          value: c['id'],
                          child: Text(c['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClassId = value;
                          _selectedSectionId = null;
                          _selectedSubjectId = null;
                          _sections.clear();
                          _subjects.clear();
                          if (value != null) {
                            _fetchSections(value);
                            _fetchSubjects(value);
                          }
                        });
                      },
                      validator: (value) => value == null ? 'Please select a class' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedSectionId,
                      decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder()),
                      items: _sections.map((s) {
                        return DropdownMenuItem<int>(
                          value: s['id'],
                          child: Text(s['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSectionId = value;
                        });
                      },
                       validator: (value) => value == null ? 'Please select a section' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedSubjectId,
                      decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                      items: _subjects.map((s) {
                        return DropdownMenuItem<int>(
                          value: s['id'],
                          child: Text(s['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubjectId = value;
                        });
                      },
                       validator: (value) => value == null ? 'Please select a subject' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _venueController,
                      decoration: const InputDecoration(labelText: 'Venue', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a venue';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            onTap: () => _selectTime(context, true),
                             validator: (value) => value == null || value.isEmpty ? 'Please select a start time' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            onTap: () => _selectTime(context, false),
                             validator: (value) => value == null || value.isEmpty ? 'Please select an end time' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addSchedule,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Add Schedule'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
