import 'package:flutter/material.dart';


class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
//TODO postList Design
//TODO postList FNC

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("설정"),
      ),
      body: Center(
        child: Text("작업중..."),
      ),
    );
  }
}
