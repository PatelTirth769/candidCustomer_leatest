import 'package:isar_community/isar.dart';

part 'CityColl.g.dart';

// run command to generate file - flutter pub run build_runner build
// run command to use localhost api - adb reverse tcp:3636 tcp:3636

@collection
class CityColl {
  Id? id; // you can also use id = null to auto increment

  final String cityID, cityName;

  CityColl({
    required this.cityID,
    required this.cityName,
  });
}
