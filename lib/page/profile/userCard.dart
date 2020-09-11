import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Artigo/fnc/user.dart';
import 'package:Artigo/fnc/dateTimeParser.dart';
import 'package:Artigo/page/profile/userProfile.dart';

//TODO 검색탭 및 기타 에서 쓸 유저 카드 만들기
//

class UserCard {

  UserCard({Key key,
    this.navigateToMyProfile,
    this.userInfo,
    this.screenSize,
    this.currentUser
  });

  final VoidCallback navigateToMyProfile;
  final UserAdditionalInfo userInfo;
  final User currentUser;
  final Size screenSize;

  Widget userCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.white,
          width: screenSize.width,
          child: ListTile(
            contentPadding: EdgeInsets.only(top: 3.0, left: 10),
            title: Row(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: Container(
                          height: 40,
                          width: 40,
                          color: Colors.grey[300],
                        )
                    ),
                    userInfo != null ?
                    userInfo.profileImageURL != null ?
                    ClipRRect( // User 정보가 있고, ProfileImage 가 존재할 때
                      borderRadius: BorderRadius.circular(80),
                      child: GestureDetector(
                        child: Container(
                          height: 40,
                          width: 40,
                          child: CachedNetworkImage(
                            filterQuality: FilterQuality.none,
                            imageUrl: userInfo.profileImageURL,
                          ),
                        ),
                        onTap: currentUser.uid == userInfo.key ? navigateToMyProfile : (){
                          Navigator.popUntil(context, ModalRoute.withName('/home'));
                          showModalBottomSheet(
                            backgroundColor: Colors.grey[300],
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return Container(
                                height: screenSize.height-50,
                                child: UserProfilePage(targetUserUid: userInfo.key, navigateToMyProfile: navigateToMyProfile,),
                              );
                            },
                          );
                        },
                      ),
                    ) :
                    ClipRRect(// User 정보가 있고, ProfileImage 가 존재하지 않을 때
                        borderRadius: BorderRadius.circular(80),
                        child: Container(
                          height: 40,
                          width: 40,
                          color: Colors.grey[400],
                        )
                    ) :
                    ClipRRect(// User 정보가 없을 때
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
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      userInfo != null ?
                      Container( // 업로더 정보가 있을 때
                        width: screenSize.width / 1.7,
                        child: InkWell(
                          child: Text(userInfo.userName??"", maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                          onTap: currentUser.uid == userInfo.key ? navigateToMyProfile : (){
                            Navigator.popUntil(context, ModalRoute.withName('/home'));
                            showModalBottomSheet(
                              backgroundColor: Colors.grey[300],
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return Container(
                                  height: screenSize.height-50,
                                  child: UserProfilePage(targetUserUid: userInfo.key, navigateToMyProfile: navigateToMyProfile,),
                                );
                              },
                            );
                          },
                        ),
                      ) :
                      Container( // 업로더 정보가 없을 때
                        width: screenSize.width / 1.7,
                        child: InkWell(
                          child: Text("", maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                          onTap:(){},
                        ),
                      ),
                      Container(
                        child: Text(
                          userInfo.description,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}