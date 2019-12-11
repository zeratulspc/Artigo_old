import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:nextor/page/login.dart';

void main() => runApp(MyApp());
//Color(0xFF5f4b8b),
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nextor Community',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        accentColor: Colors.deepPurpleAccent,
      ),
      home: LoginPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(

      )
    );
  }
}
