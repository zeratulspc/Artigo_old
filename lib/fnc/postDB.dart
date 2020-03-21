import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:nextor/fnc/auth.dart';
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
  String upLoaderUID; //TODO 유저 정보를 auth.dart 에 포함되있는 User 객체 사용
  String uploadDate;
  bool isEdited;
  List<Attach> attach;
  List<Like> like;

  Post({this.key, this.body, this.upLoaderUID, this.uploadDate, this.attach, this.like});

  Post.fromSnapShot(DataSnapshot snapshot)
      :key = snapshot.key,
        body = snapshot.value["body"],
        upLoaderUID = snapshot.value["upLoaderUID"],
        attach = snapshot.value["attach"],
        like = snapshot.value["like"],
        uploadDate = snapshot.value["date"];

  toMap() {
    return {
      "key" : key,
      "body" : body,
      "upLoaderUID" : upLoaderUID,
      "date" : uploadDate,
      "attach" : attach,
      "like" : like
    };
  }

}

class Attach {
  String id; // Md5Hash
  String fileName;
  String filePath;
  String description;
  String userId;
}