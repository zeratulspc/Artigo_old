import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nextor/fnc/auth.dart';
import 'package:shimmer/shimmer.dart';

import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/page/post/postCard.dart';
import 'package:nextor/page/post/postLoading.dart';

class PostList extends StatefulWidget {
  final VoidCallback navigateToMyProfile;
  PostList({this.navigateToMyProfile});

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> with TickerProviderStateMixin  {
//TODO postList Design
//TODO postList FNC

  //리스트 로딩 관련 변수
  PostDBFNC postDBFNC = PostDBFNC();

  // 현재 유저 정보
  AuthDBFNC authDBFNC = AuthDBFNC();
  FirebaseUser currentUser;
  User user;

  @override
  void initState() {
    super.initState();
    authDBFNC.getUser().then((_currentUser){
      setState(() {
        currentUser = _currentUser;
      });
      authDBFNC.getUserInfo(currentUser.uid).then((userInfo){
        setState(() {
          user = userInfo;
        });
      });
    });
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
              String key = await postDBFNC.createPost(Post(body: "BODY", uploadDate: DateTime.now().toIso8601String(), upLoaderUID: currentUser.uid));
              print(key);
            },
          ),
        ],
      ),
      body: Container(
        child: FirebaseAnimatedList( //TODO 10개씩만 로딩, 새로운 글이 위로 오게 하기
          query: postDBFNC.postDBRef.orderByKey(),
          itemBuilder: (context, snapshot, animation, index) {
            Post post = Post.fromSnapShot(snapshot);
            return FutureBuilder(
              builder: (context, asyncSnapshot){
                if(asyncSnapshot.hasData){
                  return PostCard(
                    animation: animation,
                    item: post,
                    navigateToMyProfile: this.widget.navigateToMyProfile,
                    onTap: () {
                      print("tap");
                    },
                    onLongPress: () { //TODO 글 작성자만 삭제 가능
                      postDBFNC.deletePost(post.key);
                    },
                    upLoader: asyncSnapshot.data,
                    currentUser: currentUser,
                    seeMore: (){
                      print("See More Info!");
                    },
                  );
                } else if(asyncSnapshot.hasError){
                  return Text("Error!"); //TODO 에러
                } else {
                  if(post.body.length <= 30) { // 글자수가 30보다 작을 경우
                    return PostCardSkeleton(animation: animation, postSizeCase: 1,);
                  } else {
                    return PostCardSkeleton(animation: animation, postSizeCase: 2,);
                  }

                }
              },
              future: authDBFNC.getUserInfo(post.upLoaderUID),
            );
          },
        )
      ),
    );
  }
}
