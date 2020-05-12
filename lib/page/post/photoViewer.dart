import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:nextor/fnc/postDB.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingChild,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex,
    @required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final Function loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<Attach> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex;
  List<bool> seeMore = List();
  bool notNull(Object o) => o != null;

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
            widget.galleryItems[currentIndex].description != null ?
            Container( //TODO 화면 터치하면 사라짐
              height: seeMore[currentIndex] ? 300 : 130,
              color: Colors.black54,
              padding: EdgeInsets.all(20.0),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child:  Column(
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
                                        style: TextStyle(color: Colors.grey[600],),
                                        recognizer: TapGestureRecognizer()..onTap = (){
                                          setState(() {
                                            setState(() {
                                              seeMore[currentIndex] = !seeMore[currentIndex];
                                              print(seeMore[currentIndex]);
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
            ) : null,
          ].where(notNull).toList(),
        ),
      ),
    );
  }

  /*
  Text(
                    "${widget.galleryItems[currentIndex]["description"] != null ?
                    widget.galleryItems[currentIndex]["description"] : ""
                    }",
                    style: TextStyle(
                      color: Colors.white,
                      decoration: null,
                    ),
                  ),
   */

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