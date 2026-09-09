import 'package:flutter/material.dart';

class ShareRefer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Share & Refer',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Aileron',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.03,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.grey,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x337C7C7C),
                  blurRadius: 25,
                  offset: Offset(0, -10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Replace this Container with your Image widget
                Image.asset(
                  'lib/Images/image2.png', // Replace with your image asset path
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
