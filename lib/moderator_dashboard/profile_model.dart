
class ProfileData {
  // from user object
  final int id; // user id
  final String name;
  final String email;
  final String status;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final int roleId;
  final int instituteId;

  // from details object
  final int detailsId;
  final String position;
  final String employmentType;
  final int userId; 
  final String photo;
  final String gender;
  final String dateOfBirth;
  final String aadharNumber;
  final String aadharPhoto;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final int xMarks;
  final String xMarksheetPhoto;
  final int xiiMarks;
  final String xiiMarksheetPhoto;
  final String qualification;
  final String resume;
  final String? alternatePhone;
  final String? relationshipStatus;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? branchName;
  final String? salary;
  final String? joiningDate;
  final int? experience;
  final String? reference;
  final String? emergencyContactName;
  final String? emergencyContactNumber;


  ProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.roleId,
    required this.instituteId,
    required this.detailsId,
    required this.position,
    required this.employmentType,
    required this.userId,
    required this.photo,
    required this.gender,
    required this.dateOfBirth,
    required this.aadharNumber,
    required this.aadharPhoto,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
    required this.xMarks,
    required this.xMarksheetPhoto,
    required this.xiiMarks,
    required this.xiiMarksheetPhoto,
    required this.qualification,
    required this.resume,
    this.alternatePhone,
    this.relationshipStatus,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.branchName,
    this.salary,
    this.joiningDate,
    this.experience,
    this.reference,
    this.emergencyContactName,
    this.emergencyContactNumber,
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? 'Inactive',
      emailVerifiedAt: map['email_verified_at'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      roleId: map['role_id'] ?? 0,
      instituteId: map['institute_id'] ?? 0,
      detailsId: map['details_id'] ?? 0,
      position: map['position'] ?? '',
      employmentType: map['employment_type'] ?? '',
      userId: map['user_id'] ?? 0,
      photo: map['photo'] ?? 'assets/images/girl_image.webp',
      gender: map['gender'] ?? '',
      dateOfBirth: map['date_of_birth'] ?? '',
      aadharNumber: map['aadhar_number'] ?? '',
      aadharPhoto: map['aadhar_photo'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      phone: map['phone'] ?? '',
      xMarks: map['x_marks'] ?? 0,
      xMarksheetPhoto: map['x_marksheet_photo'] ?? '',
      xiiMarks: map['xii_marks'] ?? 0,
      xiiMarksheetPhoto: map['xii_marksheet_photo'] ?? '',
      qualification: map['qualification'] ?? '',
      resume: map['resume'] ?? '',
      alternatePhone: map['alternate_phone'],
      relationshipStatus: map['relationship_status'],
      bankAccountNumber: map['bank_account_number'],
      ifscCode: map['ifsc_code'],
      bankName: map['bank_name'],
      branchName: map['branch_name'],
      salary: map['salary'],
      joiningDate: map['joining_date'],
      experience: map['experience'],
      reference: map['reference'],
      emergencyContactName: map['emergency_contact_name'],
      emergencyContactNumber: map['emergency_contact_number'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'aadhar_number': aadharNumber,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'phone': phone,
      'qualification': qualification,
      'alternate_phone': alternatePhone,
      'relationship_status': relationshipStatus,
      'bank_account_number': bankAccountNumber,
      'ifsc_code': ifscCode,
      'bank_name': bankName,
      'branch_name': branchName,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_number': emergencyContactNumber,
      'position': position,
      'employment_type': employmentType,
      'x_marks': xMarks,
      'xii_marks': xiiMarks,
      'salary': salary,
      'joining_date': joiningDate,
      'experience': experience,
      'status': status,
      'reference': reference,
    };
  }
}
