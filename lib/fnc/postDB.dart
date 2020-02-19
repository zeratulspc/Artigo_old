import 'package:firebase_database/firebase_database.dart';
import 'package:nextor/fnc/like.dart';

class PostDBFNC { //TODO FireStore 대신 RealTime DB 사용하기.
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
  String title;
  String body;
  String userId;
  String date;
  List<Attach> attach;
  List<Like> like;

  Post({this.key,this.title, this.body, this.userId, this.date, this.attach, this.like});

  Post.fromSnapShot(DataSnapshot snapshot)
      :key = snapshot.key,
        title = snapshot.value["title"],
        body = snapshot.value["body"],
        userId = snapshot.value["userId"],
        attach = snapshot.value["attach"],
        like = snapshot.value["like"],
        date = snapshot.value["date"];

  toMap() {
    return {
      "key" : key,
      "title" : title,
      "body" : body,
      "userId" : userId,
      "date" : date,
      "attach" : attach,
      "like" : like
    };
  }

}

class Attach {
  String id; // Md5Hash
  String fileName;
  String filePath;
  String userId;
}