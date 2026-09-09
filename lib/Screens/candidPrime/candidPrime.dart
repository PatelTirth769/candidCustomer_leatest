import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../Controllers/HomeScreenController.dart';
import '../../Services/Collections/Offers/OffersColl.dart';
import '../../Utils/MyWidgets.dart';
import '../../main.dart';
import '../OffersScreens/OfferDetailsScreen.dart';
import '../PrimeMembership/PrimeMembershipScreen.dart'; // PrimeMembership

class CandidPrimeScreen extends StatelessWidget {
  // HomeScreenController को यहाँ से हटा दिया गया है, क्योंकि GetBuilder इसे प्रदान करता है।
  // final HomeScreenController controller = HomeScreenController();

  @override
  Widget build(BuildContext context) {
    // localUser?.isUserPrimeMember को उपयोग करने से पहले null check किया गया है
    return GetBuilder(
      init: homeScreenController,
      builder: (controller) => Scaffold(
        appBar: MyWidgets().myAppBar(),
        drawer: _buildEnhancedDrawer(),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroSection(context),
                  // यह बटन अब नेविगेशन लॉजिक को संभालता है
                  _buildPrimeMembershipButton(context),
                  _buildOffersSection('DEALS FOR PRODUCTS', 'product'),
                  _buildOffersSection('DEALS FOR SERVICE', 'service'),
                  // Add bottom padding to prevent content from being hidden behind the branding
                  const SizedBox(height: 80),
                ],
              ),
            ),
            // myWidgets.getCandidBranding(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            MyWidgets().myDrawerHeader(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: bottomNavController.navDrawerItems.length,
                itemBuilder: (context, index) {
                  final item = bottomNavController.navDrawerItems[index];
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        leading: Icon(Icons.arrow_forward_ios,
                            size: 16, color: Theme.of(context).primaryColor),
                        title: Text(
                          item['title'],
                          style: TextStyle(
                            fontFamily: 'Aileron',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () => Navigator.of(navigatorKey.currentContext!)
                            .push(MaterialPageRoute(
                            builder: (context) => item['screen'])),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: 25.h,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'lib/Images/image2.png',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 50),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock Deals & Perks',
                  style: GoogleFonts.workSans(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                          color: Colors.black.withOpacity(0.5), blurRadius: 4),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Activate Prime Membership for Extra Discounts',
                  style: GoogleFonts.workSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    shadows: [
                      Shadow(
                          color: Colors.black.withOpacity(0.5), blurRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UPDATED: Prime Membership Button Logic ---
  Widget _buildPrimeMembershipButton(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      builder: (controller) {
        // चेक करें कि यूजर प्राइम मेंबर है या नहीं
        final bool isPrime = localUser?.isUserPrimeMember == true;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
          child: ElevatedButton(
            onPressed: () {
              // दोनों ही स्थितियों में PrimeMembership स्क्रीन पर नेविगेट करें,
              // लेकिन PrimeMembership स्क्रीन खुद यह तय करेगी कि क्या दिखाना है।
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PrimeMembership()),
              );
            },
            style: ElevatedButton.styleFrom(
              // प्राइम होने पर हरा रंग और न होने पर लाल रंग
              backgroundColor: isPrime ? Colors.green[700] : const Color(0xFFFF0000),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isPrime ? Icons.check_circle : Icons.star,
                    color: isPrime ? Colors.white : Colors.yellow),
                SizedBox(width: 2.w),
                Text(
                  isPrime
                      ? 'Your Prime Benefits' // प्राइम होने पर दिखाने वाला टेक्स्ट
                      : 'BECOME A PRIME MEMBER', // प्राइम न होने पर दिखाने वाला टेक्स्ट
                  style: GoogleFonts.workSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600
                    ,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // --- END UPDATED BUTTON ---

  Widget _buildOffersSection(String title, String offerType) {
    // ... (no change)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E6C),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              title,
              style: GoogleFonts.workSans(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        _buildOffersGrid(offerType),
      ],
    );
  }

  Widget _buildOffersGrid(String offerType) {
    // ... (no change)
    return StreamBuilder<List<OffersColl>>(
      stream: isar.offersColls
          .filter()
          .offerNameIsNotEmpty()
          .selectedCityEqualTo(homeScreenController.selectedCity)
          .offerTypeEqualTo(offerType)
          .sortByDistanceFromUserInMeters()
          .build()
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData || homeScreenController.trendingNowIsLoading) {
          return _buildLoadingGrid();
        }

        List<OffersColl> offers = snapshot.data ?? [];
        if (offers.isEmpty) {
          return _buildEmptyState(context);
        }

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: offers.length,
          itemBuilder: (context, index) =>
              _buildOfferCard(offers[index], context),
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    // ... (no change)
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    // ... (no change)
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: double.infinity,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 100,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(OffersColl offer, BuildContext context) {
    // ... (no change)
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OfferDetailsScreen(offerID: offer.offerID),
        ),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          // Add ConstrainedBox to control the card's size
          constraints: const BoxConstraints(
            minHeight: 250, // Minimum height to prevent overflow
            maxHeight: 300, // Maximum height to maintain consistency
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Hero(
                      tag: 'offer_image_${offer.offerID}',
                      child: Image.network(
                        offer.offerImages.isNotEmpty
                            ? offer.offerImages.first
                            : "",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.local_offer,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${offer.discountNo}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.offerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.offerDescription,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // ... (no change)
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No offers available in your area yet',
              style: GoogleFonts.workSans(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new deals!',
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
