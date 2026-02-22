import 'dart:convert';

class Institute {
  final int id;
  final String name;
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
  final DateTime createdAt;
  final DateTime updatedAt;

  Institute({
    required this.id,
    required this.name,
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory Institute.fromRawJson(String str) =>
      Institute.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Institute.fromJson(Map<String, dynamic> json) => Institute(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        logo: json["logo"],
        establishedYear: int.parse(json["established_year"].toString()),
        address: json["address"],
        city: json["city"],
        state: json["state"],
        pincode: json["pincode"],
        contactEmail: json["contact_email"],
        contactPhone: json["contact_phone"],
        chairmanName: json["chairman_name"],
        website: json["website"],
        affiliationDetails: json["affiliation_details"],
        status: json["status"],        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
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
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
