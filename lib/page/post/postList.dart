import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nextor/fnc/user.dart';
import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/emotion.dart';
import 'package:nextor/page/basicDialogs.dart';
import 'package:nextor/page/emotion/emotionInput.dart';
import 'package:nextor/page/post/postCard.dart';
import 'package:nextor/page/post/editPost.dart';
import 'package:nextor/page/comment/commentList.dart';
import 'package:nextor/page/emotion/emotionList.dart';

class PostList extends StatefulWidget {
  final GlobalKey<ScaffoldState> homeScaffoldKey;
  final VoidCallback navigateToMyProfile;
  final ScrollController scrollController;
  PostList({this.navigateToMyProfile,this.scrollController, this.homeScaffoldKey});

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> with AutomaticKeepAliveClientMixin {
  BasicDialogs basicDialogs = BasicDialogs();

  //리스트 로딩 관련 변수
  ScrollController scrollController = ScrollController();
  bool isChanged = false;
  int present = 0;
  int perPage = 10;
  PostDBFNC postDBFNC = PostDBFNC();
  List<Post> backPosts = List();
  List<Post> frontPosts = List();
  Query postQuery;

  // 현재 유저 정보
  UserDBFNC authDBFNC = UserDBFNC();
  FirebaseUser currentUser;
  User user;

  @override
  final bool wantKeepAlive = true;

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
      postDBFNC.postDBRef.once().then((snapshot) {
        LinkedHashMap<dynamic, dynamic>linkedHashMap = snapshot.value;
        linkedHashMap.forEach((key, value) {
          Post post = Post().fromLinkedHashMap(value, key);
          authDBFNC.getUserInfo(post.uploaderUID).then((data) {
            post.uploader = data;
            backPosts.add(post);
            setState(() {
              backPosts.sort((a, b){
                DateTime dateA = DateTime.parse(a.uploadDate);
                DateTime dateB = DateTime.parse(b.uploadDate);
                return dateB.compareTo(dateA);
              });
            });
          });
        });
        //상황 : 초기 로딩 끝나고 게시글 10개만 프론트 포스트 안에 넣어주는 작업임
        // 근데 안됨, 왜지?????????????????????????????????
        setState(() { //TODO 얘 왜 안됨?
          frontPosts.clear();
          frontPosts.insertAll(0, backPosts.getRange(present, perPage));
        });
        present += perPage;
        postQuery = postDBFNC.postDBRef;
        postQuery.onChildAdded.listen(_onEntryAdded);
        postQuery.onChildChanged.listen(_onEntryChanged);
        postQuery.onChildRemoved.listen(_onEntryRemoved);
      });
    }
  }

  _onEntryAdded(Event event) {
    if(this.mounted){
      bool flag = true;
      Post _post = Post().fromSnapShot(event.snapshot);
      authDBFNC.getUserInfo(_post.uploaderUID).then((userInfo) {
            _post.uploader = userInfo;
            backPosts.forEach((element) {
              if(element.key == _post.key) { // contain 확인
                flag = false;
              }
            });
            if(flag) { // 쿼리에서 감지한 post 가 backPost 에 존재하는 post 라면 추가하지 않음
              backPosts.add(_post);
              setState(() {
                backPosts.sort((a, b){
                  DateTime dateA = DateTime.parse(a.uploadDate);
                  DateTime dateB = DateTime.parse(b.uploadDate);
                  return dateB.compareTo(dateA);
                });
              });
            }
          });
    }
  }

  _onEntryChanged(Event event) {
    if(this.mounted){
      isChanged = true;
      Post _post = Post().fromSnapShot(event.snapshot);
      authDBFNC.getUserInfo(_post.uploaderUID).then(
              (userInfo) {
            _post.uploader = userInfo;
            setState(() {
              var oldEntry = backPosts.singleWhere((entry) {
                return entry.key == _post.key;
              });
              backPosts[backPosts.indexOf(oldEntry)] = _post;
            });
          }
      );
    }
  }

  _onEntryRemoved(Event event) {
    if(this.mounted){
      isChanged = true;
      setState(() {
        backPosts.removeWhere((posts) =>
        posts.key == Post()
            .fromSnapShot(event.snapshot)
            .key);
      });
    }
  }

  Future<Null> _handleRefresh() async {
    setState(() {
      isChanged = false;
      present = 0;// present reset
      frontPosts.clear();
      frontPosts.insertAll(0, backPosts.getRange(present, perPage));
    });
    return null;
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
                    }
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("게시글삭제"),
                  subtitle: Text("다시 되돌릴 수 없습니다!"),
                  onTap: () {
                    Navigator.pop(context);
                    basicDialogs.dialogWithFunction(
                        context, "게시글 삭제", "게시글을 삭제하시겠습니까?", () {
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
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        //controller: scrollController,
        padding: EdgeInsets.only(top: 6),
        itemCount: frontPosts.length,
        itemBuilder: (BuildContext context, int index) {
          Post post = frontPosts[index];
          return PostCard(
            screenSize: screenSize,
            item: post,
            navigateToMyProfile: this.widget.navigateToMyProfile,
            uploader: frontPosts[index].uploader,
            currentUser: currentUser,
            moreOption: (){
              if(currentUser.uid == post.uploaderUID || user.role == "ADMIN")
                postModalBottomSheet(context, post);
            },
            dislikeToPost: (){
              DatabaseReference likeDBRef = FirebaseDatabase.instance.reference().child("Posts").child(post.key);
              EmotionDBFNC(emotionDBRef: likeDBRef).dislike(currentUser.uid);
            },
            likeToPost: () {
              DatabaseReference likeDBRef = FirebaseDatabase.instance.reference().child("Posts").child(post.key);
              EmotionInput(likeDBRef, currentUser.uid, post.uploaderUID, (){}).showEmotionPicker(context);
            },
            showCommentSheet: () {
              showModalBottomSheet(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return CommentList(
                    getPost: () async {
                      Post data = await postDBFNC.getPost(post.key);
                      setState(() {
                        post = data;
                      });
                    },
                    navigateToMyProfile: widget.navigateToMyProfile,
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
                  return EmotionList(
                    postKey: post.key,
                    currentUser: currentUser,
                    navigateToMyProfile: widget.navigateToMyProfile,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
