
class EmployeeDetails {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String gender;
  final String dateOfBirth;
  final String relationshipStatus;
  final String phoneNumber;
  final String alternateNumber;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String position;
  final String employmentType;
  final String joiningDate;
  final String experience;
  final String status;
  final String reference;
  final String qualification;
  final String matriculationMarks;
  final String intermediateMarks;
  final String bankAccountNumber;
  final String ifscCode;
  final String bankName;
  final String branch;
  final String emergencyContactName;
  final String emergencyContactNumber;

  EmployeeDetails({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.gender,
    required this.dateOfBirth,
    required this.relationshipStatus,
    required this.phoneNumber,
    required this.alternateNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.position,
    required this.employmentType,
    required this.joiningDate,
    required this.experience,
    required this.status,
    required this.reference,
    required this.qualification,
    required this.matriculationMarks,
    required this.intermediateMarks,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branch,
    required this.emergencyContactName,
    required this.emergencyContactNumber,
  });

  factory EmployeeDetails.fromJson(Map<String, dynamic> json) {
    return EmployeeDetails(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      role: json['role'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      relationshipStatus: json['relationshipStatus'],
      phoneNumber: json['phoneNumber'],
      alternateNumber: json['alternateNumber'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pinCode: json['pinCode'],
      position: json['position'],
      employmentType: json['employmentType'],
      joiningDate: json['joiningDate'],
      experience: json['experience'],
      status: json['status'],
      reference: json['reference'],
      qualification: json['qualification'],
      matriculationMarks: json['matriculationMarks'],
      intermediateMarks: json['intermediateMarks'],
      bankAccountNumber: json['bankAccountNumber'],
      ifscCode: json['ifscCode'],
      bankName: json['bankName'],
      branch: json['branch'],
      emergencyContactName: json['emergencyContactName'],
      emergencyContactNumber: json['emergencyContactNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'relationshipStatus': relationshipStatus,
      'phoneNumber': phoneNumber,
      'alternateNumber': alternateNumber,
      'address': address,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'position': position,
      'employmentType': employmentType,
      'joiningDate': joiningDate,
      'experience': experience,
      'status': status,
      'reference': reference,
      'qualification': qualification,
      'matriculationMarks': matriculationMarks,
      'intermediateMarks': intermediateMarks,
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'branch': branch,
      'emergencyContactName': emergencyContactName,
      'emergencyContactNumber': emergencyContactNumber,
    };
  }
}
