import 'section.dart';

class Class {
  final int id;
  final String name;
  final List<Section> sections;
  Class({required this.id, required this.name, required this.sections});

  factory Class.fromJson(Map<String, dynamic> json) {
    var sectionsList = json['sections'] as List? ?? [];
    List<Section> sections = sectionsList.map((i) => Section.fromJson(i)).toList();
    return Class(id: json['id'], name: json['name'] ?? '', sections: sections);
  }
}
