import 'dart:convert';

class NewEmployee {
  final String instituteId;
  final String fullName;
  final String email;
  final String? role;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? relationshipStatus;
  final String phoneNumber;
  final String alternateNumber;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String position;
  final String? employmentType;
  final DateTime? joiningDate;
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

  NewEmployee({
    required this.instituteId, // Added instituteId
    required this.fullName,
    required this.email,
    this.role,
    this.gender,
    this.dateOfBirth,
    this.relationshipStatus,
    required this.phoneNumber,
    required this.alternateNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.position,
    this.employmentType,
    this.joiningDate,
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

  Map<String, dynamic> toJson() {
    return {
      'institute_id': instituteId, // Added institute_id to JSON
      'name': fullName,
      'email': email,
      'role': role,
      'gender': gender,
      'dob': dateOfBirth?.toIso8601String(),
      'relationship_status': relationshipStatus,
      'phone': phoneNumber,
      'alternate_phone': alternateNumber,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pinCode,
      'position': position,
      'employment_type': employmentType,
      'joining_date': joiningDate?.toIso8601String(),
      'experience': experience,
      'status': status,
      'reference': reference,
      'qualification': qualification,
      'matriculation_marks': matriculationMarks,
      'intermediate_marks': intermediateMarks,
      'bank_account_number': bankAccountNumber,
      'ifsc_code': ifscCode,
      'bank_name': bankName,
      'branch': branch,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_number': emergencyContactNumber,
    };
  }
}
