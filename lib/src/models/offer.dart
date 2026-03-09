import 'price.dart';

/// Represents an offer listing for an item in PAAPI 5.
class Offer {
  /// The main price of the offer.
  final Price? price;

  /// The condition of the item (e.g. "New", "Used").
  final String? condition;

  /// The availability message of the item.
  final String? availability;

  /// The ID of the merchant offering the item.
  final String? merchantId;

  /// Creates an [Offer] instance.
  const Offer({
    this.price,
    this.condition,
    this.availability,
    this.merchantId,
  });

  /// Parses an [Offer] from a JSON map.
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      price: json['Price'] != null
          ? Price.fromJson(json['Price'] as Map<String, dynamic>)
          : null,
      condition: json['Condition']?['Value'] as String?,
      availability: json['Availability']?['Message'] as String?,
      merchantId: json['MerchantInfo']?['Id'] as String?,
    );
  }
}
