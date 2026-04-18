class StudentProfileData {
  final StudentDetail? student;
  final FamilyDetail? family;
  final HealthDetail? health;

  StudentProfileData({this.student, this.family, this.health});

  factory StudentProfileData.fromJson(Map<String, dynamic> json) {
    return StudentProfileData(
      student: json['student'] != null ? StudentDetail.fromJson(json['student']) : null,
      family: json['family'] != null ? FamilyDetail.fromJson(json['family']) : null,
      health: json['health'] != null ? HealthDetail.fromJson(json['health']) : null,
    );
  }
}

class StudentDetail {
  final int id;
  final String firstName;
  final String? middleName;
  final String? lastName;
  final String? profileImage;
  final String? studentRollNo;
  final String? registrationNo;
  final String? academicSession;
  final String? academicYear;
  final String? admissionCategory;
  final String? dob;
  final String? gender;
  final String? email;
  final String? mobile;
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? pincode;
  final String? bloodGroup;
  final String? nationality;
  final String? religion;
  final String? caste;
  final String? domicileState;
  final int? age;
  final String? placeOfBirth;
  final String? aadharNumber;
  final String? dateOfAdmission;
  final String? mentorName;

  StudentDetail({
    required this.id,
    required this.firstName,
    this.middleName,
    this.lastName,
    this.profileImage,
    this.studentRollNo,
    this.registrationNo,
    this.academicSession,
    this.academicYear,
    this.admissionCategory,
    this.dob,
    this.gender,
    this.email,
    this.mobile,
    this.addressLine1,
    this.city,
    this.state,
    this.pincode,
    this.bloodGroup,
    this.nationality,
    this.religion,
    this.caste,
    this.domicileState,
    this.age,
    this.placeOfBirth,
    this.aadharNumber,
    this.dateOfAdmission,
    this.mentorName,
  });

  factory StudentDetail.fromJson(Map<String, dynamic> json) {
    return StudentDetail(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'],
      profileImage: (json['profile_image'] ?? 
                    json['photo'] ?? 
                    json['image'] ?? 
                    json['avatar'])?.toString(),
      studentRollNo: json['student_roll_no'],
      registrationNo: json['registration_no'],
      academicSession: json['academic_session'],
      academicYear: json['academic_year'],
      admissionCategory: json['admission_category'],
      dob: json['dob'],
      gender: json['gender'],
      email: json['email'],
      mobile: json['mobile'],
      addressLine1: json['address_line1'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      bloodGroup: json['blood_group'],
      nationality: json['nationality'],
      religion: json['religion'],
      caste: json['caste'],
      domicileState: json['domicile_state'],
      age: json['age'],
      placeOfBirth: json['place_of_birth'],
      aadharNumber: json['aadhar_number'],
      dateOfAdmission: json['date_of_admission'],
      mentorName: json['mentor_name'],
    );
  }
}

class FamilyDetail {
  final int id;
  final String? fatherName;
  final String? fatherMobile;
  final String? motherName;
  final String? motherMobile;

  FamilyDetail({
    required this.id,
    this.fatherName,
    this.fatherMobile,
    this.motherName,
    this.motherMobile,
  });

  factory FamilyDetail.fromJson(Map<String, dynamic> json) {
    return FamilyDetail(
      id: json['id'],
      fatherName: json['father_name'],
      fatherMobile: json['father_mobile'],
      motherName: json['mother_name'],
      motherMobile: json['mother_mobile'],
    );
  }
}

class HealthDetail {
  final int id;
  final double? height;
  final double? weight;
  final String? bloodGroup;

  HealthDetail({
    required this.id,
    this.height,
    this.weight,
    this.bloodGroup,
  });

  factory HealthDetail.fromJson(Map<String, dynamic> json) {
    return HealthDetail(
      id: json['id'],
      height: json['height'] != null ? double.tryParse(json['height'].toString()) : null,
      weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
      bloodGroup: json['blood_group'],
    );
  }
}