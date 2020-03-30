import 'package:flutter/material.dart';


class DataBoard extends StatefulWidget {
  @override
  _DataBoardState createState() => _DataBoardState();
}

class _DataBoardState extends State<DataBoard> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("작업중..."),
      ),
    );
  }
}
