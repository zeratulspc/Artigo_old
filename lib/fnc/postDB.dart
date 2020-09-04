import 'dart:collection';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:Artigo/fnc/comment.dart';
import 'package:Artigo/fnc/emotion.dart';
import 'package:Artigo/fnc/user.dart';
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
  UserAdditionalInfo uploader;
  bool isEdited;

  List<Attach> attach;
  List<Emotion> emotion;
  List<Comment> comment;

  Post({this.key, this.body, this.uploaderUID, this.uploadDate, this.attach,
    this.emotion, this.comment, this.isEdited,});

  fromLinkedHashMap(LinkedHashMap linkedHashMap, String key) {
    LinkedHashMap<dynamic, dynamic> _attachList = linkedHashMap["attach"];
    List<Attach> attachList;
    if(_attachList != null) {
      attachList = List();
      _attachList.forEach((k, v) {
        attachList.add(Attach().fromLinkedHashMap(v));
      });
      attachList.sort((a, b)=>DateTime.parse(a.uploadDate).compareTo(DateTime.parse(b.uploadDate)));
    }

    LinkedHashMap<dynamic, dynamic> _emotionList = linkedHashMap["emotion"];
    List<Emotion> emotionList;
    if(_emotionList != null) {
      emotionList = List();
      _emotionList.forEach((k, v) {
        emotionList.add(Emotion.fromLinkedHashMap(v));
      });
      emotionList.sort((a, b)=>DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    }

    LinkedHashMap<dynamic, dynamic> _commentList = linkedHashMap["comment"];
    List<Comment> commentList;
    if(_commentList != null) {
      commentList = List();
      _commentList.forEach((k, v) {
        commentList.add(Comment().fromLinkedHashMap(v));
      });
      commentList.sort((a, b)=>DateTime.parse(a.uploadDate).compareTo(DateTime.parse(b.uploadDate)));
    }
    return Post(
      key: key,
      body : linkedHashMap["body"],
      uploaderUID : linkedHashMap["uploaderUID"],
      attach : attachList,
      emotion : emotionList,
      comment : commentList,
      uploadDate : linkedHashMap["uploadDate"],
    );
  }

  fromSnapShot(DataSnapshot snapshot) {
    LinkedHashMap<dynamic, dynamic> _attachList = snapshot.value["attach"];
    List<Attach> attachList;
    if(_attachList != null) {
      attachList = List();
      _attachList.forEach((k, v) {
        attachList.add(Attach().fromLinkedHashMap(v));
      });
      attachList.sort((a, b)=>DateTime.parse(a.uploadDate).compareTo(DateTime.parse(b.uploadDate)));
    }

    LinkedHashMap<dynamic, dynamic> _emotionList = snapshot.value["emotion"];
    List<Emotion> emotionList;
    if(_emotionList != null) {
      emotionList = List();
      _emotionList.forEach((k, v) {
        emotionList.add(Emotion.fromLinkedHashMap(v));
      });
      emotionList.sort((a, b)=>DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    }

    LinkedHashMap<dynamic, dynamic> _commentList = snapshot.value["comment"];
    List<Comment> commentList;
    if(_commentList != null) {
      commentList = List();
      _commentList.forEach((k, v) {
        commentList.add(Comment().fromLinkedHashMap(v));
      });
      commentList.sort((a, b)=>DateTime.parse(a.uploadDate).compareTo(DateTime.parse(b.uploadDate)));
    }
    return Post(
      key: snapshot.key,
        body : snapshot.value["body"],
        uploaderUID : snapshot.value["uploaderUID"],
        attach : attachList,
        emotion : emotionList,
        comment : commentList,
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
      "emotion" : emotion
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
  List<Emotion> emotion;
  List<Comment> comment;
  File tempPhoto;
  bool seeMore = false;

  Attach({this.key, this.fileName, this.filePath, this.description, this.id,
    this.uploaderUID, this.tempPhoto, this.uploadDate, this.emotion, this.comment});

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

    LinkedHashMap<dynamic, dynamic> _commentList = linkedHashMap["comment"];
    List<Comment> commentList;
    if(_commentList != null) {
      commentList = List();
      _commentList.forEach((k, v) {
        commentList.add(Comment().fromLinkedHashMap(v));
      });
      commentList.sort((a, b)=>DateTime.parse(a.uploadDate).compareTo(DateTime.parse(b.uploadDate)));
    }

    return Attach(
        key : linkedHashMap["key"],
        id : linkedHashMap["id"],
        fileName : linkedHashMap["fileName"],
        filePath : linkedHashMap["filePath"],
        description : linkedHashMap["description"],
        emotion : emotionList,
        comment : commentList,
        uploadDate : linkedHashMap["uploadDate"],
        uploaderUID : linkedHashMap["uploaderUID"]
    );
  }

  toMap() {
    return {
      "key" : key,
      "id" : id,
      "fileName" : fileName,
      "filePath" : filePath,
      "description" : description,
      "emotion" : emotion,
      "comment" : comment,
      "uploadDate" : uploadDate,
      "uploaderUID" : uploaderUID
    };
  }



}