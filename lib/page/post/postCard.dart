import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/like.dart';
import 'package:nextor/fnc/auth.dart';
import 'package:shimmer/shimmer.dart';


class PostCard extends StatelessWidget { //TODO 카드 디자인 수정
  PostCard(
      {Key key,
        @required this.animation,
        this.onTap,
        this.navigateToMyProfile,
        this.currentUser,
        this.upLoader,
        this.moreOption,
        this.screenSize,
        this.likeToPost,
        this.dislikeToPost,
        @required this.item,})
      : assert(animation != null),
        assert(item != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final VoidCallback navigateToMyProfile;
  final Function moreOption; //TODO 변수명 수정
  final Function likeToPost;
  final Function dislikeToPost;
  final Post item;
  final User upLoader;
  final Size screenSize;
  final FirebaseUser currentUser;

  bool notNull(Object o) => o != null;


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
          onTap: onTap,
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
                            upLoader.profileImageURL != null ?
                            ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: Image.network(
                                upLoader.profileImageURL,
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
                              InkWell(
                                child: Text(upLoader.userName??"", maxLines: 1,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                                onTap: currentUser.uid == upLoader.key ? navigateToMyProfile : (){
                                  //TODO 유저 프로필 페이지로 네비게이트
                                },
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
                  Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Column(
                      children: <Widget>[
                        Row( //TODO 사진 보는 영역(GridView), 댓글 및 좋아요 영역 추가
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: Text(item.body, maxLines: 7, //TODO 더보기 구현
                              style: TextStyle(fontSize: 18.0), //TODO 사진 있을때는 fontsize 16
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,),)
                          ],
                        ),
                      ],
                    ),
                  ),
                  //
                  // 여기에
                  // 사진첩 기능
                  //
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      item.like != null ? Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                        height: 30,
                        width: 80,
                        child: Text("❤️ ${item.like.length} 명", //TODO 이모지
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ) : null,
                      item.comment != null ? Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                        height: 30,
                        width: 80,
                        child: Text("댓글 ${item.comment.length}개",
                          style: TextStyle(color: Colors.grey[700]),
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
                              Text("좋아요", style: Theme.of(context).textTheme.subtitle,)
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
                          onPressed: (){},
                        ),
                      )
                    ],
                  )
                ],
              )
            ),
          )
        ),
      ),
    );
  }
}
