import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDBFNC {
  final userDBRef = FirebaseDatabase.instance.reference().child("Users");
  final userStorageRef = FirebaseStorage.instance.ref().child("UserStorages"); //TODO UserStorages -> UserStorage 로 바꾸기 # 0.1.4
  final FirebaseAuth auth = FirebaseAuth.instance;

  //TODO 이메일 인증

  // 에러 메세지 한글화
  String errorKr(String code) {
    switch (code) {
      case "ERROR_INVALID_EMAIL":
        return "잘못된 이메일 형식입니다.";
        break;
      case "ERROR_EMAIL_NOT_FOUND":
        return "이메일이 존재하지 않습니다.";
        break;
      case "ERROR_EMAIL_EXISTS":
        return "이미 존재하는 이메일 주소입니다.";
        break;
      case "ERROR_USER_NOT_FOUND":
        return "존재하지 않는 사용자입니다.";
        break;
      case "ERROR_WEAK_PASSWORD":
        return "비밀번호는 6글자 이상으로 지정해야 합니다.";
        break;
      case "ERROR_USER_DISABLED":
        return "사용 정지된 아이디입니다, 관리자에게 문의하세요 ";
        break;
      case "ERROR_TOO_MANY_ATTEMPTS_TRY_LATER":
        return "잠시 후에 시도하세요";
        break;
      case "ERROR_WRONG_PASSWORD":
        return "비밀번호가 틀렸습니다.";
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        return "이미 존재하는 아이디입니다.";
        break;
      default :
        return "관리자에게 문의하세요.[오류코드 : $code]";
    }
  }

  // 권한 한글화
  String roleKr(String role) {
    switch (role) {
      case "ADMIN":
        return "관리자";
        break;
      case "MEMBER":
        return "회원";
        break;
      case "GUEST":
        return "손님";
        break;
      default :
        return "기타";
    }
  }

  // 생성하기
  Future<AuthResult> createUser({String email, String password}) async {
    try {
      return await auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw AuthException(e.code, e.message);
    }
  }


  Future createUserInfo({FirebaseUser user, String username, String description, String registerDate, String role}) async {
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = username;
    await user.updateProfile(updateInfo);
    await userDBRef.child(user.uid).set({
      "email": user.email,
      "uid": user.uid,
      "userName": username,
      "description": description,
      "registerDate" : registerDate,
      "role": "MEMBER",
    });
  }

  // 수정

  Future updateUserName({String uid, String userName}) async {
    await userDBRef.child(uid).update({
      "userName" : userName,
    });
  }

  Future updateUserDescription({String uid, String description}) async {
    await userDBRef.child(uid).update({
      "description" : description,
    });
  }

  Future updateUserToken({String uid, String token}) async {
    await userDBRef.child(uid).update({"token" : token});
  }

  Future updateUserRole({String uid, String role,}) async {
    await userDBRef.child(uid).update({"role" : role,});
  }

  Future updateUserRecentLoginDate({String uid, String recentLoginDate,}) async {
    await userDBRef.child(uid).update({"recentLoginDate" : recentLoginDate,});
  }


  // 프로필 사진 관련
  Future<bool> uploadUserProfileImage({String uid, File profileImage}) async {
    StorageUploadTask task = userStorageRef.child(uid).child("profileImage").child(basename(profileImage.path)).putFile(profileImage);
    String imageURL = await(await task.onComplete.catchError((_) {return false;})).ref.getDownloadURL();
    await updateUserProfileImage(uid: uid, profileImageURL: imageURL);
    return true;
  }

  Future updateUserProfileImage({String uid, String profileImageURL,}) async {
    await userDBRef.child(uid).update({"profileImageURL" : profileImageURL,});
  }

  // 삭제
  Future deleteUser({FirebaseUser currentUser}) async {
    await currentUser.delete();
  }

  //팔로우 기능
  followUser(String myUid, String targetUid) {
    userDBRef.child(targetUid).child("follower").child(myUid).set({"followerUid" : myUid, "followDate": DateTime.now().toIso8601String()});
    userDBRef.child(myUid).child("following").child(targetUid).set({"followingUid" : targetUid, "followingDate": DateTime.now().toIso8601String()});
  }

  unFollowUser(String myUid, String targetUid) {
    userDBRef.child(targetUid).child("follower").child(myUid).remove();
    userDBRef.child(myUid).child("following").child(targetUid).remove();
  }

  // 인증
  Future<AuthResult> loginUser({String email, String password, String loginDate}) async {
    try {
      AuthResult result = await auth.signInWithEmailAndPassword(email: email, password: password);
      return result;
    }  catch (e) {
      throw AuthException(e.code, e.message);
    }
  }


  // 가져오기
  Future<FirebaseUser> getUser() async { // 현재 유저의 FireBaseUser 정보 가져오기
    return await auth.currentUser();
  }

  Future<User> getUserInfo(String uid) async { // uid 를 입력한 유저의 정보 가져오기
    User user = User().fromSnapShot(await userDBRef.child(uid).once());
    return user;
  }

  Future logout() async {
    await auth.signOut();
  }

}

class User {
  String key; // KEY == UID
  String userName; // 닉네임
  String email; // 로그인 할때 이용, 변경불가
  String description; // 한줄소개
  String registerDate; // 가입날짜
  String recentLoginDate; // 최근 로그인 날짜
  String profileImageURL; // 프로필사진 FireStorage URL
  String role; // GUEST, MEMBER, ADMIN
  String token; //TODO FCM

  List<Follower> follower = List(); // 팔로워
  List<Following> following = List(); // 팔로잉

  User({this.key,this.userName, this.description, this.profileImageURL, this.following, this.follower,
    this.email, this.registerDate, this.recentLoginDate, this.role, this.token});

  fromSnapShot(DataSnapshot snapshot) {
    LinkedHashMap<dynamic, dynamic> _followerList = snapshot.value["follower"];
    List<Follower> followerList = List();
    if(_followerList != null){
      _followerList.forEach((k, v) {
        followerList.add(Follower().fromLinkedHashMap(v));
      });
    }

    LinkedHashMap<dynamic, dynamic> _followingList = snapshot.value["following"];
    List<Following> followingList = List();
    if(_followingList != null){
      _followingList.forEach((k, v) {
        followingList.add(Following().fromLinkedHashMap(v));
      });
    }

    return User(
        key : snapshot.key,
        userName : snapshot.value["userName"],
        email : snapshot.value["email"],
        description : snapshot.value["description"],
        registerDate : snapshot.value["registerDate"],
        recentLoginDate : snapshot.value["recentLoginDate"],
        profileImageURL : snapshot.value["profileImageURL"],
        role : snapshot.value["role"],
        token : snapshot.value["token"],
        follower : followerList,
        following : followingList,
    );
  }

  toMap() {
    return {
      "key" : key,
      "userName" : userName,
      "email" : email,
      "description" : description,
      "registerDate" : registerDate,
      "recentLoginDate" : recentLoginDate,
      "profileImageURL" : profileImageURL,
      "role" : role,
      "token" : token,
      "follower" : follower,
      "following" : following,
    };
  }

}

class Follower {
  String followerUid; //팔로워 uid
  String followDate; //팔로우 한 날짜
  String followerToken;

  Follower({this.followDate, this.followerUid, this.followerToken});

  Follower fromLinkedHashMap(LinkedHashMap linkedHashMap){
    return Follower(
      followerUid : linkedHashMap["followerUid"],
      followDate : linkedHashMap["followDate"],
      followerToken : linkedHashMap["followerToken"],
    );
  }

  Follower fromSnapShot(DataSnapshot snapshot){
    return Follower(
      followerUid : snapshot.value["followerUid"],
      followDate : snapshot.value["followDate"],
      followerToken: snapshot.value["followerToken"],
    );
  }

  toMap(){
    return {
      "followerUid" : followerUid,
      "followDate" : followDate,
      "followerToken": followerToken,
    };
  }
}

class Following {
  String followingUid; // 팔로우 한 사람 uid
  String followingDate; // 팔로우 한 날짜

  Following({this.followingDate, this.followingUid});

  Following fromLinkedHashMap(LinkedHashMap linkedHashMap){
    return Following(
      followingUid : linkedHashMap["followingUid"],
      followingDate : linkedHashMap["followingDate"],
    );
  }

  Following fromSnapShot(DataSnapshot snapshot){
    return Following(
      followingUid : snapshot.value["followingUid"],
      followingDate : snapshot.value["followingDate"],
    );
  }

  toMap(){
    return {
      "followingUid" : followingUid,
      "followingDate" : followingDate,
    };
  }
}