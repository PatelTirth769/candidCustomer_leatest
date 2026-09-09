import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Utils/Utils.dart';

class ChampionController extends GetxController {
  RxList<Map<String, dynamic>> championList = <Map<String, dynamic>>[].obs;
  RxString selectedChampionId = ''.obs;
  RxBool isLoading = false.obs;

  Future<void> getChampionsList() async {
    try {
      isLoading.value = true;
      String endpoint = 'https://us-central1-candid-cf9fc.cloudfunctions.net/getChampionData';
      
      http.Response res = await http.post(
        Uri.parse(endpoint),
        headers: await Utils().getHeaders(),
      );

      if (res.statusCode == 200) {
        Map jsonResponse = jsonDecode(res.body);
        if (jsonResponse.containsKey('championData')) {
          List championData = jsonResponse['championData'];
          championList.clear();
          
          for (var champion in championData) {
            if (champion is Map && 
                champion.containsKey('championId') && 
                champion['championTypeTitle'] == 'Champion') { // Only include Champions
              championList.add({
                'id': champion['championId'].toString(),
                'name': champion['championName'] ?? '',
                'city': champion['cityName'] ?? 'Unknown City',
              });
            }
          }
          
          // Sort alphabetically by name
          championList.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
        }
      } else if (res.statusCode == 401) {
        await Utils().logOutUser();
      }
    } catch (e) {
      print('Error fetching champions: $e');
    } finally {
      isLoading.value = false;
    }
  }
} 
