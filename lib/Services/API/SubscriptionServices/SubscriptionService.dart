import 'package:candid_customer/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../AuthServices/AuthConnect.dart';

class SubscriptionService {
  static Future<void> checkSubscriptionStatus() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('candidCustomers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) return;

      final userData = userDoc.data()!;
      if (!userData['isUserPrimeMember']) return;

      final subscriptionEndDate = DateTime.parse(userData['subscriptionEndDate']);
      final now = DateTime.now();

      if (now.isAfter(subscriptionEndDate)) {
        // Subscription has expired
        await AuthConnect().updateUser(
          userData: {
            'isUserPrimeMember': false,
            'subscriptionEndDate': null,
          },
          shouldShowMessage: true,
        );

        // Update local data
        await utils.refreshUser();

        // Show notification to user
        utils.showSnackBar('Your prime membership has expired. Please renew to continue enjoying benefits.');
      }
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
    }
  }

  static Future<void> setupPeriodicCheck() async {
    // Check subscription status on app start
    await checkSubscriptionStatus();

    // Schedule periodic checks
    Stream.periodic(const Duration(hours: 24)).listen((_) async {
      await checkSubscriptionStatus();
    });
  }
} 
