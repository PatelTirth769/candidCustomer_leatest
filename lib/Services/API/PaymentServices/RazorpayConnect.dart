import 'dart:convert';

import 'package:candid_customer/Screens/PaymentScreens/PrimeCustomerPaymentScreen.dart';
import 'package:candid_customer/Screens/PrimeMembership/PrimeMembershipScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../BottomNavScreen.dart';
import '../../../main.dart';
import '../AuthServices/AuthConnect.dart';

class ApiServices {
  // ============================================================
  // RAZORPAY
  // ============================================================

  String razorpayKey = "rzp_live_mXMqD6Uq31IPNc";

  // ⚠️ SECURITY WARNING:
  // DO NOT keep the Razorpay secret inside the Flutter app.
  // Move this to your backend before production.
  String razorpaySecret = "R31iM3MZyxPQdBtNmAPF4s9V";

  /// GST percentage
  static const double gstPercentage = 18.0;

  /// -----------------------------------------------------------
  /// Calculate GST
  /// -----------------------------------------------------------
  double calculateGST(double baseAmount) {
    return double.parse(
      (baseAmount * gstPercentage / 100).toStringAsFixed(2),
    );
  }

  /// -----------------------------------------------------------
  /// Calculate total amount including GST
  /// -----------------------------------------------------------
  double calculateTotal(double baseAmount) {
    final gstAmount = calculateGST(baseAmount);

    return double.parse(
      (baseAmount + gstAmount).toStringAsFixed(2),
    );
  }

  /// -----------------------------------------------------------
  /// Create Razorpay order
  ///
  /// amount should be the FINAL amount including GST.
  ///
  /// Example:
  /// base = 499
  /// GST = 89.82
  /// total = 588.82
  /// Razorpay = 58882 paise
  /// -----------------------------------------------------------
  Future<Map<String, dynamic>> razorPayApi(
      num amount,
      String receiptId,
      ) async {
    try {
      final double finalAmount = amount.toDouble();

      // Convert rupees to paise.
      // ₹588.82 -> 58882 paise
      final int amountInPaise = (finalAmount * 100).round();

      debugPrint('====================================');
      debugPrint('Razorpay Order Creation');
      debugPrint('Amount in rupees: ₹$finalAmount');
      debugPrint('Amount in paise: $amountInPaise');
      debugPrint('Receipt ID: $receiptId');
      debugPrint('====================================');

      final auth = 'Basic ${base64Encode(
        utf8.encode('$razorpayKey:$razorpaySecret'),
      )}';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': auth,
      };

      final request = http.Request(
        'POST',
        Uri.parse('https://api.razorpay.com/v1/orders'),
      );

      request.headers.addAll(headers);

      request.body = json.encode({
        'amount': amountInPaise,
        'currency': 'INR',
        'receipt': receiptId,
      });

      final http.StreamedResponse response = await request.send();

      final String responseBody =
      await response.stream.bytesToString();

      debugPrint(
        'Razorpay response status: ${response.statusCode}',
      );

      debugPrint(
        'Razorpay response body: $responseBody',
      );

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'body': jsonDecode(responseBody),
        };
      } else {
        return {
          'status': 'fail',
          'statusCode': response.statusCode,
          'message': responseBody.isNotEmpty
              ? responseBody
              : response.reasonPhrase,
        };
      }
    } catch (e, stackTrace) {
      debugPrint('Razorpay order creation error: $e');
      debugPrint('$stackTrace');

      return {
        'status': 'fail',
        'message': e.toString(),
      };
    }
  }

  /// -----------------------------------------------------------
  /// Payment failure API
  /// -----------------------------------------------------------
  Future<Map<String, dynamic>> paymentFailureApi(
      String orderId,
      ) async {
    try {
      final auth = 'Basic ${base64Encode(
        utf8.encode('$razorpayKey:$razorpaySecret'),
      )}';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': auth,
      };

      final request = http.Request(
        'POST',
        Uri.parse(
          'https://api.razorpay.com/v1/payments/$orderId/capture',
        ),
      );

      request.body = json.encode({
        'amount': 0,
        'notes': {
          'reason': 'Payment failed',
        },
      });

      request.headers.addAll(headers);

      final http.StreamedResponse response = await request.send();

      final String responseBody =
      await response.stream.bytesToString();

      debugPrint(
        'Payment failure response: ${response.statusCode}',
      );

      debugPrint(
        'Payment failure body: $responseBody',
      );

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'body': jsonDecode(responseBody),
        };
      } else {
        return {
          'status': 'fail',
          'statusCode': response.statusCode,
          'message': responseBody.isNotEmpty
              ? responseBody
              : response.reasonPhrase,
        };
      }
    } catch (e) {
      debugPrint('Payment failure API error: $e');

      return {
        'status': 'fail',
        'message': e.toString(),
      };
    }
  }

  /// -----------------------------------------------------------
  /// Payment cancellation API
  /// -----------------------------------------------------------
  Future<Map<String, dynamic>> paymentCancellationApi(
      String orderId,
      ) async {
    try {
      final auth = 'Basic ${base64Encode(
        utf8.encode('$razorpayKey:$razorpaySecret'),
      )}';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': auth,
      };

      final request = http.Request(
        'POST',
        Uri.parse(
          'https://api.razorpay.com/v1/payments/$orderId/cancel',
        ),
      );

      request.body = json.encode({
        'cancel_reason': 'Payment cancelled by user',
      });

      request.headers.addAll(headers);

      final http.StreamedResponse response = await request.send();

      final String responseBody =
      await response.stream.bytesToString();

      debugPrint(
        'Payment cancellation response: ${response.statusCode}',
      );

      debugPrint(
        'Payment cancellation body: $responseBody',
      );

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'body': jsonDecode(responseBody),
        };
      } else {
        return {
          'status': 'fail',
          'statusCode': response.statusCode,
          'message': responseBody.isNotEmpty
              ? responseBody
              : response.reasonPhrase,
        };
      }
    } catch (e) {
      debugPrint('Payment cancellation API error: $e');

      return {
        'status': 'fail',
        'message': e.toString(),
      };
    }
  }
}


// ============================================================
// PRIME CUSTOMER PAYMENT SUCCESS
// ============================================================

paymentDoneForBeingPrimeCustomerAPI({
  required String selectedPlanCost,
  required String userFullName,
}) async {
  try {
    // ----------------------------------------------------------
    // Base amount
    // ----------------------------------------------------------

    final double baseAmount =
    selectedPlanCost.isEmpty
        ? 0.0
        : double.tryParse(selectedPlanCost) ?? 0.0;

    // ----------------------------------------------------------
    // GST = 18%
    // ----------------------------------------------------------

    final double gstAmount =
    double.parse(
      (baseAmount * 18 / 100).toStringAsFixed(2),
    );

    // ----------------------------------------------------------
    // Total = Base + GST
    // ----------------------------------------------------------

    final double totalAmount =
    double.parse(
      (baseAmount + gstAmount).toStringAsFixed(2),
    );

    debugPrint('====================================');
    debugPrint('PRIME CUSTOMER PAYMENT');
    debugPrint('Base Amount: ₹$baseAmount');
    debugPrint('GST Amount: ₹$gstAmount');
    debugPrint('Total Amount: ₹$totalAmount');
    debugPrint(
      'Razorpay Amount: ${(totalAmount * 100).round()} paise',
    );
    debugPrint('====================================');

    // ----------------------------------------------------------
    // Subscription end date
    // ----------------------------------------------------------

    final DateTime now = DateTime.now();

    final DateTime subscriptionEndDate =
    now.add(const Duration(days: 365));

    // ----------------------------------------------------------
    // Update user as Prime member
    // ----------------------------------------------------------

    await AuthConnect().updateUser(
      userData: {
        'isUserPrimeMember': true,
        'subscriptionEndDate':
        subscriptionEndDate.toIso8601String(),
      },
      shouldShowMessage: false,
    );

    // ----------------------------------------------------------
    // Send SMS notification
    // ----------------------------------------------------------

    try {
      final smsData = {
        'mobile':
        localUser?.userMobileNumber ?? '0000000000',
        'name': userFullName,
      };

      final smsResponse = await http.post(
        Uri.parse(
          'https://candidoffers.com:3636/api/common/send-payment-success-primecust-sms',
        ),
        body: json.encode(smsData),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
        'SMS notification response: ${smsResponse.body}',
      );
    } catch (err) {
      debugPrint(
        'Failed to send SMS notification: $err',
      );
    }

    // ----------------------------------------------------------
    // Schedule subscription check
    // ----------------------------------------------------------

    await _scheduleSubscriptionCheck(
      subscriptionEndDate,
    );

    // ----------------------------------------------------------
    // Navigate after successful payment
    // ----------------------------------------------------------

    Future.delayed(
      const Duration(seconds: 1),
          () {
        final context = navigatorKey.currentContext;

        if (context == null) {
          debugPrint(
            'Navigation context is null.',
          );
          return;
        }

        Navigator.of(context).pop(true);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) =>
                PrimeCustomerPaymentScreen(
                  // IMPORTANT:
                  // Show actual base amount
                  baseAmount: baseAmount,

                  // IMPORTANT:
                  // Show actual GST
                  gstAmount: gstAmount,

                  // IMPORTANT:
                  // Show actual total including GST
                  totalAmount: totalAmount,
                ),
          ),
              (route) => false,
        );
      },
    );
  } catch (e, stackTrace) {
    debugPrint(
      'Error in paymentDoneForBeingPrimeCustomerAPI: $e',
    );

    debugPrint('$stackTrace');
  }
}


// ============================================================
// SUBSCRIPTION CHECK
// ============================================================

Future<void> _scheduleSubscriptionCheck(
    DateTime endDate,
    ) async {
  try {
    await FirebaseFirestore.instance
        .collection('subscriptionChecks')
        .add({
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'endDate': endDate.toIso8601String(),
      'status': 'pending',
    });

    debugPrint(
      'Subscription check scheduled successfully.',
    );
  } catch (e) {
    debugPrint(
      'Failed to schedule subscription check: $e',
    );
  }
}
