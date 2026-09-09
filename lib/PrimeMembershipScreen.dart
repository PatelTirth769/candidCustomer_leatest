import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import '../../BottomNavScreen.dart';
import '../../main.dart'; // localUser access करने के लिए

class PrimeMembershipScreen extends StatelessWidget {
  const PrimeMembershipScreen({Key? key}) : super(key: key);

  // --- प्राइम ग्राहक के लिए लाभों की सूची ---
  final List<Map<String, dynamic>> primeBenefits = const [
    {'icon': Icons.flash_on, 'title': 'Speed & Priority', 'subtitle': 'Faster service and priority access.'},
    {'icon': Icons.discount, 'title': 'Exclusive Discounts', 'subtitle': 'Special deals available only to Prime members.'},
    {'icon': Icons.support_agent, 'title': 'Dedicated Support', 'subtitle': '24/7 priority customer assistance.'},
    {'icon': Icons.redeem, 'title': 'Reward Multiplier', 'subtitle': 'Earn double rewards on every transaction.'},
  ];

  @override
  Widget build(BuildContext context) {
    // ग्राहक का पूरा नाम प्राप्त करें (यदि उपलब्ध हो)
    final String userName =
    '${localUser?.userFirstName ?? ''} ${localUser?.userLastName ?? ''}'.trim();
    final String greetingName = userName.isNotEmpty ? userName : 'Valued Customer';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Prime Member',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            // उपयोगकर्ता को वापस मुख्य नेविगेशन स्क्रीन पर भेजें
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const BottomNavScreen()),
                  (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ------------------ 🎉 Welcome Header ------------------
              _buildWelcomeCard(greetingName),
              SizedBox(height: 4.h),

              // ------------------ 🎁 Benefits Section Title ------------------
              Text(
                'Your Prime Benefits Are Active!',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),

              // ------------------ 🌟 Benefits Grid/List ------------------
              ...primeBenefits.map((benefit) => _buildBenefitTile(benefit)).toList(),
              SizedBox(height: 4.h),

              // ------------------ ✅ Action Button ------------------
              SizedBox(
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () {
                    // ग्राहक को होम स्क्रीन या मुख्य ऐप डैशबोर्ड पर भेजें
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const BottomNavScreen()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Using Prime Benefits',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Welcome Card Widget ---
  Widget _buildWelcomeCard(String name) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3498DB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium, // Prime icon
            color: Colors.amber,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'Welcome, $name!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your Prime Membership is now **Active**.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // --- Benefit Tile Widget ---
  Widget _buildBenefitTile(Map<String, dynamic> benefit) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              benefit['icon'] as IconData,
              color: Colors.blue[700],
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit['title'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  benefit['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
