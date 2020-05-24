import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nextor/page/comment/commentList.dart';

import 'package:page_transition/page_transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextor/fnc/auth.dart';

import 'package:nextor/page/post/postList.dart';
import 'package:nextor/page/post/editPost.dart';
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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
  PostDBFNC postDBFNC = PostDBFNC();
  AuthDBFNC authDBFNC = AuthDBFNC();
  ScrollController scrollController;
  PageController _pageController;
  TabController _tabController;
  bool isPageCanChanged = true;

  FirebaseUser currentUser;
  User currentUserInfo;

  void initState() { //TODO 사용자 확인
    super.initState();
    _pageController = PageController();
    _tabController = TabController(
      length: 5,
      vsync: this
    );
    scrollController = ScrollController();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        onPageChange(index: _tabController.index, p: _pageController);
      }
    });
    if(this.mounted) {
      authDBFNC.getUser().then((_currentUser){
        if(this.mounted) {
          setState(() {
            currentUser = _currentUser;
          });
        }
        authDBFNC.getUserInfo(currentUser.uid).then((userInfo){
          if(this.mounted) {
            setState(() {
              currentUserInfo = userInfo;
            });
          }
        });
      });
    }
  }


  onPageChange({int index , PageController p}) async {
    if(p != null) {
      isPageCanChanged = false;
      await _pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
      isPageCanChanged = true;
    } else {
    _tabController.animateTo(index);
    }
  }


  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size; //TODO screenSize 이용
    return Scaffold(
      key: homeScaffoldKey,
      body: NestedScrollView(
        controller: scrollController,
        dragStartBehavior: DragStartBehavior.down,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) { //TODO appbar physics 끄기
          return <Widget> [
            SliverAppBar( //TODO Appbar 움직임 재구현
              backgroundColor: Colors.white,
              floating: true,
              pinned: true,
              snap: true,
              title: Text("NEXTOR", style: TextStyle(color: Colors.black, fontFamily: "Montserrat"),), //TODO 검색 기능 및 메신저 기능
              bottom: TabBar(
                controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  indicatorColor: Theme.of(context).accentColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: <Tab>[
                    Tab(icon: Icon(Icons.home)),
                    Tab(icon: Icon(Icons.check_box)),
                    Tab(icon: Icon(Icons.dashboard)),
                    Tab(icon: Icon(Icons.person)),
                    Tab(icon: Icon(Icons.settings)),
                  ]
              ),
              actions: <Widget>[
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.search),
                  color: Colors.black87,
                  onPressed: () {},
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.edit),
                  color: Colors.black87,
                  onPressed: () {
                    Navigator.push(context,
                        PageTransition(
                          type: PageTransitionType.downToUp,
                          child: EditPost(
                            postCase: 1,
                            currentUser: currentUser,
                            uploader: currentUserInfo,
                          ),
                        )
                    );
                  },
                ),
              ],
            ),
          ];
        },
        body: PageView(
          children: <Widget>[
            PostList(
              navigateToMyProfile: () {
                onPageChange(index: 3);
              },
              homeScaffoldKey: homeScaffoldKey,
              scrollController: scrollController,
            ),
            TodoBoard(),
            DataBoard(),
            MyProfile(),
            Settings(scrollController: scrollController,),
          ],
          controller: _pageController,
          onPageChanged: (index){
            if(isPageCanChanged){
              onPageChange(index: index);
            }
          },
        ),
      ),
    );
  }
}
