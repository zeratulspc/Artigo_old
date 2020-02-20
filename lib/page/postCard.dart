import 'package:flutter/material.dart';

import 'package:nextor/fnc/postDB.dart';


class PostCard extends StatelessWidget { //TODO 아이템 항목 수정
  const PostCard(
      {Key key,
        @required this.animation,
        this.onTap,
        @required this.item,})
      : assert(animation != null),
        assert(item != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final Post item;

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(item.date);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 128.0,
            child: Card(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 15.0),
                title: Text(item.title, maxLines: 1,
                  style: TextStyle(fontSize: 18),),
                subtitle: Padding(padding: EdgeInsets.only(top: 5.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(item.userId),
                          SizedBox(width: 5,),
                          Text(DateTime.now().day == date.day && DateTime.now().month == date.month && DateTime.now().year == date.year ?
                          "${date.hour} : ${date.minute > 10 ? date.minute : "0"+date.minute.toString() }" : "${date.year}.${date.month}.${date.day}",),
                        ],
                      ),
                      Row(
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
          ),
        ),
      ),
    );
  }
}