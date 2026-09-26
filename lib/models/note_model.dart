class NoteModel {
  int? id;
  String title;
  String body;

  NoteModel({this.id, required this.title, required this.body});

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'body': body};
  }
}
