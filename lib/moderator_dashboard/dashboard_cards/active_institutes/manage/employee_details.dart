class EmployeeDetails {
  final String? id;
  final String? fullName;
  final String? email;
  final String? role;
  final String? gender;
  final String? dateOfBirth;
  final String? relationshipStatus;
  final String? phoneNumber;
  final String? alternateNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? pinCode;
  final String? position;
  final String? employmentType;
  final String? joiningDate;
  final String? experience;
  final String? status;
  final String? reference;
  final String? qualification;
  final String? matriculationMarks;
  final String? intermediateMarks;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? branch;
  final String? emergencyContactName;
  final String? emergencyContactNumber;

  EmployeeDetails({
    this.id,
    this.fullName,
    this.email,
    this.role,
    this.gender,
    this.dateOfBirth,
    this.relationshipStatus,
    this.phoneNumber,
    this.alternateNumber,
    this.address,
    this.city,
    this.state,
    this.pinCode,
    this.position,
    this.employmentType,
    this.joiningDate,
    this.experience,
    this.status,
    this.reference,
    this.qualification,
    this.matriculationMarks,
    this.intermediateMarks,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.branch,
    this.emergencyContactName,
    this.emergencyContactNumber,
  });

  factory EmployeeDetails.fromJson(Map<String, dynamic> json) {
    return EmployeeDetails(
      id: json['id'] as String?,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      relationshipStatus: json['relationshipStatus'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      alternateNumber: json['alternateNumber'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pinCode: json['pinCode'] as String?,
      position: json['position'] as String?,
      employmentType: json['employmentType'] as String?,
      joiningDate: json['joiningDate'] as String?,
      experience: json['experience'] as String?,
      status: json['status'] as String?,
      reference: json['reference'] as String?,
      qualification: json['qualification'] as String?,
      matriculationMarks: json['matriculationMarks'] as String?,
      intermediateMarks: json['intermediateMarks'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      ifscCode: json['ifscCode'] as String?,
      bankName: json['bankName'] as String?,
      branch: json['branch'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactNumber: json['emergencyContactNumber'] as String?,
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
