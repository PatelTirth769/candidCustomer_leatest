import 'package:candid_customer/Screens/OffersScreens/selectedcatoffers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../Controllers/HomeScreenController.dart';
import '../../Services/Collections/Cat/CatsColl.dart';
import '../../Utils/MyWidgets.dart';
import '../../main.dart';

class Voice extends StatefulWidget {
  final String? initialTab;

  const Voice({
    super.key,
    this.initialTab,
  });

  @override
  State<Voice> createState() => _VoiceState();
}

class _VoiceState extends State<Voice> {
  bool isProductsSelected = true;
  String selectedCategoryId = '';
  String? selectedCategoryName;
  List<CatsColl> allCategories = [];
  List<CatsColl> filteredCategories = [];
  List<String> searchHistory = []; // ✅ Search history

  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  late HomeScreenController homeScreenController;

  // ✅ Speech recognition declarations
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HomeScreenController>()) {
      Get.put(HomeScreenController());
    }
    homeScreenController = Get.find<HomeScreenController>();

    _speech = stt.SpeechToText(); // ✅ INITIALIZE

    _loadSearchHistory(); // ✅ Load persisted search history

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isProductsSelected = !homeScreenController.screenTypeProducts;
      _loadCategories();

      FocusScope.of(context).requestFocus(searchFocusNode);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    _speech.stop(); // ✅ STOP SPEECH LISTENING
    HomeScreenController().dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  void _loadCategories() {
    isar.catsColls
        .filter()
        .catNameIsNotEmpty()
        .build()
        .watch(fireImmediately: true)
        .listen((categories) {
      if (mounted) {
        setState(() {
          allCategories = categories;
          _filterCategories('');
        });
      }
    });
  }

  void _filterCategories(String query) {
    if (mounted) {
      setState(() {
        filteredCategories = allCategories
            .where((cat) =>
        cat.catType.toLowerCase() ==
            (isProductsSelected ? 'product' : 'service') &&
            cat.catName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _handleToggle(bool isProducts) {
    if (mounted) {
      setState(() {
        isProductsSelected = isProducts;
        homeScreenController.updateScreenType(!isProducts);
        _filterCategories(searchController.text);
      });
    }
  }

  // ✅ Updated function to reset mic after search completes & save to history
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('Speech status: $val');
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
            _speech.stop();
          }
        },
        onError: (val) {
          print('Speech error: $val');
          setState(() => _isListening = false);
          _speech.stop();
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              searchController.text = val.recognizedWords;
              _filterCategories(val.recognizedWords);
              if (val.recognizedWords.trim().isNotEmpty) {
                _addToHistory(val.recognizedWords.trim()); // ✅ Save mic search to history
              }
            });
          },
          listenMode: stt.ListenMode.dictation,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _addToHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      searchHistory.remove(query); // remove if already exists
      searchHistory.insert(0, query); // add at top
      if (searchHistory.length > 3) {
        searchHistory = searchHistory.sublist(0, 3); // keep only last 3
      }
    });

    await prefs.setStringList('searchHistory', searchHistory); // ✅ Save updated
  }

  void _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory.clear();
    });
    await prefs.remove('searchHistory'); // ✅ Clear from storage
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      init: homeScreenController,
      builder: (homeScreenController) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          drawer: _buildDrawer(context),
          body: SafeArea(
            child: Column(
              children: [
                _buildCustomHeader(), // ✅ NEW header

                SizedBox(height: 2.h),
                _buildToggleButtons(),
                Expanded(
                  child: _buildCategoriesGrid(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomHeader() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    onChanged: (value) {
                      _filterCategories(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search categories',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'lib/Images/RealOffers1.png',
                          width: 35,
                          height: 45,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                        onPressed: _listen,
                      ),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ✅ Search history below TextField
        if (searchHistory.isNotEmpty) _buildSearchHistoryList(),
      ],
    );
  }

  Widget _buildSearchHistoryList() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearHistory,
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8.0,
            children: searchHistory
                .map((historyItem) => ActionChip(
              label: Text(historyItem),
              onPressed: () {
                searchController.text = historyItem;
                _filterCategories(historyItem);
              },
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              'Products',
              isProductsSelected,
                  () => _handleToggle(true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildToggleButton(
              'Services',
              !isProductsSelected,
                  () => _handleToggle(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      String title, bool isSelected, VoidCallback onPressed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: isSelected ? 1 : 0,
          backgroundColor: isSelected ? Colors.white : Colors.transparent,
          foregroundColor: isSelected ? Colors.black : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: title == 'Products'
                  ? (isSelected ? Colors.red : Colors.transparent)
                  : (isSelected ? Colors.blue : Colors.transparent),
              width: 1.0,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          key: ValueKey<bool>(isProductsSelected),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: filteredCategories.length,
          itemBuilder: (context, index) =>
              _buildCategoryItem(filteredCategories[index]),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CatsColl cat) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          _addToHistory(searchController.text); // ✅ add to history on tap

          Get.to(
                () => OffersScreen(selectedCatID: cat.catID),
            arguments: {'selectedCategoryName': cat.catName},
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: cat.catType.toLowerCase() == 'product'
                  ? Colors.red
                  : Colors.blue,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.network(
                    cat.catImg,
                    fit: BoxFit.contain,
                    placeholderBuilder: (BuildContext context) =>
                    const Icon(
                      Icons.home_repair_service,
                      size: 30,
                      color: Colors.grey,
                    ),
                    cacheColorFilter: true,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    cat.catName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 9.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            MyWidgets().myDrawerHeader(),
            for (var item in bottomNavController.navDrawerItems)
              Card(
                color: Colors.white,
                margin:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      fontFamily: 'Aileron',
                      fontSize: 12.sp,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16.0,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => item['screen'],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
