import 'package:flutter/material.dart';

import 'package:nextor/fnc/user.dart';


class FollowListPage extends StatefulWidget {
  final User targetUserInfo;
  final int listCase;
  FollowListPage({@required this.targetUserInfo, @required this.listCase});

  @override
  _FollowListPageState createState() =>  _FollowListPageState(targetUserInfo, listCase);
}

class _FollowListPageState extends State<FollowListPage> {
  UserDBFNC userDBFNC = UserDBFNC();
  User targetUserInfo;
  int listCase = 0;

  List<User> followList = List();

  _FollowListPageState(this.targetUserInfo, this.listCase);

  @override
  void initState() {
    super.initState();
    if(listCase == 0) {
      targetUserInfo.follower.forEach((element) {
        userDBFNC.getUserInfo(element.followerUid).then((data) {
          setState(() {
            followList.add(data);
          });
        });
      });
    } else {
      targetUserInfo.following.forEach((element) {
        userDBFNC.getUserInfo(element.followingUid).then((data) {
          setState(() {
            followList.add(data);
          });
        });
      });
    }
  }

  String caseToWord() {
    switch(listCase) {
      case 0:
        return "팔로워";
        break;
      case 1:
        return "팔로잉";
        break;
      default:
        return "";
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          "${targetUserInfo.userName}님의 ${caseToWord()}리스트",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView.builder(
        itemCount: followList.length,
        itemBuilder: (context, index) {
          User followInfo = followList[index];
          DateTime date;
          if(listCase == 0) {
            date = DateTime.parse(targetUserInfo.follower[index].followDate);
          } else {
            date = DateTime.parse(targetUserInfo.following[index].followingDate);
          }
          return Container(
            color: Colors.white,
            child: ListTile(
              contentPadding: EdgeInsets.only(top: 3.0, left: 10, right: 15),
              title: Row(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: Container(
                            height: 40,
                            width: 40,
                            color: Colors.grey[400],
                          )
                      ),
                      followInfo.profileImageURL != null ?
                      ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: Image.network(
                          followInfo.profileImageURL,
                          height: 40.0,
                          width: 40.0,
                        ),
                      ) : ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: Container(
                            height: 40,
                            width: 40,
                            color: Colors.grey[400],
                          )
                      ),
                    ],
                  ),
                  Container(
                    width: 160,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                        child: Text(followInfo.userName??"", maxLines: 1,
                          style: TextStyle(fontSize: 18), overflow: TextOverflow.ellipsis,),
                        onTap: (){}
                    ),
                  ),
                ],
              ),
              trailing: Text(DateTime.now().day == date.day && DateTime.now().month == date.month && DateTime.now().year == date.year ?
              "${date.hour} : ${date.minute >= 10 ? date.minute : "0"+date.minute.toString() } 에 팔로우 함" : "${date.year}.${date.month}.${date.day} 에 팔로우 함",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }),
    );
  }
}