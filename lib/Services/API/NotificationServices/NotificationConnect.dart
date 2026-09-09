import 'dart:convert';

import 'package:candid_customer/Services/Collections/Notification/NotificationColl.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:http/http.dart' as http;
import '../../../Utils/Utils.dart';
import '../../../main.dart';

class NotificationConnect extends GetConnect {

  getCustomerNotificationsApi() async {
    try {
      final response = await http.post(
        Uri.parse('${Utils.apiUrl}/getCustomerNotifications'),
        headers: await utils.getHeaders(),
        body: json.encode({}),
      );

      debugPrint('getCustomerNotificationsApi | ${response.statusCode}');
      debugPrint('getCustomerNotificationsApi | ${response.body}');

      if (response.statusCode == 401) {
        utils.showSnackBar('Session expired!');
        // await utils.logOutUser();
        return;
      }

      if (response.statusCode == 200) {
        final List<NotificationColl> notificationList = [];
        final data = json.decode(response.body);

        for (var notification in data['customerNotificationList']) {
          notificationList.add(NotificationColl(
            notificationID: notification['notificationID'],
            imageUrl: notification['imageUrl'] ?? "",
            title: notification['title'],
            body: notification['body'],
            isSeen: notification['isSeen'] ?? false,
          ));
        }

        await isar.writeTxn(() async {
          await isar.notificationColls.clear();
          await isar.notificationColls.putAll(notificationList);
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      debugPrint('getCustomerNotificationsApi | Error: $e');
      utils.showSnackBar('Error fetching notifications');
    }
  }


  updateCustomerNotificationsToReadAllApi() async {
    Map<String, String> emptyBody = {};
    Response response = await post(
        '${Utils.apiUrl}/updateCustomerNotificationsToReadAll',
        headers: await utils.getHeaders(),
        emptyBody);

    debugPrint('updateCustomerNotificationsToReadAll | ${response.statusCode}');
    debugPrint('updateCustomerNotificationsToReadAll | ${response.body}');

    if (response.statusCode == 401) {
      utils.showSnackBar('session expired!');
      // await utils.logOutUser();
      return;
    } else if (response.statusCode == 200) {
      await isar.writeTxn(() async {
        List<NotificationColl> notificationList = [];
        for (var notification in await isar.notificationColls
            .filter()
            .idIsNotNull()
            .build()
            .findAll()) {
          notification.isSeen = true;
          notificationList.add(notification);
        }
        await isar.notificationColls.putAll(notificationList);
      });
    }
  }
}
