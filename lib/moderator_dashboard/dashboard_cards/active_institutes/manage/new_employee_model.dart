import 'dart:io';
import 'package:intl/intl.dart';

class NewEmployee {
  final String instituteId;
  final String fullName;
  final String email;
  final String? role;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? relationshipStatus;
  final String? phoneNumber;
  final String? alternateNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? pinCode;
  final String? position;
  final String? employmentType;
  final DateTime? joiningDate;
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
  File? profileImage;

  NewEmployee({
    required this.instituteId,
    required this.fullName,
    required this.email,
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
    this.profileImage,
  });

  int? _getRoleId(String? role) {
    if (role == null) return null;
    switch (role.toLowerCase()) {
      case "institute manager":
        return 3;
      case "teacher":
        return 4;
      case "student":
        return 5;
      case "staff":
        return 6;
      case "accountant":
        return 7;
      default:
        return null;
    }
  }

  Map<String, String> toApiData() {
    final Map<String, String> data = {};
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    data['institute_id'] = instituteId;
    data['name'] = fullName;
    data['email'] = email;

    final roleId = _getRoleId(role);
    if (roleId != null) {
      data['role_id'] = roleId.toString();
    }

    if (gender != null) data['gender'] = gender!;
    if (dateOfBirth != null) data['dob'] = formatter.format(dateOfBirth!);
    if (phoneNumber != null) data['phone'] = phoneNumber!;
    if (address != null) data['address'] = address!;
    if (city != null) data['city'] = city!;
    if (state != null) data['state'] = state!;
    if (pinCode != null) data['pincode'] = pinCode!;

    // Add other fields as meta data, which is a common practice for extended profiles.
    if (relationshipStatus != null) data['meta[relationship_status]'] = relationshipStatus!;
    if (alternateNumber != null) data['meta[alternate_phone]'] = alternateNumber!;
    if (position != null) data['meta[position]'] = position!;
    if (employmentType != null) data['meta[employment_type]'] = employmentType!;
    if (joiningDate != null) data['meta[joining_date]'] = formatter.format(joiningDate!);
    if (experience != null) data['meta[experience]'] = experience!;
    if (status != null) data['meta[status]'] = status!;
    if (reference != null) data['meta[reference]'] = reference!;
    if (qualification != null) data['meta[qualification]'] = qualification!;
    if (matriculationMarks != null) data['meta[matriculation_marks]'] = matriculationMarks!;
    if (intermediateMarks != null) data['meta[intermediate_marks]'] = intermediateMarks!;
    if (bankAccountNumber != null) data['meta[bank_account_number]'] = bankAccountNumber!;
    if (ifscCode != null) data['meta[ifsc_code]'] = ifscCode!;
    if (bankName != null) data['meta[bank_name]'] = bankName!;
    if (branch != null) data['meta[bank_branch]'] = branch!;
    if (emergencyContactName != null) data['meta[emergency_contact_name]'] = emergencyContactName!;
    if (emergencyContactNumber != null) data['meta[emergency_contact_number]'] = emergencyContactNumber!;

    return data;
  }
}
