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
  String? employeeId;
  String? emergencyContactName;
  String? emergencyContactPhone;

  // For updates
  File? photo;
  String? password;
  String? passwordConfirmation;

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
    this.employeeId,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.photo,
    this.password,
    this.passwordConfirmation,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return TeacherProfile(
      id: json['id'] ?? 0,
      name: user['name'] ?? json['name'] ?? 'N/A',
      email: user['email'] ?? json['email'] ?? 'N/A',
      photoUrl: json['photo'] ?? json['profile_image'] ?? user['photo'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'] ?? json['dob'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode']?.toString(),
      phone: json['phone']?.toString(),
      alternatePhone: json['alternate_phone']?.toString(),
      bankAccountNumber: json['bank_account_number']?.toString(),
      ifscCode: json['ifsc_code'],
      bankName: json['bank_name'],
      branch: json['bank_branch'] ?? json['branch_name'],
      position: json['designation'] ?? json['position'],
      employmentType: json['employment_type'],
      joiningDate: json['date_of_joining'] ?? json['joining_date'],
      experience: json['work_experience']?.toString() ?? json['experience']?.toString(),
      relationshipStatus: json['marital_status'] ?? json['relationship_status'],
      qualification: json['qualification'],
      xMarks: json['x_marks']?.toString(),
      xiiMarks: json['xii_marks']?.toString(),
      aadhaarNumber: json['aadhaar_number']?.toString() ?? json['aadhar_number']?.toString(),
      status: json['status'],
      employeeId: json['employee_id']?.toString(),
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone']?.toString() ?? json['emergency_contact_number']?.toString(),
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
    if (ifscCode != null) map['ifsc_code'] = ifscCode!;
    if (bankName != null) map['bank_name'] = bankName!;
    if (branch != null) map['bank_branch'] = branch!;
    if (qualification != null) map['qualification'] = qualification!;
    if (experience != null) map['work_experience'] = experience!;
    if (aadhaarNumber != null) map['aadhaar_number'] = aadhaarNumber!;
    if (emergencyContactName != null) map['emergency_contact_name'] = emergencyContactName!;
    if (emergencyContactPhone != null) map['emergency_contact_phone'] = emergencyContactPhone!;
    
    if (password != null && password!.isNotEmpty) {
      map['password'] = password!;
      if (passwordConfirmation != null) map['password_confirmation'] = passwordConfirmation!;
    }
    return map;
  }
}

class VirtualIdCardData {
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
    this.instituteLogo,
    this.instituteAddress,
    this.institutePhone,
    this.instituteWebsite,
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
    final userDetail = json['user_detail'] ?? json['userDetail'] ?? {};

    String address = (
      [userDetail['address'], userDetail['city'], userDetail['state'], userDetail['pincode']]
      .where((s) => s != null && s.toString().isNotEmpty && s.toString() != 'null').join(', '));

    return VirtualIdCardData(
      name: user['name'] ?? userDetail['name'] ?? 'N/A',
      email: user['email'] ?? userDetail['email'] ?? 'N/A',
      photoUrl: userDetail['photo'] ?? userDetail['profile_image'] ?? user['photo'],
      instituteName: json['institute_name']?.toString(),
      instituteLogo: json['institute_logo']?.toString(),
      instituteAddress: json['institute_address']?.toString(),
      institutePhone: json['institute_phone']?.toString(),
      instituteWebsite: json['institute_website']?.toString(),
      employeeId: userDetail['employee_id']?.toString() ?? userDetail['id']?.toString(),
      position: userDetail['designation'] ?? userDetail['position'] ?? 'Teacher',
      employmentType: userDetail['employment_type']?.toString(),
      joiningDate: userDetail['date_of_joining'] ?? userDetail['joining_date'],
      phone: userDetail['phone']?.toString(),
      fullAddress: address.isNotEmpty ? address : userDetail['address']?.toString(),
      emergencyContactName: userDetail['emergency_contact_name']?.toString(),
      emergencyContactPhone: userDetail['emergency_contact_phone']?.toString() ?? userDetail['emergency_contact_number']?.toString(),
      issueDate: json['issue_date']?.toString(),
      libraryId: userDetail['library_id']?.toString(),
    );
  }
}
