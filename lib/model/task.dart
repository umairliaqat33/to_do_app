class Task {
  int? done; //we will be using 0 and 1 except booleans
  String name;
  int? id;

  Task({required this.name, this.done, this.id});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'done': done,
      'id': id,
    };
  }

  factory Task.fromMap(Map<String, dynamic> json) =>
      Task(name: json['name'], done: json['done'], id: json['id']);
}