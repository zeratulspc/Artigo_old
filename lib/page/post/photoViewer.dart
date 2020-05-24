import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/auth.dart';
import 'package:nextor/fnc/like.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingChild,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex,
    this.postKey,
    this.getPost,
    @required this.currentUser,
    @required this.galleryItems,
    @required this.uploader,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final Function loadingChild;
  final Decoration backgroundDecoration;
  final VoidCallback getPost;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<Attach> galleryItems;
  final Axis scrollDirection;
  final FirebaseUser currentUser;
  final User uploader;
  final String postKey;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex;
  Attach item;
  List<bool> seeMore = List();
  bool notNull(Object o) => o != null;
  LikeDBFNC likeDBFNC = LikeDBFNC();
  PostDBFNC postDBFNC = PostDBFNC();

  likeToAttach(String key) {
    likeDBFNC.likeToAttach(widget.postKey, widget.currentUser.uid, key);
    widget.getPost();
  }
  dislikeToAttach(String key) {
    likeDBFNC.dislikeToAttach(widget.postKey, widget.currentUser.uid, key);
    widget.getPost();
  }

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    for(int i=0;widget.galleryItems.length>i;i++){
      seeMore.add(false);
    }
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    DateTime date = DateTime.parse(widget.galleryItems[currentIndex].uploadDate);
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.galleryItems.length,
              loadingBuilder: widget.loadingChild,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  color: Colors.black54,
                  width: screenSize.width,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5  ),
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(widget.uploader.userName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                        ),
                        Container(
                          child: Text(
                            date.year == DateTime.now().year ?
                            "${date.month}월 ${date.day}일 ${date.hour}시 ${date.minute}분":
                            "${date.year}. ${date.month}. ${date.day}",
                            style: TextStyle(color: Colors.grey[500]),),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.galleryItems[currentIndex].description != null ?
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenSize.height / 3.5
                  ),
                  child: Container( //TODO 화면 터치하면 사라짐
                    color: Colors.black54,
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    child: Scrollbar(
                      child: SingleChildScrollView(
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
                                            text: seeMore[currentIndex] ? widget.galleryItems[currentIndex].description :
                                            widget.galleryItems[currentIndex].description.length >= 250 ?
                                            widget.galleryItems[currentIndex].description.substring(0, 250) :
                                            widget.galleryItems[currentIndex].description,
                                            style: TextStyle(color: Colors.white), //TODO 사진 있을때는 fontSize 16
                                          ),
                                          widget.galleryItems[currentIndex].description.length >= 250 && !seeMore[currentIndex]?
                                          TextSpan(
                                            text: "...",
                                            style: TextStyle(color: Colors.white), //TODO 사진 있을때는 fontSize 16
                                          ) : null,
                                          widget.galleryItems[currentIndex].description.length >= 250 ?
                                          TextSpan(
                                              text: seeMore[currentIndex] ? " 줄이기" : " 더보기",
                                              style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                              recognizer: TapGestureRecognizer()..onTap = (){
                                                setState(() {
                                                  setState(() {
                                                    seeMore[currentIndex] = !seeMore[currentIndex];
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
                    ),
                  ),
                ) : null,
                Container(
                  color: Colors.black54,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(thickness: 0.5,color: Colors.white,),
                  ),
                ),
                Container(
                  color: Colors.black54,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: screenSize.width/2.5,
                        child: FlatButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(widget.galleryItems[currentIndex].like != null ?
                              widget.galleryItems[currentIndex].like[widget.currentUser.uid] != null ?
                              Icons.favorite : // 좋아요가 존재할 때
                              Icons.favorite_border : // 좋아요 목록에 현재 유저 아이디가 없을 때
                              Icons.favorite_border, // 좋아요 목록이 존재하지 않을 때
                                color: widget.galleryItems[currentIndex].like != null ?
                                widget.galleryItems[currentIndex].like[widget.currentUser.uid] != null ?
                                Colors.red[600] : // 좋아요가 존재할 때
                                Colors.grey[600] : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                Colors.grey[600], // 좋아요 목록이 존재하지 않을 때
                              ),
                              SizedBox(width: 5,),
                              Text("좋아요", style: TextStyle(color: Colors.white),)
                            ],
                          ),
                          onPressed: widget.galleryItems[currentIndex].like != null ?
                          widget.galleryItems[currentIndex].like[widget.currentUser.uid] != null ?
                          ()=>dislikeToAttach(widget.galleryItems[currentIndex].key) : // 좋아요가 존재할 때
                          ()=>likeToAttach(widget.galleryItems[currentIndex].key) : // 좋아요 목록에 현재 유저 아이디가 없을 때
                          ()=>likeToAttach(widget.galleryItems[currentIndex].key), // 좋아요 목록이 존재하지 않을 때
                        ),
                      ),
                      Container(
                        width: screenSize.width/2.5,
                        child: FlatButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.comment, color: Colors.grey[600],),
                              SizedBox(width: 5,),
                              Text("댓글 달기",style: TextStyle(color: Colors.white),)
                            ],
                          ),
                          onPressed: (){
                            //TODO 댓글 띄우기
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ].where(notNull).toList(),
            ),

          ].where(notNull).toList(),
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(widget.galleryItems[index].filePath),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 1.1,
      heroAttributes: PhotoViewHeroAttributes(tag: widget.galleryItems[index].fileName),
    );
  }
}