import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:nextor/fnc/postDB.dart';

class CommentDBFNC {
  CommentDBFNC(
      {@required this.postKey, this.commentKey});
  final String postKey;
  final String commentKey;

  Future<String> createComment(Comment comment) async {
    if(commentKey == null) {
      final commentDBRef = FirebaseDatabase.instance.reference().child("Posts").child(postKey).child("comment");
      String key = commentDBRef.push().key;
      await commentDBRef.child(key).set(comment.toMap());
      return key;
    } else {
      final commentDBRef = FirebaseDatabase.instance.reference().child("Posts").child(postKey).child("comment").child(commentKey).child("reply");
      String key = commentDBRef.push().key;
      await commentDBRef.child(key).set(comment.toMap());
      return key;
    }
  }

  Future updateComment(Comment comment) async {
    if(commentKey == null) {
      final commentDBRef = FirebaseDatabase.instance.reference().child("Posts").child(postKey).child("comment");
      await commentDBRef.child(comment.key).update(comment.toMap());
    } else {
      final commentDBRef = FirebaseDatabase.instance.reference().child("Posts").child(postKey).child("comment").child(commentKey).child("reply");
      await commentDBRef.child(comment.key).update(comment.toMap());
    }
  }

  Future deleteComment(String commentKey) async {
    if(this.commentKey == null) {
      final commentDBRef = FirebaseDatabase.instance.reference().child("Posts").child(postKey).child("comment");
      await commentDBRef.child(commentKey).remove();
    } else {
      final commentDBRef = FirebaseDatabase.instance.reference().child("Posts").child(postKey).child("comment").child(this.commentKey).child("reply");
      await commentDBRef.child(commentKey).remove();
    }
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