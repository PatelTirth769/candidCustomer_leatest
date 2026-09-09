import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';
import '../../Services/Collections/Offers/OffersColl.dart';
import '../../Utils/MyWidgets.dart';
import '../../main.dart';
import 'OfferDetailsScreen.dart';

class OffersScreen extends StatelessWidget {
  final String selectedCatID;

  const OffersScreen({Key? key, required this.selectedCatID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: homeScreenController,
      builder: (controller) => Scaffold(
        // appBar: MyWidgets().myAppBar(),
        drawer: _buildDrawer(context),
        resizeToAvoidBottomInset: true,
        body: StreamBuilder<List<OffersColl>>(
          stream: isar.offersColls
              .filter()
              .selectedCityEqualTo(homeScreenController.selectedCity)
              .catIdEqualTo(selectedCatID)
              .build()
              .watch(fireImmediately: true),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            List<OffersColl> allOffers = snapshot.data ?? [];

            // Separate trending and non-trending offers
            List<OffersColl> trendingOffers = allOffers.where((offer) => offer.isTrending).toList();
            List<OffersColl> regularOffers = allOffers.where((offer) => !offer.isTrending).toList();

            if (allOffers.isEmpty) {
              return _buildEmptyState(context);
            }

            return CustomScrollView(
              slivers: [
                if (trendingOffers.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        '🔥 Trending Offers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildOfferItem(trendingOffers[index], context, true),
                      ),
                      childCount: trendingOffers.length,
                    ),
                  ),
                ],
                if (regularOffers.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, trendingOffers.isEmpty ? 16 : 24, 16, 8),
                      child: const Text(
                        'All Offers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildOfferItem(regularOffers[index], context, false),
                      ),
                      childCount: regularOffers.length,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOfferItem(OffersColl offer, BuildContext context, bool isTrending) {
    return Card(
      elevation: isTrending ? 6 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isTrending
            ? const BorderSide(color: Color(0xFFDC2121), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfferDetailsScreen(offerID: offer.offerID),
          ),
        ),
        child: Column(
          children: [
            if (isTrending)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2121),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'TRENDING',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                offer.offerName,
                                style: TextStyle(
                                  fontSize: isTrending ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${offer.likesCount}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                offer.offerAddress,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OfferDetailsScreen(
                                offerID: offer.offerID,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isTrending ? Color(0xFFDC2121) : Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'VIEW OFFERS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isTrending
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRatingWidget(offer.offerID),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(12),
                    ),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: offer.offerImages.isNotEmpty
                          ? Hero(
                        tag: 'offer_image_${offer.offerID}',
                        child: CachedNetworkImage(
                          imageUrl: offer.offerImages.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      )
                          : const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingWidget(String offerID) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('candidOffers')
          .doc(offerID)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const SizedBox.shrink();

        final cumulativeRating = (data['cumulativeRating'] as num?)?.toDouble() ?? 0.0;
        final ratingCount = (data['ratingCount'] as int?) ?? 0;
        final averageRating = ratingCount > 0 ? cumulativeRating / ratingCount : 0.0;

        return Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < averageRating.round()
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
            const SizedBox(width: 8),
            Text(
              ratingCount > 0
                  ? '${averageRating.toStringAsFixed(1)} / 5'
                  : 'No ratings',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            if (ratingCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '($ratingCount)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        );
      },
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
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/Images/carousel-category-templates_0005_Layer 3.jpg',
              fit: BoxFit.contain,
              height: 200,
            ),
            const SizedBox(height: 16),
            const Text(
              'No offers available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new offers in this category',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
