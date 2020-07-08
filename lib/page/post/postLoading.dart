import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostCardSkeleton extends StatelessWidget {
  PostCardSkeleton(
      {Key key,
        this.postSizeCase
      })
      : super(key: key);

  final int periodDuration = 2000;
  final int postSizeCase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.0),
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
      ),
    );
  }
}