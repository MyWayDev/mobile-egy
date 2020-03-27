import 'package:flutter/material.dart';
import 'package:html2md/html2md.dart' as html2md;

class HowTo extends StatelessWidget {
  final String howToText;
  HowTo(this.howToText);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(3),
        child: SingleChildScrollView(
            child: Center(
                child: Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            html2md.convert(howToText ?? ''),
            style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.bold,
                fontSize: 15),
            softWrap: true,
            //!done direction orientation.
            textDirection: TextDirection.ltr,
          ),
        ))),
      ),
    );
  }
}
