import 'dart:collection';
import 'dart:io';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';


class PostDBFNC {
  final postDBRef = FirebaseDatabase.instance.reference().child("Posts");
  final StorageReference fireBaseStorageRef = FirebaseStorage.instance.ref().child("Posts");

  String createPost(Post post) {
    String key = postDBRef.push().key;
    postDBRef.child(key).set(post.toMap());
    return key;
  }

  Future addPhoto(Attach attach, String postKey, int index) async {
    print(index);
    attach.fileName = basename(attach.tempPhoto.path); //TODO 랜덤 이름
    final StorageUploadTask task =
    fireBaseStorageRef.child(postKey).child(basename(attach.fileName)).putFile(attach.tempPhoto);
    task.onComplete.then((com) async { // Photo 업로드 성공 시
      String imageUrl = await com.ref.getDownloadURL();
      attach.filePath = imageUrl;
      await postDBRef.child(postKey).child("attach").child(index.toString()).set(attach.toMap());
    }).catchError((error){ // Photo 업로드 실패 시
      print(error.hashCode);
    });
  }

  Future deletePhoto(String postKey, Attach attach,int index) async {
    attach.fileName = attach.tempPhoto != null ? basename(attach.tempPhoto.path) : attach.fileName;
    await fireBaseStorageRef.child(postKey).child(basename(attach.fileName)).delete();
    await postDBRef.child(postKey).child("attach").child(index.toString()).remove();
  }

  Future updatePost(String key, Post post) async {
    await postDBRef.child(key).set(post.toMap());
  }

  Future deletePostStorage(String key, List<Attach> attach) async {
    for(int i = 0; i < attach.length; i++) {
      await fireBaseStorageRef.child(key).child(attach[i].fileName).delete();
    }
  }

  Future deletePost(String key) async {
    await postDBRef.child(key).remove();
  }

  Future<Post> getPost(String key) async {
    return Post().fromSnapShot(await postDBRef.child(key).once());
  }

}

class Post {
  String key;
  String body;
  String uploaderUID;
  String uploadDate;
  bool isEdited;
  List<Attach> attach;
  LinkedHashMap<dynamic, dynamic> like;
  LinkedHashMap<dynamic, dynamic> comment;

  Post({this.key, this.body, this.uploaderUID, this.uploadDate, this.attach, this.like, this.comment, this.isEdited});

//  Post.fromSnapShot(DataSnapshot snapshot)
//      :key = snapshot.key,
//        body = snapshot.value["body"],
//        uploaderUID = snapshot.value["uploaderUID"],
//        attach = snapshot.value["attach"].map((i) => Attach.fromJson(i)).toList(),
//        like = snapshot.value["like"],
//        comment = snapshot.value["comment"],
//        uploadDate = snapshot.value["uploadDate"];

  fromSnapShot(DataSnapshot snapshot) {
    var _list = snapshot.value["attach"] as List;
    List<Attach> _attachList;
    if(_list != null) {
      _attachList = _list.map((i) => Attach.fromJson(i)).toList();
    }
    return Post(
      key: snapshot.key,
        body : snapshot.value["body"],
        uploaderUID : snapshot.value["uploaderUID"],
        attach : _attachList,
        like : snapshot.value["like"],
        comment : snapshot.value["comment"],
        uploadDate : snapshot.value["uploadDate"]
    );
  }

  toMap() {
    List<dynamic> attaches=
    attach != null ? attach.map((i) => i.toMap()).toList() : null;

    return {
      "key" : key,
      "body" : body,
      "uploaderUID" : uploaderUID,
      "uploadDate" : uploadDate,
      "attach" : attaches,
      "comment" : comment,
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
  LinkedHashMap<dynamic, dynamic> like;
  LinkedHashMap<dynamic, dynamic> comment;
  File tempPhoto;
  bool seeMore = false;

  Attach({this.key, this.fileName, this.filePath, this.description, this.uploaderUID, this.tempPhoto, this.uploadDate,});

  Attach.fromLinkedHashMap(LinkedHashMap linkedHashMap)
    :key = linkedHashMap["key"],
      id = linkedHashMap["id"],
      fileName = linkedHashMap["fileName"],
      filePath = linkedHashMap["filePath"],
      description = linkedHashMap["description"],
      uploadDate = linkedHashMap["uploadDate"],
      uploaderUID = linkedHashMap["uploaderUID"];

  factory Attach.fromJson(LinkedHashMap<dynamic, dynamic> parsedJson) {
    return Attach(
      key: parsedJson["key"],
      fileName: parsedJson["fileName"],
      filePath: parsedJson["filePath"],
      description: parsedJson["description"],
      uploadDate: parsedJson["uploadDate"],
      uploaderUID: parsedJson["uploaderUID"],
    );
  }


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