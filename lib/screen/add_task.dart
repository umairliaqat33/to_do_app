import 'dart:math';

import 'package:flutter/material.dart';
import 'package:to_do_app/database/database.dart';
import 'package:to_do_app/model/task.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final taskController = TextEditingController();
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    setState(() {
      _formKey = new GlobalKey<FormState>();
    });
  }

  Random random = new Random();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF757575),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Add Task',
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
                  cursorColor: Colors.black,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  controller: taskController,
                ),
                TextButton(
                  child: Text('Add', style: TextStyle(color: Colors.white)),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.amberAccent),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await DatabaseHelper.instance.add(
                        Task(
                            name: taskController.text,
                            done: 1,
                            id: random.nextInt(200)),
                      );
                      print(taskController.text);
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
    );
  }
}
