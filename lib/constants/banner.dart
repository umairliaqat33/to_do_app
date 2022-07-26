import 'package:flutter/material.dart';

class MainBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 2),
            blurRadius: 6,
          )
        ],
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
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
              child: Icon(Icons.list, color: Colors.amberAccent, size: 30)),
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
    );
  }
}
