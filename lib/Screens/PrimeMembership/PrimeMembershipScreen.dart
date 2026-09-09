import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Services/API/PaymentServices/PaymentConnect.dart';
import '../../main.dart';
import '../PaymentScreens/PrimeCustomerPaymentScreen.dart';

class PrimeMembership extends StatefulWidget {
  const PrimeMembership({super.key});

  @override
  State<PrimeMembership> createState() => _PrimeMembershipState();
}

class _PrimeMembershipState extends State<PrimeMembership> {
  String referralCode = '';
  String primeCustomerCost = '0'; // Default value
  double baseAmount = 0.0;
  double gstAmount = 0.0;
  double totalAmount = 0.0;
  bool isLoading = true;
  final double gstPercentage = 18.0;
  // चेक करें कि यूजर प्राइम मेंबर है या नहीं (बार-बार चेक करने के लिए)
  bool get isPrimeMember => localUser?.isUserPrimeMember == true;

  @override
  void initState() {
    super.initState();
    // Fees तभी लोड करें जब यूजर प्राइम मेंबर न हो
    if (!isPrimeMember) {
      _loadCustomerFees();
    } else {
      // अगर प्राइम मेंबर है, तो लोडिंग बंद करें
      isLoading = false;
    }
    _refreshUserData();
  }

  Future<void> _loadCustomerFees() async {
    try {
      String response = await PaymentConnect().getCustomerFeesApi();

      primeCustomerCost = response.trim();

      if (primeCustomerCost.isNotEmpty) {
        primeCustomerCost = primeCustomerCost.replaceAll(RegExp(r'[^\d.]'), '');
        baseAmount = double.tryParse(primeCustomerCost) ?? 0.0;

        gstAmount = (baseAmount * gstPercentage) / 100;
        totalAmount = baseAmount + gstAmount;

        debugPrint('Base Amount: $baseAmount');
        debugPrint('GST Amount: $gstAmount');
        debugPrint('Total Amount: $totalAmount');
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading customer fees: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshUserData() async {
    await utils.refreshUser(); // Refresh local user data
    // UI को अपडेट करने के लिए setState कॉल करें अगर localUser अपडेट हुआ है
    if (mounted) {
      setState(() {});
    }
  }

  // Modified Pricing Card
  Widget buildPricingCard() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // Refresh user data before checking
            await utils.refreshUser();

            if (baseAmount <= 0) {
              Fluttertoast.showToast(
                msg: 'Invalid amount. Please try again later.',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrimeCustomerPaymentScreen(
                  baseAmount: baseAmount,
                  gstAmount: gstAmount,
                  totalAmount: totalAmount,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prime Membership',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Annual subscription',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    // Arrow Icon
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black87,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Price breakdown
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Base Amount:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '₹ ${baseAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GST (18%):',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '₹ ${gstAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDB2020),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '₹ ${totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // चेक करें कि यूजर प्राइम मेंबर है या नहीं
    final bool isPrime = isPrimeMember;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:   Text(
          isPrime ? 'Prime Member Details' : 'Become Prime Member',
          style: GoogleFonts.workSans(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero Section
                _buildHeroSection(isPrime),

                // Success Message OR Benefits Section
                if (isPrime)
                // 1. अगर प्राइम मेंबर है: सक्सेस मैसेज दिखाएं
                  _buildPrimeMemberSuccessMessage()
                else
                // 2. अगर प्राइम मेंबर नहीं है: बेनिफिट्स दिखाएं
                  _buildBenefitsSection(),

                // Pricing Card (सिर्फ तभी दिखाएं जब प्राइम न हो)
                if (!isPrime)
                  buildPricingCard(),

                SizedBox(height: 2.h),
                myWidgets.getCandidBranding(),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UPDATED: Hero Section (प्राइम स्टेटस के अनुसार रंग/टेक्स्ट बदलता है) ---
  Widget _buildHeroSection(bool isPrime) {
    Color heroColor = isPrime ? Colors.green : const Color(0xFFDB2020);
    String title = isPrime ? 'You are all set!' : 'Unlock Premium Benefits';
    String subtitle = isPrime ? 'Your Prime membership is active.' : 'Exclusive deals and perks await you';

    return Container(
      height: 25.h,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Image/Color with fallback
            Container(
              color: heroColor,
              child: Image.asset(
                'lib/Images/image2.png', // Fallback
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: heroColor,
                    child: Center(
                      child: Icon(
                        Icons.card_membership,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Text content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.workSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: GoogleFonts.workSans(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- प्राइम मेंबरशिप सक्सेस मैसेज (नया विजेट) ---
  Widget _buildPrimeMemberSuccessMessage() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_user,
            color: Colors.green,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Congratulations! You are a Prime Member',
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thank you for joining. Enjoy exclusive deals, discounts, and VIP perks across all categories.',
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
  // --- END SUCCESS MESSAGE ---

  // --- बेनिफिट्स सेक्शन (केवल प्राइम न होने पर) ---
  Widget _buildBenefitsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBenefitTile(
            icon: Icons.star,
            title: 'Exclusive Prime Deals',
            subtitle:
            'Access extra discounts across all categories',
            color: Colors.amber,
          ),
          const Divider(height: 1),
          _buildBenefitTile(
            icon: Icons.savings,
            title: 'Premium Savings',
            subtitle:
            'Enjoy exclusive savings on a wide range of products',
            color: Colors.green,
          ),
          const Divider(height: 1),
          _buildBenefitTile(
            icon: Icons.diamond,
            title: 'VIP Perks',
            subtitle: 'Get special access to limited-time offers',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:   GoogleFonts.workSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.workSans(
                    fontSize: 14,
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
