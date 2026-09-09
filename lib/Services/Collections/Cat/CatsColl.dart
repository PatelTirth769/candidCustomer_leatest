import 'package:isar_community/isar.dart';

part 'CatsColl.g.dart';

// run command to generate file - flutter pub run build_runner build
// run command to use localhost api - adb reverse tcp:3636 tcp:3636

@collection
class SubCatsColl {
  Id? id; // you can also use id = null to auto increment

  @Index(unique: true, replace: true)
  final String subCatID;

  String subCatName, subCatImg;

  SubCatsColl({
    required this.subCatID,
    required this.subCatName,
    required this.subCatImg,
  });
}

@collection
class CatsColl {
  Id? id; // you can also use id = null to auto increment

  @Index(unique: true, replace: true)
  final String catID;

  String catName, catImg, catType;

  final subCats = IsarLinks<SubCatsColl>();

  CatsColl({
    required this.catID,
    required this.catName,
    required this.catImg,
    required this.catType,
  });
}
