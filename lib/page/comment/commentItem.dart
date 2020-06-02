import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


import 'package:nextor/fnc/comment.dart';
import 'package:nextor/fnc/auth.dart';


class CommentItem extends StatelessWidget {
  CommentItem(
      {Key key,
        @required this.animation,
        this.currentUser,
        this.uploader,
        this.moreOption,
        this.screenSize,
        this.seeLikeList,
        this.likeToComment,
        this.dislikeToComment,
        this.replyComment,
        @required this.item,})
      : assert(animation != null),
        assert(item != null),
        super(key: key);

  final Animation<double> animation;
  final Function seeLikeList;
  final Function moreOption;
  final Function likeToComment;
  final Function dislikeToComment;
  final Function replyComment;
  final Comment item;
  final User uploader;
  final Size screenSize;
  final FirebaseUser currentUser;

  bool notNull(Object o) => o != null;

  //TODO attach

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(item.uploadDate);
    return Padding(
      padding: EdgeInsets.only(bottom: 5, top: 5),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: GestureDetector(
          onLongPress: moreOption,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Container(
                width: screenSize.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 3.0, left: 10, right: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(15)
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: screenSize.width - 100),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  InkWell(
                                    child: Text(uploader.userName??"", maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                                    onTap: currentUser.uid == uploader.key ? (){} : (){
                                      //TODO 유저 프로필 페이지로 네비게이트
                                    },
                                  ),
                                  Container(
                                    child: Text(item.body,
                                      style: TextStyle(color: Colors.black87, fontSize: 16),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container( //TODO 위젯 사이즈 조절
                      margin: EdgeInsets.only(left: 60, top: 5),
                      child: Row(
                        children: <Widget>[
                          Text(DateTime.now().day == date.day && DateTime.now().month == date.month && DateTime.now().year == date.year ?
                          "${date.hour} : ${date.minute >= 10 ? date.minute : "0"+date.minute.toString() }" : "${date.year}.${date.month}.${date.day}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(width: 20,),
                          InkWell(
                            child: Text("좋아요",
                              style: TextStyle(
                                color: item.like != null ?
                                item.like[currentUser.uid] != null ?
                                Colors.red[600] : // 좋아요가 존재할 때
                                Colors.grey[800] : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                Colors.grey[800], // 좋아요 목록이 존재하지 않을 때
                              ),),
                            onTap: item.like != null ?
                            item.like[currentUser.uid] != null ?
                            dislikeToComment : // 좋아요가 존재할 때
                            likeToComment : // 좋아요 목록에 현재 유저 아이디가 없을 때
                            likeToComment, // 좋아요 목록이 존재하지 않을 때
                          ),
                          SizedBox(width: 20,),
                          replyComment != null ?
                          InkWell(
                            child: Text("답글"),
                            onTap: replyComment,
                          ) : null ,
                          replyComment != null ? SizedBox(width: 20,) : null,
                          item.like != null ?
                          InkWell(
                            onTap: seeLikeList,
                            child: Text("좋아요 ${item.like.length}개",
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),),
                          ) : null,
                          item.reply != null ? SizedBox(width: 20,) : null,
                          item.reply != null ?
                          replyComment != null ?
                          InkWell(
                            onTap: replyComment,
                            child: Text("답글 ${item.reply.length}개",
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),),
                          ) : null : null,
                        ].where(notNull).toList(),
                      ),
                    ),
                  ].where(notNull).toList(),
                ),
              ),
            ),
        ),
      ),
    );
  }
}
