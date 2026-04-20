
class CounselorDashboardData {
  final UserDetail userDetail;
  final Salary? lastSalary;
  final List<Event> events;
  final List<ExamType> instituteExam;
  final List<SupportTicket> tickets;
  final List<SupportTicket> assignedTickets;
  final List<Section> sections;
  final List<Subject> subjects;
  final List<ClassSchedule> schedules;
  final List<UserDetail> accounts;

  CounselorDashboardData({
    required this.userDetail,
    this.lastSalary,
    required this.events,
    required this.instituteExam,
    required this.tickets,
    required this.assignedTickets,
    required this.sections,
    required this.subjects,
    required this.schedules,
    required this.accounts,
  });

  factory CounselorDashboardData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> source = json['data'] is Map<String, dynamic> ? json['data'] : json;

    List<T> parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
      if (data == null) return [];
      Iterable rawList = [];
      if (data is Iterable) {
        rawList = data;
      } else if (data is Map && data['data'] is Iterable) {
        rawList = data['data'];
      }
      return rawList.whereType<Map<String, dynamic>>().map((e) => fromJson(e)).toList();
    }

    return CounselorDashboardData(
      userDetail: UserDetail.fromJson(source['userDetail'] is Map ? source['userDetail'] : (source['account'] is Map ? source['account'] : source)),
      lastSalary: source['lastSalary'] is Map ? Salary.fromJson(source['lastSalary']) : null,
      events: parseList(source['events'], Event.fromJson),
      instituteExam: parseList(source['exams'] ?? source['instituteexam'], ExamType.fromJson),
      tickets: parseList(source['myTickets'] ?? source['tickets'], SupportTicket.fromJson),
      assignedTickets: parseList(source['assignedTickets'] ?? source['assigntickets'], SupportTicket.fromJson),
      sections: parseList(source['sections'], Section.fromJson),
      subjects: parseList(source['subjects'] ?? source['subject'], Subject.fromJson),
      schedules: parseList(source['schedules'], ClassSchedule.fromJson),
      accounts: parseList(source['accounts'] ?? source['account'], UserDetail.fromJson),
    );
  }
}

class UserDetail {
  final int id;
  final int userId;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? alternatePhone;
  final String? gender;
  final String? dateOfBirth;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? photo;
  final String? position;
  final String? employeeId;
  final String? joiningDate;
  final String? status;
  final String? qualification;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? branchName;
  final String? relationshipStatus;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? aadharNumber;
  final String? xMarks;
  final String? xiiMarks;
  final String? salary;
  final String? experience;

  UserDetail({
    required this.id,
    required this.userId,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.alternatePhone,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.photo,
    this.position,
    this.employeeId,
    this.joiningDate,
    this.status,
    this.qualification,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.branchName,
    this.relationshipStatus,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.aadharNumber,
    this.xMarks,
    this.xiiMarks,
    this.salary,
    this.experience,
  });

  String get fullName {
    if (name != null && name!.isNotEmpty) return name!;
    if ((firstName == null || firstName!.isEmpty) && (lastName == null || lastName!.isEmpty)) {
      return "Unknown User";
    }
    return "${firstName ?? ''} ${lastName ?? ''}".trim();
  }

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return UserDetail(id: 0, userId: 0);
    
    Map<String, dynamic> data = json;
    Map<String, dynamic> userData = json['user'] is Map<String, dynamic> ? json['user'] : (json['account'] is Map<String, dynamic> ? json['account'] : json);

    return UserDetail(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? userData['id'] ?? 0,
      name: (data['name'] ?? userData['name'])?.toString(),
      firstName: (data['first_name'] ?? data['firstname'] ?? userData['first_name'])?.toString(),
      lastName: (data['last_name'] ?? data['lastname'] ?? userData['last_name'])?.toString(),
      email: (data['email'] ?? userData['email'] ?? json['email'])?.toString(),
      phone: (data['phone'] ?? json['phone'] ?? userData['phone'])?.toString(),
      alternatePhone: (data['alternate_phone'] ?? data['alt_phone'])?.toString(),
      gender: data['gender']?.toString(),
      dateOfBirth: data['date_of_birth']?.toString(),
      address: data['address']?.toString(),
      city: data['city']?.toString(),
      state: data['state']?.toString(),
      pincode: data['pincode']?.toString(),
      photo: (data['photo'] ?? 
              data['profile_image'] ?? 
              userData['photo'] ?? 
              userData['profile_image'] ?? 
              data['image'] ?? 
              data['avatar'])?.toString(),
      position: (data['position'] ?? data['designation'] ?? userData['role']?['name'])?.toString(),
      employeeId: (data['employee_id'] ?? data['id']?.toString())?.toString(),
      joiningDate: (data['joining_date'] ?? data['date_of_joining'])?.toString(),
      status: (data['status'] ?? json['status'])?.toString(),
      qualification: data['qualification']?.toString(),
      bankAccountNumber: data['bank_account_number']?.toString(),
      ifscCode: data['ifsc_code']?.toString(),
      bankName: data['bank_name']?.toString(),
      branchName: data['branch_name']?.toString(),
      relationshipStatus: data['relationship_status']?.toString(),
      emergencyContactName: data['emergency_contact_name']?.toString(),
      emergencyContactNumber: (data['emergency_contact_number'] ?? data['emergency_contact_phone'])?.toString(),
      aadharNumber: data['aadhar_number']?.toString(),
      xMarks: data['x_marks']?.toString(),
      xiiMarks: data['xii_marks']?.toString(),
      salary: data['salary']?.toString(),
      experience: data['experience']?.toString(),
    );
  }
}

class CounselorVirtualIdCardData {
  final String name;
  final String email;
  final String? photoUrl;
  final String? instituteName;
  final String? instituteLogo;
  final String? instituteAddress;
  final String? institutePhone;
  final String? instituteWebsite;
  final String? employeeId;
  final String? position;
  final String? employmentType;
  final String? joiningDate;
  final String? phone;
  final String? alternatePhone;
  final String? gender;
  final String? status;
  final String? fullAddress;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? issueDate;

  CounselorVirtualIdCardData({
    required this.name,
    required this.email,
    this.photoUrl,
    this.instituteName,
    this.instituteLogo,
    this.instituteAddress,
    this.institutePhone,
    this.instituteWebsite,
    this.employeeId,
    this.position,
    this.employmentType,
    this.joiningDate,
    this.phone,
    this.alternatePhone,
    this.gender,
    this.status,
    this.fullAddress,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.issueDate,
  });

  factory CounselorVirtualIdCardData.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? json['user'] : {};
    final userDetail = json['user_detail'] is Map 
        ? json['user_detail'] 
        : (json['userDetail'] is Map ? json['userDetail'] : json);

    String address = ([
      userDetail['address'],
      userDetail['city'],
      userDetail['state'],
      userDetail['pincode']
    ].where((s) => s != null && s.toString().isNotEmpty && s.toString() != 'null').join(', '));

    return CounselorVirtualIdCardData(
      name: (user['name'] ?? 
          (userDetail['name']) ??
          (userDetail['first_name'] != null
              ? "${userDetail['first_name']} ${userDetail['last_name'] ?? ''}".trim()
              : null) ?? 
          'N/A').toString(),
      email: (user['email'] ?? userDetail['email'] ?? 'N/A').toString(),
      photoUrl: (userDetail['photo'] ?? 
                user['photo'] ?? 
                userDetail['profile_image'] ?? 
                user['profile_image'] ??
                userDetail['image'] ?? 
                userDetail['avatar'])?.toString(),
      instituteName: json['institute_name']?.toString(),
      instituteLogo: json['institute_logo']?.toString(),
      instituteAddress: json['institute_address']?.toString(),
      institutePhone: json['institute_phone']?.toString(),
      instituteWebsite: json['institute_website']?.toString(),
      employeeId: (userDetail['employee_id'] ?? userDetail['id'] ?? user['id'])?.toString(),
      position: (userDetail['designation'] ?? userDetail['position'] ?? user['role']?['name'])?.toString(),
      employmentType: userDetail['employment_type']?.toString(),
      joiningDate: (userDetail['date_of_joining'] ?? userDetail['joining_date'])?.toString(),
      phone: (userDetail['phone'] ?? user['phone'])?.toString(),
      alternatePhone: (userDetail['alternate_phone'] ?? userDetail['alt_phone'])?.toString(),
      gender: userDetail['gender']?.toString(),
      status: (userDetail['status'] ?? 'Active').toString(),
      fullAddress: address.isNotEmpty ? address : userDetail['address']?.toString(),
      emergencyContactName: userDetail['emergency_contact_name']?.toString(),
      emergencyContactPhone: (userDetail['emergency_contact_phone'] ?? userDetail['emergency_contact_number'])?.toString(),
      issueDate: json['issue_date']?.toString(),
    );
  }
}

class ClassInfo {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final String? level;
  final int status;
  final List<Section> sections;

  ClassInfo({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.level,
    this.status = 1,
    this.sections = const [],
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    Iterable rawSections = [];
    if (json['sections'] is Iterable) {
      rawSections = json['sections'];
    } else if (json['sections'] is Map && json['sections']['data'] is Iterable) {
      rawSections = json['sections']['data'];
    }
    
    return ClassInfo(
      id: json['id'] ?? 0,
      name: json['class_name'] ?? json['name'] ?? '',
      code: json['class_code'] ?? json['code'] ?? '',
      description: json['description']?.toString(),
      level: json['level']?.toString(),
      status: json['status'] ?? 1,
      sections: rawSections.whereType<Map<String, dynamic>>().map((s) => Section.fromJson(s)).toList(),
    );
  }
}

class Salary {
  final int id;
  final String amount;
  final String paymentDate;
  final String status;
  final String month;
  final String? amountInWords;

  Salary({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.status,
    required this.month,
    this.amountInWords,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? json['net_salary'] ?? '0').toString(),
      paymentDate: (json['payment_date'] ?? json['created_at'] ?? '').toString(),
      status: (json['status'] ?? 'Paid').toString(),
      month: (json['month'] ?? '').toString(),
      amountInWords: json['amount_in_words']?.toString(),
    );
  }
}

class Event {
  final int id;
  final String title;
  final String? description;
  final String? venue;
  final String? eventDate;
  final String? startTime;
  final String? endTime;
  final String? image;
  final bool isTicketed;
  final String? ticketPrice;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.venue,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.image,
    required this.isTicketed,
    this.ticketPrice,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      venue: json['venue']?.toString(),
      eventDate: json['event_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      image: json['image']?.toString(),
      isTicketed: json['is_ticketed'] == 1 || json['is_ticketed'] == true || json['is_ticketed'] == '1',
      ticketPrice: json['ticket_price']?.toString(),
    );
  }
}

class EventRegistration {
  final int id;
  final int eventId;
  final int userId;
  final String status;
  final String? registeredAt;
  final Event event;

  EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    this.registeredAt,
    required this.event,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      status: (json['status'] ?? 'registered').toString(),
      registeredAt: (json['registered_at'] ?? json['created_at'])?.toString(),
      event: Event.fromJson(json['event'] is Map ? json['event'] : (json['events'] is Map ? json['events'] : {})),
    );
  }
}

class ExamType {
  final int id;
  final String name;
  final String? type;
  final String? code;
  final String? startDate;
  final String? endDate;

  ExamType({
    required this.id,
    required this.name,
    this.type,
    this.code,
    this.startDate,
    this.endDate,
  });

  factory ExamType.fromJson(Map<String, dynamic> json) {
    return ExamType(
      id: json['id'] ?? 0,
      name: (json['name'] ?? '').toString(),
      type: json['type']?.toString(),
      code: json['code']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
    );
  }
}

class ExamPaperSchedule {
  final int id;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? roomNo;
  final String? subjectName;
  final String? className;

  ExamPaperSchedule({
    required this.id,
    this.date,
    this.startTime,
    this.endTime,
    this.roomNo,
    this.subjectName,
    this.className,
  });

  factory ExamPaperSchedule.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> subjectData = json['subject'] is Map ? json['subject'] : {};
    final Map<String, dynamic> classData = json['class'] is Map ? json['class'] : {};
    
    return ExamPaperSchedule(
      id: json['id'] ?? 0,
      date: (json['exam_date'] ?? json['date'])?.toString(),
      startTime: (json['start_time'] ?? json['start'])?.toString(),
      endTime: (json['end_time'] ?? json['end'])?.toString(),
      roomNo: (json['room_number'] ?? json['room_no'] ?? json['room'])?.toString(),
      subjectName: (subjectData['name'] ?? subjectData['subject_name'])?.toString(),
      className: (classData['class_name'] ?? classData['name'])?.toString(),
    );
  }
}

class SupportTicket {
  final int id;
  final String title;
  final String? description;
  final String? priority;
  final String? status;
  final String? category;
  final String? createdAt;

  SupportTicket({
    required this.id,
    required this.title,
    this.description,
    this.priority,
    this.status,
    this.category,
    this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      priority: json['priority']?.toString(),
      status: json['status']?.toString(),
      category: json['category']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class TicketReply {
  final int id;
  final int ticketId;
  final int userId;
  final String message;
  final String? attachment;
  final String? createdAt;
  final String? userName;

  TicketReply({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.message,
    this.attachment,
    this.createdAt,
    this.userName,
  });

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    return TicketReply(
      id: json['id'] ?? 0,
      ticketId: json['ticket_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      message: json['message'] ?? '',
      attachment: json['attachment']?.toString(),
      createdAt: json['created_at']?.toString(),
      userName: (json['user'] is Map ? "${json['user']['first_name']} ${json['user']['last_name'] ?? ''}" : null)?.trim(),
    );
  }
}

class Section {
  final int id;
  final String name;
  final int classId;

  Section({required this.id, required this.name, required this.classId});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] ?? 0,
      name: (json['name'] ?? json['section_name'] ?? '').toString(),
      classId: json['class_id'] ?? 0,
    );
  }
}

class Subject {
  final int id;
  final String name;
  final String? code;

  Subject({required this.id, required this.name, this.code});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? 0,
      name: (json['name'] ?? json['subject_name'] ?? '').toString(),
      code: (json['code'] ?? json['subject_code'] ?? '').toString(),
    );
  }
}

class ClassSchedule {
  final int id;
  final String? day;
  final String? startTime;
  final String? endTime;
  final String? className;
  final String? sectionName;
  final String? subjectName;
  final String? teacherName;

  ClassSchedule({
    required this.id,
    this.day,
    this.startTime,
    this.endTime,
    this.className,
    this.sectionName,
    this.subjectName,
    this.teacherName,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> classData = json['class'] is Map ? json['class'] : {};
    final Map<String, dynamic> sectionData = json['section'] is Map ? json['section'] : {};
    final Map<String, dynamic> subjectData = json['subject'] is Map ? json['subject'] : {};
    final Map<String, dynamic> teacherData = json['teacher'] is Map ? json['teacher'] : {};

    return ClassSchedule(
      id: json['id'] ?? 0,
      day: (json['day'] ?? json['weekday'])?.toString(),
      startTime: (json['start_time'] ?? json['start'])?.toString(),
      endTime: (json['end_time'] ?? json['end'])?.toString(),
      className: (classData['class_name'] ?? classData['name'])?.toString(),
      sectionName: (sectionData['name'] ?? sectionData['section_name'])?.toString(),
      subjectName: (subjectData['name'] ?? subjectData['subject_name'])?.toString(),
      teacherName: (teacherData['first_name'] != null)
          ? "${teacherData['first_name']} ${teacherData['last_name'] ?? ''}".trim()
          : (teacherData['name']?.toString()),
    );
  }
}

class Book {
  final int id;
  final String title;
  final String? author;
  final String? isbn;
  final String? category;
  final String? language;
  final String? format;
  final String? publicationYear;
  final int availableCopies;

  Book({
    required this.id,
    required this.title,
    this.author,
    this.isbn,
    this.category,
    this.language,
    this.format,
    this.publicationYear,
    required this.availableCopies,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      author: json['author']?.toString(),
      isbn: json['isbn']?.toString(),
      category: json['category']?.toString(),
      language: json['language']?.toString(),
      format: json['format']?.toString(),
      publicationYear: json['publication_year']?.toString(),
      availableCopies: json['available_copies'] ?? 0,
    );
  }
}

class IssuedBook {
  final int id;
  final int bookId;
  final String? issueNo;
  final String? issuedAt;
  final String? dueDate;
  final String? returnedAt;
  final Book book;

  IssuedBook({
    required this.id,
    required this.bookId,
    this.issueNo,
    this.issuedAt,
    this.dueDate,
    this.returnedAt,
    required this.book,
  });

  factory IssuedBook.fromJson(Map<String, dynamic> json) {
    return IssuedBook(
      id: json['id'] ?? 0,
      bookId: json['book_id'] ?? 0,
      issueNo: json['id']?.toString(),
      issuedAt: json['issued_at']?.toString(),
      dueDate: json['due_date']?.toString(),
      returnedAt: json['returned_at']?.toString(),
      book: Book.fromJson(json['book'] is Map ? json['book'] : {}),
    );
  }
}
