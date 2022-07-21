import 'package:flutter/material.dart';
import 'package:to_do_app/screen/add_task.dart';
import 'database/database.dart';
import 'model/task.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  bool d = false;
  String n = " ";

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
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              color: Colors.amberAccent,
            ),
            width: w,
            padding: EdgeInsets.only(top: 60, left: 30, right: 30, bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child:
                        Icon(Icons.list, color: Colors.amberAccent, size: 30)),
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
            future: DatabaseHelper.instance.getTasks(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
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
                            return Center(
                              child: ListTile(
                                  trailing: Checkbox(
                                    activeColor: Colors.lightBlueAccent,
                                    onChanged: (done) {
                                      DatabaseHelper.instance.change(
                                          task.id!.toInt(),
                                          task.done == 1 ? 0 : 1);
                                      if (task.done == 1) {
                                        setState(() {
                                          d = true;
                                        });
                                      } else {
                                        setState(() {
                                          d = false;
                                        });
                                      }
                                      print(task.done);
                                    },
                                    value: d,
                                  ),
                                  title: Text(
                                    task.name,
                                    style: TextStyle(
                                        decoration: d
                                            ? TextDecoration.lineThrough
                                            : null),
                                  ),
                                  onLongPress: () {
                                    DatabaseHelper.instance.remove(task.name);
                                  }),
                            );
                          }).toList(),
                        ),
                ),
              );
            },
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
