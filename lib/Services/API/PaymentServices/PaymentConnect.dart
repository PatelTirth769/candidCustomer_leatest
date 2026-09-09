import 'dart:convert';

import 'package:candid_customer/BottomNavScreen.dart';
import 'package:candid_customer/Screens/PaymentScreens/PrimeCustomerPaymentScreen.dart';
import 'package:candid_customer/Screens/PrimeMembership/PrimeMembershipScreen.dart';
import 'package:candid_customer/Utils/Utils.dart';
import 'package:candid_customer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../AuthServices/AuthConnect.dart';

class PaymentConnect extends GetConnect {
  Future<String> getCustomerFeesApi() async {
    final apiUrl = '${Utils.apiUrl}/getCustomerFees';

    final response = await post(
      apiUrl,
      {},
      headers: await Utils().getHeaders(),
    );

    debugPrint('getCustomerFees status: ${response.statusCode}');
    debugPrint('getCustomerFees body: ${response.body}');

    if (response.statusCode == 200) {
      final fees = response.body['primeCustomerFees'];

      if (fees == null) {
        return '0';
      }

      return fees.toString();
    }

    return '0';
  }

  createPaymentIntent(String amount, String currency, String email) async {
    debugPrint('amount : $amount');
    try {
      var response = await post(
        'https://api.stripe.com/v1/payment_intents',
        {
          'amount': (double.parse(amount) * 100).toInt().toString(),
          'currency': currency,
          'receipt_email': email,
          'description': 'Payment is done by you!'
        },
        contentType: 'application/x-www-form-urlencoded',
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_TEST_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      debugPrint('payment response.body) : ${response.body}');
      return json.decode(json.encode(response.body));
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  paymentDoneForBeingPrimeCustomerAPI(
      {required String selectedPlanCost, required String userFullName}) async {
    await AuthConnect().updateUser(
        userData: {'isUserPrimeMember': true}, shouldShowMessage: false);

    // Send SMS notification
    try {
      var smsData = {
        'mobile': localUser?.userMobileNumber ?? '0000000000', // Replace with actual method to get user phone
        'name': userFullName,
         
      };

      var smsResponse = await post(
        'https://candidoffers.com:3636/api/common/send-payment-success-primecust-sms',
        smsData,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('SMS notification response: ${smsResponse.body}');
    } catch (err) {
      debugPrint('Failed to send SMS notification: $err');
    }

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(navigatorKey.currentContext!)
          .pop(true); // Return to the current screen
      Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => PrimeCustomerPaymentScreen(
            baseAmount: double.parse(selectedPlanCost),
            gstAmount: double.parse(selectedPlanCost),
            totalAmount: double.parse(selectedPlanCost),
          ),
        ),
        (route) => false,
      );
    });
  }
}
