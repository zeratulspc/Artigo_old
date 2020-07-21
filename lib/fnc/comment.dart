import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/user.dart';
import 'package:nextor/fnc/notification.dart';

class CommentDBFNC {
  CommentDBFNC(
      {@required this.commentDBRef});
  final DatabaseReference commentDBRef;

  Future<String> createComment(Comment comment) async {
      String key = commentDBRef.push().key;
      await commentDBRef.child(key).set(comment.toMap());
      return key;
  }

  Future updateComment(Comment comment) async {
      await commentDBRef.child(comment.key).update(comment.toMap());

  }

  Future deleteComment(String commentKey) async {
      await commentDBRef.child(commentKey).remove();
  }

}

class Comment {
  String key;
  String body;
  String uploaderUID;
  String uploadDate;
  Attach attach;
  LinkedHashMap<dynamic, dynamic> like;
  LinkedHashMap<dynamic, dynamic> reply;

  User uploaderInfo;

  Comment({this.key, this.body, this.uploaderUID, this.uploadDate, this.attach, this.like, this.reply});

  Comment.fromSnapShot(DataSnapshot snapshot)
  :key = snapshot.key,
    body = snapshot.value["body"],
    uploaderUID = snapshot.value["uploaderUID"],
    uploadDate = snapshot.value["uploadDate"],
    attach = snapshot.value["attach"],
    like = snapshot.value["like"],
    reply = snapshot.value["reply"];

  toMap() {
    return {
      "key" : key,
      "body" : body,
      "uploaderUID" : uploaderUID,
      "uploadDate" : uploadDate,
      "attach" : attach,
      "like" : like,
      "reply" : reply
    };
  }

}