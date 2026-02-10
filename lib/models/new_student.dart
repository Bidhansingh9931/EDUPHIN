import 'dart:typed_data';

class AppFile {
  final String name;
  final String? path; // Not null for mobile
  final Uint8List? bytes; // Not null for web

  AppFile({required this.name, this.path, this.bytes});
}

class NewStudent {
  String firstName = '';
  String middleName = '';
  String lastName = '';
  AppFile? profileImage;
  String aadhaarNumber = '';
  AppFile? aadhaarFile;
  AppFile? marksheet10;
  AppFile? marksheet12;
  AppFile? transferCertificate;
  AppFile? idProof;
  String rollNo = '';
  String registrationNo = '';
  int? classId;
  int? sectionId;
  DateTime? admissionDate;
  String? lateralAdmission;
  String? admissionCategory;
  String? studentStatus;
  DateTime? dob;
  String? gender;
  String? bloodGroup;
  String nationality = '';
  String phone = '';
  String altPhone = '';
  String email = '';
  String password = '';
  String address = '';
  String city = '';
  String district = '';
  String state = '';
  String pincode = '';
  String fatherName = '';
  String fatherOccupation = '';
  String fatherPhone = '';
  String motherName = '';
  String motherOccupation = '';
  String motherPhone = '';
  String guardianName = '';
  String guardianRelation = '';
  String guardianPhone = '';
  String allergies = '';
  String medications = '';
}
