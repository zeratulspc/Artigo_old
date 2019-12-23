import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:nextor/page/login.dart';

void main() => runApp(MyApp());
//Color(0xFF5f4b8b),
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: RemoveGrow(),
          child: child,
        );
      },
      title: 'Nextor Community',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.deepPurpleAccent,
      ),
      home: LoginPage(),
    );
  }
}



class RemoveGrow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
