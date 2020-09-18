import 'dart:collection';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:Artigo/fnc/user.dart';
import 'package:Artigo/fnc/postDB.dart';
import 'package:Artigo/fnc/emotion.dart';
import 'package:Artigo/page/profile/userCard.dart';
import 'package:Artigo/page/basicDialogs.dart';
import 'package:Artigo/page/emotion/emotionInput.dart';
import 'package:Artigo/page/post/postCard.dart';
import 'package:Artigo/page/post/editPost.dart';
import 'package:Artigo/page/comment/commentList.dart';
import 'package:Artigo/page/emotion/emotionList.dart';
import 'package:Artigo/page/profile/userProfile.dart';

class SearchPage extends StatefulWidget {
  final VoidCallback navigateToMyProfile;

  SearchPage({this.navigateToMyProfile});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  PostDBFNC postDBFNC = PostDBFNC();
  UserDBFNC userDBFNC = UserDBFNC();
  BasicDialogs basicDialogs = BasicDialogs();

  List<Post> posts = List();
  List<UserAdditionalInfo> users = List();
  List<Widget> frontWidgets = List();

  User currentUser;
  UserAdditionalInfo user;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = userDBFNC.getUser();
    userDBFNC.getUserInfo(currentUser.uid).then((userInfo){
      if(this.mounted) {
        setState(() {
          user = userInfo;
        });
      }
    });
    postDBFNC.postDBRef.once().then((snapshot) {
      LinkedHashMap<dynamic, dynamic>linkedHashMap = snapshot.value;
      linkedHashMap.forEach((key, value) async {
        Post post = Post().fromLinkedHashMap(value, key);
        UserAdditionalInfo data = await userDBFNC.getUserInfo(post.uploaderUID);
        post.uploader = data;
        posts.add(post);
        setState(() {
          posts.sort((a, b){
            DateTime dateA = DateTime.parse(a.uploadDate);
            DateTime dateB = DateTime.parse(b.uploadDate);
            return dateB.compareTo(dateA);
          });
        });
      });
    });
    userDBFNC.userDBRef.once().then((snapshot) {
      LinkedHashMap<dynamic, dynamic>linkedHashMap = snapshot.value;
      linkedHashMap.forEach((key, value) async {
        UserAdditionalInfo user = UserAdditionalInfo().fromLinkedHashMap(value, key); //
        users.add(user);
      });
    });
  }

  searchPost(String keyword, Size screenSize) {
    if(posts.length != 0 && users.length != 0) {
      setState(() {
        // 유저 검색
        users.forEach((e) {
          if(e.userName == keyword) {
            frontWidgets.add(
              UserCard(
                navigateToMyProfile: widget.navigateToMyProfile,
                onTap: (){
                  Navigator.popUntil(context, ModalRoute.withName('/home'));
                  showModalBottomSheet(
                    backgroundColor: Colors.grey[300],
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return Container(
                        height: screenSize.height-50,
                        child: UserProfilePage(targetUserUid: e.key, navigateToMyProfile: widget.navigateToMyProfile,),
                      );
                    },
                  );
                },
                userInfo: e,
                screenSize: screenSize,
                currentUser:  currentUser,
              ).userCard(context),
            );
          }
        });
        // 게시글 검색
        posts.forEach((e) {
          if(e.body.contains(keyword)) {
            frontWidgets.add(
                PostCard(
                  moreOption: (){
                    if(currentUser.uid == e.uploaderUID || user.role == "ADMIN")
                      postModalBottomSheet(context, e);
                  },
                  dislikeToPost: (){
                    DatabaseReference likeDBRef = FirebaseDatabase.instance.reference().child("Posts").child(e.key);
                    EmotionDBFNC(emotionDBRef: likeDBRef).dislike(currentUser.uid);
                  },
                  likeToPost: () {
                    DatabaseReference likeDBRef = FirebaseDatabase.instance.reference().child("Posts").child(e.key);
                    EmotionInput(likeDBRef, currentUser.uid, e.uploaderUID, (){}).showEmotionPicker(context);
                  },
                  showCommentSheet: () {
                    showModalBottomSheet(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return CommentList(
                          getPost: () async {
                            Post data = await postDBFNC.getPost(e.key);
                            setState(() {
                              e = data;
                            });
                          },
                          navigateToMyProfile: widget.navigateToMyProfile,
                          postKey: e.key,
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
                          postKey: e.key,
                          currentUser: currentUser,
                          navigateToMyProfile: widget.navigateToMyProfile,
                        );
                      },
                    );
                  },
                  item: e,
                  uploader: e.uploader,
                  screenSize: screenSize,
                  currentUser: currentUser
                ).postCard(context),
            );
          }
        });
      });
    } else {
      // 다시 시도해주세요! OR 게시글이 없습니다
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
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        backgroundColor: Colors.white,
        title: TextField(
          controller: textController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: '궁금한 것을 검색해보세요',
            contentPadding: EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).accentColor),
              borderRadius: BorderRadius.circular(25.7),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25.7),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(25.7),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(25.7),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.black87,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: (){
              String keyword = textController.value.text;
              if(keyword.length != 0) {
                //검색 진행
                searchPost(keyword, screenSize);
              } else {
                // 인증실패 신호 보내기
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: frontWidgets.length,
        padding: EdgeInsets.only(top: 3),
        itemBuilder: (context, index){
          return frontWidgets[index];
        },
      ),
    );
  }
}