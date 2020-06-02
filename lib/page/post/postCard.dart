import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/auth.dart';
import 'package:nextor/page/post/postDetail.dart';


class PostCard extends StatelessWidget {
  PostCard(
      {Key key,
        @required this.animation,
        this.navigateToMyProfile,
        this.currentUser,
        this.uploader,
        this.moreOption,
        this.screenSize,
        this.likeToPost,
        this.dislikeToPost,
        this.showCommentSheet,
        this.showLikeSheet,
        @required this.item,})
      : assert(animation != null),
        assert(item != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback navigateToMyProfile;
  final Function moreOption;
  final Function likeToPost;
  final Function dislikeToPost;
  final Function showCommentSheet;
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


  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(item.uploadDate);
    return Padding(
      padding: EdgeInsets.only(bottom: 3),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(bottom: 3),
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
                            uploader.profileImageURL != null ?
                            ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: Image.network(
                                uploader.profileImageURL,
                                height: 40.0,
                                width: 40.0,
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
                                  child: Text(uploader.userName??"", maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                                  onTap: currentUser.uid == uploader.key ? navigateToMyProfile : (){
                                    //TODO 유저 프로필 페이지로 네비게이트
                                  },
                                ),
                              ),
                              Text(DateTime.now().day == date.day && DateTime.now().month == date.month && DateTime.now().year == date.year ?
                              "${date.hour} : ${date.minute >= 10 ? date.minute : "0"+date.minute.toString() }" : "${date.year}.${date.month}.${date.day}",
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
                      onTap: (){
                        Navigator.push(context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: PostDetail(item: item, uploader: uploader, currentUser: currentUser,),)
                        );
                      },
                    ),
                  ),
                  item.attach.length != 0? Container(
                    width: screenSize.width,
                    height: screenSize.width < screenSize.height ? screenSize.height/2.5 : screenSize.width/1.5,
                    child: InkWell(
                      onTap: (){
                        Navigator.push(context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: PostDetail(item: item, uploader: uploader, currentUser: currentUser,),)
                        );
                      },
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
                              return Container( //TODO 로딩박스, 이미지 캐싱
                                child: CachedNetworkImage(
                                  imageUrl: item.attach[index].filePath,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder: (context, url, downloadProgress){
                                    return Container(
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
                      item.like != null ? Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                        height: 30,
                        width: 80,
                        child: InkWell(
                          child: Text("❤️ ${item.like.length} 명",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          onTap: showLikeSheet,
                        ),
                      ) : null,
                      item.comment != null ? Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                        height: 30,
                        width: 80,
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
                    width: screenSize.width -20,
                    child: Divider(thickness: 1,),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: screenSize.width/2,
                        child: FlatButton(
                          child: Row( //Icons.favorite_border : Icons.favorite
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(item.like != null ?
                                  item.like[currentUser.uid] != null ?
                                  Icons.favorite : // 좋아요가 존재할 때
                                  Icons.favorite_border : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                  Icons.favorite_border, // 좋아요 목록이 존재하지 않을 때
                                color: item.like != null ?
                                item.like[currentUser.uid] != null ?
                                Colors.red[600] : // 좋아요가 존재할 때
                                Colors.grey[600] : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                Colors.grey[600], // 좋아요 목록이 존재하지 않을 때
                              ),
                              SizedBox(width: 5,),
                              InkWell(
                                child: Text("좋아요", style: Theme.of(context).textTheme.subtitle,),
                                onTap: null,
                              ),
                            ],
                          ),
                          onPressed: item.like != null ?
                          item.like[currentUser.uid] != null ?
                          dislikeToPost : // 좋아요가 존재할 때
                          likeToPost : // 좋아요 목록에 현재 유저 아이디가 없을 때
                          likeToPost, // 좋아요 목록이 존재하지 않을 때
                        ),
                      ),
                      Container(
                        width: screenSize.width/2,
                        child: FlatButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.comment, color: Colors.grey[600],),
                              SizedBox(width: 5,),
                              Text("댓글 달기",style: Theme.of(context).textTheme.subtitle,)
                            ],
                          ),
                          onPressed: showCommentSheet,
                        ),
                      )
                    ],
                  )
                ].where(notNull).toList(),
              )
            ),
          )
        ),
      ),
    );
  }
}
