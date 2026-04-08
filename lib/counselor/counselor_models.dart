import 'package:intl/intl.dart';

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
    // If the top level has a 'data' key, unwrap it first
    final Map<String, dynamic> source = json['data'] is Map<String, dynamic> ? json['data'] : json;

    List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
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
      events: _parseList(source['events'], Event.fromJson),
      // PHP key is 'exams', model uses 'instituteexam'
      instituteExam: _parseList(source['exams'] ?? source['instituteexam'], ExamType.fromJson),
      // PHP key is 'myTickets', model uses 'tickets'
      tickets: _parseList(source['myTickets'] ?? source['tickets'], SupportTicket.fromJson),
      // PHP key is 'assignedTickets', model uses 'assigntickets'
      assignedTickets: _parseList(source['assignedTickets'] ?? source['assigntickets'], SupportTicket.fromJson),
      sections: _parseList(source['sections'], Section.fromJson),
      subjects: _parseList(source['subjects'] ?? source['subject'], Subject.fromJson),
      schedules: _parseList(source['schedules'], ClassSchedule.fromJson),
      accounts: _parseList(source['accounts'] ?? source['account'], UserDetail.fromJson),
    );
  }
}

class UserDetail {
  final int id;
  final int userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
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

  UserDetail({
    required this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
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
  });

  String get fullName {
    if ((firstName == null || firstName!.isEmpty) && (lastName == null || lastName!.isEmpty)) {
      return "Unknown User";
    }
    return "${firstName ?? ''} ${lastName ?? ''}".trim();
  }

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return UserDetail(id: 0, userId: 0);
    
    // Check if details are nested under 'account', 'userDetail', or 'user'
    Map<String, dynamic> data = json;
    if (json['account'] is Map<String, dynamic>) {
      data = json['account'];
    } else if (json['userDetail'] is Map<String, dynamic>) {
      data = json['userDetail'];
    } else if (json['user'] is Map<String, dynamic>) {
      data = json['user'];
    }

    return UserDetail(
      id: json['id'] ?? data['id'] ?? 0,
      userId: json['user_id'] ?? data['user_id'] ?? 0,
      firstName: (data['first_name'] ?? data['firstname'] ?? data['name'])?.toString(),
      lastName: (data['last_name'] ?? data['lastname'])?.toString(),
      email: (data['email'] ?? json['email'])?.toString(),
      phone: (data['phone'] ?? json['phone'])?.toString(),
      gender: data['gender']?.toString(),
      dateOfBirth: data['date_of_birth']?.toString(),
      address: data['address']?.toString(),
      city: data['city']?.toString(),
      state: data['state']?.toString(),
      pincode: data['pincode']?.toString(),
      photo: (data['photo'] ?? data['profile_image'])?.toString(),
      position: data['position']?.toString(),
      employeeId: (data['employee_id'] ?? data['id']?.toString())?.toString(),
      joiningDate: data['joining_date']?.toString(),
      status: (data['status'] ?? json['status'])?.toString(),
      qualification: data['qualification']?.toString(),
      bankAccountNumber: data['bank_account_number']?.toString(),
      ifscCode: data['ifsc_code']?.toString(),
      bankName: data['bank_name']?.toString(),
      branchName: data['branch_name']?.toString(),
      relationshipStatus: data['relationship_status']?.toString(),
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
      event: Event.fromJson(json['event'] is Map ? json['event'] : {}),
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
    return ExamPaperSchedule(
      id: json['id'] ?? 0,
      date: json['exam_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      roomNo: json['room_number']?.toString(),
      subjectName: (json['subject'] is Map ? json['subject']['name'] : null)?.toString(),
      className: (json['class'] is Map ? (json['class']['class_name'] ?? json['class']['name']) : null)?.toString(),
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
    return ClassSchedule(
      id: json['id'] ?? 0,
      day: json['day']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      className: (json['class'] is Map ? (json['class']['class_name'] ?? json['class']['name']) : null)?.toString(),
      sectionName: (json['section'] is Map ? json['section']['name'] : null)?.toString(),
      subjectName: (json['subject'] is Map ? json['subject']['name'] : null)?.toString(),
      teacherName: (json['teacher'] is Map && json['teacher']['first_name'] != null)
          ? "${json['teacher']['first_name']} ${json['teacher']['last_name'] ?? ''}".trim()
          : null,
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
