import 'dart:io';
import 'dart:typed_data';
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
  Uint8List? webImage;
  String? imageName;

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
    this.webImage,
    this.imageName,
  });

  int? _getRoleId(String? role) {
    if (role == null) return null;
    switch (role.toLowerCase()) {
      case "moderator":
        return 2;
      case "institute manager":
        return 3;
      case "counselors":
      case "counselor":
        return 4;
      case "teacher":
      case "teachers":
        return 5;
      case "student":
      case "students":
        return 6;
      case "librarian":
        return 7;
      case "accountant":
      case "accountants":
        return 8;
      case "staff":
        return 9;
      default:
        return null;
    }
  }

  String _getApiStatus(String? status) {
    if (status == null || status.isEmpty) return 'live';
    final s = status.toLowerCase();
    if (s == 'active' || s == 'live') return 'live';
    if (s == 'inactive' || s == 'expired') return 'expired';
    return s;
  }

  Map<String, dynamic> toApiData() {
    final Map<String, dynamic> data = {};
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    data['institute_id'] = instituteId;
    data['name'] = fullName;
    data['email'] = email;

    final roleId = _getRoleId(role);
    if (roleId != null) {
      data['role_id'] = roleId;
    }

    if (gender != null) data['gender'] = gender!;
    if (dateOfBirth != null) {
      final formattedDate = formatter.format(dateOfBirth!);
      data['dob'] = formattedDate;
      data['date_of_birth'] = formattedDate;
    }
    if (phoneNumber != null) data['phone'] = phoneNumber!;
    if (address != null) data['address'] = address!;
    if (city != null) data['city'] = city!;
    if (state != null) data['state'] = state!;
    if (pinCode != null) data['pincode'] = pinCode!;

    if (relationshipStatus != null) data['relationship_status'] = relationshipStatus!;
    if (alternateNumber != null) data['alternate_phone'] = alternateNumber!;
    if (position != null) data['position'] = position!;
    if (employmentType != null) data['employment_type'] = employmentType!;
    if (joiningDate != null) data['joining_date'] = formatter.format(joiningDate!);
    if (experience != null) data['experience'] = experience!;
    if (status != null) {
      data['status'] = _getApiStatus(status);
    }
    if (reference != null) data['reference'] = reference!;
    if (qualification != null) data['qualification'] = qualification!;
    if (matriculationMarks != null) data['x_marks'] = matriculationMarks!;
    if (intermediateMarks != null) data['xii_marks'] = intermediateMarks!;
    if (bankAccountNumber != null) data['bank_account_number'] = bankAccountNumber!;
    if (ifscCode != null) data['ifsc_code'] = ifscCode!;
    if (bankName != null) data['bank_name'] = bankName!;
    if (branch != null) data['branch_name'] = branch!;
    if (emergencyContactName != null) data['emergency_contact_name'] = emergencyContactName!;
    if (emergencyContactNumber != null) data['emergency_contact_number'] = emergencyContactNumber!;

    return data;
  }
}
