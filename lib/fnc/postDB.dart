import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:nextor/fnc/auth.dart';
import 'package:nextor/fnc/comment.dart';
import 'package:nextor/fnc/like.dart';

class PostDBFNC {
  final postDBRef = FirebaseDatabase.instance.reference().child("Posts");

  Future<String> createPost(Post post) async {
    String key = postDBRef.push().key;
    postDBRef.child(key).set(post.toMap());
    return key;
  }

  Future<bool> updatePost(String key, Post post) async {
    await postDBRef.child(key).set(post.toMap());
    return true;
  }

  Future<bool> deletePost(String key) async {
    await postDBRef.child(key).remove();
    return true;
  }

}

class Post {
  String key;
  String body;
  String uploaderUID; //TODO 유저 정보를 auth.dart 에 포함되있는 User 객체 사용
  String uploadDate;
  bool isEdited;
  LinkedHashMap<dynamic, dynamic> attach;
  LinkedHashMap<dynamic, dynamic> like;
  LinkedHashMap<dynamic, dynamic> comment;

  Post({this.key, this.body, this.uploaderUID, this.uploadDate, this.attach, this.like, this.comment});

  Post.fromSnapShot(DataSnapshot snapshot)
      :key = snapshot.key,
        body = snapshot.value["body"],
        uploaderUID = snapshot.value["uploaderUID"],
        attach = snapshot.value["attach"],
        like = snapshot.value["like"],
        uploadDate = snapshot.value["uploadDate"];

  toMap() {
    return {
      "key" : key,
      "body" : body,
      "uploaderUID" : uploaderUID,
      "uploadDate" : uploadDate,
      "attach" : attach,
      "like" : like
    };
  }

}

class Attach {
  String key;
  String id; // Md5Hash
  String fileName;
  String filePath;
  String description;
  String uploaderUID;

  Attach.fromLinkedHashMap(LinkedHashMap linkedHashMap)
    :key = linkedHashMap["key"],
      id = linkedHashMap["id"],
      fileName = linkedHashMap["fileName"],
      filePath = linkedHashMap["filePath"],
      description = linkedHashMap["description"],
      uploaderUID = linkedHashMap["uploaderUID"];

}