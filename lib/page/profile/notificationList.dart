import 'package:flutter/material.dart';

import 'package:nextor/fnc/notification.dart';

class NotificationList extends StatefulWidget {
  @override
  NotificationListState createState() => NotificationListState();
}

class NotificationListState extends State<NotificationList> {

  @override
  void initState() {
    super.initState();
    //TODO get noti info
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("{}님의 알림함", style: TextStyle(color: Colors.black),),
      ),
      backgroundColor: Colors.white,
    );
  }

}