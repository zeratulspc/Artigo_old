import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';

import 'package:nextor/fnc/auth.dart';
import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/like.dart';
import 'package:nextor/page/basicDialogs.dart';
import 'package:nextor/page/post/editPost.dart';
import 'package:nextor/page/post/photoViewer.dart';
import 'package:nextor/page/comment/commentList.dart';

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
  BasicDialogs basicDialogs = BasicDialogs();
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
  likeToAttach(String key) {
    likeDBFNC.likeToAttach(widget.item.key, widget.currentUser.uid, key);
    refreshPost();
  }
  dislikeToAttach(String key) {
    likeDBFNC.dislikeToAttach(widget.item.key, widget.currentUser.uid, key);
    refreshPost();
  }
  refreshPost() {
    postDBFNC.getPost(widget.item.key).then((data){
      setState(() {
        item = data;
      });
    });
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
                          EditPost(postCase: 2, initialPost: post, uploader: widget.uploader, currentUser: widget.currentUser,)));
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
                              Container(
                                width: screenSize.width / 1.7,
                                child: InkWell(
                                  child: Text(widget.uploader.userName??"", maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                                  onTap: widget.currentUser.uid == widget.uploader.key ?
                                      (){} :
                                      (){},//TODO 유저 프로필 페이지로 네비게이트
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
                      onPressed: ()=> postModalBottomSheet(context, item),
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
                                style: TextStyle(fontSize: item.body.length>=250?16:18), //TODO 사진 있을때는 fontsize 16
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
                          child: Row(
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
                          onPressed: (){
                            showModalBottomSheet(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return CommentList(
                                  postKey: item.key,
                                  currentUser: widget.currentUser,
                                );
                              },
                            );
                          },
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
                                getPost: (){
                                  refreshPost();
                                },
                                uploader: widget.uploader,
                                currentUser: widget.currentUser,
                                galleryItems: item.attach,
                                postKey: widget.item.key,
                                backgroundDecoration: BoxDecoration(
                                  color: Colors.black,
                                ),
                                initialIndex: index,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ),
                          child: Hero(
                              tag: item.attach[index].fileName,
                              child: Image.network(
                                  item.attach[index].filePath,
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
                      item.attach[index].description != null ?
                      Container( //TODO 텍스트 너무 많을 때 더보기 및 스크롤 기능 추가
                        child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                                              style: TextStyle(color: Colors.black87), //TODO 사진 있을때는 fontSize 16
                                          ),
                                          item.attach[index].description.length >= 250 && !seeMore[index]?
                                          TextSpan(
                                            text: "...",
                                            style: TextStyle(color: Colors.black87), //TODO 사진 있을때는 fontSize 16
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
                          item.attach[index].like != null ? Container(
                            margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                            height: 30,
                            width: 80,
                            child: Text("❤️ ${item.attach[index].like.length} 명", //TODO 이모지
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ) : null,
                          item.attach[index].comment != null ? Container(
                            margin: EdgeInsets.only(left: 10, right: 10, top: 10,),
                            height: 30,
                            width: 80,
                            child: Text("댓글 ${item.attach[index].comment.length}개",
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
                                  Icon(item.attach[index].like != null ?
                                  item.attach[index].like[widget.currentUser.uid] != null ?
                                  Icons.favorite : // 좋아요가 존재할 때
                                  Icons.favorite_border : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                  Icons.favorite_border, // 좋아요 목록이 존재하지 않을 때
                                    color: item.attach[index].like != null ?
                                    item.attach[index].like[widget.currentUser.uid] != null ?
                                    Colors.red[600] : // 좋아요가 존재할 때
                                    Colors.grey[600] : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                    Colors.grey[600], // 좋아요 목록이 존재하지 않을 때
                                  ),
                                  SizedBox(width: 5,),
                                  Text("좋아요", style: Theme.of(context).textTheme.subtitle,)
                                ],
                              ),
                              onPressed: item.attach[index].like != null ?
                              item.attach[index].like[widget.currentUser.uid] != null ?
                              ()=>dislikeToAttach(item.attach[index].key) : // 좋아요가 존재할 때
                              ()=>likeToAttach(item.attach[index].key) : // 좋아요 목록에 현재 유저 아이디가 없을 때
                              ()=>likeToAttach(item.attach[index].key), // 좋아요 목록이 존재하지 않을 때
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
                              onPressed: (){
                                showModalBottomSheet(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return CommentList(
                                      postKey: item.key,
                                      currentUser: widget.currentUser,
                                      attachKey: item.attach[index].key,
                                      getPost: (){
                                        refreshPost();
                                      },
                                    );
                                  },
                                );
                              },
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
