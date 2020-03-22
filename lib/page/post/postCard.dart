import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/auth.dart';
import 'package:shimmer/shimmer.dart';


class PostCard extends StatelessWidget { //TODO 카드 디자인 수정
  PostCard(
      {Key key,
        @required this.animation,
        this.onTap,
        this.onLongPress,
        this.navigateToMyProfile,
        this.currentUser,
        this.upLoader,
        this.seeMore,
        @required this.item,})
      : assert(animation != null),
        assert(item != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback navigateToMyProfile;
  final Function seeMore; //TODO 변수명 수정
  final Post item;
  final User upLoader;
  final FirebaseUser currentUser;

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(item.uploadDate);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.0),
            child: Card(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 15.0),
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
                          "${date.hour} : ${date.minute > 10 ? date.minute : "0"+date.minute.toString() }" : "${date.year}.${date.month}.${date.day}",
                          style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.more_horiz,),
                  onPressed: seeMore,
                ),
                subtitle: Padding(padding: EdgeInsets.only(top: 5.0),
                  child: Column(
                    children: <Widget>[
                      Row( //TODO 사진 추가
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(child: Text(item.body, maxLines: 3,
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,),)
                        ],
                      )
                    ],
                  ),),
              ),
            ),
          )
        ),
      ),
    );
  }
}

class PostCardSkeleton extends StatelessWidget {
  PostCardSkeleton(
      {Key key,
        @required this.animation,
        this.postSizeCase
      })
      : assert(animation != null),
        super(key: key);

  final Animation<double> animation;
  final int periodDuration = 2000;
  final int postSizeCase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.0),
          child: Card(
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 15.0),
              title: Row(
                children: <Widget>[
                  Shimmer.fromColors(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: Container(
                          height: 40,
                          width: 40,
                          color: Colors.grey[400],
                        )
                    ),
                    baseColor: Colors.grey[400],
                    highlightColor: Colors.grey[300],
                    period: Duration(milliseconds: periodDuration),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Shimmer.fromColors(
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(color: Colors.grey[400],borderRadius: BorderRadius.all(Radius.circular(15))),
                              height: 15,
                              width: 100,
                            ),
                            baseColor: Colors.grey[400],
                            highlightColor: Colors.grey[200],
                            period: Duration(milliseconds: periodDuration),
                        ),
                        Shimmer.fromColors(
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(color: Colors.grey[400],borderRadius: BorderRadius.all(Radius.circular(15))),
                            height: 15,
                            width: 200,
                          ),
                          baseColor: Colors.grey[400],
                          highlightColor: Colors.grey[200],
                          period: Duration(milliseconds: periodDuration),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Padding(padding: EdgeInsets.only(top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Shimmer.fromColors(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(color: Colors.grey[400],borderRadius: BorderRadius.all(Radius.circular(15))),
                        height: 15,
                        width: 300,
                      ),
                      baseColor: Colors.grey[400],
                      highlightColor: Colors.grey[200],
                      period: Duration(milliseconds: periodDuration),
                    ),
                    postSizeCase > 1 ? Shimmer.fromColors(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(color: Colors.grey[400],borderRadius: BorderRadius.all(Radius.circular(15))),
                        height: 15,
                        width: 300,
                      ),
                      baseColor: Colors.grey[400],
                      highlightColor: Colors.grey[200],
                      period: Duration(milliseconds: periodDuration),
                    ) : SizedBox(),
                    postSizeCase > 1 ? Shimmer.fromColors(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        height: 15,
                        width: 200,
                        decoration: BoxDecoration(color: Colors.grey[400],borderRadius: BorderRadius.all(Radius.circular(15))),
                      ),
                      baseColor: Colors.grey[400],
                      highlightColor: Colors.grey[200],
                      period: Duration(milliseconds: periodDuration),
                    ) : SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}