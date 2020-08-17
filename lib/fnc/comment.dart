import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:Artigo/fnc/emotion.dart';
import 'package:Artigo/fnc/postDB.dart';
import 'package:Artigo/fnc/user.dart';

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
  List<Emotion> emotion;
  List<Comment> reply;

  User uploaderInfo;

  Comment({this.key, this.body, this.uploaderUID, this.uploadDate, this.attach, this.emotion, this.reply});

  fromLinkedHashMap(LinkedHashMap linkedHashMap) {
    LinkedHashMap<dynamic, dynamic> _emotionList = linkedHashMap["emotion"];
    List<Emotion> emotionList;
    if(_emotionList != null) {
      emotionList = List();
      _emotionList.forEach((k, v) {
        emotionList.add(Emotion.fromLinkedHashMap(v));
      });
      emotionList.sort((a, b)=>DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    }

    LinkedHashMap<dynamic, dynamic> _replyList = linkedHashMap["reply"];
    List<Comment> replyList;
    if(_replyList != null) {
      replyList = List();
      _replyList.forEach((k, v) {
        replyList.add(Comment().fromLinkedHashMap(v));
      });
      replyList.sort((a, b)=>DateTime.parse(a.uploadDate).compareTo(DateTime.parse(b.uploadDate)));
    }

    return Comment(
        body : linkedHashMap["body"],
        uploaderUID : linkedHashMap["uploaderUID"],
        uploadDate : linkedHashMap["uploadDate"],
        emotion : emotionList,
        reply : replyList,
    );
  }

  fromSnapShot(DataSnapshot snapshot) {
    LinkedHashMap<dynamic, dynamic> _emotionList = snapshot.value["emotion"];
    List<Emotion> emotionList;
    if(_emotionList != null) {
      emotionList = List();
      _emotionList.forEach((k, v) {
        emotionList.add(Emotion.fromLinkedHashMap(v));
      });
      emotionList.sort((a, b)=>DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    }

    LinkedHashMap<dynamic, dynamic> _commentList = snapshot.value["reply"];
    List<Comment> replyList;
    if(_commentList != null) {
      replyList = List();
      _commentList.forEach((k, v) {
        replyList.add(Comment().fromLinkedHashMap(v));
      });
      replyList.sort((a, b)=>DateTime.parse(a.uploadDate).compareTo(DateTime.parse(b.uploadDate)));
    }
    return Comment(
      key : snapshot.key,
      body : snapshot.value["body"],
      uploaderUID : snapshot.value["uploaderUID"],
      uploadDate : snapshot.value["uploadDate"],
      //attach = snapshot.value["attach"],
      emotion : emotionList,
      reply : replyList,
    );
  }

  toMap() {
    return {
      "key" : key,
      "body" : body,
      "uploaderUID" : uploaderUID,
      "uploadDate" : uploadDate,
      "attach" : attach,
      "like" : emotion,
      "reply" : reply
    };
  }

}