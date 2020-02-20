import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shimmer/shimmer.dart';

import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/page/postCard.dart';
import 'package:nextor/page/postLoading.dart';

class PostList extends StatefulWidget {
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> with TickerProviderStateMixin  {
//TODO postList Design
//TODO postList FNC

  //애니메이션 리스트 관련 변수
  GlobalKey<AnimatedListState> postListAnimationKey = GlobalKey<AnimatedListState>();
  AnimationController emptyListController;

  //리스트 로딩 관련 변수
  PostDBFNC postDBFNC = PostDBFNC();
  List<Post> posts = List();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FirebaseAnimatedList(
          query: postDBFNC.postDBRef.orderByKey(),
          itemBuilder: (context, snapshot, animation, index) {
            return PostCard(
              animation: animation,
              item: Post.fromSnapShot(snapshot),
            );
          },
        )
      ),
    );
  }
}
