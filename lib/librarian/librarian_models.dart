import 'package:intl/intl.dart';

class LibrarianDashboardData {
  final UserDetail? userDetail;
  final Salary? lastSalary;
  final List<Event> events;
  final List<ExamType> instituteExams;
  final List<SupportTicket> tickets;
  final List<SupportTicket> assignedTickets;
  final List<Book> books;
  final List<IssuedBook> issuedBooks;
  final List<IssuedBook> overdueBooks;
  final int totalBooksQuantity;

  LibrarianDashboardData({
    this.userDetail,
    this.lastSalary,
    required this.events,
    required this.instituteExams,
    required this.tickets,
    required this.assignedTickets,
    required this.books,
    required this.issuedBooks,
    required this.overdueBooks,
    required this.totalBooksQuantity,
  });

  factory LibrarianDashboardData.fromJson(Map<String, dynamic> json) {
    return LibrarianDashboardData(
      userDetail: (json['userDetail'] is Map<String, dynamic>) ? UserDetail.fromJson(json['userDetail']) : null,
      lastSalary: (json['lastSalary'] is Map<String, dynamic>) ? Salary.fromJson(json['lastSalary']) : null,
      events: (json['events'] as List? ?? []).map((e) => Event.fromJson(e is Map<String, dynamic> ? e : {})).toList(),
      instituteExams: (json['instituteexam'] as List? ?? []).map((e) => ExamType.fromJson(e is Map<String, dynamic> ? e : {})).toList(),
      tickets: (json['tickets'] as List? ?? []).map((e) => SupportTicket.fromJson(e is Map<String, dynamic> ? e : {})).toList(),
      assignedTickets: (json['assigntickets'] as List? ?? []).map((e) => SupportTicket.fromJson(e is Map<String, dynamic> ? e : {})).toList(),
      books: (json['books'] as List? ?? []).map((e) => Book.fromJson(e is Map<String, dynamic> ? e : {})).toList(),
      issuedBooks: (json['issuebook'] as List? ?? []).map((e) => IssuedBook.fromJson(e is Map<String, dynamic> ? e : {})).toList(),
      overdueBooks: (json['overduebook'] as List? ?? []).map((e) => IssuedBook.fromJson(e is Map<String, dynamic> ? e : {})).toList(),
      totalBooksQuantity: int.tryParse(json['totalBooksQuantity']?.toString() ?? '0') ?? 0,
    );
  }
}

class UserDetail {
  final int id;
  final int userId;
  final String? firstName;
  final String? lastName;
  final String? photo;
  final String? employeeId;
  final String? email;
  final String? phone;
  final String? address;
  final String? gender;
  final String? dob;
  final String? city;
  final String? state;
  final String? pincode;
  final String? alternatePhone;
  final String? relationshipStatus;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? branchName;
  final String? emergencyContactName;
  final String? emergencyContactNumber;

  UserDetail({
    required this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.photo,
    this.employeeId,
    this.email,
    this.phone,
    this.address,
    this.gender,
    this.dob,
    this.city,
    this.state,
    this.pincode,
    this.alternatePhone,
    this.relationshipStatus,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.branchName,
    this.emergencyContactName,
    this.emergencyContactNumber,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      photo: json['photo']?.toString(),
      employeeId: json['employee_id']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      gender: json['gender']?.toString(),
      dob: json['date_of_birth']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      alternatePhone: json['alternate_phone']?.toString(),
      relationshipStatus: json['relationship_status']?.toString(),
      bankAccountNumber: json['bank_account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      bankName: json['bank_name']?.toString(),
      branchName: json['branch_name']?.toString(),
      emergencyContactName: json['emergency_contact_name']?.toString(),
      emergencyContactNumber: json['emergency_contact_number']?.toString(),
    );
  }

  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();
}

class Salary {
  final int id;
  final String amount;
  final String? paymentDate;
  final String? status;

  Salary({
    required this.id,
    required this.amount,
    this.paymentDate,
    this.status,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      amount: json['amount']?.toString() ?? '0',
      paymentDate: (json['payment_date'] ?? json['created_at'])?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class Event {
  final int id;
  final String title;
  final String? description;
  final String? eventDate;
  final String? venue;
  final String? startTime;
  final String? endTime;
  final bool isTicketed;
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
    required this.isTicketed,
    this.ticketPrice,
    this.image,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'N/A',
      description: json['description']?.toString(),
      eventDate: json['event_date']?.toString(),
      venue: json['venue']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      isTicketed: json['is_ticketed'] == 1 || json['is_ticketed'] == true || json['is_ticketed'] == '1',
      ticketPrice: json['ticket_price']?.toString(),
      image: json['image']?.toString(),
    );
  }
}

class EventRegistration {
  final int id;
  final int eventId;
  final int userId;
  final String status;
  final String? registeredAt;
  final String? reasonForCancel;
  final Event event;

  EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    this.registeredAt,
    this.reasonForCancel,
    required this.event,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      eventId: int.tryParse(json['event_id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'Unknown',
      registeredAt: json['registered_at']?.toString(),
      reasonForCancel: json['reason_for_cancel']?.toString(),
      event: Event.fromJson(json['event'] ?? {}),
    );
  }
}

class ExamType {
  final int id;
  final String name;
  final String? status;

  ExamType({
    required this.id,
    required this.name,
    this.status,
  });

  factory ExamType.fromJson(Map<String, dynamic> json) {
    return ExamType(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'N/A',
      status: json['status']?.toString(),
    );
  }
}

class SupportTicket {
  final int id;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final String? category;
  final String? createdAt;
  final String? assignedToName;

  SupportTicket({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.category,
    this.createdAt,
    this.assignedToName,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'N/A',
      description: json['description']?.toString(),
      priority: json['priority']?.toString() ?? 'Low',
      status: json['status']?.toString() ?? 'Open',
      category: json['category']?.toString(),
      createdAt: json['created_at']?.toString(),
      assignedToName: json['assigned_to_user']?['name']?.toString(),
    );
  }
}

class Book {
  final int id;
  final String title;
  final String? author;
  final String? isbn;
  final String? category;
  final int quantity;
  final String? createdAt;

  Book({
    required this.id,
    required this.title,
    this.author,
    this.isbn,
    this.category,
    required this.quantity,
    this.createdAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'N/A',
      author: json['author']?.toString(),
      isbn: json['isbn']?.toString(),
      category: json['category']?.toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString(),
    );
  }
}

class IssuedBook {
  final int id;
  final int bookId;
  final int? issuedToId;
  final String? bookTitle;
  final String? lenderName;
  final String? issuedAt;
  final String? dueDate;
  final String? returnedAt;

  IssuedBook({
    required this.id,
    required this.bookId,
    this.issuedToId,
    this.bookTitle,
    this.lenderName,
    this.issuedAt,
    this.dueDate,
    this.returnedAt,
  });

  factory IssuedBook.fromJson(Map<String, dynamic> json) {
    final lender = json['lender'] ?? json['issued_to_user'] ?? json['user'];
    return IssuedBook(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      bookId: int.tryParse(json['book_id']?.toString() ?? '0') ?? 0,
      issuedToId: int.tryParse(json['issued_to']?.toString() ?? '') ?? int.tryParse(lender?['id']?.toString() ?? ''),
      bookTitle: (json['book']?['title'] ?? json['book_title'])?.toString(),
      lenderName: (lender?['name'] ?? lender?['full_name'])?.toString(),
      issuedAt: (json['issued_at'] ?? json['created_at'])?.toString(),
      dueDate: (json['due_date'] ?? json['return_date'])?.toString(),
      returnedAt: json['returned_at']?.toString(),
    );
  }
}
