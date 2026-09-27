class NoteModel {
  int? id;
  String title;
  String body;
  String category;

  NoteModel({
    this.id,
    required this.title,
    required this.body,
    required this.category,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      category: map['category'] ?? 'Personal',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'body': body, 'category': category};
  }
}
