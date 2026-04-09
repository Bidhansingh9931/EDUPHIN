import 'package:eduphin/teacher/dashboard/ticket_models.dart' show SupportTicket;

class StaffDashboardData {
  final UserDetail? userDetail;
  final Salary? lastSalary;
  final List<Event> events;
  final List<Exam> exams;
  final List<SupportTicket> tickets;
  final List<SupportTicket> assignedTickets;

  StaffDashboardData({
    this.userDetail,
    this.lastSalary,
    required this.events,
    required this.exams,
    required this.tickets,
    required this.assignedTickets,
  });

  factory StaffDashboardData.fromJson(Map<String, dynamic> json) {
    return StaffDashboardData(
      userDetail: json['user_detail'] != null ? UserDetail.fromJson(json['user_detail']) : null,
      lastSalary: json['last_salary'] != null ? Salary.fromJson(json['last_salary']) : null,
      events: (json['events'] as List? ?? []).map((e) => Event.fromJson(e)).toList(),
      exams: (json['exams'] as List? ?? []).map((e) => Exam.fromJson(e)).toList(),
      tickets: (json['tickets'] as List? ?? []).map((e) => SupportTicket.fromJson(e)).toList(),
      assignedTickets: (json['assigned_tickets'] as List? ?? []).map((e) => SupportTicket.fromJson(e)).toList(),
    );
  }
}

class UserDetail {
  final dynamic id;
  final dynamic userId;
  final String? photo;
  final String? gender;
  final String? dateOfBirth;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? phone;
  final String? alternatePhone;
  final String? relationshipStatus;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? branchName;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final User? user;

  UserDetail({
    required this.id,
    required this.userId,
    this.photo,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.phone,
    this.alternatePhone,
    this.relationshipStatus,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.branchName,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.user,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'],
      userId: json['user_id'],
      photo: json['photo'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      phone: json['phone'],
      alternatePhone: json['alternate_phone'],
      relationshipStatus: json['relationship_status'],
      bankAccountNumber: json['bank_account_number'],
      ifscCode: json['ifsc_code'],
      bankName: json['bank_name'],
      branchName: json['branch_name'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactNumber: json['emergency_contact_number'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, String> toApiData() {
    return {
      'gender': gender ?? '',
      'date_of_birth': dateOfBirth ?? '',
      'address': address ?? '',
      'city': city ?? '',
      'state': state ?? '',
      'pincode': pincode ?? '',
      'phone': phone ?? '',
      'alternate_phone': alternatePhone ?? '',
      'relationship_status': relationshipStatus ?? '',
      'bank_account_number': bankAccountNumber ?? '',
      'ifsc_code': ifscCode ?? '',
      'bank_name': bankName ?? '',
      'branch_name': branchName ?? '',
      'emergency_contact_name': emergencyContactName ?? '',
      'emergency_contact_number': emergencyContactNumber ?? '',
    };
  }
}

class User {
  final dynamic id;
  final String name;
  final String email;
  final int? roleId;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.roleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roleId: json['role_id'],
    );
  }
}

class Salary {
  final dynamic id;
  final String amount;
  final String month;
  final String year;
  final String status;
  final String? basicSalary;
  final String? netSalary;

  Salary({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
    required this.status,
    this.basicSalary,
    this.netSalary,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: json['id'],
      amount: (json['net_salary'] ?? json['amount'] ?? '0').toString(),
      month: json['month'].toString(),
      year: json['year'].toString(),
      status: json['status'] ?? '',
      basicSalary: json['basic_salary']?.toString(),
      netSalary: json['net_salary']?.toString(),
    );
  }
}

class SalaryPageData {
  final UserDetail account;
  final List<Salary> salaries;

  SalaryPageData({
    required this.account,
    required this.salaries,
  });

  factory SalaryPageData.fromJson(Map<String, dynamic> json) {
    return SalaryPageData(
      account: UserDetail.fromJson(json['account']),
      salaries: (json['salaries'] as List? ?? []).map((e) => Salary.fromJson(e)).toList(),
    );
  }
}

class SalaryDetailData {
  final Salary salary;
  final String amountInWords;

  SalaryDetailData({
    required this.salary,
    required this.amountInWords,
  });

  factory SalaryDetailData.fromJson(Map<String, dynamic> json) {
    return SalaryDetailData(
      salary: Salary.fromJson(json['salary']),
      amountInWords: json['amount_in_words'] ?? '',
    );
  }
}

class Event {
  final dynamic id;
  final String title;
  final String? description;
  final String? eventDate;
  final String? venue;
  final String? startTime;
  final String? endTime;
  final bool? isTicketed;
  final String? ticketPrice;
  final String? image;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.eventDate,
    this.venue,
    this.startTime,
    this.endTime,
    this.isTicketed,
    this.ticketPrice,
    this.image,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      eventDate: json['event_date'],
      venue: json['venue'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isTicketed: json['is_ticketed'] == 1 || json['is_ticketed'] == true,
      ticketPrice: json['ticket_price']?.toString(),
      image: json['image'],
    );
  }
}

class EventRegistration {
  final dynamic id;
  final String? encryptedId;
  final String? status;
  final Event event;

  EventRegistration({
    required this.id,
    this.encryptedId,
    this.status,
    required this.event,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'],
      encryptedId: json['encrypted_id'] ?? json['id'].toString(),
      status: json['status'],
      event: Event.fromJson(json['event'] ?? {}),
    );
  }
}

class Exam {
  final dynamic id;
  final String? encryptedId;
  final String name;
  final String? status;

  Exam({
    required this.id,
    this.encryptedId,
    required this.name,
    this.status,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      encryptedId: json['encrypted_id']?.toString() ?? json['id']?.toString(),
      name: json['name'] ?? '',
      status: json['status'],
    );
  }
}

class ExamPaperSchedule {
  final dynamic id;
  final dynamic examId;
  final String subject;
  final String date;
  final String startTime;
  final String endTime;
  final String? venue;

  ExamPaperSchedule({
    required this.id,
    required this.examId,
    required this.subject,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.venue,
  });

  factory ExamPaperSchedule.fromJson(Map<String, dynamic> json) {
    return ExamPaperSchedule(
      id: json['id'],
      examId: json['exam_id'],
      subject: json['subject_name'] ?? json['subject'] ?? '',
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      venue: json['venue'],
    );
  }
}

class Ticket {
  final dynamic id;
  final String title;
  final String status;
  final String priority;

  Ticket({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
    );
  }
}

class Fee {
  final dynamic id;
  final String name;
  final String amount;
  final String? description;

  Fee({
    required this.id,
    required this.name,
    required this.amount,
    this.description,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['id'],
      name: json['name'] ?? '',
      amount: json['amount'].toString(),
      description: json['description'],
    );
  }
}

class StudentFeeDetail {
  final dynamic id;
  final String studentName;
  final String rollNo;
  final String className;
  final List<StudentFeeItem> fees;

  StudentFeeDetail({
    required this.id,
    required this.studentName,
    required this.rollNo,
    required this.className,
    required this.fees,
  });

  factory StudentFeeDetail.fromJson(Map<String, dynamic> json) {
    return StudentFeeDetail(
      id: json['id'] ?? 0,
      studentName: json['student_name'] ?? '',
      rollNo: json['roll_no'] ?? '',
      className: json['class_name'] ?? '',
      fees: (json['fees'] as List? ?? []).map((f) => StudentFeeItem.fromJson(f)).toList(),
    );
  }
}

class StudentFeeItem {
  final String title;
  final String amount;
  final String status;

  StudentFeeItem({
    required this.title,
    required this.amount,
    required this.status,
  });

  factory StudentFeeItem.fromJson(Map<String, dynamic> json) {
    return StudentFeeItem(
      title: json['title'] ?? '',
      amount: json['amount'].toString(),
      status: json['status'] ?? 'Pending',
    );
  }
}

class StaffVirtualIdCardData {
  final User user;
  final UserDetail userDetail;

  StaffVirtualIdCardData({
    required this.user,
    required this.userDetail,
  });

  factory StaffVirtualIdCardData.fromJson(Map<String, dynamic> json) {
    return StaffVirtualIdCardData(
      user: User.fromJson(json['user'] ?? json['userDetail']?['user'] ?? {}),
      userDetail: UserDetail.fromJson(json['user_detail'] ?? json['userDetail'] ?? {}),
    );
  }
}
