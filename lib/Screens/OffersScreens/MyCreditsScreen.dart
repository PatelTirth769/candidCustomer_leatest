import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyCreditsScreen extends StatefulWidget {
  @override
  _MyCreditsScreenState createState() => _MyCreditsScreenState();
}

class _MyCreditsScreenState extends State<MyCreditsScreen> {
  int referredCount = 0; // How many times referral shared
  int membershipCount = 0; // NEW: How many purchased membership via my referral

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadReferredCount();
    _loadMembershipCount();
  }

  // --------------------------- OLD: Load referredCount from candidCustomers ---------------------------
  Future<void> _loadReferredCount() async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('candidCustomers').doc(userId);
      final doc = await userDoc.get();
      final referralDetails = doc.get('referralDetails');

      final referredCountString = referralDetails['referredCount'] ?? '0';
      final referredCountInt = int.tryParse(referredCountString) ?? 0;

      setState(() {
        referredCount = referredCountInt;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  // -------------------------------------- NEW: Load membership purchased count -------------------------
  Future<void> _loadMembershipCount() async {
    try {
      // Count users in PrimeMembership collection who used my referral
      final snap = await FirebaseFirestore.instance
          .collection("PrimeMembership")
          .where("referredById", isEqualTo: userId)
          .get();

      setState(() {
        membershipCount = snap.docs.length;
      });
    } catch (e) {
      print("Error loading membership count: $e");
    }
  }

  // -------------------------------------- SHARE BUTTON --------------------------------------
  void _shareUserId() async {
    const appLink =
        'https://play.google.com/store/apps/details?id=com.customer.candid.candid_customer';

    final message =
        'Check out CandidCustomer App! Use my referral ID: $userId.\nDownload now: $appLink';

    final url = 'https://wa.me/?text=${Uri.encodeComponent(message)}';

    if (await canLaunch(url)) {
      await launch(url);
      Fluttertoast.showToast(msg: 'Shared the app link successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Could not launch WhatsApp');
    }
  }

  // -------------------------------------- UI START --------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Refer and Earn',
          style: TextStyle(
            fontFamily: 'Aileron',
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [

                  // TOP IMAGE + COUNTS
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 35.h,
                        width: 60.w,
                        padding: EdgeInsets.only(top: 6.h),
                        child: SvgPicture.asset(
                          'lib/Images/Group 7044.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'Your Shares: ${referredCount + membershipCount}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // OFFER BOX
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('lib/Images/Vector (2).png'),
                      Text(
                        'Share with 12 customers \nand get One Year Prime Membership Free.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // REFERRAL PROGRAM CARD
                  Card(
                    margin: const EdgeInsets.all(0),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Referral Program',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Share Referral Id: $userId',
                                  style: TextStyle(fontSize: 11.sp),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: _shareUserId,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: userId));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Referral ID copied to clipboard'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          const Text(
                            'Terms and Conditions Apply\n'
                                'Share Referral ID with others. When someone uses Referral ID to become a prime member, you will get credit.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),
                  myWidgets.getCandidBranding(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
