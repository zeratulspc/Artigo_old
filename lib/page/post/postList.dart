import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shimmer/shimmer.dart';

import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/page/post/postCard.dart';
import 'package:nextor/page/post/postLoading.dart';

class PostList extends StatefulWidget {
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> with TickerProviderStateMixin  {
//TODO postList Design
//TODO postList FNC

  //리스트 로딩 관련 변수
  PostDBFNC postDBFNC = PostDBFNC();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("게시글"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async { //TODO 게시글 작성 페이지로 이동
              String key = await postDBFNC.createPost(Post(title: "TITLE", body: "BODY", date: DateTime.now().toIso8601String(), userUID: "userID"));
              print(key);
            },
          ),
        ],
      ),
      body: Container(
        child: FirebaseAnimatedList( //TODO 10개씩만 로딩
          query: postDBFNC.postDBRef.orderByKey(),
          itemBuilder: (context, snapshot, animation, index) {
            Post post = Post.fromSnapShot(snapshot);
            return PostCard(
              animation: animation,
              item: post,
              onTap: () {
                print("tap");
              },
              onLongPress: () { //TODO 글 작성자만 삭제 가능
                postDBFNC.deletePost(post.key);
              },
            );
          },
        )
      ),
    );
  }
}
