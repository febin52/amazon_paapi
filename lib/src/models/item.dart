import 'browse_node.dart';
import 'image.dart';
import 'offer.dart';

/// Represents an item returned by the PAAPI 5 API.
///
/// Contains detailed information about a product, including its ASIN,
/// title, URL, images, categories, and offers.
class Item {
  /// The Amazon Standard Identification Number (ASIN) of the item.
  final String asin;

  /// The title of the item.
  final String? title;

  /// The detailed URL to the item on Amazon.
  final String? detailPageUrl;

  /// Primary image for the item.
  final Image? primaryImage;

  /// List of offers available for the item.
  final List<Offer>? offers;

  /// List of browse nodes (categories) associated with the item.
  final List<BrowseNode>? browseNodes;

  /// Creates an [Item] instance.
  const Item({
    required this.asin,
    this.title,
    this.detailPageUrl,
    this.primaryImage,
    this.offers,
    this.browseNodes,
  });

  /// Parses an [Item] from a JSON map.
  factory Item.fromJson(Map<String, dynamic> json) {
    // Parse Images
    Image? primaryImg;
    final imagesJson = json['Images']?['Primary']?['Medium'];
    if (imagesJson != null) {
      primaryImg = Image.fromJson(imagesJson as Map<String, dynamic>);
    }

    // Parse Offers
    List<Offer>? parsedOffers;
    final listingsJson = json['Offers']?['Listings'] as List<dynamic>?;
    if (listingsJson != null) {
      parsedOffers = listingsJson
          .map((e) => Offer.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse BrowseNodes
    List<BrowseNode>? parsedNodes;
    final nodesJson = json['BrowseNodeInfo']?['BrowseNodes'] as List<dynamic>?;
    if (nodesJson != null) {
      parsedNodes = nodesJson
          .map((e) => BrowseNode.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Item(
      asin: json['ASIN'] as String? ?? '',
      title: json['ItemInfo']?['Title']?['DisplayValue'] as String?,
      detailPageUrl: json['DetailPageURL'] as String?,
      primaryImage: primaryImg,
      offers: parsedOffers,
      browseNodes: parsedNodes,
    );
  }
}
