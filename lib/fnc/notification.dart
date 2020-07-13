import 'dart:collection';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;


class NotificationFCMFnc {
  final String serverToken = "AIzaSyA_SQJ1eOKjEDhPMHeAi-2qi4e-s7tTNQw"; //TODO 보안
  final FirebaseMessaging fbMessaging = FirebaseMessaging();
  final NotificationDatabaseFnc notificationDBFnc = NotificationDatabaseFnc();

  Future<bool> sendNotification({
    String userToken,
    String receiver,
    String sender,
    String body,
    String title,
  }) async {
    await fbMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
    );
    notificationDBFnc.sendNotification(Notification(
      title: title,
      body: body,
      receiverUid: receiver,
      senderUid: sender,
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
            'receiver' : receiver,
            'sender' : sender,
            'body' : body,
            'title' : title
          },
          'to': userToken,
        },
      ),
    );
    if(response.statusCode == 200) {
      return true; //TODO true 값 반환되면서 dialog
    } else {
      return false; //TODO false 값 반환되면서 dialog
    }
  }

}

class NotificationDatabaseFnc {
  final notificationDbRef = FirebaseDatabase.instance.reference().child("Users");
  
  void sendNotification(Notification notification,) {
    String key = notificationDbRef.child(notification.receiverUid).child("receivedNotification").push().key;
    notificationDbRef.child(notification.receiverUid).child("receivedNotification").child(key).set(notification.toJson());
    notificationDbRef.child(notification.senderUid).child("sentNotification").child(key).set(notification.toJson());
  }



}

//[알림-사용범위]
//1. 게시글
//1-1. 팔로우 한 유저가 게시글을 썼을 때
//1-2. 팔로우 한 유저가 게시글을 수정했을 때
//1-3. 게시글에 좋아요가 달렸을 때
//2. 댓글
//2-1. 내 게시글에 유저가 댓글을 달았을 때
//2-2. 내 댓글에 유저가 답글을 달았을 때
//2-3. 내 댓글에 좋아요가 달렸을 때

class Notification {
  String key; // 알림 키, 대상 및 본인 둘다 동일
  String receiverUid; // 수신자 아이디
  String senderUid; // 송신자 아이디
  String title; // 알림 타이틀
  String body; // 알림 바디
  String date; // 알림 송수신일
  bool isChecked; // 대상자의 알림 확인 여부

  Notification({this.key, this.receiverUid, this.senderUid,this.title, this.body, this.date, this.isChecked});

  Notification.fromSnapShot(DataSnapshot snapshot)
      :key = snapshot.key,
        receiverUid = snapshot.value["receiverUid"],
        senderUid = snapshot.value["senderUid"],
        body = snapshot.value["body"],
        date = snapshot.value["date"],
        title = snapshot.value["title"],
        isChecked = snapshot.value["isChecked"];

  toJson() {
    return {
      "receiverUid": receiverUid,
      "senderUid" : senderUid,
      "body" : body,
      "date" : date,
      "title": title,
      "isChecked": isChecked,
    };
  }

}
