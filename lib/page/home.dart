import 'package:flutter/material.dart';

import 'package:nextor/page/post/postList.dart';
import 'package:nextor/page/todo/todoBoard.dart';
import 'package:nextor/page/data/dataBoard.dart';
import 'package:nextor/page/settings/settings.dart';
import 'package:nextor/page/profile/myProfile.dart';

//temp
import 'package:nextor/fnc/postDB.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PostDBFNC postDBFNC;
  PageController _pageController;
  int _page = 0;
//TODO Home Design
//TODO Home FNC

  void initState() { //TODO 사용자 확인
    super.initState();
    _pageController = PageController();
    postDBFNC = PostDBFNC();
  }

  void navigateToPage(int page) {
    _pageController.animateToPage(page,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size; //TODO screenSize 이용
    return Scaffold(
      body: PageView(
        children: <Widget>[
          PostList(navigateToMyProfile: () {
            navigateToPage(3);
          },),
          TodoBoard(),
          DataBoard(),
          MyProfile(),
          Settings(),
        ],
        controller: _pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text("게시글"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            title: Text("할 일"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            title: Text("통계보드"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text("프로필"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dehaze),
            title: Text("설정"),
          ),
        ],
        onTap: navigateToPage,
        currentIndex: _page,
      ),
    );
  }
}
