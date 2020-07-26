import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/user.dart';
import 'package:nextor/fnc/dateTimeParser.dart';
import 'package:nextor/fnc/emotion.dart';
import 'package:nextor/page/post/postDetail.dart';
import 'package:nextor/page/profile/userProfile.dart';
import 'package:nextor/page/emotion/emotionBoard.dart';

class PostCard extends StatelessWidget {
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
      : assert(item != null),
        super(key: key);

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

  List<StaggeredTile> tileForm(int imageCount) {
    switch(imageCount){
      case 1:
        return [
          StaggeredTile.count(3, 2),
        ];
        break;
      case 2:
        return [
          StaggeredTile.count(3, 1),
          StaggeredTile.count(3, 1),
        ];
        break;
      case 3:
        return [
          StaggeredTile.count(2, 2),
          StaggeredTile.count(1, 1),
          StaggeredTile.count(1, 1),
        ];
        break;
      default:
        if(imageCount >= 3) {
          return [
            StaggeredTile.count(2, 2),
            StaggeredTile.count(1, 1),
            StaggeredTile.count(1, 1),
          ];
        } else {
          return [
            StaggeredTile.count(3, 2),
          ];
        }
        break;

    }
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


  @override
  Widget build(BuildContext context) {
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
                    contentPadding: EdgeInsets.only(top: 3.0, left: 10, right: 15),
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
                            uploader != null ?
                            uploader.profileImageURL != null ?
                            ClipRRect( // User 정보가 있고, ProfileImage 가 존재할 때
                              borderRadius: BorderRadius.circular(80),
                              child: GestureDetector(
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  child: CachedNetworkImage(
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
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
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
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                                  onTap:(){},
                                ),
                              ),
                              Text(DateTimeParser().defaultParse(date),
                                style: TextStyle(color: Colors.grey[600]),
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
                      child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(child: Text(item.body, maxLines: 7,
                                  style: TextStyle(fontSize: item.body.length>=250?14:18),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,),)
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
                    alignment: Alignment.center,
                    width: screenSize.width,
                    height: screenSize.width < screenSize.height ? screenSize.height/3.0 : screenSize.width/1.5,
                    child: InkWell(
                      onTap: uploader != null ?(){
                        Navigator.push(context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: PostDetail(item: item, uploader: uploader, currentUser: currentUser,),)
                        );
                      } : (){},
                      child: Stack(
                        children: <Widget>[
                          StaggeredGridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(0),
                            crossAxisCount: 3,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                            staggeredTiles:tileForm(item.attach.length),
                            children: List<Widget>.generate(item.attach.length, (index){
                              return Container(
                                child: CachedNetworkImage(
                                  imageUrl: item.attach[index].filePath,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder: (context, url, downloadProgress){
                                    return Container(
                                      color: Colors.grey,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.white,
                                          value: downloadProgress.progress,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ),
                          item.attach.length > 3 ?
                          StaggeredGridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(0),
                            crossAxisCount: 3,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                            staggeredTiles:tileForm(item.attach.length),
                            children: <Widget>[
                              Container(),
                              Container(),
                              Container(
                                color: Colors.black.withOpacity(0.6),
                                child: Center(
                                  child: Text("+${item.attach.length -3}",
                                    style: TextStyle(color: Colors.white, fontSize: 24),),
                                ),
                              ),
                            ],
                          ) : null,
                        ].where(notNull).toList(),
                      ),
                    ),
                  ) : null,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      item.emotion != null ? Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                        height: 30,
                        width: 150,
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
                        height: 30,
                        width: 50,
                        child: InkWell(
                            child:Text("댓글 ${item.comment.length}개",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            onTap:showCommentSheet
                        ),
                      ) : null,
                    ].where(notNull).toList(),
                  ),
                  SizedBox(
                    height: 20,
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
                ].where(notNull).toList(),
              )
          ),
      ),
    );
  }
}
