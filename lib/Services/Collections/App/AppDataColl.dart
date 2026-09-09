import 'package:isar_community/isar.dart';

part 'AppDataColl.g.dart';

// run command to generate file - flutter pub run build_runner build
// run command to use localhost api - adb reverse tcp:3636 tcp:3636
// run command to use firebase localhost api - adb reverse tcp:5001 tcp:5001

@collection
class AppDataColl {
  var id = Isar.autoIncrement; // you can also use id = null to auto increment

  bool isSignedIn;
  String sessionCookie;

  AppDataColl({required this.isSignedIn, required this.sessionCookie});
}
