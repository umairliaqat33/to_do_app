import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/model/task.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'task1.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Task(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    done INTEGER
    )''');
  }

  // id INTEGER Primary KEY,

  Future<List<Task>> getTasks() async {
    Database db = await instance.database;
    var task = await db.query('Task', orderBy: 'name');
    List<Task> taskList =
    task.isNotEmpty ? task.map((e) => Task.fromMap(e)).toList() : [];
    return taskList;
  }

  Future<int> add(Task task) async {
    Database db = await instance.database;
    return await db.insert('Task', task.toMap());
  }


  Future<int> remove(String name) async {
    Database db = await instance.database;
    return await db.delete('Task', where: 'name=?', whereArgs: [name]);
  }

  Future<int> change(int id,int done) async {
    Database db = await instance.database;
    return await db.rawUpdate(
        'UPDATE Task SET done = ? WHERE id = ?', [done, id]);
  }

  // Future<int> change(Task task,int id) async {
  //   Database db = await instance.database;
  //   return await db.update('Task',task.toMap(), where: 'id=?',whereArgs: [id]);
  // }


}