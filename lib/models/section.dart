class Section {
  final int id;
  final String sectionName;
  Section({required this.id, required this.sectionName});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(id: json['id'], sectionName: json['section_name']);
  }
}
