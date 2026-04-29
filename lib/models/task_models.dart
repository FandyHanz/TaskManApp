class Task {
  int id;
  String title;
  String desc;
  DateTime deadline;
  bool isFinished;

  Task({required this.id, required this.title, required this.desc, required this.deadline, this.isFinished = false});

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'desc': desc, 'deadline': deadline.toIso8601String(), 'isFinished': isFinished,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    desc: json['desc'],
    deadline: DateTime.parse(json['deadline']),
    isFinished: json['isFinished'],
  );
}