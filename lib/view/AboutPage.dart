import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 18, 84, 218),
        title: Text('about this apps'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Developed by: Shivem Kumar , '
          '           '
          'l got degrees in B.Tech Computer Science and Engineering from IK.Gujral Punjab Technical University Mohali Campuse -I ',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
