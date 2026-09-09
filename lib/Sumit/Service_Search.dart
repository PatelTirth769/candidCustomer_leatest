// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../main.dart';
// import 'Product_Search.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
//
// class ServiceHomeScreen extends StatefulWidget {
//   const ServiceHomeScreen({Key? key}) : super(key: key);
//
//   @override
//   _ServiceHomeScreenState createState() => _ServiceHomeScreenState();
// }
//
// class _ServiceHomeScreenState extends State<ServiceHomeScreen> {
//   bool _showAllCategories = false;
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _voiceText = '';
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedCategory = '';
//   List<String> _filteredProducts = [];
//   String _searchQuery = '';
//
//   void _selectCategory(String category) {
//     setState(() {
//       if (_selectedCategory == category && _searchQuery.isEmpty) {
//         _selectedCategory = '';
//         _filteredProducts = [];
//       } else {
//         _selectedCategory = category;
//         _searchQuery = '';
//         _filteredProducts = mainCategories2[category]!;
//       }
//     });
//   }
//
//   void _search(String query) {
//     setState(() {
//       _searchQuery = query;
//       if (query.isEmpty) {
//         if (_selectedCategory.isNotEmpty) {
//           _filteredProducts = mainCategories2[_selectedCategory]!;
//         } else {
//           _filteredProducts = [];
//         }
//       } else {
//         _filteredProducts = mainCategories2.entries
//             .expand((e) => e.value)
//             .where((item) => item.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }
//
//   void _startListening() async {
//     bool available = await _speech.initialize(
//       onStatus: (status) {
//         if (status == 'done' && _isListening) {
//           _stopListening();
//         }
//       },
//       onError: (error) {
//         print('Speech error: $error');
//         setState(() => _isListening = false);
//       },
//     );
//
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(
//         onResult: (result) {
//           setState(() {
//             _voiceText = result.recognizedWords;
//             _searchController.text = _voiceText;
//             _search(_voiceText);
//           });
//
//           if (result.finalResult) {
//             _stopListening(); // Stop automatically when speech is done
//           }
//         },
//         listenMode: stt.ListenMode.dictation,
//         cancelOnError: false,
//         partialResults: true,
//       );
//     }
//   }
//
//   void _stopListening() {
//     _speech.stop();
//     setState(() => _isListening = false);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final allCategories = mainCategories2.keys.toList();
//     final visibleCategories =
//     _showAllCategories ? allCategories : allCategories.take(12).toList();
//
//     return WillPopScope(
//       onWillPop: () async {
//         if (_selectedCategory.isNotEmpty || _searchQuery.isNotEmpty) {
//           setState(() {
//             _selectedCategory = '';
//             _searchQuery = '';
//             _filteredProducts = [];
//             _searchController.clear();
//           });
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         appBar: myWidgets.myAppBar(),
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.orange.shade100, Colors.pink.shade50],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//             ),
//             BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//               child: SafeArea(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 🔍 Search Bar
//                         TextField(
//                           controller: _searchController,
//                           decoration: InputDecoration(
//                             hintText: 'Search services...',
//                             hintStyle: GoogleFonts.workSans(),
//                             prefixIcon: IconButton(
//                               icon: Icon(
//                                 Icons.mic,
//                                 color: _isListening ? Colors.green : Colors.red,
//                               ),
//                               onPressed: () {
//                                 if (_isListening) {
//                                   _stopListening();
//                                 } else {
//                                   _startListening();
//                                 }
//                               },
//                             ),
//                             suffixIcon: GestureDetector(
//                               onTap: () {
//                                 Navigator.pop(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           ProductHomeScreen()),
//                                 );
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.all(3.0),
//                                 child: Image.network(
//                                   'https://www.shutterstock.com/image-vector/swipe-icon-screen-scroll-button-260nw-2122832096.jpg',
//                                   height: 30,
//                                 ),
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white.withOpacity(0.85),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                           onChanged: _search,
//                         ),
//
//                         SizedBox(height: 10),
//
//                         // 🗂 Category Grid (when nothing selected or searched)
//                         if (_searchQuery.isEmpty &&
//                             _selectedCategory.isEmpty) ...[
//                           GridView.count(
//                             crossAxisCount: 2,
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             crossAxisSpacing: 12,
//                             mainAxisSpacing: 12,
//                             childAspectRatio: 2.5,
//                             children: visibleCategories.map((category) {
//                               final isSelected = _selectedCategory == category;
//                               return GestureDetector(
//                                 onTap: () => _selectCategory(category),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black12,
//                                         blurRadius: 4,
//                                         offset: Offset(2, 2),
//                                       ),
//                                     ],
//                                     color: isSelected
//                                         ? Colors.red.shade100.withOpacity(0.9)
//                                         : Colors.white.withOpacity(0.8),
//                                   ),
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 8),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         categoryIcons2[category],
//                                         size: 28,
//                                         color: Colors.red,
//                                       ),
//                                       SizedBox(width: 10),
//                                       Expanded(
//                                         child: Text(
//                                           category,
//                                           style: GoogleFonts.workSans(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w600,
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//
//                           // ⬇️ Centered "More" Button
//                           if (!_showAllCategories)
//                             Padding(
//                               padding:
//                               const EdgeInsets.symmetric(vertical: 12.0),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   TextButton(
//                                     onPressed: () {
//                                       setState(() {
//                                         _showAllCategories = true;
//                                       });
//                                     },
//                                     child: Text(
//                                       'More',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//
//                         // 🔍 No Results Found
//                         if (_searchQuery.isNotEmpty &&
//                             _filteredProducts.isEmpty)
//                           Center(
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 40),
//                               child: Text(
//                                 'No services found',
//                                 style: GoogleFonts.workSans(
//                                   fontSize: 20,
//                                   color: Colors.black54,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                         // 📦 Filtered Service Results
//                         if (_filteredProducts.isNotEmpty)
//                           GridView.builder(
//                             itemCount: _filteredProducts.length,
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             gridDelegate:
//                             SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               childAspectRatio: 0.85,
//                               crossAxisSpacing: 10,
//                               mainAxisSpacing: 10,
//                             ),
//                             itemBuilder: (context, index) {
//                               final product = _filteredProducts[index];
//                               return GlassProductCard(
//                                 icon: serviceIcons2[product] ??
//                                     Icons.miscellaneous_services,
//                                 title: product,
//                                 subtitle: '',
//                               );
//                             },
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class GlassProductCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//
//   const GlassProductCard({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.white.withOpacity(0.8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//             offset: Offset(3, 3),
//           ),
//         ],
//       ),
//       padding: EdgeInsets.all(12),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 48, color: Colors.red),
//           SizedBox(height: 12),
//           Text(
//             title,
//             style: GoogleFonts.workSans(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           // if (subtitle.isNotEmpty)
//           //   Padding(
//           //     padding: const EdgeInsets.only(top: 6.0),
//           //     child: Text(
//           //       subtitle,
//           //       style: GoogleFonts.workSans(
//           //         color: Colors.black,
//           //         fontSize: 12,
//           //       ),
//           //     ),
//           //   ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
// final Map<String, List<String>> mainCategories2 = {
//   'Home Services': ['Electrician', 'Plumber', 'Carpenter', 'Painter'],
//   'Health Services': ['Doctor', 'Nurse', 'Physiotherapist', 'Dentist'],
//   'Education': ['Tutor', 'Coach', 'Music Teacher', 'Yoga Instructor'],
//   'Vehicle Services': [
//     'Mechanic',
//     'Car Wash',
//     'Tyre Repair',
//     'Battery Service'
//   ],
//   'Beauty & Wellness': ['Beautician', 'Hair Stylist', 'Masseuse', 'Spa'],
//   'Repair': ['AC Repair', 'Fridge Repair', 'TV Repair', 'Mobile Repair'],
//   'Cleaning': [
//     'House Cleaning',
//     'Sofa Cleaning',
//     'Water Tank Cleaning',
//     'Pest Control'
//   ],
//   'Delivery': ['Courier', 'Parcel', 'Food Delivery', 'Grocery Delivery'],
//   'Event': ['Photographer', 'DJ', 'Caterer', 'Decorator'],
//   'Security': ['Security Guard', 'Bodyguard', 'Bouncer', 'CCTV Monitor'],
//   'Transportation': ['Driver', 'Taxi Service', 'Auto Rickshaw', 'Bike Taxi'],
//   'Home Appliances': [
//     'Washing Machine Repair',
//     'Microwave Repair',
//     'Geyser Repair',
//     'Chimney Repair'
//   ],
//   'Fitness': [
//     'Personal Trainer',
//     'Gym Trainer',
//     'Zumba Instructor',
//     'Dietician'
//   ],
//   'Legal': ['Lawyer', 'Notary', 'Document Writer', 'Legal Advisor'],
//   'Finance': ['Accountant', 'Tax Consultant', 'Loan Agent', 'Insurance Agent'],
//   'Childcare': ['Babysitter', 'Nanny', 'Daycare', 'Tuition Teacher'],
//   'Elder Care': [
//     'Caregiver',
//     'Old Age Companion',
//     'Walking Assistant',
//     'Medicine Reminder'
//   ],
//   'IT Support': [
//     'Computer Repair',
//     'Software Install',
//     'WiFi Setup',
//     'Printer Setup'
//   ],
//   'Construction': ['Mason', 'Welder', 'Painter', 'Tile Worker'],
//   'Miscellaneous': ['Gardener', 'Laundry', 'Key Maker', 'Pet Walker'],
// };
//
// final Map<String, IconData> categoryIcons2 = {
//   'Home Services': Icons.home_repair_service,
//   'Health Services': Icons.health_and_safety,
//   'Education': Icons.school,
//   'Vehicle Services': Icons.car_repair,
//   'Beauty & Wellness': Icons.spa,
//   'Repair': Icons.build,
//   'Cleaning': Icons.cleaning_services,
//   'Delivery': Icons.local_shipping,
//   'Event': Icons.celebration,
//   'Security': Icons.security,
//   'Transportation': Icons.directions_car,
//   'Home Appliances': Icons.kitchen,
//   'Fitness': Icons.fitness_center,
//   'Legal': Icons.gavel,
//   'Finance': Icons.account_balance,
//   'Childcare': Icons.child_friendly,
//   'Elder Care': Icons.elderly,
//   'IT Support': Icons.computer,
//   'Construction': Icons.construction,
//   'Miscellaneous': Icons.miscellaneous_services,
// };
//
// final Map<String, IconData> serviceIcons2 = {
//   'Electrician': Icons.electrical_services,
//   'Plumber': Icons.plumbing,
//   'Carpenter': Icons.handyman,
//   'Painter': Icons.format_paint,
//   'Doctor': Icons.local_hospital,
//   'Nurse': Icons.healing,
//   'Physiotherapist': Icons.accessibility_new,
//   'Dentist': Icons.medical_services,
//   'Tutor': Icons.menu_book,
//   'Coach': Icons.sports,
//   'Music Teacher': Icons.music_note,
//   'Yoga Instructor': Icons.self_improvement,
//   'Mechanic': Icons.build,
//   'Car Wash': Icons.local_car_wash,
//   'Tyre Repair': Icons.tire_repair,
//   'Battery Service': Icons.battery_charging_full,
//   'Beautician': Icons.face,
//   'Hair Stylist': Icons.cut,
//   'Masseuse': Icons.spa,
//   'Spa': Icons.hot_tub,
//   'AC Repair': Icons.ac_unit,
//   'Fridge Repair': Icons.kitchen,
//   'TV Repair': Icons.tv,
//   'Mobile Repair': Icons.phone_android,
//   'House Cleaning': Icons.cleaning_services,
//   'Sofa Cleaning': Icons.chair,
//   'Water Tank Cleaning': Icons.water_damage,
//   'Pest Control': Icons.bug_report,
//   'Courier': Icons.local_shipping,
//   'Parcel': Icons.inventory,
//   'Food Delivery': Icons.delivery_dining,
//   'Grocery Delivery': Icons.shopping_cart,
//   'Photographer': Icons.camera_alt,
//   'DJ': Icons.audiotrack,
//   'Caterer': Icons.restaurant,
//   'Decorator': Icons.emoji_events,
//   'Security Guard': Icons.security,
//   'Bodyguard': Icons.shield,
//   'Bouncer': Icons.do_not_step,
//   'CCTV Monitor': Icons.videocam,
//   'Driver': Icons.drive_eta,
//   'Taxi Service': Icons.local_taxi,
//   'Auto Rickshaw': Icons.electric_rickshaw,
//   'Bike Taxi': Icons.two_wheeler,
//   'Washing Machine Repair': Icons.local_laundry_service,
//   'Microwave Repair': Icons.microwave,
//   'Geyser Repair': Icons.water,
//   'Chimney Repair': Icons.fireplace,
//   'Personal Trainer': Icons.fitness_center,
//   'Gym Trainer': Icons.sports_gymnastics,
//   'Zumba Instructor': Icons.music_video,
//   'Dietician': Icons.restaurant_menu,
//   'Lawyer': Icons.balance,
//   'Notary': Icons.edit_document,
//   'Document Writer': Icons.description,
//   'Legal Advisor': Icons.rule,
//   'Accountant': Icons.calculate,
//   'Tax Consultant': Icons.receipt_long,
//   'Loan Agent': Icons.monetization_on,
//   'Insurance Agent': Icons.policy,
//   'Babysitter': Icons.baby_changing_station,
//   'Nanny': Icons.family_restroom,
//   'Daycare': Icons.house,
//   'Tuition Teacher': Icons.cast_for_education,
//   'Caregiver': Icons.health_and_safety,
//   'Old Age Companion': Icons.emoji_people,
//   'Walking Assistant': Icons.accessible,
//   'Medicine Reminder': Icons.alarm,
//   'Computer Repair': Icons.computer,
//   'Software Install': Icons.system_update_alt,
//   'WiFi Setup': Icons.wifi,
//   'Printer Setup': Icons.print,
//   'Mason': Icons.architecture,
//   'Welder': Icons.precision_manufacturing,
//   'Tile Worker': Icons.grid_on,
//   'Gardener': Icons.grass,
//   'Laundry': Icons.local_laundry_service,
//   'Key Maker': Icons.vpn_key,
//   'Pet Walker': Icons.pets,
// };
//
// final Map<String, String> multiLangMap2 = {
//   'Electrician': 'ઇલેક્ટ્રિશિયન इलेक्ट्रिशियन electrician',
//   'Plumber': 'પ્લમ્બર प्लम्बर plumber',
//   'Carpenter': 'સુથાર बढ़ई carpenter',
//   'Painter': 'ચિત્રકાર चित्रकार painter',
//   'Doctor': 'ડોક્ટર डॉक्टर doctor',
//   'Nurse': 'નર્સ नर्स nurse',
//   'Physiotherapist': 'ફિઝિયોથેરાપિસ્ટ फिजियोथेरेपिस्ट physiotherapist',
//   'Dentist': 'દાંતનો ડોક્ટર दंत चिकित्सक dentist',
//   'Tutor': 'શિક્ષક शिक्षक tutor',
//   'Coach': 'પ્રશિક્ષક कोच coach',
//   'Music Teacher': 'સંગીત શિક્ષક संगीत शिक्षक music teacher',
//   'Yoga Instructor': 'યોગ શિક્ષક योग प्रशिक्षक yoga instructor',
//   'Mechanic': 'મેકેનિક मैकेनिक mechanic',
//   'Car Wash': 'કાર ધોવાનું कार धुलाई car wash',
//   'Tyre Repair': 'ટાયર રિપેર टायर मरम्मत tyre repair',
//   'Battery Service': 'બેટરી સેવા बैटरी सेवा battery service',
//   'Beautician': 'બ્યુટિશિયન ब्यूटीशियन beautician',
//   'Hair Stylist': 'હેર સ્ટાઈલિસ્ટ हेयर स्टाइलिस्ट hair stylist',
//   'Masseuse': 'મસાજ કરનાર मालिश करने वाला masseuse',
//   'Spa': 'સ્પા स्पा spa',
//   'AC Repair': 'એસી રિપેર एसी मरम्मत ac repair',
//   'Fridge Repair': 'ફ્રિજ રિપેર फ्रिज मरम्मत fridge repair',
//   'TV Repair': 'ટિવી રિપેર टीवी मरम्मत tv repair',
//   'Mobile Repair': 'મોબાઇલ રિપેર मोबाइल मरम्मत mobile repair',
//   'House Cleaning': 'ઘર સાફ કરવું घर की सफाई house cleaning',
//   'Sofa Cleaning': 'સોફા સાફ સફાઈ सोफा सफाई sofa cleaning',
//   'Water Tank Cleaning': 'પાણીની ટાંકી સાફ करना पानी की टंकी सफाई',
//   'Pest Control': 'કીટ નિયંત્રણ कीट नियंत्रण pest control',
//   'Courier': 'કુરિયર कूरियर courier',
//   'Parcel': 'પાર્સલ पार्सल parcel',
//   'Food Delivery': 'ભોજન પહોંચાડવું भोजन वितरण food delivery',
//   'Grocery Delivery': 'કિરાણા પહોંચાડવું किराना वितरण grocery delivery',
//   'Photographer': 'ફોટોગ્રાફર फोटोग्राफर photographer',
//   'DJ': 'ડિજે डीजे DJ',
//   'Caterer': 'ખાનપાન સેવા खानपान सेवा caterer',
//   'Decorator': 'સજાવટકાર सजावटकार decorator',
//   'Security Guard': 'સુરક્ષા રક્ષક सुरक्षा गार्ड security guard',
//   'Bodyguard': 'બોડીગાર્ડ अंगरक्षक bodyguard',
//   'Bouncer': 'બાઉન્સર बाउंसर bouncer',
//   'CCTV Monitor': 'સીસીટવી મોનિટર सीसीटीवी मॉनिटर cctv monitor',
//   'Driver': 'ડ્રાઈવર ड्राइवर driver',
//   'Taxi Service': 'ટેક્સી સેવા टैक्सी सेवा taxi service',
//   'Auto Rickshaw': 'ઑટો રિક્ષા ऑटो रिक्शा auto rickshaw',
//   'Bike Taxi': 'બાઈક ટેક્સી बाइक टैक्सी bike taxi',
//   'Washing Machine Repair':
//   'વોશિંગ મશીન રિપેર वॉशिंग मशीन मरम्मत washing machine repair',
//   'Microwave Repair': 'માઇક્રોવેવ રિપેર माइक्रोवेव मरम्मत microwave repair',
//   'Geyser Repair': 'ગીઝર રિપેર गीजर मरम्मत geyser repair',
//   'Chimney Repair': 'ચિમની રિપેર चिमनी मरम्मत chimney repair',
//   'Personal Trainer': 'પર્સનલ ટ્રેનર व्यक्तिगत प्रशिक्षक personal trainer',
//   'Gym Trainer': 'જિમ ટ્રેનર जिम ट्रेनर gym trainer',
//   'Zumba Instructor': 'ઝુંબા તાલીમકાર जुम्बा प्रशिक्षक zumba instructor',
//   'Dietician': 'આહાર નિષ્ણાત आहार विशेषज्ञ dietician',
//   'Lawyer': 'વકીલ वकील lawyer',
//   'Notary': 'નોટરી नोटरी notary',
//   'Document Writer': 'દસ્તાવેજ લેખક दस्तावेज़ लेखक document writer',
//   'Legal Advisor': 'કાયદેસર સલાહકાર कानूनी सलाहकार legal advisor',
//   'Accountant': 'હિસાબનું બુક રાખનાર लेखाकार accountant',
//   'Tax Consultant': 'કર સલાહકાર कर सलाहकार tax consultant',
//   'Loan Agent': 'લોન એજન્ટ ऋण एजेंट loan agent',
//   'Insurance Agent': 'વીમો એજન્ટ बीमा एजेंट insurance agent',
//   'Babysitter': 'બેબીસિટર बच्चों की देखभाल करने वाला babysitter',
//   'Nanny': 'નાની आया nanny',
//   'Daycare': 'ડે કેર डे केयर daycare',
//   'Tuition Teacher': 'ટ્યુશન શિક્ષક ट्यूशन शिक्षक tuition teacher',
//   'Caregiver': 'કાળજી રાખનાર देखभाल करने वाला caregiver',
//   'Old Age Companion': 'વૃદ્ધ માટે સાથી बुजुर्ग साथी old age companion',
//   'Walking Assistant': 'ચાલવા માટે સહાયક चलने में सहायक walking assistant',
//   'Medicine Reminder': 'દવાઓ યાદ અપાવનાર दवा अनुस्मारक medicine reminder',
//   'Computer Repair': 'કમ્પ્યુટર રિપેર कंप्यूटर मरम्मत computer repair',
//   'Software Install': 'સોફ્ટવેર ઇન્સ્ટોલ सॉफ्टवेयर इंस्टाल software install',
//   'WiFi Setup': 'વાઇફાઇ સેટઅપ वाई-फाई सेटअप wifi setup',
//   'Printer Setup': 'પ્રિન્ટર સેટઅપ प्रिंटर सेटअप printer setup',
//   'Mason': 'ราชમિસ્ત્રી राजमिस्त्री mason',
//   'Welder': 'વેલ્ડર वेल्डर welder',
//   'Tile Worker': 'ટાઇલ કામદાર टाइल कारीगर tile worker',
//   'Gardener': 'માળી माली gardener',
//   'Laundry': 'લૉન્ડ્રી लॉन्ड्री laundry',
//   'Key Maker': 'તાળાની ચાવી બનાવનાર चाभी बनाने वाला key maker',
//   'Pet Walker': 'પેટ વોકર पालतू घुमाने वाला pet walker',
// };
//
//
//
//
