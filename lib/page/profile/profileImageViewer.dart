import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:nextor/fnc/user.dart';

import 'package:photo_view/photo_view.dart';

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingChild,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    @required this.currentUser,
    @required this.userInfo,
    this.scrollDirection = Axis.horizontal,
  });

  final Function loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final Axis scrollDirection;
  final FirebaseUser currentUser;
  final User userInfo;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  bool visible = true;
  bool notNull(Object o) => o != null;
  DatabaseReference likeDBRef;


  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
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
              PhotoView(
                imageProvider: NetworkImage(widget.userInfo.profileImageURL,),
                initialScale: widget.minScale,
                minScale: widget.minScale,
                maxScale: widget.maxScale,
                heroAttributes: PhotoViewHeroAttributes(tag: "${widget.userInfo.userName}님의 프로필 사진")
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
                              child: Text("${widget.userInfo.userName}님의 프로필 사진",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                            ),
                          ],
                        ),
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
}