import 'dart:collection';
import 'dart:io';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nextor/fnc/comment.dart';
import 'package:nextor/fnc/like.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';


class PostDBFNC {
  final postDBRef = FirebaseDatabase.instance.reference().child("Posts");
  final StorageReference fireBaseStorageRef = FirebaseStorage.instance.ref().child("Posts");
  final Uuid _uuid = Uuid();

  String createPost(Post post) {
    String key = postDBRef.push().key;
    postDBRef.child(key).set(post.toMap());
    return key;
  }

  Future addPhoto(Attach attach, String postKey) async {
    attach.fileName = "${_uuid.v1()}.${attach.tempPhoto.path.split('.').last}";
    final StorageUploadTask task =
    fireBaseStorageRef.child(postKey).child(attach.fileName).putFile(attach.tempPhoto);
    task.onComplete.then((com) async { // Photo 업로드 성공 시
      String imageUrl = await com.ref.getDownloadURL();
      attach.filePath = imageUrl;
      String key = postDBRef.child(postKey).child("attach").push().key;
      attach.key = key;
      postDBRef.child(postKey).child('attach').child(key).update(attach.toMap());
    }).catchError((error){ // Photo 업로드 실패 시
      print(error.hashCode);
    });
  }



  Future deletePhoto(String postKey, Attach attach) async {
    await fireBaseStorageRef.child(postKey).child(attach.fileName).delete();
    await postDBRef.child(postKey).child("attach").child(attach.key).remove();
  }

  Future updatePost(String key, Post post) async {
    await postDBRef.child(key).set(post.toMap());
  }

  Future deletePostStorage(String key, List<Attach> attach) async {
    attach.forEach((v) async {
      await fireBaseStorageRef.child(key).child(v.fileName).delete();
    });
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

  Post({this.key, this.body, this.uploaderUID, this.uploadDate, this.attach,
    this.like, this.comment, this.isEdited,});

  fromSnapShot(DataSnapshot snapshot) {
// List<dynamic> 을 List<Attach> 으로 파싱하는 코드임.
//    var _list = snapshot.value["attach"] as List;
//    List<Attach> _attachList;
//    if(_list != null) {
//      _attachList = _list.map((i) => Attach.fromJson(i)).toList();
//    }
    LinkedHashMap<dynamic, dynamic> _list = snapshot.value["attach"];
    List<Attach> attachList = List();
    if(_list != null){
      _list.forEach((k, v) {
        attachList.add(Attach.fromLinkedHashMap(v));
      });
    }
    attachList.sort((a, b)=>DateTime.parse(a.uploadDate).compareTo(DateTime.parse(b.uploadDate)));
    return Post(
      key: snapshot.key,
        body : snapshot.value["body"],
        uploaderUID : snapshot.value["uploaderUID"],
        attach : attachList,
        like : snapshot.value["like"],
        comment : snapshot.value["comment"],
        uploadDate : snapshot.value["uploadDate"],
    );
  }

  toMap() {
    LinkedHashMap<dynamic, dynamic> attaches = LinkedHashMap();
    if(attach!=null){
      for(int i = 0;i<attach.length;i++){
        attaches.putIfAbsent(attach[i].key, () => attach[i].toMap());
      }
    }

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

  Attach({this.key, this.fileName, this.filePath, this.description,
    this.uploaderUID, this.tempPhoto, this.uploadDate,});

  Attach.fromLinkedHashMap(LinkedHashMap linkedHashMap)
    :key = linkedHashMap["key"],
      id = linkedHashMap["id"],
      fileName = linkedHashMap["fileName"],
      filePath = linkedHashMap["filePath"],
      description = linkedHashMap["description"],
      uploadDate = linkedHashMap["uploadDate"],
      uploaderUID = linkedHashMap["uploaderUID"];

  factory Attach.fromJson(dynamic parsedJson) {
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