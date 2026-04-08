import 'dart:convert';

class StudentFeeData {
  final Student? student;
  final List<Fee> fees;
  final Map<String, Override> overrides;
  final List<Fine> fines;
  final List<Payment> payments;
  final FeeSummary summary;

  StudentFeeData({
    this.student,
    required this.fees,
    required this.overrides,
    required this.fines,
    required this.payments,
    required this.summary,
  });

  factory StudentFeeData.fromJson(Map<String, dynamic> json) {
    var feesList = json['fees'] as List? ?? [];
    var finesList = json['fine'] as List? ?? [];
    var paymentsList = json['payments'] as List? ?? [];
    
    // Safely handle overrides which might come as [] if empty
    Map<String, dynamic> overridesMap = {};
    if (json['overrides'] != null && json['overrides'] is Map) {
      overridesMap = Map<String, dynamic>.from(json['overrides']);
    }

    // Safely handle summary which might come as [] if empty
    Map<String, dynamic> summaryJson = {};
    if (json['summary'] != null && json['summary'] is Map) {
      summaryJson = Map<String, dynamic>.from(json['summary']);
    }

    return StudentFeeData(
      student: json['student'] != null ? Student.fromJson(json['student']) : null,
      fees: feesList.map((e) => Fee.fromJson(e)).toList(),
      overrides: overridesMap.map((key, value) => MapEntry(key, Override.fromJson(value))),
      fines: finesList.map((e) => Fine.fromJson(e)).toList(),
      payments: paymentsList.map((e) => Payment.fromJson(e)).toList(),
      summary: FeeSummary.fromJson(summaryJson),
    );
  }
}

class Student {
  final int id;
  final String firstName;
  final String? lastName;
  final String? studentRollNo;
  final String? email;
  final String? feeFrequency;
  final ClassInfo? classInfo;

  Student({
    required this.id,
    required this.firstName,
    this.lastName,
    this.studentRollNo,
    this.email,
    this.feeFrequency,
    this.classInfo,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'],
      studentRollNo: json['student_roll_no'],
      email: json['email'],
      feeFrequency: json['fee_frequency'],
      classInfo: json['class'] != null ? ClassInfo.fromJson(json['class']) : null,
    );
  }
}

class ClassInfo {
  final int id;
  final String name;

  ClassInfo({required this.id, required this.name});

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class Fee {
  final int id;
  final String name;
  final dynamic amount;
  final int? classId;

  Fee({required this.id, required this.name, required this.amount, this.classId});

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['id'],
      name: json['name'] ?? '',
      amount: json['amount'],
      classId: json['class_id'],
    );
  }
}

class Override {
  final int id;
  final int feeId;
  final dynamic overriddenAmount;

  Override({required this.id, required this.feeId, required this.overriddenAmount});

  factory Override.fromJson(Map<String, dynamic> json) {
    return Override(
      id: json['id'],
      feeId: json['fee_id'],
      overriddenAmount: json['overridden_amount'],
    );
  }
}

class Fine {
  final int id;
  final String reason;
  final dynamic amount;
  final String? remarks;

  Fine({required this.id, required this.reason, required this.amount, this.remarks});

  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      id: json['id'],
      reason: json['reason'] ?? '',
      amount: json['amount'],
      remarks: json['remarks'],
    );
  }
}

class Payment {
  final int id;
  final String? idHash;
  final dynamic paidAmount;
  final String date;
  final String paymentMethod;
  final String? referenceNo;
  final String? remark;
  final Submitter? submitter;

  Payment({
    required this.id,
    this.idHash,
    required this.paidAmount,
    required this.date,
    required this.paymentMethod,
    this.referenceNo,
    this.remark,
    this.submitter,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      idHash: json['id_hash'],
      paidAmount: json['paid_amount'],
      date: json['date'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      referenceNo: json['reference_no'],
      remark: json['remark'],
      submitter: json['submitter'] != null ? Submitter.fromJson(json['submitter']) : null,
    );
  }
}

class Submitter {
  final int id;
  final String name;

  Submitter({required this.id, required this.name});

  factory Submitter.fromJson(Map<String, dynamic> json) {
    return Submitter(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class FeeSummary {
  final dynamic totalFee;
  final dynamic totalFine;
  final dynamic totalPayable;
  final dynamic totalPaid;
  final dynamic due;

  FeeSummary({
    required this.totalFee,
    required this.totalFine,
    required this.totalPayable,
    required this.totalPaid,
    required this.due,
  });

  factory FeeSummary.fromJson(Map<String, dynamic> json) {
    return FeeSummary(
      totalFee: json['totalFee'] ?? 0,
      totalFine: json['totalFine'] ?? 0,
      totalPayable: json['totalPayable'] ?? 0,
      totalPaid: json['totalPaid'] ?? 0,
      due: json['due'] ?? 0,
    );
  }
}
