import 'item.dart';

/// Represents the top-level response from a PAAPI 5 SearchItems or GetItems request.
class SearchResult {
  /// The list of returned items.
  final List<Item> items;

  /// Total number of search results available (only available in SearchItems).
  final int? totalResultCount;

  /// Creates a [SearchResult] instance.
  const SearchResult({
    required this.items,
    this.totalResultCount,
  });

  /// Parses a [SearchResult] from a JSON map based on SearchItems response structure.
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final searchResultJson = json['SearchResult'];
    if (searchResultJson == null) {
      // Could be GetItems response
      final itemsResultJson = json['ItemsResult']?['Items'] as List<dynamic>?;
      if (itemsResultJson != null) {
        return SearchResult(
          items: itemsResultJson
              .map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return const SearchResult(items: []);
    }

    final itemsList = searchResultJson['Items'] as List<dynamic>? ?? [];

    return SearchResult(
      items: itemsList
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalResultCount: searchResultJson['TotalResultCount'] as int?,
    );
  }
}
