import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:nextor/page/profile/userProfile.dart';
import 'package:nextor/fnc/user.dart';
import 'package:nextor/fnc/notification.dart';
import 'package:nextor/fnc/dateTimeParser.dart';

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

  _rOnEntryAdded(Event event) async {
    if(this.mounted){
      NotificationUnit unit = NotificationUnit().fromLinkedHashMap(event.snapshot.value);
      unit.key = event.snapshot.key;
      unit.senderInfo = await UserDBFNC().getUserInfo(unit.senderUid);
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

  _rOnEntryChanged(Event event) async {
    if(this.mounted){
      NotificationUnit unit = NotificationUnit().fromLinkedHashMap(event.snapshot.value);
      unit.key = event.snapshot.key;
      unit.senderInfo = await UserDBFNC().getUserInfo(unit.senderUid);
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

  _sOnEntryAdded(Event event) async {
    if(this.mounted){
      NotificationUnit unit = NotificationUnit().fromLinkedHashMap(event.snapshot.value);
      unit.key = event.snapshot.key;
      unit.receiverInfo = await UserDBFNC().getUserInfo(unit.receiverUid);
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

  _sOnEntryChanged(Event event) async {
    if(this.mounted){
      NotificationUnit unit = NotificationUnit().fromLinkedHashMap(event.snapshot.value);
      unit.key = event.snapshot.key;
      unit.receiverInfo = await UserDBFNC().getUserInfo(unit.receiverUid);
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
    Size screenSize = MediaQuery.of(context).size;
    double profileImgRadius = 240;
    double profileImgHeight = 60;
    double profileImgWidth = 60;
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
              DateTime date = DateTime.parse(unit.date);
              return InkWell(
                onTap: unit.isChecked ? (){} : (){
                  NotificationDatabaseFnc().setIsChecked(
                    key: unit.key,
                    userUid: currentUserInfo.key,
                    notification: "receivedNotifications",
                    isChecked: false,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  color: unit.isChecked ? Colors.white : Colors.lightGreenAccent,
                  child: ListTile(
                    leading: unit.senderInfo != null ? unit.senderInfo.profileImageURL != null ?
                    ClipRRect( // User 정보가 있고, ProfileImage 가 존재할 때
                      borderRadius: BorderRadius.circular(profileImgRadius),
                      child: GestureDetector(
                        child: Container(
                          height: profileImgHeight,
                          width: profileImgWidth,
                          child: CachedNetworkImage(
                            imageUrl: unit.senderInfo.profileImageURL,
                          ),
                        ),
                        onTap: widget.currentUserUid == unit.senderInfo.key ? (){} : (){
                          Navigator.popUntil(context, ModalRoute.withName('/home'));
                          showModalBottomSheet(
                            backgroundColor: Colors.grey[300],
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return Container(
                                height: screenSize.height-50,
                                child: UserProfilePage(targetUserUid: unit.senderInfo.key, navigateToMyProfile: (){},),
                              );
                            },
                          );
                        },
                      ),
                    ) :
                    ClipRRect(// User 정보가 있고, ProfileImage 가 존재하지 않을 때
                        borderRadius: BorderRadius.circular(profileImgRadius),
                        child: Container(
                          height: profileImgHeight,
                          width: profileImgHeight,
                          color: Colors.grey[400],
                        )
                    ) : ClipRRect(//user 정보가 없을 때
                        borderRadius: BorderRadius.circular(profileImgRadius),
                        child: Container(
                          height: profileImgHeight,
                          width: profileImgHeight,
                          color: Colors.grey[400],
                        )
                    ),
                    title: Text(unit.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(unit.body),
                        SizedBox(height: 5,),
                        Text(DateTimeParser().defaultParse(date)),
                      ],
                    ),
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
              DateTime date = DateTime.parse(unit.date);
              return Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                color: Colors.white,
                child: ListTile(
                  leading: unit.receiverInfo != null ? unit.receiverInfo.profileImageURL != null ?
                  ClipRRect( // User 정보가 있고, ProfileImage 가 존재할 때
                    borderRadius: BorderRadius.circular(profileImgRadius),
                    child: GestureDetector(
                      child: Container(
                        height: profileImgHeight,
                        width: profileImgWidth,
                        child: CachedNetworkImage(
                          imageUrl: unit.receiverInfo.profileImageURL,
                        ),
                      ),
                      onTap: widget.currentUserUid == unit.receiverInfo.key ? (){} : (){
                        Navigator.popUntil(context, ModalRoute.withName('/home'));
                        showModalBottomSheet(
                          backgroundColor: Colors.grey[300],
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return Container(
                              height: screenSize.height-50,
                              child: UserProfilePage(targetUserUid: unit.receiverInfo.key, navigateToMyProfile: (){},),
                            );
                          },
                        );
                      },
                    ),
                  ) :
                  ClipRRect(// User 정보가 있고, ProfileImage 가 존재하지 않을 때
                      borderRadius: BorderRadius.circular(profileImgRadius),
                      child: Container(
                        height: profileImgHeight,
                        width: profileImgHeight,
                        color: Colors.grey[400],
                      )
                  ) : ClipRRect(//user 정보가 없을 때
                      borderRadius: BorderRadius.circular(profileImgRadius),
                      child: Container(
                        height: profileImgHeight,
                        width: profileImgHeight,
                        color: Colors.grey[400],
                      )
                  ),
                  title: Text(unit.receiverInfo.userName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(unit.body),
                      SizedBox(height: 5,),
                      Text(DateTimeParser().defaultParse(date)),
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