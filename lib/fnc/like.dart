import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import 'package:nextor/fnc/notification.dart';

class LikeDBFNC {
  LikeDBFNC({@required this.likeDBRef});
  final DatabaseReference likeDBRef;

  Future like(String userUid, String targetUserUid) async {
    likeDBRef.child("like").child(userUid).set(
        Like(userUID: userUid, isLiked: true, date: DateTime.now().toIso8601String()).toMap());
    if(userUid != targetUserUid) {
      NotificationFCMFnc().sendNotification(
        senderUid: userUid,
        receiverUid: targetUserUid,
        title: "좋아요 알림",
        body: "님이 좋아요를 눌렀습니다.",
      );
    }
  }

  Future dislike(String userUID) async {
    likeDBRef.child("like").child(userUID).remove();
  }
}

class Like {
  String userUID;
  bool isLiked;
  String date;

  Like({this.userUID, this.isLiked, this.date});

  Like.fromSnapshot(DataSnapshot snapshot)
    :userUID = snapshot.value["userUID"],
      isLiked = snapshot.value["isLiked"],
      date = snapshot.value["date"];

  Like.fromLinkedHashMap(LinkedHashMap linkedHashMap)
      :userUID = linkedHashMap["userUID"],
        isLiked = linkedHashMap["isLiked"],
        date = linkedHashMap["date"];

  toMap() {
    return {
      "userUID" : userUID,
      "isLiked" : isLiked,
      "date" : date
    };
  }
}