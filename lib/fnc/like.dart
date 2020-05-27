import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class LikeDBFNC { //TODO 리팩토링
  LikeDBFNC({@required this.likeDBRef});
  final DatabaseReference likeDBRef;

  Future like(String userUID) async {
    likeDBRef.child("like").child(userUID).set(
        Like(userUID: userUID, isLiked: true, date: DateTime.now().toIso8601String()).toMap());
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