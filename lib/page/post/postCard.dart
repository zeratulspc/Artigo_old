import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Artigo/fnc/postDB.dart';
import 'package:Artigo/fnc/user.dart';
import 'package:Artigo/fnc/dateTimeParser.dart';
import 'package:Artigo/fnc/emotion.dart';
import 'package:Artigo/page/post/postDetail.dart';
import 'package:Artigo/page/profile/userProfile.dart';
import 'package:Artigo/page/emotion/emotionBoard.dart';

class PostCard {
  PostCard(
      {Key key,
        this.navigateToMyProfile,
        this.currentUser,
        this.uploader,
        this.moreOption,
        this.screenSize,
        this.likeToPost,
        this.dislikeToPost,
        this.showProfileSheet,
        this.showCommentSheet,
        this.showLikeSheet,
        @required this.item,})
      : assert(item != null);


  final VoidCallback navigateToMyProfile;
  final Function moreOption;
  final Function likeToPost;
  final Function dislikeToPost;
  final Function showCommentSheet;
  final Function showProfileSheet;
  final Function showLikeSheet;
  final Post item;
  final User uploader;
  final Size screenSize;
  final FirebaseUser currentUser;

  bool notNull(Object o) => o != null;

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


  Widget postCard(BuildContext context) {
    DateTime date = DateTime.parse(item.uploadDate);
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
            color: Colors.white,
            width: screenSize.width,
            child: Column(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.only(top: 3.0, left: 10),
                  title: Row(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: Container(
                                height: 40,
                                width: 40,
                                color: Colors.grey[300],
                              )
                          ),
                          uploader != null ?
                          uploader.profileImageURL != null ?
                          ClipRRect( // User 정보가 있고, ProfileImage 가 존재할 때
                            borderRadius: BorderRadius.circular(80),
                            child: GestureDetector(
                              child: Container(
                                height: 40,
                                width: 40,
                                child: CachedNetworkImage(
                                  filterQuality: FilterQuality.none,
                                  imageUrl: uploader.profileImageURL,
                                ),
                              ),
                              onTap: currentUser.uid == uploader.key ? navigateToMyProfile : (){
                                Navigator.popUntil(context, ModalRoute.withName('/home'));
                                showModalBottomSheet(
                                  backgroundColor: Colors.grey[300],
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      height: screenSize.height-50,
                                      child: UserProfilePage(targetUserUid: uploader.key, navigateToMyProfile: navigateToMyProfile,),
                                    );
                                  },
                                );
                              },
                            ),
                          ) :
                          ClipRRect(// User 정보가 있고, ProfileImage 가 존재하지 않을 때
                              borderRadius: BorderRadius.circular(80),
                              child: Container(
                                height: 40,
                                width: 40,
                                color: Colors.grey[400],
                              )
                          ) :
                          ClipRRect(// User 정보가 없을 때
                              borderRadius: BorderRadius.circular(80),
                              child: Container(
                                height: 40,
                                width: 40,
                                color: Colors.grey[400],
                              )
                          )
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            uploader != null ?
                            Container( // 업로더 정보가 있을 때
                              width: screenSize.width / 1.7,
                              child: InkWell(
                                child: Text(uploader.userName??"", maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                                onTap: currentUser.uid == uploader.key ? navigateToMyProfile : (){
                                  Navigator.popUntil(context, ModalRoute.withName('/home'));
                                  showModalBottomSheet(
                                    backgroundColor: Colors.grey[300],
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        height: screenSize.height-50,
                                        child: UserProfilePage(targetUserUid: uploader.key, navigateToMyProfile: navigateToMyProfile,),
                                      );
                                    },
                                  );
                                },
                              ),
                            ) :
                            Container( // 업로더 정보가 없을 때
                              width: screenSize.width / 1.7,
                              child: InkWell(
                                child: Text("", maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                                onTap:(){},
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
                    onPressed: moreOption,
                  ),
                ),
                Container(
                  child: InkWell(
                    child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(item.body, maxLines: 7,
                                  style: TextStyle(fontSize: item.body.length>=250?14:18),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: uploader != null ? (){
                      Navigator.push(context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: PostDetail(item: item, uploader: uploader, currentUser: currentUser, navigateToMyProfile: navigateToMyProfile,),)
                      );
                    } : (){},
                  ),
                ),
                item.attach != null? Container(
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  width: screenSize.width,
                  child: InkWell(
                    onTap: uploader != null ?(){
                      Navigator.push(context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: PostDetail(item: item, uploader: uploader, currentUser: currentUser,),)
                      );
                    } : (){},
                    child: CarouselSlider.builder(
                      options: CarouselOptions(
                        initialPage: 0,
                        aspectRatio: 1/1,
                        viewportFraction: 1,
                        enableInfiniteScroll: false,
                        disableCenter: true,
                      ),
                      itemCount: item.attach.length,
                      itemBuilder: (context, index) {
                        return Container(
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Container(
                                color: Colors.grey[200],
                                child: CachedNetworkImage(
                                  filterQuality: FilterQuality.none,
                                  imageUrl: item.attach[index].filePath,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder: (context, url, downloadProgress) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.grey[200],
                                          value: downloadProgress.progress,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              item.attach.length > 1 ? Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(30)
                                  ),
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  child: Text("${index+1}/${item.attach.length}", style: TextStyle(color: Colors.white),),
                                ),
                              ) : null,
                            ].where(notNull).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ) : null,
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
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
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                        child: InkWell(
                            child:Text("댓글 ${item.comment.length}개",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            onTap:showCommentSheet
                        ),
                      ) : null,
                    ].where(notNull).toList(),
                  ),
                ),
                SizedBox(
                  height: 5,
                  width: screenSize.width -20,
                  child: Divider(thickness: 1,),
                ),
                EmotionBoard(
                  navigateToMyProfile: navigateToMyProfile,
                  currentUser: currentUser,
                  emotion: item.emotion,
                  comment: item.comment,
                  postKey: item.key,
                  likeToPost: likeToPost,
                  dislikeToPost: dislikeToPost,
                ),
                //TODO 댓글 목록 보여주는거 만들기
              ].where(notNull).toList(),
            )
        ),
      ),
    );
  }
}