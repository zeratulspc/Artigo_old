import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:nextor/fnc/auth.dart';

class MyProfile extends StatefulWidget { // 내 프로필 페이지
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  AuthDBFNC authDBFNC = AuthDBFNC();
  FirebaseUser currentUser;
  User uploader = User();
  int postCount = 0;

  @override
  void initState() {
    super.initState();
    authDBFNC.getUser().then(
            (data) {
          currentUser = data;
          authDBFNC.getUserInfo(currentUser.uid).then((data) {
              if(this.mounted) {
                setState(() {
                  uploader = data;
                });
              }
            }
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait; // 세로모드 확인
    Size screenSize = MediaQuery.of(context).size;
    double profileImgWidth;
    double profileImgHeight;
    double profileImgCircular;
    if(isPortrait){
      profileImgWidth = screenSize.width/3.2;
      profileImgHeight = screenSize.width/3.2;
      profileImgCircular = 80;
    } else {
      profileImgWidth = screenSize.width/3.2;
      profileImgHeight = screenSize.width/3.2;
      profileImgCircular = 120;
    }
    return ListView(
      padding: EdgeInsets.only(top: 6),
      children: <Widget>[
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(profileImgCircular),
                          child: Container(
                            height: profileImgHeight,
                            width: profileImgWidth,
                            color: Colors.grey[400],
                          )
                      ),
                      uploader != null ?
                      uploader.profileImageURL != null ?
                      ClipRRect( // User 정보가 있고, ProfileImage 가 존재할 때
                        borderRadius: BorderRadius.circular(profileImgCircular),
                        child: Container(
                          height: profileImgHeight,
                          width: profileImgWidth,
                          child: CachedNetworkImage(
                            imageUrl: uploader.profileImageURL,
                          ),
                        ),
                      ) :
                      ClipRRect(// User 정보가 있고, ProfileImage 가 존재하지 않을 때
                          borderRadius: BorderRadius.circular(profileImgCircular),
                          child: Container(
                            height: profileImgHeight,
                            width: profileImgWidth,
                            color: Colors.grey[400],
                          )
                      ) :
                      ClipRRect(// User 정보가 없을 때
                          borderRadius: BorderRadius.circular(profileImgCircular),
                          child: Container(
                            height: profileImgHeight,
                            width: profileImgWidth,
                            color: Colors.grey[400],
                          )
                      )
                    ],
                  ),
                ),
                margin: EdgeInsets.only(top: 50,),
                height: screenSize.width/3.2,
                width: screenSize.width/3.2,
              ),
              Container(
                child: Center(
                  child: Text(
                    uploader.userName??"불러오는 중",
                    maxLines: 1,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
                  ),
                ),
                height: 50, // 길이는 Expand 위젯 사용
                width: screenSize.width/1.8,
              ),
              Container(
                child: Center(
                  child: Text(
                    uploader.description??"불러오는 중",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                margin: EdgeInsets.only(bottom: 10),
                width: screenSize.width/1.5,
              ),
              Container(
                width: screenSize.width - 80,
                child: Divider(),
              ),
              Container(
                width: screenSize.width/1.5,
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              "$postCount",
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                          Container(
                            child: Text(
                              "게시글",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              "4", //TODO 연결
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                          Container(
                            child: Text(
                              "팔로워",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              "32", //TODO 연결
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                          Container(
                            child: Text(
                              "팔로잉",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    "팔로우",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: (){},
                ),
                margin: EdgeInsets.only(bottom: 30),
                height: 50, // 길이는 Expand 위젯 사용
                width: screenSize.width/1.5,
              ),
            ],
          )
        ),
      ],
    );
  }
}
