/// Represents a retail price in PAAPI 5.
class Price {
  /// The formatted price amount with currency symbol (e.g. "\$19.99").
  final String? displayAmount;

  /// The numeric decimal amount of the price (e.g. 19.99).
  final double? amount;

  /// The currency code (e.g. "USD", "INR").
  final String? currency;

  /// Creates a [Price] instance.
  const Price({
    this.displayAmount,
    this.amount,
    this.currency,
  });

  /// Parses a [Price] from a JSON map.
  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      displayAmount: json['DisplayAmount'] as String?,
      amount: (json['Amount'] as num?)?.toDouble(),
      currency: json['Currency'] as String?,
    );
  }
}
