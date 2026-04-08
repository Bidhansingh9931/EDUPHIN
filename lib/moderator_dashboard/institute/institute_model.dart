import 'dart:convert';

class Institute {
  final int id;
  final String name;
  final String? gstNumber;
  final String? panNumber;
  final String code;
  final String? logo;
  final int establishedYear;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String contactEmail;
  final String contactPhone;
  final String chairmanName;
  final String? website;
  final String? affiliationDetails;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Institute({
    required this.id,
    required this.name,
    this.gstNumber,
    this.panNumber,
    required this.code,
    this.logo,
    required this.establishedYear,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.contactEmail,
    required this.contactPhone,
    required this.chairmanName,
    this.website,
    this.affiliationDetails,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Institute.fromRawJson(String str) =>
      Institute.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Institute.fromJson(Map<String, dynamic> json) => Institute(
        id: json["id"],
        name: json["name"] ?? '',
        gstNumber: json["gst_number"],
        panNumber: json["pan_number"],
        code: json["code"] ?? json["institute_code"] ?? '',
        logo: json["logo"],
        establishedYear: int.tryParse(json["established_year"].toString()) ?? 0,
        address: json["address"] ?? '',
        city: json["city"] ?? '',
        state: json["state"] ?? '',
        pincode: json["pincode"]?.toString() ?? '',
        contactEmail: json["contact_email"] ?? '',
        contactPhone: json["contact_phone"]?.toString() ?? '',
        chairmanName: json["chairman_name"] ?? '',
        website: json["website"],
        affiliationDetails: json["affiliation_details"],
        status: json["status"] ?? 'Active',
        createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
        updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "gst_number": gstNumber,
        "pan_number": panNumber,
        "code": code,
        "logo": logo,
        "established_year": establishedYear,
        "address": address,
        "city": city,
        "state": state,
        "pincode": pincode,
        "contact_email": contactEmail,
        "contact_phone": contactPhone,
        "chairman_name": chairmanName,
        "website": website,
        "affiliation_details": affiliationDetails,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
