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
  Query postQuery;

  @override
  void initState() {
    super.initState();
    if(this.mounted) {
      postQuery = postDBFNC.postDBRef.orderByKey();
      postQuery.onChildAdded.listen(_onPostAdded);
      postQuery.onChildChanged.listen(_onPostChanged);
      postQuery.onChildRemoved.listen(_onPostRemoved);
    }
  }

  _onPostAdded(Event event) {
      setState(() {
        posts.insert(0 , Post.fromSnapShot(event.snapshot));
      });
  }

  _onPostChanged(Event event) {
      print("Entry Cahnged : " + event.snapshot.key);
      setState(() {
        var oldEntry = posts.singleWhere((entry) {
          return entry.key == event.snapshot.key;
        });
        posts[posts.indexOf(oldEntry)] =
            Post.fromSnapShot(event.snapshot);
      });
  }

  _onPostRemoved(Event event) {
      print("Post Removed! : " + event.snapshot.key);
      setState(() {
        posts.removeWhere((posts) =>
        posts.key == Post
            .fromSnapShot(event.snapshot)
            .key);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: posts.length == 0 ?
            Center(
              child: Text("게시글이 없습니다."),
            ) :
        AnimatedList( //TODO 에니메이션 리스트, 스켈레톤 로딩 구현
          key: postListAnimationKey,
          initialItemCount: posts.length,
          itemBuilder: (context, index, animation) {
            return CardItem(
              animation: animation,
              item: posts[index],
              onTap: () {
                setState(() {
                });
              },
            );
          },
        ),
      ),
    );
  }
}
