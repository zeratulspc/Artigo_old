import 'package:firebase_database/firebase_database.dart';
import 'package:package_info/package_info.dart';

class VersionCheck {
  final versionDBRef = FirebaseDatabase.instance.reference().child("Version");

  Future<Version> getVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return Version(versionName: info.version, updateDate: DateTime.now().toIso8601String());
  }

  updateVersion() async {
    Version version = await getVersion();
    versionDBRef.child("CurrentVersion").set(version.toMap());
  }

  Future<bool> checkVersion() async {
    Version currentVersion = await getVersion();

    Version serverVersion = Version.fromSnapshot(await versionDBRef.child("CurrentVersion").once());
    if(currentVersion.versionName == serverVersion.versionName) {
      return true;
    } else {
      return false;
    }
  }

}

class Version {
  String key;
  final String versionName; // 버전명
  final String updateDate; // 업데이트 날짜

  Version({this.versionName, this.updateDate});

  Version.fromSnapshot(DataSnapshot snapshot)
    :key = snapshot.key,
      versionName = snapshot.value["versionName"],
      updateDate = snapshot.value["updateDate"];

  toMap() {
    return {
      "versionName" : versionName,
      "updateDate" : updateDate,
    };
  }
}