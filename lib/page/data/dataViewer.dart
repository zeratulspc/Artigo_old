import 'package:flutter/material.dart';


class DataViewer extends StatefulWidget {
  @override
  _DataViewerState createState() => _DataViewerState();
}

class _DataViewerState extends State<DataViewer> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DataViewer"),
      ),
    );
  }
}
