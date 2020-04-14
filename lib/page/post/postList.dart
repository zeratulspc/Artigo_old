import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'package:nextor/fnc/auth.dart';
import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/like.dart';
import 'package:nextor/page/basicDialogs.dart';
import 'package:nextor/page/post/postCard.dart';
import 'package:nextor/page/post/editPost.dart';
import 'package:nextor/page/post/postLoading.dart';
import 'package:nextor/page/comment/commentList.dart';
import 'package:nextor/page/like/likeList.dart';

class PostList extends StatefulWidget {
  final GlobalKey<ScaffoldState> homeScaffoldKey;
  final VoidCallback navigateToMyProfile;
  final ScrollController scrollController;
  PostList({this.navigateToMyProfile, this.scrollController, this.homeScaffoldKey});

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> with TickerProviderStateMixin  {

  BasicDialogs basicDialogs = BasicDialogs();

  //리스트 로딩 관련 변수
  PostDBFNC postDBFNC = PostDBFNC();
  LikeDBFNC likeDBFNC = LikeDBFNC();

  // 현재 유저 정보
  AuthDBFNC authDBFNC = AuthDBFNC();
  FirebaseUser currentUser;
  User user;

  @override
  void initState() {
    super.initState();
    if(this.mounted) {
      authDBFNC.getUser().then((_currentUser){
        if(this.mounted) {
          setState(() {
            currentUser = _currentUser;
          });
        }
        authDBFNC.getUserInfo(currentUser.uid).then((userInfo){
          if(this.mounted) {
            setState(() {
              user = userInfo;
            });
          }
        });
      });
    }
  }

  void postModalBottomSheet(context, Post post) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext _context){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('게시글 수정'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          EditPost(postCase: 2, initialPost: post, uploader: user, currentUser: currentUser,)));
                    } //TODO 게시글 수정
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("게시글삭제"),
                  subtitle: Text("다시 되돌릴 수 없습니다!"),
                  onTap: () {
                    Navigator.pop(context);
                    basicDialogs.dialogWithFunction(
                        context, "게시글 삭제", "게시글을 삭제하시겠습니까?",
                        () {
                          Navigator.pop(context);
                          basicDialogs.showLoading(context, "게시글을 삭제하는 중입니다.");
                          if(post.attach != null) {
                            postDBFNC.deletePostStorage(post.key, post.attach)
                                .then((_)=>postDBFNC.deletePost(post.key).then((_)=>Navigator.pop(context)));
                          } else {
                            postDBFNC.deletePost(post.key).then((_)=>Navigator.pop(context));
                          }
                        });
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: FirebaseAnimatedList(//TODO 10개씩만 로딩
          query: postDBFNC.postDBRef,
          controller: widget.scrollController,
          sort: (a , b) => DateTime.parse(b.value["uploadDate"]).compareTo(DateTime.parse(a.value["uploadDate"])), //TODO 새로운 글이 위로 오게 하기 (현재 스켈레톤 로딩이 아래로 감.)
          itemBuilder: (context, snapshot, animation, index) {
            Post post = Post().fromSnapShot(snapshot);
            return FutureBuilder(
              future: authDBFNC.getUserInfo(post.uploaderUID),
              builder: (context, asyncSnapshot){
                if(!asyncSnapshot.hasData){
                  if(post.body.length <= 30) { // 글자수가 30보다 작을 경우
                    return PostCardSkeleton(animation: animation, postSizeCase: 1,);
                  } else {
                    return PostCardSkeleton(animation: animation, postSizeCase: 2,);
                  }
                } else if(asyncSnapshot.hasError){
                  return Text("Error!"); //TODO 에러
                } else {
                  return PostCard(
                    animation: animation,
                    screenSize: screenSize,
                    item: post,
                    navigateToMyProfile: this.widget.navigateToMyProfile,
                    uploader: asyncSnapshot.data,
                    currentUser: currentUser,
                    moreOption: (){
                      if(currentUser.uid == post.uploaderUID)
                        postModalBottomSheet(context, post);
                    },
                    dislikeToPost: (){
                      likeDBFNC.dislikeToPost(post.key, currentUser.uid);
                    },
                    likeToPost: (){
                      likeDBFNC.likeToPost(post.key, currentUser.uid);
                    },
                    showCommentSheet: () {
                      showModalBottomSheet(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                        isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return CommentList(
                              postKey: post.key,
                              currentUser: currentUser,
                            );
                          },
                      );
                    },
                    showLikeSheet: () {
                      showModalBottomSheet(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return LikeList(
                            postKey: post.key,
                            currentUser: currentUser,
                          );
                        },
                      );
                    },
                  );
                }
              },
            );
          },
        )
      ),
    );
  }
}
