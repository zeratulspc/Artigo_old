import 'package:flutter/material.dart';

import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

import 'package:nextor/fnc/animations.dart';
import 'package:nextor/page/postBoard.dart';
import 'package:nextor/page/todoBoard.dart';
import 'package:nextor/page/dataBoard.dart';
import 'package:nextor/page/settings.dart';


class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
//TODO Home FNC

  Widget noticeCard(String userName, String date, String title, bool isLiked) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      width: 300,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.white,
        elevation: 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.person, size: 70),
              title: Text(userName),
              subtitle: Text(date),
            ),
            SizedBox(height: 5,),
            ListTile(
                title: Text(title, maxLines: 2,),
                trailing: IconButton(icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.pink, size: 24.0,), onPressed: (){},)
            ),
          ],
        ),
      ),
    );
  }

  Widget newsCard(BuildContext context, String userName, String date, String title) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 220,
      width: screenSize.width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.white,
        elevation: 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.person, size: 70),
              title: Text(userName),
              subtitle: Text(date),
            ),
            SizedBox(height: 5,),
            ListTile(
              title: Text(title, maxLines: 2,),
            ),
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    onPressed: () {},
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  final List<Widget> screens = [
    PostBoard(),
    TodoBoard(),
    DataBoard(),
    Settings(),
  ]; // to store nested tabs

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: WaveClipperOne(),
                    child: Container(color: Theme.of(context).primaryColor,
                      width: screenSize.width,
                      height: 300,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 50,),
                      Container(
                        padding: EdgeInsets.only(left: 30),
                        child: FadeIn(1.5,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("안녕하세요",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.0,
                                ),
                              ),
                              Text("김민재님!", //TODO USERNAME
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.0,
                                ),
                              ),
                            ],
                          ),),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      FadeIn(2.0,
                        Container(
                          padding: EdgeInsets.only(left: 30),
                          child: Text("공지사항을 확인해 보세요", //TODO NOTICE
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ),),
                      SizedBox(
                        height: 15,
                      ),
                      FadeIn(2.33,
                          Container(
                            height: 160,
                            child: ListView(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                noticeCard(
                                    "김민재",
                                    "2019.12.11",
                                    "Nextor 커뮤니티 앱 활용 방안 및 안내 ",
                                    true),
                                noticeCard(
                                    "이한서",
                                    "2019.12.11",
                                    "Nextor 동아리 개편사항 및 새로운 프로젝트 안내 ",
                                    false),
                                noticeCard(
                                    "김민재",
                                    "2019.12.11",
                                    "앱 제작 비하인드 스토리",
                                    true),
                              ],
                            ),
                          )
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              FadeIn(
                2.66,
                Container(
                  padding: EdgeInsets.only(left: 30, bottom: 10),
                  child: Text("새로운 소식을 확인해 보세요", //TODO NEWS
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              FadeIn(3.5,
                  Column(
                    children: <Widget>[
                      newsCard(context, "김민재", "2019.12.11", "이번주 최고의 출석률 맴버!"),
                      newsCard(context, "김민재", "2019.12.11", "다음주 동아리 프로젝트 예고"),
                      newsCard(context, "이한서", "2019.12.11", "데이터의 흐름에 대해서"),
                    ],
                  )
              ),
              SizedBox(height: 15,),
              FadeIn(4.0,
                  Center(
                    child: RaisedButton(
                      elevation: 10,
                      color: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.deepPurpleAccent),
                      ),
                      onPressed: () {

                      },
                      child: Container(
                        height: 50,
                        width: 300,
                        child: Center(
                          child: Text("확인했어요", style: TextStyle(color: Colors.white, ),
                          ),
                        ),
                      ),
                    ),
                  )
              ),
              SizedBox(height: 15,),
            ],
          ),
        )
    );
  }
}
