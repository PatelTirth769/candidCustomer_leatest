import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:sizer/sizer.dart';

import '../../Services/Collections/Offers/OffersColl.dart';
import '../../Utils/MyWidgets.dart';
import '../../main.dart';
import 'VendorOffersScreen.dart';

class StoreListingScreen extends StatefulWidget {
  const StoreListingScreen({Key? key}) : super(key: key);

  @override
  State<StoreListingScreen> createState() => _StoreListingScreenState();
}

class _StoreListingScreenState extends State<StoreListingScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // ACTIVE OFFER CHECK
  // ============================================================

  bool _isActiveOffer(OffersColl offer) {
    return offer.offerStatus == OfferStatus.live ||
        offer.offerStatus == OfferStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Store Listing',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),

      drawer: drawer,

      body: Column(
        children: [

          // ======================================================
          // SEARCH BAR
          // ======================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,

                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },

                decoration: InputDecoration(
                  hintText: 'Search stores by name or address...',

                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),

                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      _searchController.clear();

                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),

          // ======================================================
          // SELECTED CITY
          // ======================================================

          GetBuilder(
            init: homeScreenController,
            builder: (controller) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.red,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    homeScreenController.selectedCity.isNotEmpty
                        ? 'Showing stores in ${homeScreenController.selectedCity}'
                        : 'Showing all stores',

                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ======================================================
          // STORE LIST
          // ======================================================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('candidVendors')
                  .where(
                'isActive',
                isEqualTo: true,
              )
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(
                    'No active stores found.',
                  );
                }

                final docs = snapshot.data!.docs;

                // ==================================================
                // FILTER STORES
                // ==================================================

                final selectedCityLower =
                homeScreenController.selectedCity
                    .toLowerCase()
                    .trim();

                final filteredDocs = docs.where((doc) {
                  final data =
                  doc.data() as Map<String, dynamic>?;

                  if (data == null) {
                    return false;
                  }

                  // ----------------------------------------------
                  // CITY FILTER
                  // ----------------------------------------------

                  bool matchesCity = true;

                  if (selectedCityLower.isNotEmpty) {
                    final vendorCity =
                    (data['userAddressCity'] ??
                        data['city'] ??
                        '')
                        .toString()
                        .toLowerCase()
                        .trim();

                    bool outletMatches = false;

                    final outlets =
                    data['myOutlets'] as List?;

                    if (outlets != null) {
                      for (var outlet in outlets) {
                        if (outlet is Map) {
                          final outletCity =
                          (outlet[
                          'userOutletAddressCity'] ??
                              '')
                              .toString()
                              .toLowerCase()
                              .trim();

                          if (outletCity ==
                              selectedCityLower) {
                            outletMatches = true;
                            break;
                          }
                        }
                      }
                    }

                    matchesCity =
                        vendorCity == selectedCityLower ||
                            outletMatches;
                  }

                  // ----------------------------------------------
                  // SEARCH FILTER
                  // ----------------------------------------------

                  bool matchesSearch = true;

                  if (_searchQuery.isNotEmpty) {
                    final searchLower =
                    _searchQuery
                        .toLowerCase()
                        .trim();

                    final storeName =
                    (data['storeName'] ??
                        data['userFullName'] ??
                        data['vendorName'] ??
                        '')
                        .toString()
                        .toLowerCase();

                    final address =
                    (data['userAddress'] ?? '')
                        .toString()
                        .toLowerCase();

                    matchesSearch =
                        storeName.contains(searchLower) ||
                            address.contains(searchLower);
                  }

                  return matchesCity && matchesSearch;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return _buildEmptyState(
                    'No stores found matching your search.',
                  );
                }

                // ==================================================
                // STORE LIST
                // ==================================================

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                  ),

                  itemCount: filteredDocs.length,

                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];

                    final data =
                    doc.data() as Map<String, dynamic>;

                    final vendorId =
                    (data['vendorId'] ?? doc.id)
                        .toString();

                    final storeName =
                    (data['storeName'] ??
                        data['userFullName'] ??
                        data['vendorName'] ??
                        'Unnamed Store')
                        .toString();

                    final address =
                    (data['userAddress'] ??
                        data['userAddressCity'] ??
                        'Address not provided')
                        .toString();

                    final rating =
                        data['storeRating']
                            ?.toString() ??
                            '4.5';

                    final logoUrl =
                    (data['userCompanyLogo'] ??
                        data['userProfilePic'] ??
                        '')
                        .toString();

                    // ==================================================
                    // IMPORTANT:
                    // Count actual active offers from Isar.
                    //
                    // We DO NOT use:
                    // data['offerCount']
                    //
                    // because we want the actual offer count.
                    // ==================================================

                    return StreamBuilder<List<OffersColl>>(
                      stream: isar.offersColls
                          .filter()
                          .vendorIdEqualTo(vendorId)
                          .watch(
                        fireImmediately: true,
                      ),

                      builder:
                          (context, offerSnapshot) {
                        final offers =
                            offerSnapshot.data ?? [];

                        final activeOfferCount =
                            offers.where(
                              _isActiveOffer,
                            ).length;

                        return StoreCard(
                          vendorId: vendorId,
                          storeName: storeName,
                          address: address,
                          rating: rating,
                          offerCount: activeOfferCount,
                          logoUrl: logoUrl,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 80,
              color: Colors.grey,
            ),

            const SizedBox(height: 16),

            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// STORE CARD
// =================================================================

class StoreCard extends StatelessWidget {
  final String vendorId;
  final String storeName;
  final String address;
  final String rating;
  final int offerCount;
  final String logoUrl;

  const StoreCard({
    Key? key,
    required this.vendorId,
    required this.storeName,
    required this.address,
    required this.rating,
    required this.offerCount,
    required this.logoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      elevation: 3,

      shadowColor: Colors.black.withOpacity(0.2),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),

            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                // ==================================================
                // STORE LOGO
                // ==================================================

                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(12),

                  child: Container(
                    width: 80,
                    height: 80,

                    color: Colors.grey[100],

                    child: logoUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.cover,

                      placeholder:
                          (context, url) =>
                      const Center(
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),

                      errorWidget:
                          (context, url, error) =>
                      const Icon(
                        Icons.storefront,
                        size: 40,
                        color: Colors.grey,
                      ),
                    )
                        : const Icon(
                      Icons.storefront,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // ==================================================
                // STORE DETAILS
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        storeName,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),

                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              address,

                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),

                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            rating.isNotEmpty
                                ? rating
                                : '4.5',

                            style:
                            const TextStyle(
                              fontSize: 12,
                              fontWeight:
                              FontWeight.bold,
                              color:
                              Colors.black87,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ==================================================
                          // ACTIVE OFFER COUNT
                          // ==================================================

                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),

                            decoration:
                            BoxDecoration(
                              color: Colors.red[50],
                              borderRadius:
                              BorderRadius.circular(
                                  8),
                            ),

                            child: Text(
                              '$offerCount Active Offers',

                              style:
                              const TextStyle(
                                fontSize: 10,
                                fontWeight:
                                FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // VIEW OFFERS
                      // ==================================================

                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  VendorOffersScreen(
                                    vendorId: vendorId,
                                    vendorName: storeName,
                                  ),
                            ),
                          );
                        },

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor:
                          Colors.white,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                          ),

                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

                          minimumSize: Size.zero,

                          tapTargetSize:
                          MaterialTapTargetSize
                              .shrinkWrap,
                        ),

                        child: const Text(
                          'VIEW OFFERS',

                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==========================================================
          // FAVORITE BUTTON
          // ==========================================================

          const Positioned(
            top: 12,
            right: 12,
            child: FavoriteButton(),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// FAVORITE BUTTON
// =================================================================

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({Key? key}) : super(key: key);

  @override
  State<FavoriteButton> createState() =>
      _FavoriteButtonState();
}

class _FavoriteButtonState
    extends State<FavoriteButton> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFavorite = !isFavorite;
        });
      },

      child: Container(
        padding: const EdgeInsets.all(6),

        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,

          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),

        child: Icon(
          isFavorite
              ? Icons.favorite
              : Icons.favorite_border,

          color: isFavorite
              ? Colors.red
              : Colors.grey,

          size: 18,
        ),
      ),
    );
  }
}
