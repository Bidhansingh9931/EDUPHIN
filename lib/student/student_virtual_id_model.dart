class StudentVirtualIdData {
  final User? user;
  final Student? student;
  final String? instituteName;
  final String? instituteLogo;
  final String? instituteAddress;
  final String? institutePhone;
  final String? instituteWebsite;
  final String? instituteEmail;

  StudentVirtualIdData({
    this.user,
    this.student,
    this.instituteName,
    this.instituteLogo,
    this.instituteAddress,
    this.institutePhone,
    this.instituteWebsite,
    this.instituteEmail,
  });

  factory StudentVirtualIdData.fromJson(Map<String, dynamic> json) {
    return StudentVirtualIdData(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      student: json['student'] != null ? Student.fromJson(json['student']) : null,
      instituteName: json['institute_name'],
      instituteLogo: json['institute_logo'],
      instituteAddress: json['institute_address'],
      institutePhone: json['institute_phone'],
      instituteWebsite: json['institute_website'],
      instituteEmail: json['institute_email'],
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Student {
  final int id;
  final String firstName;
  final String? lastName;
  final String? studentRollNo;
  final String? registrationNo;
  final String? dob;
  final String? mobile;
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final String? guardianFirstName;
  final String? guardianMobile;
  final String? academicYear;
  final String? profileImage;

  Student({
    required this.id,
    required this.firstName,
    this.lastName,
    this.studentRollNo,
    this.registrationNo,
    this.dob,
    this.mobile,
    this.addressLine1,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.guardianFirstName,
    this.guardianMobile,
    this.academicYear,
    this.profileImage,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'],
      studentRollNo: json['student_roll_no'],
      registrationNo: json['registration_no'],
      dob: json['dob'],
      mobile: json['mobile'],
      addressLine1: json['address_line1'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'],
      guardianFirstName: json['guardian_first_name'],
      guardianMobile: json['guardian_mobile'],
      academicYear: json['academic_year'],
      profileImage: (json['profile_image'] ?? 
                    json['photo'] ?? 
                    json['image'] ?? 
                    json['avatar'])?.toString(),
    );
  }
}
