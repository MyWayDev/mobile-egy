import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final double barHeight = 32.0; // change this for different heights

  CustomAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;

    return new Container(
      padding: new EdgeInsets.only(top: statusbarHeight),
      height: statusbarHeight + barHeight,
      child: new Center(
        child: new Text(
          title,
          style: new TextStyle(
              fontSize: 17.0,
              color: Colors.black38,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
