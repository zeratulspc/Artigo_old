import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';

import 'package:nextor/fnc/auth.dart';
import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/like.dart';
import 'package:nextor/page/post/photoViewer.dart';

class PostDetail extends StatefulWidget {
  final Post item;
  final User uploader;
  final FirebaseUser currentUser;

  PostDetail({this.item, this.uploader, this.currentUser});

  @override
  _PostDetailState createState() => _PostDetailState(item);
}

class _PostDetailState extends State<PostDetail> {
  LikeDBFNC likeDBFNC = LikeDBFNC();
  PostDBFNC postDBFNC = PostDBFNC();
  Post item;

  List<bool> seeMore = List();

  _PostDetailState(this.item);
  bool notNull(Object o) => o != null;
  likeToPost() {
    likeDBFNC.likeToPost(widget.item.key, widget.currentUser.uid);
    refreshPost();
  }
  dislikeToPost() {
    likeDBFNC.dislikeToPost(widget.item.key, widget.currentUser.uid);
    refreshPost();
  }
  likeToAttach(int index) {
    likeDBFNC.likeToAttach(widget.item.key, widget.currentUser.uid, index);
    refreshPost();
  }
  dislikeToAttach(int index) {
    likeDBFNC.dislikeToAttach(widget.item.key, widget.currentUser.uid, index);
    refreshPost();
  }
  refreshPost() {
    postDBFNC.getPost(widget.item.key).then((data){
      setState(() {
        item = data;
      });
    });
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
                            widget.uploader.profileImageURL != null ?
                            ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: Image.network(
                                widget.uploader.profileImageURL,
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
                                child: Text(widget.uploader.userName??"", maxLines: 1,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                                onTap: widget.currentUser.uid == widget.uploader.key ?
                                    (){} :
                                    (){},//TODO 유저 프로필 페이지로 네비게이트
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
                      onPressed: (){},
                    ),
                  ),
                  Container(
                    child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(child: Text(
                                item.body,
                                style: TextStyle(fontSize: 18.0), //TODO 사진 있을때는 fontsize 16
                                textAlign: TextAlign.left,),)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
                              item.like[widget.currentUser.uid] != null ?
                              Icons.favorite : // 좋아요가 존재할 때
                              Icons.favorite_border : // 좋아요 목록에 현재 유저 아이디가 없을 때
                              Icons.favorite_border, // 좋아요 목록이 존재하지 않을 때
                                color: item.like != null ?
                                item.like[widget.currentUser.uid] != null ?
                                Colors.red[600] : // 좋아요가 존재할 때
                                Colors.grey[600] : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                Colors.grey[600], // 좋아요 목록이 존재하지 않을 때
                              ),
                              SizedBox(width: 5,),
                              Text("좋아요", style: Theme.of(context).textTheme.subtitle,)
                            ],
                          ),
                          onPressed: item.like != null ?
                          item.like[widget.currentUser.uid] != null ?
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
                          onPressed: (){}, //TODO 댓글창 열기
                        ),
                      ),
                    ],
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
                                galleryItems: item.attach,
                                backgroundDecoration: BoxDecoration(
                                  color: Colors.black,
                                ),
                                initialIndex: index,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ),
                          child: Hero(
                              tag: item.attach[index]["fileName"],
                              child: Image.network(
                                  item.attach[index]["filePath"],
                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null)
                                      return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                            : null,
                                      ),
                                    );
                                  }
                              )
                          ),
                        ),
                      ),
                      item.attach[index]["description"] != null ?
                      Container( //TODO 텍스트 너무 많을 때 더보기 및 스크롤 기능 추가
                        child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      item.attach[index]["description"],
                                      style: TextStyle(fontSize: 18.0), //TODO 사진 있을때는 fontSize 16
                                      textAlign: TextAlign.left,
                                      maxLines: seeMore[index] ? null : 7,
                                      overflow: seeMore[index] ? null : TextOverflow.ellipsis
                                    ),
                                  )
                                ],
                              ),
                              item.attach[index]["description"].length >= 50 ? Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        seeMore[index] ? "줄이기" : "더보기",
                                        style: TextStyle(color: Theme.of(context).primaryColor),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      seeMore[index] = !seeMore[index];
                                      print(seeMore[index]);
                                    });
                                  },
                                ),
                              ) : null
                            ].where(notNull).toList(),
                          ),
                        ),
                      ) : null,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          item.attach[index]["like"] != null ? Container(
                            margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                            height: 30,
                            width: 80,
                            child: Text("❤️ ${item.attach[index]["like"].length} 명", //TODO 이모지
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ) : null,
                          item.attach[index]["comment"] != null ? Container(
                            margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                            height: 30,
                            width: 80,
                            child: Text("댓글 ${item.attach[index].length}개",
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
                                  Icon(item.attach[index]["like"] != null ?
                                  item.attach[index]["like"][widget.currentUser.uid] != null ?
                                  Icons.favorite : // 좋아요가 존재할 때
                                  Icons.favorite_border : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                  Icons.favorite_border, // 좋아요 목록이 존재하지 않을 때
                                    color: item.attach[index]["like"] != null ?
                                    item.attach[index]["like"][widget.currentUser.uid] != null ?
                                    Colors.red[600] : // 좋아요가 존재할 때
                                    Colors.grey[600] : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                    Colors.grey[600], // 좋아요 목록이 존재하지 않을 때
                                  ),
                                  SizedBox(width: 5,),
                                  Text("좋아요", style: Theme.of(context).textTheme.subtitle,)
                                ],
                              ),
                              onPressed: item.attach[index]["like"] != null ?
                              item.attach[index]["like"][widget.currentUser.uid] != null ?
                              ()=>dislikeToAttach(index) : // 좋아요가 존재할 때
                              ()=>likeToAttach(index) : // 좋아요 목록에 현재 유저 아이디가 없을 때
                              ()=>likeToAttach(index), // 좋아요 목록이 존재하지 않을 때
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
                              onPressed: (){}, //TODO 댓글창 열기
                            ),
                          ),
                        ],
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
