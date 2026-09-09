import 'dart:convert';
import 'package:candid_customer/Services/Collections/Cat/CatsColl.dart';
import 'package:candid_customer/Services/Collections/User/UserColl.dart';
import 'package:candid_customer/main.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../Utils/Utils.dart';

class CatsConnect extends GetConnect {

  Future<void> getCatsList() async {
    try {
      // // Print URL and Headers for debugging
      // print('API URL: ${Utils.apiUrl}/getCatsList');
      // print('Headers: ${await Utils().getHeaders()}');
      // Make sure the body is encoded as JSON if that's what the server expects
      var response = await http.post(
        Uri.parse('${Utils.apiUrl}/getCatsList'),
        headers: await Utils().getHeaders(),
        body: jsonEncode({
          'userPhone': (await Utils().getUser() as UserColl).userMobileNumber,
        }),
      );
      // // Print the response for debugging
      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');
      if (response.statusCode == 401) {
        Utils().showSnackBar('Session expired!');
        // await Utils().logOutUser();
        return;
      } else if (response.statusCode == 200) {
        var catsList = jsonDecode(response.body)['catsList'];
        print('Cats List from API: $catsList');
        await isar.writeTxn(() async {
          await isar.catsColls.clear();
        });
        for (var cat in catsList) {
          List<SubCatsColl> localSubCatsList = [];
          var catData = cat['catsData'];
          var catCol = CatsColl(
            catID: cat['id'],
            catName: catData['catName'],
            catImg: catData['catImg'],
            catType: catData['catType'],
          );
          if (cat['subCatsList'] != null) {
            for (var subCat in cat['subCatsList']) {
              var subCatData = subCat['subCatData'];
              localSubCatsList.add(SubCatsColl(
                subCatID: subCat['id'],
                subCatImg: subCatData['subCatImg'],
                subCatName: subCatData['subCatName'],
              ));
            }
          }
          await isar.writeTxn(() async {
            catCol.subCats.addAll(localSubCatsList);
            await isar.subCatsColls.putAll(localSubCatsList);
            await isar.catsColls.put(catCol);
            await catCol.subCats.save();
          });
        }
      } else {
        // Print error response
        // print('Unexpected response status code: ${response.statusCode}');
        // print('Response Body: ${response.body}');
      }
    } catch (e) {
      // Catch and print any exceptions
      // print('Error in getCatsList: $e');
    }
  }
}
