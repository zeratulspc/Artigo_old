import 'dart:core';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Artigo/fnc/user.dart';
import 'package:Artigo/fnc/postDB.dart';
import 'package:Artigo/fnc/emotion.dart';
import 'package:Artigo/page/basicDialogs.dart';
import 'package:Artigo/page/emotion/emotionInput.dart';
import 'package:Artigo/page/post/postCard.dart';
import 'package:Artigo/page/post/editPost.dart';
import 'package:Artigo/page/comment/commentList.dart';
import 'package:Artigo/page/emotion/emotionList.dart';

class PostList extends StatefulWidget {
  final VoidCallback navigateToMyProfile;
  PostList({
    Key key ,
    this.navigateToMyProfile,
  }) : super(key: key);

  @override
  PostListState createState() => PostListState();
}

class PostListState extends State<PostList> with AutomaticKeepAliveClientMixin {
  BasicDialogs basicDialogs = BasicDialogs();

  //리스트 로딩 관련 변수
  bool isPageOpened = true;
  bool allLoaded = false;
  int present = 0;
  final int perPage = 5;
  PostDBFNC postDBFNC = PostDBFNC();
  List<Post> backPosts = List();
  List<Post> frontPosts = List();
  Query postQuery;
  ScrollController scrollController;

  // 현재 유저 정보
  UserDBFNC userDBFNC = UserDBFNC();
  FirebaseUser currentUser;
  User user;


  @override
  final bool wantKeepAlive = true;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    if(this.mounted) {
      userDBFNC.getUser().then((_currentUser){
        if(this.mounted) {
          setState(() {
            currentUser = _currentUser;
          });
        }
        userDBFNC.getUserInfo(currentUser.uid).then((userInfo){
          if(this.mounted) {
            setState(() {
              user = userInfo;
            });
          }
        });
      });
      postDBFNC.postDBRef.once().then((snapshot) {
        LinkedHashMap<dynamic, dynamic>linkedHashMap = snapshot.value;
        linkedHashMap.forEach((key, value) async {
          Post post = Post().fromLinkedHashMap(value, key);
          User data = await userDBFNC.getUserInfo(post.uploaderUID);
          post.uploader = data;
          backPosts.add(post);
          setState(() {
            backPosts.sort((a, b){
              DateTime dateA = DateTime.parse(a.uploadDate);
              DateTime dateB = DateTime.parse(b.uploadDate);
              return dateB.compareTo(dateA);
            });
          });
          if(backPosts.length == linkedHashMap.length) {
            handleRefresh();
          }
        });
        scrollController.addListener(() {
          if(isPageOpened) {
            if(frontPosts.length >= perPage) {
              if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
                loadMore();
              }
            }
          }
        });
        postQuery = postDBFNC.postDBRef;
        postQuery.onChildAdded.listen(_onEntryAdded);
        postQuery.onChildChanged.listen(_onEntryChanged);
        postQuery.onChildRemoved.listen(_onEntryRemoved);
      });
    }
  }

  _onEntryAdded(Event event) {
    if(this.mounted){
      bool isContained = true;
      Post _post = Post().fromSnapShot(event.snapshot);
      userDBFNC.getUserInfo(_post.uploaderUID).then((userInfo) {
        _post.uploader = userInfo;
        backPosts.forEach((element) {
          if(element.key == _post.key) { // contain 확인
            isContained = false;
          }
        });
        if(isContained) { // 쿼리에서 감지한 post 가 backPost 에 존재하는 post 라면 추가하지 않음
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
      Post _post = Post().fromSnapShot(event.snapshot);
      userDBFNC.getUserInfo(_post.uploaderUID).then((userInfo) {
        _post.uploader = userInfo;
        setState(() {
          Post oldEntryBack = backPosts.singleWhere((entry) {
            return entry.key == _post.key;
          });
          backPosts[backPosts.indexOf(oldEntryBack)] = _post;
          if(frontPosts.singleWhere((e) {return e.key == _post.key;},
              orElse: (){return null;}) != null) {
            Post oldEntryFront = frontPosts.singleWhere((entry) {
              return entry.key == _post.key;
            });
            frontPosts[frontPosts.indexOf(oldEntryFront)] = _post;
          }
        });
      }
      );
    }
  }

  _onEntryRemoved(Event event) {
    if(this.mounted){
      setState(() {
        backPosts.removeWhere((posts) =>
        posts.key == event.snapshot.key);
        if(frontPosts.singleWhere((e) {return e.key == event.snapshot.key;},
            orElse: (){return null;}) != null) {
          frontPosts.removeWhere((posts) =>
          posts.key == event.snapshot.key);
        }
      });
    }
  }

  loadMore() {
    setState(() {
      try {
        if(!allLoaded) {
          present += perPage;
          frontPosts.insertAll(present, backPosts.getRange(present, present + perPage));
        }
      } catch (e) {
        allLoaded = true;
        RangeError error = e;
        frontPosts.insertAll(present, backPosts.getRange(present, error.end));
      }
    });
  }

  Future<Null> handleRefresh() async {
    setState(() {
      scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn);
      allLoaded = false;
      present = 0;// present reset
      frontPosts.clear();
      try {
        frontPosts.insertAll(0, backPosts.getRange(present, perPage));
      } catch (e) {
        RangeError error = e;
        frontPosts.insertAll(0, backPosts.getRange(present, error.end));
      }
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
    return Scaffold(
      body: RefreshIndicator(
        displacement: 5,
        onRefresh: handleRefresh,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 6),
          controller: scrollController,
          itemCount: frontPosts.length+1,
          itemBuilder: (BuildContext context, int index) {
            if(index == frontPosts.length && frontPosts.length != 0) {
              return Container(
                height: 100,
                width: screenSize.width,
              );
            }
            if(frontPosts.length != 0) {
              Post post = frontPosts[index];
              return PostCard(
                screenSize: screenSize,
                item: post,
                navigateToMyProfile: this.widget.navigateToMyProfile,
                uploader: frontPosts[index].uploader, // delete this
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
              ).postCard(context);
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}