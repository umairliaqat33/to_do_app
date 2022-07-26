import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../database/database.dart';

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
                    msg: "Task deleted",
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
