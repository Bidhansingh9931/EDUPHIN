
import 'dart:io';

class TeacherProfile {
  final int id;
  String name;
  final String email;
  String? photoUrl;
  String? gender;
  String? dateOfBirth;
  String? address;
  String? city;
  String? state;
  String? pincode;
  String? phone;
  String? alternatePhone;
  String? bankAccountNumber;
  String? ifscCode;
  String? bankName;
  String? branch;
  String? position;
  String? employmentType;
  String? joiningDate;
  String? experience;
  String? relationshipStatus;
  String? qualification;
  String? xMarks;
  String? xiiMarks;
  String? aadhaarNumber;
  String? status;

  // For updates
  File? photo;
  String? password;

  TeacherProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.phone,
    this.alternatePhone,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.branch,
    this.position,
    this.employmentType,
    this.joiningDate,
    this.experience,
    this.relationshipStatus,
    this.qualification,
    this.xMarks,
    this.xiiMarks,
    this.aadhaarNumber,
    this.status,
    this.photo,
    this.password,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return TeacherProfile(
      id: json['id'],
      name: user['name'] ?? 'N/A',
      email: user['email'] ?? 'N/A',
      photoUrl: json['photo'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode']?.toString(),
      phone: json['phone']?.toString(),
      alternatePhone: json['alternate_phone']?.toString(),
      bankAccountNumber: json['bank_account_number']?.toString(),
      ifscCode: json['ifsc_code'],
      bankName: json['bank_name'],
      branch: json['bank_branch'],
      position: json['designation'],
      employmentType: json['employment_type'],
      joiningDate: json['date_of_joining'],
      experience: json['work_experience']?.toString(),
      relationshipStatus: json['marital_status'],
      qualification: json['qualification'],
      xMarks: json['x_marks']?.toString(),
      xiiMarks: json['xii_marks']?.toString(),
      aadhaarNumber: json['aadhaar_number']?.toString(),
      status: json['status'],
    );
  }

  Map<String, String> toApiData() {
    final map = <String, String>{};
    if (name.isNotEmpty) map['name'] = name;
    if (gender != null) map['gender'] = gender!;
    if (dateOfBirth != null) map['date_of_birth'] = dateOfBirth!;
    if (address != null) map['address'] = address!;
    if (city != null) map['city'] = city!;
    if (state != null) map['state'] = state!;
    if (pincode != null) map['pincode'] = pincode!;
    if (phone != null) map['phone'] = phone!;
    if (alternatePhone != null) map['alternate_phone'] = alternatePhone!;
    if (relationshipStatus != null) map['marital_status'] = relationshipStatus!;
    if (bankAccountNumber != null) map['bank_account_number'] = bankAccountNumber!;
    if (password != null && password!.isNotEmpty) map['password'] = password!;
    return map;
  }
}

class VirtualIdCardData {
  final String name;
  final String email;
  final String? photoUrl;
  final String? instituteName;
  final String? instituteAddress;
  final String? employeeId;
  final String? position;
  final String? employmentType;
  final String? joiningDate;
  final String? phone;
  final String? fullAddress;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? issueDate;
  final String? libraryId;

  VirtualIdCardData({
    required this.name,
    required this.email,
    this.photoUrl,
    this.instituteName,
    this.instituteAddress,
    this.employeeId,
    this.position,
    this.employmentType,
    this.joiningDate,
    this.phone,
    this.fullAddress,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.issueDate,
    this.libraryId,
  });

  factory VirtualIdCardData.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final userDetail = json['user_detail'] ?? {};
    final institute = user['institute'] ?? {};

    String address = (
      [userDetail['address'], userDetail['city'], userDetail['state'], userDetail['pincode']]
      .where((s) => s != null && s.toString().isNotEmpty).join(', '));

    return VirtualIdCardData(
      name: user['name'] ?? 'N/A',
      email: user['email'] ?? 'N/A',
      photoUrl: userDetail['photo'],
      instituteName: institute['name'] ?? 'Indian Institute of Applied Sciences (IIAS)',
      instituteAddress: institute['address'] ?? 'lot No. 88, Knowledge Park, Mock Industrial Estate, Delhi\nNew Delhi 102030',
      employeeId: userDetail['employee_id'] ?? 'EMP0005',
      position: userDetail['designation'] ?? 'Senior Mathematics Teacher',
      employmentType: userDetail['employment_type'] ?? 'full-time',
      joiningDate: userDetail['date_of_joining'] ?? '20 Jun 2017',
      phone: userDetail['phone']?.toString(),
      fullAddress: address,
      emergencyContactName: userDetail['emergency_contact_name'] ?? 'N/A',
      emergencyContactPhone: userDetail['emergency_contact_phone']?.toString() ?? 'N/A',
      issueDate: json['issue_date'] ?? '2025-10-08 11:40:00',
      libraryId: userDetail['library_id'] ?? 'LIB0006',
    );
  }
}
