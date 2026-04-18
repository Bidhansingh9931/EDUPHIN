import 'dart:typed_data';
import 'new_student.dart';

class NewEmployee {
  String name = '';
  String email = '';
  String password = '';
  String roleId = '';
  String? gender;
  DateTime? dob;
  String? relationshipStatus;
  String aadharNumber = '';
  String phone = '';
  String alternatePhone = '';
  String address = '';
  String city = '';
  String state = '';
  String pincode = '';
  String position = '';
  String? employmentType;
  DateTime? joiningDate;
  String experience = '';
  String? status;
  String reference = '';
  String qualification = '';
  String matricMarks = '';
  String interMarks = '';
  String bankAccountNumber = '';
  String ifscCode = '';
  String bankName = '';
  String branch = '';
  String emergencyContactName = '';
  String emergencyContactNumber = '';
  
  AppFile? photo;
  AppFile? matriculationMarksheet;
  AppFile? intermediateMarksheet;
  AppFile? aadharPhoto; // Added based on profile response
  AppFile? resume;

  NewEmployee();
}
