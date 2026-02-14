import 'dart:async';
import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

class StudentRegistration {
  final int registrationId;
  final String studentName;
  final String rollNo;

  StudentRegistration(
      {required this.registrationId, required this.studentName, required this.rollNo});

  factory StudentRegistration.fromJson(Map<String, dynamic> json) {
    final student = json['student'];
    return StudentRegistration(
        registrationId: json['id'],
        studentName: student['user']?['name'] ?? 'N/A',
        rollNo: student['student_roll_no'] ?? 'N/A');
  }
}

class Mark {
  final TextEditingController obtainedController = TextEditingController();
  final TextEditingController maxController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
}

class EnterMarksPage extends StatefulWidget {
  final int paperId;
  final int examId;
  final int classId;
  final int sectionId;
  final int subjectId;
  final String subjectName;

  const EnterMarksPage({
    super.key,
    required this.paperId,
    required this.examId,
    required this.classId,
    required this.sectionId,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<EnterMarksPage> createState() => _EnterMarksPageState();
}

class _EnterMarksPageState extends State<EnterMarksPage> {
  bool _isLoading = true;
  String _error = '';

  List<StudentRegistration> _students = [];
  final Map<int, Mark> _marks = {};

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await ApiService.get(
          'manager/registrations/${widget.examId}/${widget.classId}/${widget.sectionId}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          _students = data.map((json) => StudentRegistration.fromJson(json)).toList();
          for (var student in _students) {
            _marks[student.registrationId] = Mark();
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _saveMarks() async {
    final Map<String, dynamic> marksPayload = {};

    _marks.forEach((registrationId, mark) {
      marksPayload[registrationId.toString()] = {
        'subject_id': widget.subjectId,
        'obtained': mark.obtainedController.text,
        'max': mark.maxController.text,
        'grade': mark.gradeController.text,
        'remark': mark.remarkController.text,
      };
    });

    try {
      final response = await ApiService.post('manager/marks/${widget.paperId}', {
        'marks': marksPayload,
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marks saved successfully!')),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to save marks');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Marks - ${widget.subjectName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMarks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: IntrinsicColumnWidth(),
                        2: IntrinsicColumnWidth(),
                        3: IntrinsicColumnWidth(),
                        4: IntrinsicColumnWidth(),
                      },
                      children: [
                        const TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Obtained', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Max', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Remark', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        ..._students.map((student) {
                          final mark = _marks[student.registrationId]!;
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(student.studentName),
                                    Text('(Roll: ${student.rollNo})'),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80,
                                  child: TextFormField(controller: mark.obtainedController),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80,
                                  child: TextFormField(controller: mark.maxController),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80,
                                  child: TextFormField(controller: mark.gradeController),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 120,
                                  child: TextFormField(controller: mark.remarkController),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
    );
  }
}
