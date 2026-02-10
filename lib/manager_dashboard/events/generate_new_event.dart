import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class GenerateNewEvent extends StatefulWidget {
  const GenerateNewEvent({super.key});

  @override
  State<GenerateNewEvent> createState() => _GenerateNewEventState();
}

class _GenerateNewEventState extends State<GenerateNewEvent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _ticketPriceController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  File? _eventPoster;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  bool isTicked = false;
  bool openForAll = false;
  bool _isLoading = false;

  Map<String, bool> audienceSelection = {
    "Student": false,
    "Teacher": false,
    "Accountant": false,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _ticketPriceController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _pickEventPoster() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final imageSize = await imageFile.length();
      if (imageSize > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image size cannot exceed 5MB.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        _eventPoster = imageFile;
      });
    }
  }

  Future<void> _generateEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_eventPoster == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an event poster.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final startTime = '${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}:00';
      final endTime = '${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}:00';
      final date = DateFormat('dd-MM-yyyy').parse(_dateController.text);
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      List<String> selectedAudiences = [];
      if (openForAll) {
        selectedAudiences.add('all');
      } else {
        audienceSelection.forEach((key, value) {
          if (value) {
            selectedAudiences.add(key.toLowerCase());
          }
        });
      }

      final fields = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'venue': _venueController.text,
        'event_date': formattedDate,
        'start_time': startTime,
        'end_time': endTime,
        'is_ticketed': isTicked ? '1' : '0',
        if (isTicked) 'ticket_price': _ticketPriceController.text,
        if (_maxParticipantsController.text.isNotEmpty)
          'max_participants': _maxParticipantsController.text,
      };

      for (int i = 0; i < selectedAudiences.length; i++) {
        fields['audience[$i]'] = selectedAudiences[i];
      }

      final streamedResponse = await ApiService.postWithFile(
        'manager/events',
        fields,
        _eventPoster!,
        'image',
      );

      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Event generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (response.statusCode == 422 && responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          } else {
            throw Exception(firstError.toString());
          }
        } else {
          throw Exception(responseData['message'] ?? 'Failed to generate event. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateOpenForAll() {
    final allSelected = audienceSelection.values.every((element) => element);
    if (openForAll != allSelected) {
      setState(() {
        openForAll = allSelected;
      });
    }
  }

  Future<void> selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
      });
    }
  }

  Future<void> selectTime(TextEditingController controller, Function(TimeOfDay) onTimeSelected) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      if (!mounted) return;
      setState(() {
        controller.text = pickedTime.format(context);
      });
      onTimeSelected(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Generate New Event"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: constraints.maxWidth > 800
                  ? _buildWideLayout(theme)
                  : _buildNarrowLayout(theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildLeftColumn(theme)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildRightColumn(theme)),
      ],
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return Column(
      children: [
        _buildLeftColumn(theme),
        const SizedBox(height: 16),
        _buildRightColumn(theme),
      ],
    );
  }

  Column _buildLeftColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Event Title"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
          decoration: InputDecoration(
            hintText: "Enter Event Title",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        if (_eventPoster != null) Text(_eventPoster!.path),
        const Text("Event Poster"),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickEventPoster,
          child: DottedBorder(
            color: theme.hintColor,
            strokeWidth: 2,
            dashPattern: const [8, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _eventPoster != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_eventPoster!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Click to upload event poster",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "PNG, JPG, up to 5MB",
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Description"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
          decoration: InputDecoration(
            hintText: "Enter a detailed Description for the event",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        const Text("Venue"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _venueController,
          validator: (value) => value == null || value.isEmpty ? 'Please enter a venue' : null,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.location_on, color: theme.colorScheme.onPrimary),
            filled: true,
            fillColor: theme.primaryColor,
            hintText: "Enter the Venue",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Event Date"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: () => selectDate(),
          validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.calendar_month, color: theme.colorScheme.onPrimary),
            filled: true,
            fillColor: theme.primaryColor,
            hintText: "Select Event Date",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Event Start Time"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _startTimeController,
          readOnly: true,
          onTap: () => selectTime(_startTimeController, (time) {
            _selectedStartTime = time;
          }),
          validator: (value) => value == null || value.isEmpty ? 'Please select a start time' : null,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.access_time_rounded, color: theme.colorScheme.onPrimary),
            filled: true,
            fillColor: theme.primaryColor,
            hintText: "Select Start Time",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Event End Time"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _endTimeController,
          readOnly: true,
          onTap: () => selectTime(_endTimeController, (time) {
            _selectedEndTime = time;
          }),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an end time';
            }
            if (_selectedStartTime != null && _selectedEndTime != null) {
              final startTimeInMinutes = _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
              final endTimeInMinutes = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;
              if (endTimeInMinutes <= startTimeInMinutes) {
                return 'End time must be after start time';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.access_time_rounded, color: theme.colorScheme.onPrimary),
            filled: true,
            fillColor: theme.primaryColor,
            hintText: "Select End Time",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Column _buildRightColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Who can attend the event?"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16.0,
          runSpacing: 8.0,
          children: [
            ...audienceSelection.keys.map((key) {
              return CustomCheckbox(label: key, value: audienceSelection[key]!, onChanged: (val) {
                setState(() {
                  audienceSelection[key] = val!;
                  _updateOpenForAll();
                });
              });
            }),
            CustomCheckbox(
              label: "Open for all",
              value: openForAll,
              onChanged: (val) {
                setState(() {
                  openForAll = val!;
                  for (final key in audienceSelection.keys.toList()) {
                    audienceSelection[key] = val;
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text("Max Participants (Optional)"),
        const SizedBox(height: 8),
        TextFormField(
          controller: _maxParticipantsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.group, color: theme.colorScheme.onPrimary),
            hintText: "Enter max participants",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            "Ticketed Event?",
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
          ),
          value: isTicked,
          onChanged: (val) {
            setState(() {
              isTicked = val;
            });
          },
          activeThumbColor: theme.colorScheme.primary,
        ),
        if (isTicked) ...[
          const SizedBox(height: 16),
          const Text("Ticket Price"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ticketPriceController,
            keyboardType: TextInputType.number,
            validator: (value) => isTicked && (value == null || value.isEmpty) ? 'Please enter a ticket price' : null,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.currency_rupee, color: theme.colorScheme.onPrimary),
              hintText: "Enter Ticket Price",
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.primaryColor,
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _generateEvent,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text("Generate Event"),
          ),
        ),
      ],
    );
  }
}

class CustomCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const CustomCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        onChanged?.call(!value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? theme.colorScheme.primaryContainer : theme.primaryColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? theme.colorScheme.primaryContainer : theme.hintColor.withAlpha((255 * 0.4).round()),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              color: value ? theme.colorScheme.onPrimaryContainer : theme.hintColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: value ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
