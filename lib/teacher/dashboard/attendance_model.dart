class StudentForAttendance {
  final int id;
  final String name;
  final String rollNo;

  StudentForAttendance({
    required this.id,
    required this.name,
    required this.rollNo,
  });

  factory StudentForAttendance.fromJson(Map<String, dynamic> json) {
    final userDetail = json['user_detail'] ?? {};
    return StudentForAttendance(
      id: json['id'],
      name: userDetail['name'] ?? 'N/A',
      rollNo: json['roll_no'] ?? 'N/A',
    );
  }
}

class AttendanceRecord {
  String status;
  String? remarks;

  AttendanceRecord({required this.status, this.remarks});

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      status: json['status'] ?? 'Absent',
      remarks: json['remarks'] ?? '',
    );
  }
}
