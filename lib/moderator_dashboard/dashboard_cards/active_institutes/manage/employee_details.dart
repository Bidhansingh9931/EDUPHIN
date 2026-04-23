import 'dart:io';
import 'dart:typed_data';
import 'package:eduphin/services/api_service.dart';

class EmployeeDetails {
  final String? id;
  final String? fullName;
  final String? email;
  final String? photo;
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
  final String? instituteId;

  // For updates
  final File? profileImage;
  final Uint8List? webImage;
  final String? imageName;

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
    this.photo,
    this.profileImage,
    this.webImage,
    this.imageName,
    this.instituteId,
  });

  factory EmployeeDetails.fromJson(Map<String, dynamic> json) {
    String? status = json['status']?.toString()?.toLowerCase();
    // Normalize status
    if (status == 'active' || status == 'live') {
      status = 'live';
    } else if (status == 'inactive' || status == 'expired') {
      status = 'expired';
    }

    return EmployeeDetails(
      id: (json['encrypted_id'] ?? json['id'])?.toString(),
      fullName: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: (json['dob'] ?? json['date_of_birth'])?.toString(),
      relationshipStatus: json['relationship_status'] as String?,
      phoneNumber: json['phone'] as String?,
      alternateNumber: json['alternate_phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pinCode: json['pincode']?.toString(),
      position: json['position'] as String?,
      employmentType: json['employment_type'] as String?,
      joiningDate: json['joining_date'] as String?,
      experience: json['experience']?.toString(),
      status: status,
      reference: json['reference'] as String?,
      qualification: json['qualification'] as String?,
      matriculationMarks: (json['x_marks'] ?? json['matriculation_marks'])?.toString(),
      intermediateMarks: (json['xii_marks'] ?? json['intermediate_marks'])?.toString(),
      bankAccountNumber: json['bank_account_number']?.toString(),
      ifscCode: json['ifsc_code'] as String?,
      bankName: json['bank_name'] as String?,
      branch: json['branch_name'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactNumber: json['emergency_contact_number']?.toString(),
      photo: ApiService.getStorageUrl(json['photo']),
      instituteId: json['institute_id']?.toString(),
    );
  }

  Map<String, dynamic> toApiData() {
    final Map<String, dynamic> data = {
      'name': fullName ?? '',
      'email': email ?? '',
      'gender': gender ?? '',
      'phone': phoneNumber ?? '',
      'alternate_phone': alternateNumber ?? '',
      'address': address ?? '',
      'city': city ?? '',
      'state': state ?? '',
      'pincode': pinCode ?? '',
      'relationship_status': relationshipStatus ?? '',
      'position': position ?? '',
      'employment_type': employmentType ?? '',
      'joining_date': joiningDate ?? '',
      'experience': int.tryParse(experience ?? '0') ?? 0,
      'status': _getApiStatus(status),
      'reference': reference ?? '',
      'qualification': qualification ?? '',
      'x_marks': int.tryParse(matriculationMarks ?? '0') ?? 0,
      'xii_marks': int.tryParse(intermediateMarks ?? '0') ?? 0,
      'bank_account_number': bankAccountNumber ?? '',
      'ifsc_code': ifscCode ?? '',
      'bank_name': bankName ?? '',
      'branch_name': branch ?? '',
      'emergency_contact_name': emergencyContactName ?? '',
      'emergency_contact_number': emergencyContactNumber ?? '',
      'institute_id': instituteId,
    };

    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) {
      data['date_of_birth'] = dateOfBirth!;
      data['dob'] = dateOfBirth!;
    }

    final roleId = _getRoleId(role);
    if (roleId != null) {
      data['role_id'] = roleId.toString();
    }

    return data;
  }

  Map<String, dynamic> toJson() {
    return toApiData();
  }

  int? _getRoleId(String? roleName) {
    if (roleName == null) return null;
    switch (roleName.toLowerCase()) {
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
}
