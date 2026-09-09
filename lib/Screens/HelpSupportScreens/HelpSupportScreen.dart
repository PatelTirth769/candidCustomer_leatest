import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({Key? key}) : super(key: key);

  // Function to launch email
  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@candidoffers.com',
      queryParameters: {
        'subject': 'Support Request for Candid Offers App',
      },
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      // Show error if email can't be launched
      _showErrorDialog();
    }
  }

  // Function to show error dialog
  void _showErrorDialog() {
    // Implement a dialog to show email launch error
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 15.h,
            backgroundColor: Colors.white,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Help & Support',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              centerTitle: true,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Main Content
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Support Information Card
                _buildSupportInfoCard(),

                SizedBox(height: 2.h),

                // Contact Methods
                _buildContactMethodsSection(context),

                SizedBox(height: 2.h),

                // FAQs Section
               ]),
            ),
          ),
        ],
      ),
    );
  }

  // Support Information Card
  Widget _buildSupportInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We\'re Here to Help!',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Our support team is dedicated to providing you with the best assistance. Whether you have a question, concern, or suggestion, we\'re just a message away.',
            style: GoogleFonts.openSans(
              fontSize: 10.sp,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // Contact Methods Section
  Widget _buildContactMethodsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Methods',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),

          // Email Contact
          _buildContactMethod(
            icon: Icons.mail_rounded,   // ✅ Email Icon Added
            title: 'Email Support',
            subtitle: 'support@candidoffers.com',
            onTap: _launchEmail,
          ),

          // Phone Support (Optional)
          _buildContactMethod(
            icon: Icons.phone_rounded,  // ✅ Phone Icon Added
            title: 'Phone Support',
            subtitle: '+91 93598 42355',
            onTap: () {
              // Implement phone launch functionality
              launch('tel:++919359842355');
            },
          ),
        ],
      ),
    );
  }

  // Contact Method Item
  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.blue.shade600,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.openSans(
          fontSize: 9.sp,
          color: Colors.black54,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.send_rounded,
          color: Colors.blue.shade600,
        ),
        onPressed: onTap,
      ),
    );
  }

  // FAQs Section

  // FAQ Item
  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      childrenPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      children: [
        Text(
          answer,
          style: GoogleFonts.openSans(
            fontSize: 9.sp,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
