import 'package:flutter/material.dart';

import 'package:nextor/page/postBoard.dart';
import 'package:nextor/page/todoBoard.dart';
import 'package:nextor/page/dataBoard.dart';
import 'package:nextor/page/settings.dart';
import 'package:nextor/page/profile.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController;
  int _page = 0;
//TODO Home Design
//TODO Home FNC

  void initState() {
    super.initState();
    _pageController = PageController();
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
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text("Nextor"),),
      body: PageView(
        children: <Widget>[
          PostBoard(),
          TodoBoard(),
          DataBoard(),
          Profile(),
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
            title: Text("게시판"),
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
