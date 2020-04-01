import 'dart:collection';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

import 'package:nextor/fnc/auth.dart';
import 'package:nextor/fnc/comment.dart';
import 'package:nextor/fnc/like.dart';

class PostDBFNC {
  final postDBRef = FirebaseDatabase.instance.reference().child("Posts");
  final StorageReference fireBaseStorageRef = FirebaseStorage.instance.ref().child("Posts");

  Future<String> createPost(Post post) async {
    String key = postDBRef.push().key;
    postDBRef.child(key).set(post.toMap());
    return key;
  }

  Future addPhoto(Attach attach, String postKey) async {
    final StorageUploadTask task =
    fireBaseStorageRef.child(postKey).child(basename(attach.tempPhoto.path)).putFile(attach.tempPhoto);
    await task.onComplete;
    String imageUrl = await(await task.onComplete).ref.getDownloadURL();
    attach.key = postDBRef.child(postKey).child("attach").push().key;
    attach.filePath = imageUrl;
    await postDBRef.child(postKey).child("attach").child(attach.key).set(attach.toMap());
  }

  Future updatePost(String key, Post post) async {
    await postDBRef.child(key).set(post.toMap());
  }

  Future deletePost(String key) async {
    await postDBRef.child(key).remove();
  }

  Future<Post> getPost(String key) async {
    return Post.fromSnapShot(await postDBRef.child(key).once());
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

  Post({this.key, this.body, this.uploaderUID, this.uploadDate, this.attach, this.like, this.comment, this.isEdited});

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
  String uploadDate;
  File tempPhoto;

  Attach({this.fileName, this.filePath, this.description, this.uploaderUID, this.tempPhoto, this.uploadDate});

  Attach.fromLinkedHashMap(LinkedHashMap linkedHashMap)
    :key = linkedHashMap["key"],
      id = linkedHashMap["id"],
      fileName = linkedHashMap["fileName"],
      filePath = linkedHashMap["filePath"],
      description = linkedHashMap["description"],
      uploadDate = linkedHashMap["uploadDate"],
      uploaderUID = linkedHashMap["uploaderUID"];

  toMap() {
    return {
      "key" : key,
      "id" : id,
      "fileName" : fileName,
      "filePath" : filePath,
      "description" : description,
      "uploadDate" : uploadDate,
      "uploaderUID" : uploaderUID
    };
  }

}