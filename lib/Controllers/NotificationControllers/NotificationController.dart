import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../Services/API/NotificationServices/NotificationConnect.dart';

class NotificationController extends GetxController {
  RxBool isLoading = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      isLoading.value = true;
      await NotificationConnect().getCustomerNotificationsApi();
    } catch (e) {
      debugPrint('NotificationController | init | catch | $e');
    } finally {
      isLoading.value = false;
    }
  }


  markReadAllNotificationsClickHandler() async {
    try {
      isLoading.value = true;
      update();
      await NotificationConnect().updateCustomerNotificationsToReadAllApi();
      isLoading.value = false;
      update();
    } catch (e) {
      debugPrint(
          'NotificationController | markReadAllNotificationsClickHandler | catch | $e');
      isLoading.value = false;
      update();
    }
  }
}
