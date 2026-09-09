import 'package:candid_customer/Services/Collections/City/CityColl.dart';
import 'package:candid_customer/Utils/Utils.dart';
import 'package:candid_customer/main.dart';
import 'package:get/get.dart';

class CityConnect extends GetConnect {
  // run command to use localhost api - adb reverse tcp:5001 tcp:5001
  getCityListApi() async {
   // print('API URL: ${Utils.apiUrl}/getCityList');
    print('Headers: ${Utils().getHeaders()}');
    Map<String, String> emptyBody = {};
    Response response = await post(
        '${Utils.apiUrl}/getCityList',
        headers: await Utils().getHeaders(),
        emptyBody);
    //print('Response body: ${response.body}');
    if (response.statusCode == 401) {
      Utils().showSnackBar('session expired!');
     // await Utils().logOutUser();
      return;
    } else if (response.statusCode == 200) {
      List<CityColl> cityList = [];
      for (var city in response.body['data']) {
        cityList.add(CityColl(
            cityID: city['cityID'], cityName: city['cityData']['cityName']));
      }
      await isar.writeTxn(() async {
        await isar.cityColls.clear();
        await isar.cityColls.putAll(cityList);
      });
    }
  }
}
