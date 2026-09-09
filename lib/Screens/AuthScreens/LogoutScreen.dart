import 'package:candid_customer/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LoginScreen.dart';

class LogoutScreen extends StatefulWidget {
  @override
  _LogoutScreenState createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  bool _isLoggingOut = false;

  Future<void> logOutUser() async {
    try {
      debugPrint('Starting logout process...');

      await firebaseAuth.signOut();
      debugPrint('Firebase signed out successfully.');

      try {
        // await googleSignIn.disconnect();
        // await googleSignIn.signOut();
        debugPrint('Google signed out successfully.');
      } catch (e) {
        debugPrint('logOutUser: GOOGLE SIGN_OUT CATCH: $e');
      }

      await isar.writeTxn(() async {
        await isar.clear();
        debugPrint('Data cleared successfully.');
      });

      await Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
            (route) => false,
      );

      debugPrint('Logout process completed.');
    } catch (e) {
      debugPrint('logOutUser: CATCH: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDB2020), Color(0xFF8F0A0A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center( // Ensures everything is center aligned
          child: Column(
            mainAxisSize: MainAxisSize.min, // Takes only required vertical space
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Click yes to logout!',
                style: GoogleFonts.workSans(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 32.0),
              _isLoggingOut
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                    ),
                    child: Text(
                      'No',
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoggingOut = true;
                      });
                      await logOutUser();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.green,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                    ),
                    child: Text(
                      'Yes',
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
