class Task {
  int? done;
  String name;
  int? id;
  String date;

  Task({required this.name, this.done, this.id, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'done': done,
      'id': id,
      'date': date,
    };
  }

  factory Task.fromMap(Map<String, dynamic> json) => Task(
      name: json['name'],
      done: json['done'],
      id: json['id'],
      date: json['date']);
}
