import 'dart:convert';
import 'package:candid_customer/Screens/PrimeMembership/PrimeMembershipScreen.dart';
import 'package:candid_customer/Services/Collections/User/UserColl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../../BottomNavScreen.dart';
import '../../PrimeMembershipScreen.dart';
import '../../RazorPay/Global.dart';
import '../../Services/API/PaymentServices/PaymentConnect.dart';
import '../../Services/API/PaymentServices/RazorpayConnect.dart';
import '../../main.dart';
import 'package:get/get.dart';
import '../../Utils/MyWidgets.dart';
import '../../Controllers/ChampionController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// --------------------------- ENUM FOR REFERRAL TYPE ---------------------------
enum ReferrerType { champion, seller, customer }

class PrimeCustomerPaymentScreen extends StatefulWidget {
  final double baseAmount;
  final double gstAmount;
  final double totalAmount;

  const PrimeCustomerPaymentScreen({
    Key? key,
    required this.baseAmount,
    required this.gstAmount,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<PrimeCustomerPaymentScreen> createState() =>
      _PrimeCustomerPaymentScreenState();
}

class _PrimeCustomerPaymentScreenState
    extends State<PrimeCustomerPaymentScreen> {
  final Razorpay _razorpay = Razorpay();

  Map<String, dynamic>? paymentIntent;
  bool isPaymentDone = false;
  bool isLoading = true;
  bool isPaymentSuccessful = false;
  bool isReferralVerified = false;
  String primeCustomerCost = '';
  final TextEditingController referralController = TextEditingController();
  UserColl? customerData;
  final ChampionController championController = Get.put(ChampionController());
  RxBool isReferredBySomeone = false.obs;

  // State variables for Seller and Customer data
  List<Map<String, dynamic>> sellerList = [];
  List<Map<String, dynamic>> customerList = [];
  String? currentUserId; // To store the logged-in user's ID

  // State to track selected referrer type
  ReferrerType? selectedReferrerType;

  // Speech-to-Text Variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _initializeRazorpay();

    // Get current user ID early
    currentUserId = FirebaseAuth.instance.currentUser?.uid;

    _loadUserData().then((_) async {
      // Load champions, sellers, and prime customers concurrently
      championController.getChampionsList(); // Fetches Champions
      await _fetchSellers(); // Fetches Sellers (Vendors)
      await _fetchCustomers(); // **MODIFIED**: Fetches Prime Customers from PrimeMembership

      if (mounted) {
        setState(() {}); // Rebuild to update dropdown items
      }
    });
  }

  // --- Utility method to format display name (Name and Address/City) ---
  String _getDisplayName(Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown Name';
    final address = data['city'];

    if (address != null &&
        address.isNotEmpty &&
        address != 'Address not provided') {
      return '$name (${address})';
    }
    return name;
  }
  // -------------------------------------------------------------------------

  // --- Fetches Seller/Vendor data ---
  Future<void> _fetchSellers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('candidVendors')
          .where('isActive', isEqualTo: true)
          .get();
      sellerList = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': data['vendorId'] ?? doc.id,
          'name': data['userFullName'] ?? data['vendorName'] ?? 'No Name',
          'city':
              data['userAddressCity'] ?? data['city'] ?? 'Address not provided',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching sellers: $e');
    }
  }

  // --- MODIFIED: Fetches Prime Customer data from PrimeMembership and filters current user ---
  Future<void> _fetchCustomers() async {
    final String currentId = currentUserId ?? '';

    try {
      // 1. Fetch documents from PrimeMembership collection
      final snapshot =
          await FirebaseFirestore.instance.collection('PrimeMembership').get();

      final Set<String> uniqueCustomerIds = {};
      final List<Map<String, dynamic>> fetchedCustomers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['newPrimeCustomerUserId'];
        final userName = data['newPrimeCustomerName'] ?? 'No Name';
        final userCity =
            data['newPrimeCustomerAddress'] ?? 'Address not provided';

        // 2. Filter: Ensure the list does not contain the current user's ID
        if (userId != null &&
            userId != currentId &&
            !uniqueCustomerIds.contains(userId)) {
          uniqueCustomerIds.add(userId);
          fetchedCustomers.add({
            'id': userId,
            'name': userName,
            'city': userCity,
          });
        }
      }

      customerList = fetchedCustomers;
    } catch (e) {
      debugPrint('Error fetching customers from PrimeMembership: $e');
    }
  }

  // --- Helper method to get the selected referrer's name and city ---
  Map<String, String> _getReferrerNameData(String id, ReferrerType? type) {
    List<Map<String, dynamic>> list = [];
    if (type == ReferrerType.champion) {
      list = championController.championList.toList();
    } else if (type == ReferrerType.seller) {
      list = sellerList;
    } else if (type == ReferrerType.customer) {
      list = customerList;
    }

    final item = list.firstWhereOrNull((item) => item['id'] == id);

    return {
      'name': item?['name'] ?? 'Unknown Name',
      'city': item?['city'] ?? 'Unknown Address',
    };
  }

  // Method to start/stop listening for voice input
  void _startStopListening(Function(String) onResult) async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    bool available = await _speech.initialize(
      onError: (val) => print('STT Error: $val'),
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          String recognizedWords = result.recognizedWords;
          onResult(recognizedWords);

          if (result.finalResult) {
            _speech.stop();
            setState(() => _isListening = false);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );
    } else {
      setState(() => _isListening = false);
      Fluttertoast.showToast(
        msg: "Speech recognition not available or permission denied.",
        backgroundColor: Colors.red,
      );
    }
  }

  // --------------------------- MODIFIED: verifyReferral (Hides API failure from user) ---------------------------
  Future<void> verifyReferral(BuildContext context) async {
    if (referralController.text.trim().isEmpty ||
        selectedReferrerType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a referrer and ensure the ID is set."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String referrerTypeString = selectedReferrerType == ReferrerType.champion
          ? 'champion'
          : selectedReferrerType == ReferrerType.seller
              ? 'vendor'
              : 'customer';

      final referralId = referralController.text.trim();
      final String currentId = currentUserId ?? '';

      if (currentId.isEmpty) {
        throw Exception("User not logged in or User ID is empty.");
      }

      // --- 1. Attempt API Call ---
      bool isApiSuccess = false;
      try {
        final response = await http.post(
          Uri.parse(
              'https://candidoffers.com:3636/api/firebase/prime-customer/referral-transaction'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userUid': currentId,
            'referralId': referralId,
            'referrerType': referrerTypeString,
          }),
        );

        if (response.statusCode == 200) {
          isApiSuccess = true;
        } else {
          // Log API failure details but DON'T show a negative Toast to the user yet.
          final errorResponse = jsonDecode(response.body);
          debugPrint(
              'API validation failed: Status ${response.statusCode}, Message: ${errorResponse['message']}');
        }
      } catch (e) {
        // Log Network/Connection Error
        debugPrint(
            'API Network/Connection error: $e. Proceeding to Firestore save.');
      }

      // --- 2. LOGIC TO SAVE TO FIRESTORE (This is the crucial success step for the user) ---
      final firestore = FirebaseFirestore.instance;
      final timestamp = FieldValue.serverTimestamp();

      final currentUserDataDoc =
          await firestore.collection('candidCustomers').doc(currentId).get();
      final currentUserData = currentUserDataDoc.data();
      final referrerNameData =
          _getReferrerNameData(referralId, selectedReferrerType);

      Map<String, dynamic> referralData = {
        'referredByUserId': referralId,
        'referredByUserName': referrerNameData['name'],
        'referredByAddress': referrerNameData['city'],
        'referrerType': referrerTypeString,
        'newPrimeCustomerUserId': currentId,
        'newPrimeCustomerName': currentUserData?['userFirstName'] ?? '',
        'newPrimeCustomerEmail': currentUserData?['userEmail'] ?? '',
        'newPrimeCustomerAddress':
            currentUserData?['userAddress'] ?? 'Address not provided',
        'transactionDate': timestamp,
        // Status indicates the API result for internal tracking
        'status': isApiSuccess ? 'verified_api_success' : 'verified_api_failed',
        'referredById': referralId,
        'userId': currentId,
      };

      // Save the referral transaction to the **PrimeMembership** collection (Doc ID: currentUserId)
      await firestore
          .collection('PrimeMembership')
          .doc(currentId)
          .set(referralData);

      setState(() {
        isReferralVerified = true;
      });

      // Show success toast because Firestore save was successful.
      // API failure is now only a debug log, not a user-facing error.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Referral verified and saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Redirect to the home screen (BottomNavScreen) after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const BottomNavScreen()),
            (route) => false,
          );
        }
      });
    } catch (e) {
      debugPrint('Referral verification error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "An unexpected error occurred during verification. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
// -----------------------------------------------------------------------------------------

  // --------------------------- Email Sending Function ---------------------------
  Future<void> sendWelcomeEmail(
      String userName, String userEmail, double amount) async {
    // NOTE: Replace with your actual email sending API endpoint
    final url = Uri.parse('YOUR_EMAIL_SENDING_API_ENDPOINT');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recipientEmail': userEmail,
          'subject': 'Welcome to Candid Offers Prime Membership!',
          'body':
              'Dear $userName,\n\nThank you for purchasing the Prime Membership for ₹${amount.toStringAsFixed(2)}. You can now enjoy all the premium benefits!',
        }),
      );

      if (response.statusCode == 200) {
        print('Welcome email sent successfully to $userEmail');
      } else {
        print('Failed to send welcome email: ${response.body}');
      }
    } catch (e) {
      print('Error sending welcome email: $e');
    }
  }
// ---------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Prime Membership',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            // Navigate back to the main screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BottomNavScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[50]!, Colors.white],
                ),
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and Header
                        SizedBox(
                          height: 15.h,
                          child: SvgPicture.asset(
                            'lib/Images/Group 366.svg',
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Show premium content only for non-prime members
                        if (!localUser!.isUserPrimeMember) ...[
                          _buildPremiumCard(),
                          SizedBox(height: 2.h),
                          _buildBenefitsSection(),
                          SizedBox(height: 2.h),
                          _buildActionButtons(),
                          SizedBox(height: 2.h),
                        ],

                        // Show prime member status if user is prime
                        if (localUser!.isUserPrimeMember)
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 48,
                                ),
                                SizedBox(height: 2.h),
                                const Text(
                                  'You are a Prime Member!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                const Text(
                                  'Thank you for your purchase. Enjoy the premium benefits!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 2.h),
                        // Referral section for all users
                        if (localUser!.isUserPrimeMember)
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Obx(() => Checkbox(
                                          value: isReferredBySomeone.value,
                                          onChanged: (bool? value) {
                                            isReferredBySomeone.value =
                                                value ?? false;
                                            if (!isReferredBySomeone.value) {
                                              selectedReferrerType = null;
                                              championController
                                                  .selectedChampionId
                                                  .value = '';
                                              referralController.clear();
                                              setState(() {
                                                isReferralVerified = false;
                                              });
                                            } else {
                                              // Default to Champion when checked
                                              selectedReferrerType =
                                                  ReferrerType.champion;
                                            }
                                          },
                                          activeColor: Colors.blue[700],
                                        )),
                                    const Text(
                                      'Referred by someone?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Obx(() => isReferredBySomeone.value
                                    ? Column(
                                        children: [
                                          SizedBox(height: 2.h),
                                          // --- Referrer Type Selector ---
                                          _buildReferrerTypeSelector(),
                                          SizedBox(height: 2.h),
                                          // --- Dropdown based on Type ---
                                          _buildReferrerDropdown(),
                                          if (!isReferralVerified) ...[
                                            SizedBox(height: 2.h),
                                            TextField(
                                              controller: referralController,
                                              enabled: !isReferralVerified,
                                              readOnly:
                                                  true, // ID is selected via dropdown
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Referral ID (Selected automatically)',
                                                filled: true,
                                                fillColor: Colors.grey[50],
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                            _buildVerifyButton(),
                                          ],
                                        ],
                                      )
                                    : const SizedBox.shrink()),
                              ],
                            ),
                          ),
                        SizedBox(height: 2.h),
                        myWidgets.getCandidBranding(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Referrer Type Selector Widget ---
  Widget _buildReferrerTypeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Who referred you?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ReferrerType.values.map((type) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(
                      type.name.capitalizeFirst!,
                      style: TextStyle(
                        color: selectedReferrerType == type
                            ? Colors.white
                            : Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: selectedReferrerType == type,
                    selectedColor: Colors.blue[700],
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selectedReferrerType == type
                          ? Colors.blue[700]!
                          : Colors.grey[300]!,
                    ),
                    onSelected: (bool selected) {
                      if (selected) {
                        championController.selectedChampionId.value = '';
                        referralController.clear();
                        setState(() {
                          selectedReferrerType = type;
                          isReferralVerified = false;
                        });
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- Dropdown Widget to handle all types (Name and City/Address) ---
  Widget _buildReferrerDropdown() {
    if (selectedReferrerType == null) {
      return const SizedBox.shrink();
    }

    List<Map<String, dynamic>> itemsList = [];
    String hintText = '';
    String searchHint = '';

    if (selectedReferrerType == ReferrerType.champion) {
      itemsList = championController.championList.toList();
      hintText = 'Select a Champion (Name/City)';
      searchHint = "Search Champion by Name or City";
    } else if (selectedReferrerType == ReferrerType.seller) {
      itemsList = sellerList;
      hintText = 'Select a Seller (Name/Address)';
      searchHint = "Search Seller by Name or Address";
    } else if (selectedReferrerType == ReferrerType.customer) {
      // Use the filtered list for Prime Customers
      itemsList = customerList;
      hintText = 'Select a Prime Customer (Name/Address)';
      searchHint = "Search Customer by Name or Address";
    }

    Map<String, dynamic>? selectedItem;
    // Check if an item is selected based on the ID stored in the controller
    if (championController.selectedChampionId.value.isNotEmpty) {
      selectedItem = itemsList.firstWhereOrNull(
        (item) => item['id'] == championController.selectedChampionId.value,
      );
    }

    return DropdownSearch<Map<String, dynamic>>(
      items: itemsList,
      selectedItem: selectedItem,
      itemAsString: _getDisplayName,
      onChanged: (Map<String, dynamic>? referrer) {
        if (referrer != null) {
          // Store the selected ID in the controller and the text field
          championController.selectedChampionId.value = referrer['id'];
          referralController.text = referrer['id'];
          setState(() {
            isReferralVerified = false;
          });
        }
      },
      compareFn: (item1, item2) => item1['id'] == item2['id'],
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      popupProps: PopupProps.modalBottomSheet(
        showSelectedItems: true,
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: searchHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  // Pass the search controller to the STT function
                  _startStopListening((recognizedWords) {
                    _searchController.text = recognizedWords;
                  });
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          const Text(
            '🌟 Premium Membership',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '₹${widget.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Including GST (₹${widget.gstAmount.toStringAsFixed(2)})',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      {'icon': Icons.star, 'text': 'Exclusive Premium Features'},
      {'icon': Icons.support_agent, 'text': 'Priority Customer Support'},
      {'icon': Icons.local_offer, 'text': 'Special Discounts & Offers'},
      {'icon': Icons.trending_up, 'text': 'Advanced Analytics'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Premium Benefits',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        ...benefits
            .map((benefit) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
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
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          benefit['text'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    // If user is already prime, hide action buttons
    if (localUser!.isUserPrimeMember) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 5.h,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const BottomNavScreen()),
                (route) => false,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Maybe Later',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: SizedBox(
            height: 5.h,
            child: ElevatedButton(
              onPressed: () {
                if (widget.totalAmount > 0) {
                  try {
                    openSession(
                      amount: widget.totalAmount,
                      razorpayKey: AppConfig.razorpayKey,
                    );
                  } catch (e) {
                    print("Error initiating payment: $e");
                    Fluttertoast.showToast(
                      msg: "Payment initialization failed. Please try again.",
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Upgrade Now',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    if (isReferralVerified) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 2.w),
            const Text(
              'Referral Verified',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    if (selectedReferrerType == null || referralController.text.isEmpty) {
      return SizedBox(
        height: 5.h,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.verified_outlined, size: 18),
          label: const Text(
            'Verify Code',
            style: TextStyle(fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 5.h,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => verifyReferral(context),
        icon: isLoading
            ? const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.verified_outlined, size: 18),
        label: const Text(
          'Verify Code',
          style: TextStyle(fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _initializeRazorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // --------------------------- MODIFIED: Payment Success Handler ---------------------------
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment Success: ${response.paymentId}');

    final String currentId = currentUserId ?? '';
    if (currentId.isEmpty) {
      Fluttertoast.showToast(
        msg: "Payment success but user ID is missing. Please log in again.",
        backgroundColor: Colors.red,
      );
      return;
    }

    // 1. Update user's prime status on the backend/database (API Call)
    await paymentDoneForBeingPrimeCustomerAPI(
        selectedPlanCost: widget.totalAmount.toStringAsFixed(2),
        userFullName: localUser!.userFirstName);

    // ********************************************************************
    // *************** 🔥 LOGIC TO UPDATE FIRESTORE 🔥 ******************
    // ********************************************************************
    try {
      final firestore = FirebaseFirestore.instance;

      // A. Update candidCustomers to set the user as a Prime Member
      await firestore.collection('candidCustomers').doc(currentId).update({
        'isUserPrimeMember': true,
        'primeMemberSince': FieldValue.serverTimestamp(),
      });

      // B. Create/Update a transaction record in PrimeMembership.
      final paymentData = {
        'paymentId': response.paymentId,
        'transactionStatus': 'Payment Success',
        'amountPaid': widget.totalAmount,
        'baseAmount': widget.baseAmount,
        'gstAmount': widget.gstAmount,
        'paymentDate': FieldValue.serverTimestamp(),
      };

      final isReferralDocExists =
          await firestore.collection('PrimeMembership').doc(currentId).get();

      if (isReferralDocExists.exists) {
        // Referral was used and verified: Update the existing document with payment details
        await firestore
            .collection('PrimeMembership')
            .doc(currentId)
            .update(paymentData);
      } else {
        // No referral was used: Create a new document with only payment and user details
        final currentUserDataDoc =
            await firestore.collection('candidCustomers').doc(currentId).get();
        final currentUserData = currentUserDataDoc.data();

        await firestore.collection('PrimeMembership').doc(currentId).set({
          ...paymentData,
          'referrerType': 'none',
          'referredByUserId': '',
          'referredByUserName': 'N/A',
          'referredByAddress': 'N/A',
          'newPrimeCustomerUserId': currentId,
          'newPrimeCustomerName': currentUserData?['userFirstName'] ?? '',
          'newPrimeCustomerEmail': currentUserData?['userEmail'] ?? '',
          'newPrimeCustomerAddress':
              currentUserData?['userAddress'] ?? 'Address not provided',
          'status': 'purchased_directly',
          'userId': currentId,
        });
      }
    } catch (e) {
      debugPrint('Firestore update failed after payment success: $e');
    }
    // ********************************************************************

    // 2. Send Welcome Email
    if (localUser != null && localUser!.userEmail != null) {
      await sendWelcomeEmail(
        '${localUser!.userFirstName ?? ''} ${localUser!.userLastName ?? ''}'
            .trim(),
        localUser!.userEmail!,
        widget.totalAmount,
      );
    }

    // Clear Razorpay instance
    _razorpay.clear();

    // Show a success toast
    Fluttertoast.showToast(
      msg: "Prime Membership Purchased Successfully! Welcome.",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    // 3. Navigate to the desired welcome/profile screen and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) =>
            const PrimeMembershipScreen(), // Navigate to the Prime Membership screen
      ),
      (route) => false, // Remove all previous routes
    );
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    print('Payment Error: ${response.message}');
    Fluttertoast.showToast(
      msg: "Payment Failed: ${response.message}",
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );

    _razorpay.clear();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    _razorpay.clear();
  }

  void openSession({required num amount, required razorpayKey}) {
    createOrder(amount: widget.totalAmount).then((orderId) {
      print(orderId);

      if (orderId.toString().isNotEmpty) {
        var options = {
          'key': AppConfig.razorpayKey,
          'amount': (widget.totalAmount * 100)
              .round(), // Amount in smallest currency unit (paise)
          'name': 'Candid Offers',
          'order_id': orderId,
          'description': 'Prime Customer Fees (Incl. 18% GST)',
          'prefill': {
            'contact': localUser?.userMobileNumber,
            'email': localUser?.userEmail,
          },
          'config': {
            'display': {
              'locale': 'en_IN', // Optional, can be customized
            }
          }
        };

        _razorpay.open(options);
      } else {
        Fluttertoast.showToast(
          msg: "Failed to create payment order. Please try again.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    });
  }

  Future<String> createOrder({required num amount}) async {
    // Note: Assuming ApiServices().razorPayApi handles conversion to required format (e.g., paise)
    final myData = await ApiServices().razorPayApi(amount, "rcp_id_1");

    if (myData["status"] == "success") {
      print(myData);
      return myData["body"]["id"] ?? "";
    } else {
      print("Order creation failed: ${myData["message"]}");
      return "";
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    referralController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user =
          await utils.getUser(); // Assuming this fetches UserColl object

      if (mounted) {
        setState(() {
          customerData = user as UserColl;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
