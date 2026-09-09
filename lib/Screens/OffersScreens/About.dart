import 'package:candid_customer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizer/sizer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      backgroundColor: Colors.white,
      appBar:  AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'About Us',
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
      body:
      SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20.h,
                width: double.infinity,
                child: SvgPicture.asset(
                  'lib/Images/Group 366.svg',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 3.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildInfoText(
                      '* Candid offers are a unique take on the e-commerce ecosystem unlike the existing business models.',
                    ),
                    SizedBox(height: 2.h),
                    _buildInfoText(
                      '* It is a consumer-facing platform which operates with a chain of neighborhood stores, specialty stores, services, or any business offerings of all kinds of products and services.',
                    ),
                    SizedBox(height: 2.h),
                    _buildInfoText(
                      '* It aims to democratize access to the best deals and offers on a variety of products and services across diverse segments for Indian consumers.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              GestureDetector(
                onTap: () => _launchURL('https://candidoffers.com'),
                child:   Text(
                  'Visit our website: candidoffers.com',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
                Text(
                'Follow us on:',
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(
                    Icons.facebook,
                    'https://www.facebook.com/your_facebook',
                    Colors.blueAccent,
                  ),
                  SizedBox(width: 3.w),
                  _buildSocialIcon(
                    Icons.email,
                    'mailto:support@candidoffers.com',
                    Colors.redAccent,
                  ),
                  
                  // Add more social icons here if needed
                ],
              ),
              SizedBox(height: 2.h),
                          myWidgets.getCandidBranding(),
                          SizedBox(height: 2.h),
              //  SizedBox(height: 2.h),
              //        myWidgets.getCandidBranding(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style:   GoogleFonts.workSans(
        fontWeight: FontWeight.w500,
        fontSize: 15,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url, Color color) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: color.withOpacity(0.2),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}
