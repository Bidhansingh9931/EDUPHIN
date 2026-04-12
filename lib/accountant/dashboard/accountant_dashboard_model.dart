class AccountantDashboardData {
  final UserDetail userDetail;
  final Salary? lastSalary;
  final List<Salary> salaryList;
  final List<Fine> fines;
  final List<Payment> payments;
  final List<Event> events;
  final List<Exam> exams;
  final List<Ticket> createdTickets;
  final List<Ticket> assignedTickets;
  final List<Fee> instituteFees;
  final List<Fee> classFees;
  final Map<String, String> roles;

  AccountantDashboardData({
    required this.userDetail,
    this.lastSalary,
    required this.salaryList,
    required this.fines,
    required this.payments,
    required this.events,
    required this.exams,
    required this.createdTickets,
    required this.assignedTickets,
    required this.instituteFees,
    required this.classFees,
    required this.roles,
  });

  factory AccountantDashboardData.fromJson(Map<String, dynamic> json) {
    return AccountantDashboardData(
      userDetail: UserDetail.fromJson(json['user_detail']),
      lastSalary: json['last_salary'] != null ? Salary.fromJson(json['last_salary']) : null,
      salaryList: (json['salary_list'] as List? ?? []).map((e) => Salary.fromJson(e)).toList(),
      fines: (json['fines'] as List? ?? []).map((e) => Fine.fromJson(e)).toList(),
      payments: (json['payments'] as List? ?? []).map((e) => Payment.fromJson(e)).toList(),
      events: (json['events'] as List? ?? []).map((e) => Event.fromJson(e)).toList(),
      exams: (json['exams'] as List? ?? []).map((e) => Exam.fromJson(e)).toList(),
      createdTickets: (json['created_tickets'] as List? ?? []).map((e) => Ticket.fromJson(e)).toList(),
      assignedTickets: (json['assigned_tickets'] as List? ?? []).map((e) => Ticket.fromJson(e)).toList(),
      instituteFees: (json['institute_fees'] as List? ?? []).map((e) => Fee.fromJson(e)).toList(),
      classFees: (json['class_fees'] as List? ?? []).map((e) => Fee.fromJson(e)).toList(),
      roles: Map<String, String>.from(json['roles'] ?? {}),
    );
  }
}

class UserDetail {
  final int id;
  final int userId;
  final String name;
  final String? photo;
  final String? gender;
  final String? dateOfBirth;
  final String? phone;
  final String? alternatePhone;
  final String? relationshipStatus;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? branchName;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? email;
  final String? position;
  final String? employmentType;
  final String? joiningDate;
  final String? experience;
  final String? status;
  final String? qualification;
  final String? xMarks;
  final String? xiiMarks;
  final String? aadhaarNumber;
  final String? encryptedId;

  UserDetail({
    required this.id,
    required this.userId,
    required this.name,
    this.photo,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.alternatePhone,
    this.relationshipStatus,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.branchName,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.email,
    this.position,
    this.employmentType,
    this.joiningDate,
    this.experience,
    this.status,
    this.qualification,
    this.xMarks,
    this.xiiMarks,
    this.aadhaarNumber,
    this.encryptedId,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      photo: json['photo']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      phone: json['phone']?.toString(),
      alternatePhone: json['alternate_phone']?.toString(),
      relationshipStatus: json['relationship_status']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      bankAccountNumber: json['bank_account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      bankName: json['bank_name']?.toString(),
      branchName: json['branch_name']?.toString(),
      emergencyContactName: json['emergency_contact_name']?.toString(),
      emergencyContactNumber: json['emergency_contact_number']?.toString(),
      email: json['email']?.toString(),
      position: json['position']?.toString(),
      employmentType: json['employment_type']?.toString(),
      joiningDate: json['joining_date']?.toString(),
      experience: json['experience']?.toString(),
      status: json['status']?.toString(),
      qualification: json['qualification']?.toString(),
      xMarks: json['x_marks']?.toString(),
      xiiMarks: json['xii_marks']?.toString(),
      aadhaarNumber: json['aadhaar_number']?.toString(),
      encryptedId: json['encrypted_id']?.toString(),
    );
  }

  Map<String, String> toApiData() {
    return {
      'gender': gender ?? '',
      'date_of_birth': dateOfBirth ?? '',
      'phone': phone ?? '',
      'alternate_phone': alternatePhone ?? '',
      'relationship_status': relationshipStatus ?? '',
      'address': address ?? '',
      'city': city ?? '',
      'state': state ?? '',
      'pincode': pincode ?? '',
      'bank_account_number': bankAccountNumber ?? '',
      'ifsc_code': ifscCode ?? '',
      'bank_name': bankName ?? '',
      'branch_name': branchName ?? '',
      'emergency_contact_name': emergencyContactName ?? '',
      'emergency_contact_number': emergencyContactNumber ?? '',
    };
  }
}

class Salary {
  final int id;
  final String amount;
  final String? month;
  final String? year;
  final String? paymentDate;
  final String status;
  final String? encryptedId;

  Salary({
    required this.id,
    required this.amount,
    this.month,
    this.year,
    this.paymentDate,
    required this.status,
    this.encryptedId,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: json['id'] ?? 0,
      amount: json['amount']?.toString() ?? '0',
      month: json['month']?.toString(),
      year: json['year']?.toString(),
      paymentDate: json['payment_date']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      encryptedId: json['encrypted_id']?.toString(),
    );
  }
}

class Fine {
  final int id;
  final String amount;
  final String reason;
  final String date;
  final String? encryptedId;

  Fine({
    required this.id,
    required this.amount,
    required this.reason,
    required this.date,
    this.encryptedId,
  });

  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      id: json['id'] ?? 0,
      amount: json['amount']?.toString() ?? '0',
      reason: json['reason']?.toString() ?? '',
      date: json['created_at']?.toString() ?? '',
      encryptedId: json['encrypted_id']?.toString(),
    );
  }
}

class Payment {
  final int id;
  final String amount;
  final String date;
  final String? encryptedId;

  Payment({
    required this.id,
    required this.amount,
    required this.date,
    this.encryptedId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      amount: json['amount']?.toString() ?? '0',
      date: json['created_at']?.toString() ?? '',
      encryptedId: json['encrypted_id']?.toString(),
    );
  }
}

class Event {
  final dynamic id;
  final String title;
  final String date;
  final String? description;
  final bool isTicketed;
  final String? ticketPrice;
  final String? image;
  final String? encryptedId;

  Event({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    this.isTicketed = false,
    this.ticketPrice,
    this.image,
    this.encryptedId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title']?.toString() ?? '',
      date: json['event_date']?.toString() ?? '',
      description: json['description']?.toString(),
      isTicketed: json['is_ticketed'] == 1 || json['is_ticketed'] == true,
      ticketPrice: json['ticket_price']?.toString(),
      image: json['image']?.toString(),
      encryptedId: json['encrypted_id']?.toString(),
    );
  }
}

class EventRegistration {
  final dynamic id;
  final String status;
  final String? reasonForCancel;
  final Event event;
  final String? encryptedId;

  EventRegistration({
    required this.id,
    required this.status,
    this.reasonForCancel,
    required this.event,
    this.encryptedId,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'],
      status: json['status']?.toString() ?? '',
      reasonForCancel: json['reason_for_cancel']?.toString(),
      event: Event.fromJson(json['event']),
      encryptedId: json['encrypted_id']?.toString(),
    );
  }
}

class Exam {
  final int id;
  final String name;
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? encryptedId;

  Exam({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
    this.status,
    this.encryptedId,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      status: json['status']?.toString(),
      encryptedId: json['encrypted_id']?.toString(),
    );
  }
}

class ExamPaperSchedule {
  final int id;
  final int examId;
  final String? paperName;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? venue;
  final Map<String, dynamic>? subject;

  ExamPaperSchedule({
    required this.id,
    required this.examId,
    this.paperName,
    this.date,
    this.startTime,
    this.endTime,
    this.venue,
    this.subject,
  });

  factory ExamPaperSchedule.fromJson(Map<String, dynamic> json) {
    return ExamPaperSchedule(
      id: json['id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      paperName: json['paper_name']?.toString(),
      date: json['date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      venue: json['venue']?.toString(),
      subject: json['subject'] is Map<String, dynamic> ? json['subject'] : null,
    );
  }
}

class Ticket {
  final int id;
  final String title;
  final String status;
  final String? encryptedId;

  Ticket({
    required this.id,
    required this.title,
    required this.status,
    this.encryptedId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      encryptedId: json['encrypted_id']?.toString(),
    );
  }
}

class Fee {
  final int id;
  final String feeName;
  final String amount;
  final String? description;
  final bool isOptional;
  final int? classId;
  final String? className;
  final String? encryptedId;

  Fee({
    required this.id,
    required this.feeName,
    required this.amount,
    this.description,
    required this.isOptional,
    this.classId,
    this.className,
    this.encryptedId,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['id'] ?? 0,
      feeName: json['fee_name']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      description: json['description']?.toString(),
      isOptional: json['is_optional'] == 1 || json['is_optional'] == true || json['is_optional'] == '1',
      classId: json['class_id'],
      className: json['class'] != null ? (json['class'] is Map ? json['class']['name']?.toString() : null) : null,
      encryptedId: json['encrypted_id']?.toString(),
    );
  }
}

class AccountantVirtualIdCardData {
  final UserDetail userDetail;
  final String? instituteName;
  final String? instituteAddress;
  final String name;
  final String? photoUrl;
  final String? employeeId;
  final String? position;
  final String? employmentType;
  final String? joiningDate;
  final String? phone;
  final String? email;
  final String? fullAddress;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  AccountantVirtualIdCardData({
    required this.userDetail,
    this.instituteName,
    this.instituteAddress,
    required this.name,
    this.photoUrl,
    this.employeeId,
    this.position,
    this.employmentType,
    this.joiningDate,
    this.phone,
    this.email,
    this.fullAddress,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  factory AccountantVirtualIdCardData.fromJson(Map<String, dynamic> json) {
    return AccountantVirtualIdCardData(
      userDetail: UserDetail.fromJson(json['user_detail'] ?? {}),
      instituteName: json['institute_name'],
      instituteAddress: json['institute_address'],
      name: json['name'] ?? '',
      photoUrl: json['photo_url'],
      employeeId: json['employee_id'],
      position: json['position'],
      employmentType: json['employment_type'],
      joiningDate: json['joining_date'],
      phone: json['phone'],
      email: json['email'],
      fullAddress: json['full_address'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
    );
  }
}
