import 'package:candid_customer/Screens/OffersScreens/productcateogry.dart';
import 'package:candid_customer/Screens/OffersScreens/selectedcatoffers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Controllers/HomeScreenController.dart';
import '../../Services/Collections/Cat/CatsColl.dart';
import '../../Utils/MyWidgets.dart';
import '../../main.dart';

class ServiceCategory extends StatefulWidget {
  final String? initialTab;

  const ServiceCategory({
    super.key,
    this.initialTab,
  });

  @override
  State<ServiceCategory> createState() => _ServiceCategoryState();
}

class _ServiceCategoryState extends State<ServiceCategory> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  final FocusNode _searchFocusNode = FocusNode();
  bool _speechEnabled = false;
  List<CatsColl> _cachedCats = [];
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<HomeScreenController>().updateScreenType(true);
      _searchFocusNode.requestFocus();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
    });
  }

  void _initSpeech() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          print('Speech recognition status: $status');
        },
        onError: (error) {
          print('Speech recognition error: $error');
        },
      );
    }
  }

  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
          _searchText = result.recognizedWords.toLowerCase();
        });
        if (result.finalResult) {
          _speechToText.stop();
        }
      });
    } else {
      print('The user has not granted permission to use the microphone.');
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      init: homeScreenController,
      builder: (homeScreenController) {
        return Scaffold(
          appBar: MyWidgets().myAppBar(),
          drawer: _buildDrawer(context),
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildSearchBar(),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: _buildCategoriesGrid(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Text(
      'Service Categories',
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        fontFamily: 'Aileron',
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Search categories...',
        prefixIcon: IconButton(
          icon: Icon(
            _speechToText.isListening ? Icons.mic_off : Icons.mic,
            color: Colors.black,
          ),
          onPressed:
          _speechToText.isListening ? _stopListening : _startListening,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.black),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            IconButton(
              icon: const Icon(Icons.compare_arrows_sharp),
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(builder: (context) => Productcateogry()),
                );
              },
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
        const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
            ...bottomNavController.navDrawerItems.map(
                  (item) => Card(
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
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return StreamBuilder<List<CatsColl>>(
      stream: isar.catsColls
          .filter()
          .catNameIsNotEmpty()
          .build()
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        _cachedCats = (snapshot.data ?? [])
            .where((cat) => cat.catType.toLowerCase() == 'service')
            .toList();

        final filteredCats = _cachedCats.where((cat) {
          return cat.catName.toLowerCase().contains(_searchText);
        }).toList();

        if (filteredCats.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No service categories found')),
          );
        }

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCategoryItem(filteredCats[index]),
            childCount: filteredCats.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(CatsColl cat) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          Get.to(
                () => OffersScreen(selectedCatID: cat.catID),
            arguments: {'selectedCategoryName': cat.catName},
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red, width: 1), // 🔴 Red border added
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 6.h,
                width: 14.w,
                child: SvgPicture.network(
                  cat.catImg,
                  fit: BoxFit.contain,
                  placeholderBuilder: (BuildContext context) => const Icon(
                    Icons.home_repair_service,
                    size: 50,
                    color: Colors.grey,
                  ),
                  cacheColorFilter: true,
                ),
              ),
              const SizedBox(height: 3.0),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    cat.catName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
