import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

import 'package:eduphin/manager_dashboard/examinations/create_new_exam.dart';
import 'package:eduphin/manager_dashboard/examinations/edit_exam.dart';
import 'package:eduphin/manager_dashboard/examinations/manage_schedule.dart';
import 'package:flutter/material.dart';

// Data model from API
class Exam {
  final int id;
  final String name;
  final String? type;
  final String examCode;
  final bool isActive;
  final String? startDate;
  final String? endDate;
  final String? description;

  Exam({
    required this.id,
    required this.name,
    this.type,
    required this.examCode,
    required this.isActive,
    this.startDate,
    this.endDate,
    this.description,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      name: json['name'] as String? ?? 'Unnamed Exam',
      type: json['type'] as String?,
      examCode: json['code'] as String? ?? 'N/A',
      isActive: json['status'] == 'active',
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      description: json['description'] as String?,
    );
  }
}

class ExamInfoPage extends StatefulWidget {
  const ExamInfoPage({super.key});

  @override
  State<StatefulWidget> createState() => _ExamInfoPageState();
}

class _ExamInfoPageState extends State<ExamInfoPage> {
  late Future<List<Exam>> _examsFuture;

  @override
  void initState() {
    super.initState();
    _examsFuture = _fetchExams();
  }

  Future<List<Exam>> _fetchExams() async {
    try {
      final response = await ApiService.get('manager/exams');
      final body = json.decode(response.body);
      if (body['status'] == true) {
        final List<dynamic> examJson = body['data'];
        return examJson.map((json) => Exam.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exams: ${body['message']}');
      }
    } catch (e) {
      // Providing a more user-friendly error message
      throw Exception('Could not fetch exams. Please check your network connection and try again.');
    }
  }

  void _refreshExams() {
    if (mounted) {
      setState(() {
        _examsFuture = _fetchExams();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateExamScreen()));
              if (result == true) {
                _refreshExams();
              }
            },
            backgroundColor: theme.colorScheme.primary,
            label: Text(
              "Create New Exam",
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onPrimary),
            ),
            icon: Icon(
              Icons.add_circle_sharp,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Exam List"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: FutureBuilder<List<Exam>>(
          future: _examsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Display the error message from the exception
              return Center(child: Text('Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No exams found.'));
            } else {
              final exams = snapshot.data!;
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return _buildListView(exams);
                  } else {
                    return _buildGridView(exams);
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildListView(List<Exam> exams) {
    return ListView.separated(
      itemCount: exams.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final exam = exams[index];
        return _buildExamCard(exam);
      },
    );
  }

  Widget _buildGridView(List<Exam> exams) {
    return GridView.builder(
      itemCount: exams.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.8, // Adjust this for best fit
      ),
      itemBuilder: (context, index) {
        final exam = exams[index];
        return _buildExamCard(exam);
      },
    );
  }

  Widget _buildExamCard(Exam exam) {
    String formattedStartDate = 'N/A';
    if (exam.startDate != null && exam.startDate!.isNotEmpty) {
      try {
        formattedStartDate = DateFormat('dd MMM yyyy').format(DateTime.parse(exam.startDate!));
      } catch (e) {
        formattedStartDate = 'Invalid Date';
      }
    }

    String formattedEndDate = 'N/A';
    if (exam.endDate != null && exam.endDate!.isNotEmpty) {
      try {
        formattedEndDate = DateFormat('dd MMM yyyy').format(DateTime.parse(exam.endDate!));
      } catch (e) {
        formattedEndDate = 'Invalid Date';
      }
    }

    final startEndDate = '$formattedStartDate - $formattedEndDate';

    return CustomExamListContainerBox(
      heading: '#${exam.id}',
      subHeading: exam.name,
      type: exam.type ?? 'N/A',
      examCode: exam.examCode,
      isActive: exam.isActive ? 'Active' : 'Inactive',
      startEndDate: startEndDate,
      onEdit: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditExamPage(
              examId: exam.id,
              examName: exam.name,
              examType: exam.type ?? 'N/A',
              examCode: exam.examCode,
              isActive: exam.isActive,
              startEndDate: startEndDate,
              description: exam.description,
            ),
          ),
        ).then((result) {
          if (result == true) {
            _refreshExams();
          }
        });
      },
      onManageSchedule: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageSchedulePage(
              examId: exam.id,
              examName: exam.name,
            ),
          ),
        ).then((result) {
          if (result == true) {
            _refreshExams();
          }
        });
      },
    );
  }
}

class CustomExamListContainerBox extends StatelessWidget {
  final String heading;
  final String subHeading;
  final String type;
  final String examCode;
  final String isActive;
  final String startEndDate;
  final VoidCallback onEdit;
  final VoidCallback onManageSchedule;

  const CustomExamListContainerBox({
    super.key,
    required this.heading,
    required this.subHeading,
    required this.type,
    required this.examCode,
    required this.isActive,
    required this.startEndDate,
    required this.onEdit,
    required this.onManageSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isActiveStatus = isActive == "Active";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDarkMode ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(heading,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(150))),
                    Container(
                        decoration: BoxDecoration(
                          color: isActiveStatus
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error.withAlpha(178),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Text(
                            isActive,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: isActiveStatus ? theme.colorScheme.onPrimary: theme.colorScheme.onError,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
                Text(subHeading,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: theme.colorScheme.onSurface)),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Type",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(150))),
                          Text(type,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Exam Code",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(150))),
                          Text(examCode,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Start Date - End Date",
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withAlpha(150))),
                    Text(startEndDate,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.secondary)),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(height: 8),
                Divider(
                  color: theme.dividerColor,
                  thickness: 1,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary.withAlpha(25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(
                          Icons.edit,
                          color: theme.colorScheme.secondary,
                          size: 16,
                        ),
                        label: Text("Edit",
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: theme.colorScheme.secondary)),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onManageSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary.withAlpha(25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Manage Schedule",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
