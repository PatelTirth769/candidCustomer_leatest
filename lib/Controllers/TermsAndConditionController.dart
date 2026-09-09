class TermsAndConditions {
  final List<Section> sections;

  TermsAndConditions({required this.sections});

  factory TermsAndConditions.fromJson(Map<String, dynamic> json) {
    List<Section> sections = (json['sections'] as List)
        .map((sectionJson) => Section.fromJson(sectionJson))
        .toList();
    return TermsAndConditions(sections: sections);
  }
}

class Section {
  final String title;
  final String content;

  Section({required this.title, required this.content});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      title: json['title'],
      content: json['content'],
    );
  }
}
