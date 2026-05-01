class Note {
  int id;
  String title;
  String content;
  bool isHidden; 

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.isHidden = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'isHidden': isHidden,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        isHidden: json['isHidden'] ?? false,
      );
}