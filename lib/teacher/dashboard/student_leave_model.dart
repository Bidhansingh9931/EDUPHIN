class StudentLeave {
  final int id;
  final String studentName;
  final String className;
  final String sectionName;
  final String rollNo;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final String reason;
  String status;
  final String appliedAt;

  StudentLeave({
    required this.id,
    required this.studentName,
    required this.className,
    required this.sectionName,
    required this.rollNo,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    required this.appliedAt,
  });

  factory StudentLeave.fromJson(Map<String, dynamic> json) {
    return StudentLeave(
      id: json['id'] ?? 0,
      studentName: json['student_name'] ?? '',
      className: json['class_name'] ?? '',
      sectionName: json['section_name'] ?? '',
      rollNo: json['roll_no'] ?? '',
      leaveType: json['leave_type'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      appliedAt: json['applied_at'] ?? '',
    );
  }
}
