import 'package:flutter/material.dart';

import 'package:nextor/fnc/postDB.dart';

class CardItem extends StatelessWidget { //TODO 아이템 항목 수정
  const CardItem(
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
              child: Center(
                child: Text(item.title),
              ),
            ),
          ),
        ),
      ),
    );
  }
}