class Task {
  int done;
  String name;
  int? id;
  String date;
  String time;

  Task(
      {required this.name,
      required this.done,
      this.id,
      required this.date,
      required this.time});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'done': done,
      'id': id,
      'date': date,
      'time': time,
    };
  }

  factory Task.fromMap(Map<String, dynamic> json) => Task(
        name: json['name'],
        done: json['done'],
        id: json['id'],
        date: json['date'],
        time: json['time'],
      );
}
