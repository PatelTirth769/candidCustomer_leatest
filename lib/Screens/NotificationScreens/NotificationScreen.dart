import 'package:candid_customer/Controllers/NotificationControllers/NotificationController.dart';
import 'package:candid_customer/Screens/OtherScreens/ShowLoadingScreen.dart';
import 'package:candid_customer/Services/Collections/Notification/NotificationColl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import '../../main.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GetBuilder<NotificationController>(
        init: NotificationController(),
        builder: (controller) => StreamBuilder<List<NotificationColl>>(
          stream: isar.notificationColls
              .filter()
              .notificationIDIsNotEmpty()
              .watch(fireImmediately: true),
          builder: (context, snapshot) {
            debugPrint('snapshot: $snapshot');

            // Handle the data from the snapshot
            List<NotificationColl> notifications = [];
            if (snapshot.hasData && snapshot.data != null) {
              notifications = snapshot.data!;
              debugPrint('LEN: ${notifications.length}');
            }

            // Display the UI based on the data and loading state
            return AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: snapshot.connectionState == ConnectionState.waiting ||
                  controller.isLoading.value
                  ? const ShowLoadingScreen()
                  : notifications.isEmpty
                  ? const Center(
                child: Text(
                    'No Notifications found! You can check back later.'),
              )
                  : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (BuildContext context, int index) {
                          final NotificationColl notification =
                          notifications[index];
                          return Center(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 4.0),
                              child: myWidgets.getNotificationCard(
                                headline: notification.title,
                                description: notification.body,
                                isSeen: notification.isSeen,
                                onMarkAsRead: () {
                                  controller
                                      .markReadAllNotificationsClickHandler();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 2.h),
                    myWidgets.getCandidBranding(),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
