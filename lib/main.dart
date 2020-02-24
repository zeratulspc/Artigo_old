import 'package:flutter/material.dart';

import 'package:nextor/page/auth/login.dart';
import 'package:nextor/page/home.dart';

void main() => runApp(MyApp());

final routes = {
  '/login': (BuildContext context) => LoginPage(),
  '/home': (BuildContext context) => HomePage(),
};

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: RemoveGrow(),
          child: child,
        );
      },
      title: 'Nextor Community',
      theme: ThemeData(
        primaryColor: Colors.orange[700],
        primarySwatch: Colors.orange,
        accentColor: Colors.orangeAccent,
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
