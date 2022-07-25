import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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
  bool isSelected = false;

  creatingAlertDialog(BuildContext context, String name) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            title: Text('Delete Task'),
            content: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: name,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        )),
                    TextSpan(
                        text: "\nAre you sure you want to delete task?",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        )),
                    TextSpan(
                        text: "\n*Once deleted will never be restored*",
                        style: TextStyle(fontSize: 10, color: Colors.red))
                  ],
                )),
            actions: [
              TextButton(
                onPressed: () {
                  DatabaseHelper.instance.remove(name);
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(
                      msg: "Task have been deleted",
                      backgroundColor: Colors.amberAccent,
                      textColor: Colors.white,
                      fontSize: 16.0);
                },
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        });
  }

  late final GlobalKey<FormState> _formKey;
  @override
  void initState() {
    super.initState();
    setState(() {
      _formKey = new GlobalKey<FormState>();
    });
  }


  creatingUpdateAlertDialog(BuildContext context, Task task) {
    final taskController = TextEditingController(text: task.name);
    DateTime selectedDate = DateFormat("dd-MM-yyyy").parse(task.date);

    DateTime DatePicker() {
      showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030))
          .then((pickedDate) {
        if (pickedDate == null) {
          return;
        }
        setState(() {
          selectedDate = pickedDate;
          // taskController.text=task.name;
        });
      });
      return selectedDate;
    }
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            title: Text('Update Task'),
            content: Form(
              key: _formKey,
              child: Container(
                height: 200,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Update Task',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 30, color: Colors.amberAccent)),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            // this will be checking if we have any value in it or not?
                            return "Field required";
                          }
                          return null;
                        },
                        autofocus: true,
                        cursorColor: Colors.black,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        controller: taskController,
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedDate = DatePicker();
                              });
                              FocusScope.of(context).unfocus();
                            },
                            child: Text(
                              "Chose Date",
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Picked Date: ${(DateFormat.yMd().format(selectedDate))}",
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        child: Text('Update', style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.amberAccent),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await DatabaseHelper.instance.update(
                              Task(
                                name: taskController.text,
                                done: task.done,
                                id: task.id,
                                date:
                                "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                              ),
                            );
                            Fluttertoast.showToast(
                                msg: "Task have been added",
                                backgroundColor: Colors.amberAccent,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                            Navigator.pop(context);
                            setState(() {
                              taskController.clear();
                            });

                          }
                        },
                      )
                    ]),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // DatabaseHelper.instance.remove(name);
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(
                      msg: "Task Updated",
                      backgroundColor: Colors.amberAccent,
                      textColor: Colors.white,
                      fontSize: 16.0);
                },
                child: Text(
                  "Update",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        });
  }

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
        child: const Icon(Icons.add),
      ),
      body: Consumer<DatabaseHelper>(
        builder: (context, databaseHelper, child) => Column(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 2),
                    blurRadius: 6,
                  )
                ],
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
                  SizedBox(height: 10, width: 10),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isSelected
                    ? Text(
                        "Show Non Completed Tasks",
                        style: TextStyle(color: Colors.grey),
                      )
                    : Text(
                        "Show Completed Tasks",
                        style: TextStyle(color: Colors.grey),
                      ),
                Switch(
                    value: isSelected,
                    onChanged: (bool value) {
                      setState(() {
                        isSelected = value;
                      });
                    }),
              ],
            ),
            isSelected
                ? FutureBuilder<List<Task>>(
                    future: databaseHelper.getDoneTasks(0),
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
                                    _task = task;
                                    return Card(
                                      elevation: 10.0,
                                      child: ListTile(
                                        leading: Checkbox(
                                          activeColor: Colors.amberAccent,
                                          splashRadius: 50,
                                          onChanged: (_) async {
                                            _task = Task(
                                              name: task.name,
                                              id: task.id,
                                              done: task.done == 1 ? 0 : 1,
                                              date: task.date,
                                            );
                                            if (_task == null) return;
                                            await DatabaseHelper.instance
                                                .change(
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
                                            }
                                            // else {
                                            //   setState(() {
                                            //     bool_done = true;
                                            //   });
                                            // }
                                            print(_task!.done);
                                          },
                                          value:
                                              _task!.done == 1 ? false : true,
                                        ),
                                        trailing: Container(
                                          width: 100,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    creatingAlertDialog(
                                                        context, task.name);
                                                  },
                                                  icon: Icon(
                                                      Icons.delete_forever)),
                                              IconButton(
                                                  onPressed: () {
                                                    creatingUpdateAlertDialog(context, task);
                                                  },
                                                  icon: Icon(Icons.edit))
                                            ],
                                          ),
                                        ),
                                        title: Column(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _task!.name, //here
                                              style: TextStyle(
                                                  decoration: _task!.done == 0
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null),
                                            ),
                                            Text(
                                              _task!.date, //here
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                      );
                    },
                  )
                : FutureBuilder<List<Task>>(
                    future: databaseHelper.getNotDoneTasks(1),
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
                                    _task = task;
                                    return Card(
                                      elevation: 10.0,
                                      child: ListTile(
                                          trailing: Container(
                                            width: 100,
                                            child: Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      creatingAlertDialog(
                                                          context, task.name);
                                                    },
                                                    icon: Icon(
                                                        Icons.delete_forever)),
                                                IconButton(
                                                    onPressed: () {
                                                      creatingUpdateAlertDialog(context, task);
                                                    },
                                                    icon: Icon(Icons.edit))
                                              ],
                                            ),
                                          ),
                                          leading: Checkbox(
                                            activeColor: Colors.lightBlueAccent,
                                            onChanged: (_) async {
                                              _task = Task(
                                                name: task.name,
                                                id: task.id,
                                                done: task.done == 1 ? 0 : 1,
                                                date: task.date,
                                              );
                                              if (_task == null) return;
                                              await DatabaseHelper.instance
                                                  .change(
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
                                              }
                                              // else {
                                              //   setState(() {
                                              //     bool_done = true;
                                              //   });
                                              // }
                                              print(_task!.done);
                                            },
                                            value:
                                                _task!.done == 1 ? false : true,
                                          ),
                                          title: Column(
                                            // mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _task!.name, //here
                                                style: TextStyle(
                                                    decoration: _task!.done == 0
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : null),
                                              ),
                                              Text(
                                                _task!.date, //here
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onLongPress: () {
                                            creatingAlertDialog(
                                                context, task.name);
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
