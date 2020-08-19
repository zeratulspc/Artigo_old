import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:Artigo/fnc/user.dart';
import 'package:Artigo/fnc/postDB.dart';
import 'package:Artigo/fnc/emotion.dart';
import 'package:Artigo/fnc/dateTimeParser.dart';
import 'package:Artigo/page/emotion/emotionBoard.dart';
import 'package:Artigo/page/emotion/emotionInput.dart';
import 'package:Artigo/page/emotion/emotionList.dart';
import 'package:Artigo/page/basicDialogs.dart';
import 'package:Artigo/page/post/editPost.dart';
import 'package:Artigo/page/post/photoViewer.dart';
import 'package:Artigo/page/comment/commentList.dart';
import 'package:Artigo/page/profile/userProfile.dart';

class PostDetail extends StatefulWidget {
  final Post item;
  final User uploader;
  final FirebaseUser currentUser;
  final VoidCallback navigateToMyProfile;

  PostDetail({this.item, this.uploader, this.currentUser, this.navigateToMyProfile});

  @override
  _PostDetailState createState() => _PostDetailState(item);
}

class _PostDetailState extends State<PostDetail> {
  PostDBFNC postDBFNC = PostDBFNC();
  BasicDialogs basicDialogs = BasicDialogs();
  Post item;

  List<bool> seeMore = List();



  _PostDetailState(this.item);
  bool notNull(Object o) => o != null;
  likeToPost() {
    DatabaseReference emotionDBRef = FirebaseDatabase.instance.reference().child("Posts").child(widget.item.key);
    EmotionInput(emotionDBRef, widget.currentUser.uid, item.uploaderUID, refreshPost).showEmotionPicker(context);
    refreshPost();
  }
  dislikeToPost() {
    DatabaseReference emotionDBRef = FirebaseDatabase.instance.reference().child("Posts").child(widget.item.key);
    EmotionDBFNC(emotionDBRef: emotionDBRef).dislike(widget.currentUser.uid).then((value) => refreshPost());
  }
  likeToAttach(String key) {
    DatabaseReference emotionDBRef = FirebaseDatabase.instance.reference().child("Posts").child(widget.item.key).child("attach").child(key);
    EmotionInput(emotionDBRef, widget.currentUser.uid, item.uploaderUID,refreshPost).showEmotionPicker(context);
    refreshPost();
  }
  dislikeToAttach(String key) {
    DatabaseReference emotionDBRef = FirebaseDatabase.instance.reference().child("Posts").child(widget.item.key).child("attach").child(key);
    EmotionDBFNC(emotionDBRef: emotionDBRef).dislike(widget.currentUser.uid).then((value) => refreshPost());
  }
  refreshPost() {
    postDBFNC.getPost(widget.item.key).then((data){
      setState(() {
        item = data;
      });
    });
  }

  String emotionCount(List<Emotion> list) {
    String _emotions = "";
    int count = 0;
    list.forEach((value) {
      count++;
      if(count < 4) {
        _emotions+=value.emotionCode;
      }
    });
    if(!(count < 4)) {
      _emotions+=" 외 ${list.length - 3}개";
    }
    return _emotions;
  }


  showLikeSheet() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return EmotionList(
          postKey: item.key,
          currentUser: widget.currentUser,
          navigateToMyProfile: widget.navigateToMyProfile,
        );
      },
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
                          EditPost(
                            postCase: 2,
                            initialPost: post,
                            uploader: widget.uploader,
                            currentUser: widget.currentUser,
                          )));
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
                                .then((_)=>postDBFNC.deletePost(post.key).then((_){Navigator.pop(context);Navigator.pop(context);}));
                          } else {
                            postDBFNC.deletePost(post.key).then((_){Navigator.pop(context);Navigator.pop(context);});
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
    DateTime date = DateTime.parse(widget.item.uploadDate);
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black87),
          backgroundColor: Colors.white,
          title: Text(
            "${widget.uploader.userName}",
            style: TextStyle(color: Colors.black),),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 5),
                color: Colors.white,
                width: screenSize.width,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.only(top: 3.0, left: 10, right: 10),
                      title: Row(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(80),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    color: Colors.grey[400],
                                  )
                              ),
                              widget.uploader.profileImageURL != null ?
                              ClipRRect(
                                borderRadius: BorderRadius.circular(80),
                                child: GestureDetector(
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    child: CachedNetworkImage(
                                      imageUrl: widget.uploader.profileImageURL,
                                    ),
                                  ),
                                  onTap: widget.currentUser.uid == widget.uploader.key ?
                                  widget.navigateToMyProfile : (){
                                    showModalBottomSheet(
                                      backgroundColor: Colors.grey[300],
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          height: screenSize.height-50,
                                          child: UserProfilePage(targetUserUid: item.uploader.key, navigateToMyProfile: widget.navigateToMyProfile,),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ) : ClipRRect(
                                  borderRadius: BorderRadius.circular(80),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    color: Colors.grey[400],
                                  )
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: screenSize.width / 1.7,
                                  child: InkWell(
                                    child: Text(widget.uploader.userName??"", maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                                    onTap: widget.currentUser.uid == widget.uploader.key ?
                                    widget.navigateToMyProfile : (){
                                      showModalBottomSheet(
                                        backgroundColor: Colors.grey[300],
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            height: screenSize.height-50,
                                            child: UserProfilePage(targetUserUid: item.uploader.key, navigateToMyProfile: widget.navigateToMyProfile,),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    DateTimeParser().defaultParse(date),
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.more_horiz,),
                        onPressed: (){
                          if(widget.currentUser.uid == item.uploaderUID){
                            postModalBottomSheet(context, item);
                          }
                        },
                      ),
                    ),
                    Container(
                      child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    item.body,
                                    style: TextStyle(fontSize: item.body.length>=250?16:18),
                                    textAlign: TextAlign.left,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        item.emotion != null ? Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                          child: InkWell(
                            child: Text(emotionCount(item.emotion),
                              style: TextStyle(color: Colors.grey[700], fontSize: 14),
                            ),
                            onTap: showLikeSheet,
                          ),
                        ) : null,
                        item.comment != null ? Container(
                          margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                          child: InkWell(
                            onTap: (){
                              showModalBottomSheet(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return CommentList(
                                    navigateToMyProfile: widget.navigateToMyProfile,
                                    postKey: item.key,
                                    currentUser: widget.currentUser,
                                  );
                                },
                              );
                            },
                            child: Text("댓글 ${item.comment.length}개",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ) : null,
                      ].where(notNull).toList(),
                    ),
                    SizedBox(
                      width: screenSize.width -20,
                      child: Divider(thickness: 1,),
                    ),
                    EmotionBoard(
                      currentUser: widget.currentUser,
                      navigateToMyProfile: widget.navigateToMyProfile,
                      postKey: item.key,
                      emotion: item.emotion,
                      comment: item.comment,
                      dislikeToPost: dislikeToPost,
                      likeToPost: likeToPost,
                    ),
                  ],
                ),
              ),
              item.attach != null ? Column(
                children: List<Widget>.generate(item.attach.length, (index){
                  seeMore.add(false);
                  return Container(
                    margin: EdgeInsets.only(top: 5),
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GalleryPhotoViewWrapper(
                                  navigateToMyProfile: widget.navigateToMyProfile,
                                  uploader: widget.uploader,
                                  currentUser: widget.currentUser,
                                  galleryItems: item.attach,
                                  postKey: widget.item.key,
                                  backgroundDecoration: BoxDecoration(
                                    color: Colors.black,
                                  ),
                                  initialIndex: index,
                                  scrollDirection: Axis.horizontal,
                                  getPost: (){
                                    refreshPost();
                                  },
                                ),
                              ),
                            ),
                            child: Hero(
                                tag: item.attach[index].fileName,
                                child: CachedNetworkImage(
                                    imageUrl: item.attach[index].filePath,
                                    progressIndicatorBuilder: (context, url, downloadProgress) {
                                      return Container(
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                            value: downloadProgress.progress,
                                          ),
                                        ),
                                      );
                                    }
                                )
                            ),
                          ),
                        ),
                        item.attach[index].description != null ?
                        Container(
                          child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: seeMore[index] ? item.attach[index].description :
                                                item.attach[index].description.length >= 250 ?
                                                item.attach[index].description.substring(0, 250) :
                                                item.attach[index].description,
                                                style: TextStyle(color: Colors.black87),
                                              ),
                                              item.attach[index].description.length >= 250 && !seeMore[index]?
                                              TextSpan(
                                                text: "...",
                                                style: TextStyle(color: Colors.black87),
                                              ) : null,
                                              item.attach[index].description.length >= 250 ?
                                              TextSpan(
                                                  text: seeMore[index] ? " 줄이기" : " 더보기",
                                                  style: TextStyle(color: Colors.grey[600],),
                                                  recognizer: TapGestureRecognizer()..onTap = (){
                                                    setState(() {
                                                      setState(() {
                                                        seeMore[index] = !seeMore[index];
                                                      });
                                                    });
                                                  }
                                              ) : null,
                                            ].where(notNull).toList()
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ) : null,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            item.attach[index].emotion != null ? Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                              child: InkWell(
                                onTap:() {
                                  showModalBottomSheet(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return EmotionList(
                                        postKey: item.key,
                                        currentUser: widget.currentUser,
                                        attachKey: item.attach[index].key,
                                        navigateToMyProfile: widget.navigateToMyProfile,
                                      );
                                    },
                                  );
                                },
                                child: Text(emotionCount(item.attach[index].emotion),
                                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                ),
                              ),
                            ) : null,
                            item.attach[index].comment != null ? Container(
                              margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                              child: InkWell(
                                onTap: (){
                                  showModalBottomSheet(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return CommentList(
                                        getPost: () => refreshPost(),
                                        postKey: item.key,
                                        currentUser: widget.currentUser,
                                        attachKey: item.attach[index].key,
                                        navigateToMyProfile: widget.navigateToMyProfile,
                                      );
                                    },
                                  );
                                },
                                child: Text("댓글 ${item.attach[index].comment.length}개",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ) : null,
                          ].where(notNull).toList(),
                        ),
                        SizedBox(
                          width: screenSize.width -20,
                          child: Divider(thickness: 1,),
                        ),
                        EmotionBoard(
                          currentUser: widget.currentUser,
                          postKey: item.key,
                          attachKey: item.attach[index].key,
                          likeToPost: (){likeToAttach(item.attach[index].key);},
                          dislikeToPost: (){dislikeToAttach(item.attach[index].key);},
                          navigateToMyProfile: widget.navigateToMyProfile,
                          emotion: item.attach[index].emotion,
                          comment: item.attach[index].comment,
                        ),
                      ].where(notNull).toList(),
                    ),
                  );
                }),
              ) : null,
            ].where(notNull).toList(),
          ),
        )
    );
  }
}