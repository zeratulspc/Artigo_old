import 'dart:collection';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:nextor/page/basicDialogs.dart';
import 'package:nextor/fnc/user.dart';

class NotificationFCMFnc {
  final FirebaseMessaging fbMessaging = FirebaseMessaging();
  final NotificationDatabaseFnc notificationDBFnc = NotificationDatabaseFnc();
  String serverToken;

  Future<String> getServerToken() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child("Version").child("Token").once();
    return snapshot.value["fcmServerToken"];
  }

  Future<bool> sendNotification({
    String receiverUid,
    String senderUid,
    String body,
    String title,
  }) async {
    User receiver = await UserDBFNC().getUserInfo(receiverUid);
    User sender = await UserDBFNC().getUserInfo(senderUid);
    serverToken = await getServerToken();
    String key = notificationDBFnc.sendNotification(NotificationUnit(
      title: title,
      body: "${sender.userName}$body",
      receiverUid: receiverUid,
      senderUid: senderUid,
      date: DateTime.now().toIso8601String(),
      isChecked: false,
    ));
    http.Response response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': "${sender.userName}$body",
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'receiverUid' : receiverUid,
            'senderUid' : senderUid,
            'body' : "${sender.userName}$body",
            'title' : title
          },
          'to': receiver.token,
        },
      ),
    );
    if(response.statusCode == 200) {
      notificationDBFnc.setIsSent( // DB에 성공여부 기록
        key: key,
        receiverUid: receiverUid,
        senderUid: senderUid,
        isSent: true,
      );
      return true;
    } else {
      notificationDBFnc.setIsSent( // DB에 성공여부 기록
        key: key,
        receiverUid: receiverUid,
        senderUid: senderUid,
        isSent: false,
      );
      return false;
    }
  }

  Future sendFollowerNotification({
    BuildContext context,
    String senderUid,
    String body,
    String title,
  }) async {
    User sender = await UserDBFNC().getUserInfo(senderUid);
    serverToken = await getServerToken();
    for(int i = 0; i < sender.follower.length; i++) {
      String _followerToken;
      _followerToken = sender.follower[i].followerToken;
      if(_followerToken == null) {
        User receiverInfo = await UserDBFNC().getUserInfo(sender.follower[i].followerUid);
        _followerToken = receiverInfo.token;
      }
      String key = notificationDBFnc.sendNotification(NotificationUnit(
        title: title,
        body: body,
        receiverUid: sender.follower[i].followerUid,
        senderUid: senderUid,
        date: DateTime.now().toIso8601String(),
        isChecked: false,
      ));
      http.Response response = await http.post(
        'https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'receiverUid' : sender.follower[i].followerUid,
              'senderUid' : senderUid,
              'body' : body,
              'title' : title
            },
            'to': _followerToken,
          },
        ),
      );
      if(response.statusCode == 200) {
        notificationDBFnc.setIsSent( // DB에 성공여부 기록
          key: key,
          receiverUid: sender.follower[i].followerUid,
          senderUid: senderUid,
          isSent: true,
        );
      } else {
        notificationDBFnc.setIsSent( // DB에 성공여부 기록
          key: key,
          receiverUid: sender.follower[i].followerUid,
          senderUid: senderUid,
          isSent: false,
        );
      }
    }
  }

  static Future<dynamic> onResume(BuildContext context, Map<String, dynamic> message) async {
    NotificationUnit unit = NotificationUnit().fromMap(message);
    BasicDialogs().dialogWithYes(context, unit.title, unit.body);
  }

  static Future<dynamic> onMessage(BuildContext context, Map<String, dynamic> message) async {

  }

  static Future<dynamic> onLaunch(BuildContext context, Map<String, dynamic> message) async {
    NotificationUnit unit = NotificationUnit().fromMap(message);
    BasicDialogs().dialogWithYes(context, unit.title, unit.body);
  }

}

class NotificationDatabaseFnc {
  final notificationDbRef = FirebaseDatabase.instance.reference().child("Notifications");
  
  String sendNotification(NotificationUnit notification) {
    String key = notificationDbRef.child(notification.receiverUid).child("receivedNotification").push().key;
    notificationDbRef.child(notification.receiverUid).child("receivedNotifications").child(key).set(notification.toJson());
    notificationDbRef.child(notification.senderUid).child("sentNotifications").child(key).set(notification.toJson());
    return key;
  }

  void setIsChecked({
    String key,
    String userUid,
    String notification,
    bool isChecked,
  }) {
    notificationDbRef.child(userUid).child(notification).child(key).child("isChecked").set(isChecked);
  }

  void setIsSent({
    String key, // DB에 성공여부 기록
    String receiverUid,
    String senderUid,
    bool isSent}){
    notificationDbRef.child(receiverUid).child("receivedNotifications").child(key).child("isSent").set(isSent);
    notificationDbRef.child(senderUid).child("sentNotifications").child(key).child("isSent").set(isSent);
  }

}


class Notifications {
  List<NotificationUnit> receivedNotifications = List();
  List<NotificationUnit> sentNotifications = List();

  Notifications({this.receivedNotifications, this.sentNotifications});

  fromSnapshot(DataSnapshot snapshot) {
    LinkedHashMap<dynamic, dynamic> _received = snapshot.value["receivedNotifications"];
    List<NotificationUnit> received = List();
    if(_received != null){
      _received.forEach((k, v) {
        received.add(NotificationUnit().fromLinkedHashMap(v));
      });
    }

    LinkedHashMap<dynamic, dynamic> _sent = snapshot.value["sentNotifications"];
    List<NotificationUnit> sent = List();
    if(_sent != null){
      _sent.forEach((k, v) {
        sent.add(NotificationUnit().fromLinkedHashMap(v));
      });
    }

    return Notifications(
      receivedNotifications: received,
      sentNotifications: sent,
    );
  }

}

class NotificationUnit {
  String key; // 알림 키, 대상 및 본인 둘다 동일
  String receiverUid; // 수신자 아이디
  String senderUid; // 송신자 아이디
  String title; // 알림 타이틀
  String body; // 알림 바디
  String date; // 알림 송수신일
  bool isChecked; // 송수신자의 알림 확인 여부
  bool isSent; // FCM 전달이 성공했는지

  User senderInfo;
  User receiverInfo;

  NotificationUnit({this.key, this.receiverUid, this.senderUid,this.title, this.body, this.date, this.isChecked, this.isSent});

  fromMap(Map<String, dynamic> message) {
    return NotificationUnit(
      key: message["data"]["key"],
      receiverUid: message["data"]["receiverUid"],
      senderUid: message["data"]["senderUid"],
      title: message["data"]["title"],
      body: message["data"]["body"],
      date: message["data"]["date"],
      isChecked: message["data"]["isChecked"],
      isSent: message["data"]["isSent"],
    );
  }

  NotificationUnit.fromSnapShot(DataSnapshot snapshot)
      :key = snapshot.key,
        receiverUid = snapshot.value["receiverUid"],
        senderUid = snapshot.value["senderUid"],
        body = snapshot.value["body"],
        date = snapshot.value["date"],
        title = snapshot.value["title"],
        isChecked = snapshot.value["isChecked"],
        isSent = snapshot.value["isSent"];

  fromLinkedHashMap(LinkedHashMap linkedHashMap){
    return NotificationUnit(
      receiverUid: linkedHashMap["receiverUid"],
      senderUid: linkedHashMap["senderUid"],
      title: linkedHashMap["title"],
      body: linkedHashMap["body"],
      date: linkedHashMap["date"],
      isChecked: linkedHashMap["isChecked"],
      isSent: linkedHashMap["isSent"],
    );
  }

  toJson() {
    return {
      "receiverUid": receiverUid,
      "senderUid" : senderUid,
      "body" : body,
      "date" : date,
      "title": title,
      "isChecked": isChecked,
      "isSent": isSent,
    };
  }

}
