import 'package:isar_community/isar.dart';

part 'NotificationColl.g.dart';

// run command to generate file - flutter pub run build_runner build
// run command to use localhost api - adb reverse tcp:3636 tcp:3636

@collection
class NotificationColl {
  Id? id; // you can also use id = null to auto increment

  final String notificationID, imageUrl, title, body;
  bool isSeen;

  NotificationColl({
    required this.notificationID,
    required this.imageUrl,
    required this.title,
    required this.body,
    required this.isSeen,
  });
}
