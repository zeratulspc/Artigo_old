import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:nextor/fnc/user.dart';
import 'package:nextor/fnc/notification.dart';

class NotificationList extends StatefulWidget {
  final String currentUserUid;
  NotificationList(this.currentUserUid);
  @override
  NotificationListState createState() => NotificationListState();
}

class NotificationListState extends State<NotificationList> with SingleTickerProviderStateMixin{
  Notifications notifications = Notifications(receivedNotifications: List(), sentNotifications: List());
  User currentUserInfo;
  Query receivedQuery;
  Query sentQuery;

  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this,length: 2);
    UserDBFNC().getUserInfo(widget.currentUserUid).then((data) {
      setState(() {
        currentUserInfo = data;
      });
      receivedQuery = FirebaseDatabase.instance.reference().child("Notifications").child(currentUserInfo.key).child("receivedNotifications");
      receivedQuery.onChildAdded.listen(_rOnEntryAdded);
      receivedQuery.onChildChanged.listen(_rOnEntryChanged);
      receivedQuery.onChildRemoved.listen(_rOnEntryRemoved);
      sentQuery = FirebaseDatabase.instance.reference().child("Notifications").child(currentUserInfo.key).child("sentNotifications");
      sentQuery.onChildAdded.listen(_sOnEntryAdded);
      sentQuery.onChildChanged.listen(_sOnEntryChanged);
      sentQuery.onChildRemoved.listen(_sOnEntryRemoved);
    });
  }

  _rOnEntryAdded(Event event) {
    if(this.mounted){
      NotificationUnit unit = NotificationUnit().fromLinkedHashMap(event.snapshot.value);
      unit.key = event.snapshot.key;
      setState(() {
        notifications.receivedNotifications.insert(0, unit);
        notifications.receivedNotifications.sort((a, b){
          DateTime dateA = DateTime.parse(a.date);
          DateTime dateB = DateTime.parse(b.date);
          return dateB.compareTo(dateA);
        });
      });
    }
  }

  _rOnEntryChanged(Event event) {
    if(this.mounted){
      NotificationUnit unit = NotificationUnit().fromLinkedHashMap(event.snapshot.value);
      unit.key = event.snapshot.key;
      var oldEntry = notifications.receivedNotifications.singleWhere((entry) {
          return entry.key == unit.key;
      });
      setState(() {
        notifications.receivedNotifications[notifications.receivedNotifications.indexOf(oldEntry)] = unit;
      });
    }
  }

  _rOnEntryRemoved(Event event) {
    if(this.mounted){
      NotificationUnit unit = NotificationUnit().fromLinkedHashMap(event.snapshot.value);
      setState(() {
        notifications.receivedNotifications.removeWhere((element) =>
          element.key == unit.key,
        );
      });
    }
  }

  _sOnEntryAdded(Event event) {
    if(this.mounted){
      NotificationUnit unit = NotificationUnit().fromLinkedHashMap(event.snapshot.value);
      unit.key = event.snapshot.key;
      setState(() {
        notifications.sentNotifications.insert(0, unit);
        notifications.sentNotifications.sort((a, b){
          DateTime dateA = DateTime.parse(a.date);
          DateTime dateB = DateTime.parse(b.date);
          return dateB.compareTo(dateA);
        });
      });
    }
  }

  _sOnEntryChanged(Event event) {
    if(this.mounted){
      NotificationUnit unit = NotificationUnit().fromLinkedHashMap(event.snapshot.value);
      unit.key = event.snapshot.key;
      var oldEntry = notifications.sentNotifications.singleWhere((entry) {
        return entry.key == unit.key;
      });
      setState(() {
        notifications.sentNotifications[notifications.sentNotifications.indexOf(oldEntry)] = unit;
      });
    }
  }

  _sOnEntryRemoved(Event event) {
    if(this.mounted){
      NotificationUnit unit = NotificationUnit().fromLinkedHashMap(event.snapshot.value);
      setState(() {
        notifications.sentNotifications.removeWhere((element) =>
        element.key == unit.key,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("${currentUserInfo != null ? currentUserInfo.userName : "불러오는 중"}님의 알림함", style: TextStyle(color: Colors.black),),
        bottom: TabBar(
          controller: tabController,
          tabs: <Widget>[
            Tab(
              child: Text(
                "받은 알림",
                style: TextStyle(color: Colors.black),
              ),
            ),
            Tab(
              child: Text(
                "보낸 알림",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          notifications.receivedNotifications != null ?  ListView.builder(
            itemCount: notifications.receivedNotifications.length,
            itemBuilder: (context, index) {
              NotificationUnit unit = notifications.receivedNotifications[index];
              return InkWell(
                onTap: (){
                  NotificationDatabaseFnc().setIsChecked(
                      key: unit.key,
                      userUid: currentUserInfo.key,
                      notification: "receivedNotifications",
                      isChecked: true,
                  );
                },
                child: Container(
                  color: unit.isChecked ? Colors.white : Theme.of(context).accentColor,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(unit.title),
                        subtitle: Text(unit.body),
                      ),
                      Divider(),
                    ],
                  ),
                ),
              );
            },
          ): Center(
            child: CircularProgressIndicator(),
          ),
          notifications.sentNotifications != null ?  ListView.builder(
            itemCount: notifications.sentNotifications.length,
            itemBuilder: (context, index) {
              NotificationUnit unit = notifications.sentNotifications[index];
              return InkWell(
                onTap: (){
                  NotificationDatabaseFnc().setIsChecked(
                    key: unit.key,
                    userUid: currentUserInfo.key,
                    notification: "sentNotifications",
                    isChecked: true,
                  );
                },
                child: Container(
                  color: unit.isChecked ? Colors.white : Theme.of(context).accentColor,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(unit.title),
                        subtitle: Text(unit.body),
                      ),
                      Divider(),
                    ],
                  ),
                ),
              );
            },
          ): Center(
            child: CircularProgressIndicator(),
          ),
        ],
        controller: tabController,
      ),
    );
  }
}