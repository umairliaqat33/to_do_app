import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/screen/add_task.dart';
import 'constants/constants.dart';
import 'database/database.dart';
import 'model/task.dart';
import 'package:to_do_app/constants/banner.dart';

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
  final _prefs = SharedPreferences.getInstance();

  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    getSwitchState();
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
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Update ' "\'${task.name}\'",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 30, color: Colors.amberAccent)),
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
                      Row(
                        children: [
                          TextButton(
                            onPressed: () async {
                              TimeOfDay? newTime = await showTimePicker(
                                  context: context, initialTime: time);
                              if (newTime == null) return;
                              setState(() {
                                time = newTime;
                              });
                              FocusScope.of(context).unfocus();
                            },
                            child: Text(
                              "Chose Time",
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Picked Time: ${time.format(context)}",
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        child: Text('Update',
                            style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.amberAccent),
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
                                  time: time.format(context),
                                ),
                                task.id);
                            Fluttertoast.showToast(
                                msg: "Task Updated",
                                backgroundColor: Colors.amberAccent,
                                textColor: Colors.white,
                                fontSize: 16.0);
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

  TimeOfDay time = TimeOfDay.now();

  saveSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("switchState", isSelected);
  }

  getSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isSelected = prefs.getBool("switchState")!;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            MainBanner(),
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
                        saveSwitchState();
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
                                              time: task.time,
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
                                                    creatingUpdateAlertDialog(
                                                        context, task);
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
                                            Row(
                                              children: [
                                                Text(
                                                  _task!.date, //here
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  _task!.time, //here
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
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
                                                      creatingUpdateAlertDialog(
                                                          context, task);
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
                                                time: task.time,
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
                                                    fontSize: 18,
                                                    decoration: _task!.done == 0
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : null),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    _task!.date, //here
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    _task!.time, //here
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
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
      ),
    );
  }
}
