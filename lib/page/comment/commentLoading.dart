import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommentSkeleton extends StatelessWidget { //TODO 스켈레톤 수정
  CommentSkeleton(
      {Key key,
        @required this.animation,
      })
      : assert(animation != null),
        super(key: key);

  final Animation<double> animation;
  final int periodDuration = 2000;

  int next(int min, int max) => min + Random().nextInt(max - min);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.0),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 15.0),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Shimmer.fromColors(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(color: Colors.grey[400],borderRadius: BorderRadius.all(Radius.circular(15))),
                        height: next(30, 100).toDouble(),
                        width: next(80, 300).toDouble(),
                      ),
                      baseColor: Colors.grey[400],
                      highlightColor: Colors.grey[200],
                      period: Duration(milliseconds: periodDuration),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}