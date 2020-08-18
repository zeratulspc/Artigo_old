import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:Artigo/fnc/postDB.dart';
import 'package:Artigo/fnc/user.dart';
import 'package:Artigo/fnc/emotion.dart';
import 'package:Artigo/fnc/dateTimeParser.dart';
import 'package:Artigo/page/comment/commentList.dart';
import 'package:Artigo/page/emotion/emotionInput.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingChild,
    this.backgroundDecoration,
    this.navigateToMyProfile,
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
  final VoidCallback navigateToMyProfile;
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
  bool visible = true;
  List<Attach> items = List();
  List<bool> seeMore = List();
  bool notNull(Object o) => o != null;
  EmotionDBFNC likeDBFNC;
  PostDBFNC postDBFNC = PostDBFNC();
  DatabaseReference emotionDBRef;

  likeToAttach(String key) {
    emotionDBRef = postDBFNC.postDBRef.child(widget.postKey).child("attach").child(key);
    EmotionInput(emotionDBRef, widget.currentUser.uid, widget.uploader.key, refreshPost).showEmotionPicker(context);
  }
  dislikeToAttach(String key) {
    emotionDBRef = postDBFNC.postDBRef.child(widget.postKey).child("attach").child(key);
    EmotionDBFNC(emotionDBRef: emotionDBRef).dislike(widget.currentUser.uid).then((data){
      refreshPost();
    });
  }

  refreshPost() {
    postDBFNC.getPost(widget.postKey).then((data) {
      setState(() {
        items = data.attach;
      });
    });
    widget.getPost();
  }

  @override
  void initState() {
    setState(() {
      items.addAll(widget.galleryItems);
    });
    currentIndex = widget.initialIndex;
    for(int i=0;items.length>i;i++){
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
    DateTime date = DateTime.parse(items[currentIndex].uploadDate);
    return Scaffold(
      body: GestureDetector(
        onTap: (){
          setState(() {
            visible = !visible;
          });
        },
        child: Container(
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
                itemCount: items.length,
                loadingBuilder: widget.loadingChild,
                backgroundDecoration: widget.backgroundDecoration,
                pageController: widget.pageController,
                onPageChanged: onPageChanged,
                scrollDirection: widget.scrollDirection,
              ),
              AnimatedOpacity(
                opacity: visible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 100),
                child: Column(
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
                              child: Text(DateTimeParser().defaultParse(date),
                                style: TextStyle(color: Colors.grey[500]),),
                            ),
                          ],
                        ),
                      ),
                    ),
                    items[currentIndex].description != null ?
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: screenSize.height / 3.5
                      ),
                      child: Container(
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
                                                text: seeMore[currentIndex] ? items[currentIndex].description :
                                                items[currentIndex].description.length >= 250 ?
                                                items[currentIndex].description.substring(0, 250) :
                                                items[currentIndex].description,
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              items[currentIndex].description.length >= 250 && !seeMore[currentIndex]?
                                              TextSpan(
                                                text: "...",
                                                style: TextStyle(color: Colors.white),
                                              ) : null,
                                              items[currentIndex].description.length >= 250 ?
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
                            width: screenSize.width/2,
                            child: FlatButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(items[currentIndex].emotion != null ?
                                  items[currentIndex].emotion.singleWhere((e) => e.userUID == widget.currentUser.uid, orElse: ()=> null) != null ?
                                  Icons.favorite : // 좋아요가 존재할 때
                                  Icons.insert_emoticon : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                  Icons.insert_emoticon, // 좋아요 목록이 존재하지 않을 때
                                    color: items[currentIndex].emotion != null ?
                                    items[currentIndex].emotion.singleWhere((e) => e.userUID == widget.currentUser.uid, orElse: () => null) != null ?
                                    Colors.transparent: // 좋아요가 존재할 때
                                    Colors.grey[600] : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                    Colors.grey[600], // 좋아요 목록이 존재하지 않을 때
                                  ),
                                  SizedBox(width: 5,),
                                  Text("${
                                      items[currentIndex].emotion != null ?
                                      items[currentIndex].emotion.singleWhere((e) => e.userUID == widget.currentUser.uid, orElse: ()=> null) != null ?
                                      items[currentIndex].emotion[items[currentIndex].emotion.indexOf(items[currentIndex].emotion.singleWhere((e) => e.userUID == widget.currentUser.uid, orElse: ()=> null))].emotionCode :
                                      "공감하기" :
                                      "공감하기"}",
                                    style: items[currentIndex].emotion != null ?
                                    items[currentIndex].emotion.singleWhere((e) => e.userUID == widget.currentUser.uid, orElse: ()=> null) != null ?
                                    Theme.of(context).textTheme.headline5 :
                                    TextStyle(color: Colors.white) :
                                    TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              onPressed: items[currentIndex].emotion != null ?
                              items[currentIndex].emotion.singleWhere((e) => e.userUID == widget.currentUser.uid, orElse:()=> null) != null ?
                                  ()=>dislikeToAttach(items[currentIndex].key) : // 좋아요가 존재할 때
                                  ()=>likeToAttach(items[currentIndex].key) : // 좋아요 목록에 현재 유저 아이디가 없을 때
                                  ()=>likeToAttach(items[currentIndex].key), // 좋아요 목록이 존재하지 않을 때
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
                                showModalBottomSheet(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return CommentList(
                                      getPost: (){
                                        refreshPost();
                                      },
                                      postKey: widget.postKey,
                                      currentUser: widget.currentUser,
                                      attachKey: items[currentIndex].key,
                                      navigateToMyProfile: widget.navigateToMyProfile,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ].where(notNull).toList(),
                ),
              ),
            ].where(notNull).toList(),
          ),
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