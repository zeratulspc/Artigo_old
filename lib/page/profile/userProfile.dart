import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:nextor/fnc/user.dart';
import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/like.dart';
import 'package:nextor/page/basicDialogs.dart';
import 'package:nextor/page/post/postCard.dart';
import 'package:nextor/page/post/editPost.dart';
import 'package:nextor/page/comment/commentList.dart';
import 'package:nextor/page/like/likeList.dart';
import 'package:nextor/page/settings/editProfile.dart';
import 'package:nextor/page/profile/profileImageViewer.dart';
import 'package:nextor/page/profile/followList.dart';

class UserProfilePage extends StatefulWidget { // 내 프로필 페이지
  final String targetUserUid;
  final VoidCallback navigateToMyProfile;
  UserProfilePage({this.targetUserUid, this.navigateToMyProfile});
  @override
  _UserProfilePageState createState() => _UserProfilePageState(targetUserUid: targetUserUid);
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserDBFNC userDBFNC = UserDBFNC();
  FirebaseUser currentUser;
  User userInfo = User();
  String targetUserUid;


  _UserProfilePageState({this.targetUserUid});

  //리스트 로딩 관련 변수
  PostDBFNC postDBFNC = PostDBFNC();
  List<Post> myPosts = List();
  Query postQuery;

  BasicDialogs basicDialogs = BasicDialogs();

  @override
  void initState() {
    super.initState();
    postQuery = postDBFNC.postDBRef;
    userDBFNC.getUser().then((data) {
          currentUser = data;
          if(targetUserUid == null)
            targetUserUid = currentUser.uid;
          userDBFNC.getUserInfo(targetUserUid).then((data) {
            if(this.mounted) {
              postQuery.onChildAdded.listen(_onEntryAdded);
              postQuery.onChildChanged.listen(_onEntryChanged);
              postQuery.onChildRemoved.listen(_onEntryRemoved);
              setState(() {
                userInfo = data;
              });
            }
          }
          );
    });
  }

  _onEntryAdded(Event event) {
    if(this.mounted){
      Post _post = Post().fromSnapShot(event.snapshot);
      if(_post.uploaderUID == targetUserUid) {
        userDBFNC.getUserInfo(_post.uploaderUID).then(
                (userInfo) {
              _post.uploader = userInfo;
              myPosts.insert(0 , _post);
              setState(() {
                myPosts.sort((a, b){
                  DateTime dateA = DateTime.parse(a.uploadDate);
                  DateTime dateB = DateTime.parse(b.uploadDate);
                  return dateB.compareTo(dateA);
                });

              });
            });
      }
    }
  }

  _onEntryChanged(Event event) {
    if(this.mounted){
      Post _post = Post().fromSnapShot(event.snapshot);
      userDBFNC.getUserInfo(_post.uploaderUID).then(
              (userInfo) {
            _post.uploader = userInfo;
            setState(() {
              var oldEntry = myPosts.singleWhere((entry) {
                return entry.key == _post.key;
              });
              myPosts[myPosts.indexOf(oldEntry)] = _post;
            });
          }
      );
    }
  }

  _onEntryRemoved(Event event) {
    if(this.mounted){
      setState(() {
        myPosts.removeWhere((posts) =>
        posts.key == Post()
            .fromSnapShot(event.snapshot)
            .key);
      });
    }
  }

  Widget lowerButtons(Size screenSize) {
    if(currentUser == null) {
      return Container( // 로딩중

      );
    } else {
      if(targetUserUid == currentUser.uid) {
        return Container(
          child: RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Theme.of(context).accentColor)
            ),
            color: Colors.white,
            elevation: 0,
            child: Text(
              "프로필 수정",
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
            ),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => EditProfilePage(
                  callback: () {
                    userDBFNC.getUserInfo(currentUser.uid).then((data) {
                      setState(() {
                        userInfo = data;
                      });
                    });
                  },
                ),
              ));
            },
          ),
          margin: EdgeInsets.only(bottom: 30),
          height: 35,
          width: screenSize.width/2,
        );
      } else {
        bool isFollowed = false;
        if(userInfo.follower != null) {
          userInfo.follower.forEach((element) {
            if(element.followerUid == currentUser.uid)
              isFollowed = true;
          });
        }
        if(!isFollowed) {
          return Container( // 팔로우 안했을 때
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
              ),
              color: Theme.of(context).primaryColor,
              elevation: 0,
              child: Text(
                "팔로우",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: (){
                userDBFNC.followUser(currentUser.uid, targetUserUid);
                userDBFNC.getUserInfo(targetUserUid).then((data) {
                    setState(() {
                      userInfo = data;
                    });
                });
              },
            ),
          );
        } else {
          return Container( // 팔로우 안했을 때
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Theme.of(context).accentColor)
              ),
              color: Colors.white,
              elevation: 0,
              child: Text(
                "언팔로우",
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
              ),
              onPressed: (){
                userDBFNC.unFollowUser(currentUser.uid, targetUserUid);
                userDBFNC.getUserInfo(targetUserUid).then((data) {
                  setState(() {
                    userInfo = data;
                  });
                });
              },
            ),
          );
        }
      }
    }
  }

  Widget profileCard(Size screenSize,double profileImgWidth, double profileImgHeight, double profileImgCircular,) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Center(
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(profileImgCircular),
                      child: Container(
                        height: profileImgHeight,
                        width: profileImgWidth,
                        color: Colors.grey[400],
                      )
                  ),
                  userInfo != null ?
                  userInfo.profileImageURL != null ?
                  ClipRRect( // User 정보가 있고, ProfileImage 가 존재할 때
                    borderRadius: BorderRadius.circular(profileImgCircular),
                    child: GestureDetector(
                      child: Container(
                        height: profileImgHeight,
                        width: profileImgWidth,
                        child: CachedNetworkImage(
                          imageUrl: userInfo.profileImageURL, //TODO 사진 자세히보기
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GalleryPhotoViewWrapper(
                            userInfo: userInfo,
                            currentUser: currentUser,
                            backgroundDecoration: BoxDecoration(
                              color: Colors.black,
                            ),
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                      ),
                    ),
                  ) :
                  ClipRRect(// User 정보가 있고, ProfileImage 가 존재하지 않을 때
                      borderRadius: BorderRadius.circular(profileImgCircular),
                      child: Container(
                        height: profileImgHeight,
                        width: profileImgWidth,
                        color: Colors.grey[400],
                      )
                  ) :
                  ClipRRect(// User 정보가 없을 때
                      borderRadius: BorderRadius.circular(profileImgCircular),
                      child: Container(
                        height: profileImgHeight,
                        width: profileImgWidth,
                        color: Colors.grey[400],
                      )
                  )
                ],
              ),
            ),
            margin: EdgeInsets.only(top: 50,),
            height: screenSize.width/3.2,
            width: screenSize.width/3.2,
          ),
          Container(
            child: Center(
              child: Text(
                userInfo.userName??"불러오는 중",
                maxLines: 1,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
              ),
            ),
            height: 50, // 길이는 Expand 위젯 사용
            width: screenSize.width/1.8,
          ),
          Container(
            child: Center(
              child: Text(
                userInfo.description??"불러오는 중",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            margin: EdgeInsets.only(bottom: 10),
            width: screenSize.width/1.5,
          ),
          Container(
            width: screenSize.width - 80,
            child: Divider(thickness: 1,),
          ),
          Container(
            width: screenSize.width/1.5,
            margin: EdgeInsets.only(top: 5,bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          "${myPosts.length}",
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      Container(
                        child: Text(
                          "게시글",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: InkWell(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            "${userInfo.follower != null ?
                            userInfo.follower.length : 0}",
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        Container(
                          child: Text(
                            "팔로워",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => FollowListPage(listCase: 0, targetUserInfo: userInfo,)
                      ));
                    },
                  ),
                ),
                Container(
                  child: InkWell(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            "${userInfo.following != null ?
                            userInfo.following.length : 0}",
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        Container(
                          child: Text(
                            "팔로잉",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => FollowListPage(listCase: 1, targetUserInfo: userInfo,)
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
          lowerButtons(screenSize),
        ],
      ),
    );
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
                          EditPost(postCase: 2, initialPost: post, uploader: userInfo, currentUser: currentUser,))
                      );
                    }
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
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait; // 세로모드 확인
    Size screenSize = MediaQuery.of(context).size;
    double profileImgWidth;
    double profileImgHeight;
    double profileImgCircular;
    if(isPortrait){
      profileImgWidth = screenSize.width/3.2;
      profileImgHeight = screenSize.width/3.2;
      profileImgCircular = 80;
    } else {
      profileImgWidth = screenSize.width/3.2;
      profileImgHeight = screenSize.width/3.2;
      profileImgCircular = 120;
    }
    return ListView.builder(
      padding: EdgeInsets.only(top: 3),
      itemCount: myPosts.length+2,
      itemBuilder: (context, index) {
        if(index == 0) {
          return profileCard(screenSize, profileImgWidth, profileImgHeight, profileImgCircular);
        } else if(index == 1) {
          if(currentUser == null) {
            return Container(
              color: Colors.white,
              width: screenSize.width,
              margin: EdgeInsets.only(bottom: 2),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 15, top: 6, bottom: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            if(targetUserUid == currentUser.uid) {
              return Container(
                color: Colors.white,
                width: screenSize.width,
                margin: EdgeInsets.only(bottom: 2),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 15, top: 6, bottom: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "내가 쓴 게시글",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                color: Colors.white,
                width: screenSize.width,
                margin: EdgeInsets.only(bottom: 2),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 10, top: 6, bottom: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${userInfo.userName}님이 쓴 게시글",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        } else {
          Post post = myPosts[index-2];
          return PostCard(
            screenSize: screenSize,
            item: post,
            uploader: post.uploader,
            currentUser: currentUser,
            moreOption: (){
              if(post.uploaderUID == currentUser.uid)
                postModalBottomSheet(context, post);
            },
            dislikeToPost: (){
              DatabaseReference likeDBRef = FirebaseDatabase.instance.reference().child("Posts").child(post.key);
              LikeDBFNC(likeDBRef: likeDBRef).dislike(currentUser.uid);
            },
            likeToPost: (){
              DatabaseReference likeDBRef = FirebaseDatabase.instance.reference().child("Posts").child(post.key);
              LikeDBFNC(likeDBRef: likeDBRef).like(currentUser.uid, post.uploaderUID);
            },
            showCommentSheet: () {
              showModalBottomSheet(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return CommentList(
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
                  return LikeList(
                    postKey: post.key,
                    currentUser: currentUser,
                    navigateToMyProfile: widget.navigateToMyProfile,
                  );
                },
              );
            },
          );
        }

      },
    );
  }
}
