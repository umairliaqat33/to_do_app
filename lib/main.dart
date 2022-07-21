import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/screen/add_task.dart';
import 'database/database.dart';
import 'model/task.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      ChangeNotifierProvider(create: (_) => DatabaseHelper(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        primaryColor: Colors.amberAccent,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool bool_done = false;

  Task? _task;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) => AddTaskScreen());
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      body: Consumer<DatabaseHelper>(
        builder: (context, databaseHelper, child) => Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                color: Colors.amberAccent,
              ),
              width: w,
              padding:
                  EdgeInsets.only(top: 60, left: 30, right: 30, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.list,
                          color: Colors.amberAccent, size: 30)),
                  SizedBox(height: 10),
                  SizedBox(width: 10),
                  Text('To-Do',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w700)),
                  // Text('${DatabaseHelper.instance} Tasks',
                  //     style: TextStyle(color: Colors.white, fontSize: 18))
                ],
              ),
            ),
            FutureBuilder<List<Task>>(
              future: databaseHelper.getTasks(),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Task>> snapshot,
              ) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text("Loading"),
                  );
                }
                return Expanded(
                  child: SizedBox(
                    child: snapshot.data!.isEmpty
                        ? Center(
                            child: Text("No Tasks"),
                          )
                        : ListView(
                            children: snapshot.data!.map((task) {
                              // n=task.name;
                              _task = task;
                              return Center(
                                child: ListTile(
                                    trailing: Checkbox(
                                      activeColor: Colors.lightBlueAccent,
                                      onChanged: (done) async {
                                        _task = Task(
                                          name: task.name,
                                          id: task.id,
                                          done: done! ? 0 : 1,
                                        );
                                        if (_task == null) return;
                                        await DatabaseHelper.instance.change(
                                          _task!,
                                          _task!.id!.toInt(),
                                        );
                                        if (_task!.done == 1) {
                                          setState(() {
                                            bool_done = true;
                                          });
                                        } else if (_task!.done == 0) {
                                          setState(() {
                                            bool_done = false;
                                          });
                                        } else {
                                          setState(() {
                                            bool_done = true;
                                          });
                                        }
                                        print(_task!.done);
                                      },
                                      value: _task!.done! == 1 ? false : true,
                                    ),
                                    title: Text(
                                      _task!.name, //here
                                      style: TextStyle(
                                          decoration: _task!.done == 0
                                              ? TextDecoration.lineThrough
                                              : null),
                                    ),
                                    onLongPress: () {
                                      DatabaseHelper.instance
                                          .remove(_task!.name);
                                    }),
                              );
                            }).toList(),
                          ),
                  ),
                );
              },
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
