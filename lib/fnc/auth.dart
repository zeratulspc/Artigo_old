import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthDBFNC {
  final userDBRef = FirebaseDatabase.instance.reference().child("Users");
  final userStorageRef = FirebaseStorage.instance.ref().child("UserStorages");
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

  //TODO 커버사진

  // 삭제

  Future deleteUser({FirebaseUser currentUser}) async {
    await userDBRef.child(currentUser.uid).remove();
    await currentUser.delete();
  }


  // Auth

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
    User user = User.fromSnapShot(await userDBRef.child(uid).once());
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

  List<String> follower; // 팔로워
  List<String> following; // 팔로잉

  User({this.key,this.userName,
    this.email, this.registerDate, this.recentLoginDate, this.role, this.token});

  User.fromLinkedHashMap(LinkedHashMap linkedHashMap)
      :key = linkedHashMap["key"],
        userName = linkedHashMap["userName"],
        email = linkedHashMap["email"],
        description = linkedHashMap["description"],
        registerDate = linkedHashMap["registerDate"],
        recentLoginDate = linkedHashMap["recentLoginDate"],
        profileImageURL = linkedHashMap["profileImageURL"],
        role = linkedHashMap["role"],
        token = linkedHashMap["token"];

  User.fromSnapShot(DataSnapshot snapshot)
      :key = snapshot.key,
        userName = snapshot.value["userName"],
        email = snapshot.value["email"],
        description = snapshot.value["description"],
        registerDate = snapshot.value["registerDate"],
        recentLoginDate = snapshot.value["recentLoginDate"],
        profileImageURL = snapshot.value["profileImageURL"],
        role = snapshot.value["role"],
        token = snapshot.value["token"],
        follower = snapshot.value["follower"],
        following = snapshot.value["following"];

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


}