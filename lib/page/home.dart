import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:nextor/fnc/user.dart';
import 'package:nextor/fnc/notification.dart';
import 'package:nextor/page/post/postList.dart';
import 'package:nextor/page/post/editPost.dart';
import 'package:nextor/page/todo/todoBoard.dart';
import 'package:nextor/page/data/dataBoard.dart';
import 'package:nextor/page/settings/settings.dart';
import 'package:nextor/page/profile/userProfile.dart';
import 'package:nextor/page/post/searchPage.dart';
import 'package:nextor/page/profile/notificationList.dart';
//TEMP
import 'package:nextor/page/post/postListTest.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  //UI
  GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController;
  TabController _tabController;
  bool isPageCanChanged = true;

  //Auth
  UserDBFNC authDBFNC = UserDBFNC();
  FirebaseUser currentUser;
  User currentUserInfo;

  //FCM
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this
    );
    scrollController = ScrollController();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        onPageChange(_tabController.index);
      }
    });
    if(this.mounted) {
      authDBFNC.getUser().then((_currentUser){
        if(this.mounted) {
          setState(() {
            currentUser = _currentUser;
          });
        }
        firebaseMessaging.getToken().then((token){
          authDBFNC.updateUserToken(uid: currentUser.uid, token: token);
        });
        authDBFNC.getUserInfo(currentUser.uid).then((userInfo){
          if(this.mounted) {
            setState(() {
              currentUserInfo = userInfo;
            });
          }
        });
      });
    }

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) => NotificationFCMFnc.onMessage(context, message),
      onResume: (Map<String, dynamic> message) => NotificationFCMFnc.onResume(context, message),
      onLaunch: (Map<String, dynamic> message) => NotificationFCMFnc.onLaunch(context, message),
    );
  }


  onPageChange(int index) async {
    _tabController.animateTo(index);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      body: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              floating: true,
              snap: true,
              title: Text("ARTIGO", style: TextStyle(color: Colors.black, fontFamily: "Montserrat"),), //TODO 검색 기능 및 메신저 기능
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
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchPage()
                    ));
                  },
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.notifications_none),
                  color: Colors.black87,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NotificationList(currentUser.uid),
                    ));
                  },
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
        body: TabBarView(
          children: <Widget>[
            PostListTest(
              navigateToMyProfile: () {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
                onPageChange(3);
              },
              homeScaffoldKey: homeScaffoldKey,
              scrollController: scrollController,
            ),
            TodoBoard(),
            DataBoard(),
            UserProfilePage(
              navigateToMyProfile: () {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
                onPageChange(3);
              },
            ),
            Settings(scrollController: scrollController,),
          ],
          controller: _tabController,
        ),
      ),
    );
  }
}
