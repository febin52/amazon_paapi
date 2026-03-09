import 'package:http/http.dart' as http;

import '../auth/aws_v4_signer.dart';
import '../cache/memory_cache.dart';
import '../utils/rate_limiter.dart';
import '../utils/retry_policy.dart';
import '../models/search_result.dart';
import '../services/item_service.dart';
import '../services/search_service.dart';

export '../services/item_service.dart';
export '../services/search_service.dart';

/// The main entry point for interacting with the Amazon PAAPI 5.
class PaapiClient {
  /// The AWS Access Key.
  final String accessKey;

  /// The AWS Secret Key.
  final String secretKey;

  /// Your Amazon affiliate Partner Tag.
  final String partnerTag;

  /// The Amazon marketplace URL (e.g. 'www.amazon.com', 'www.amazon.in').
  final String marketplace;

  /// Optional region override. Defaults to 'us-east-1'.
  final String region;

  /// The HTTP client used for requests.
  final http.Client httpClient;

  /// The rate limiter applied to requests.
  final RateLimiter rateLimiter;

  /// The retry policy applied to failed requests.
  final RetryPolicy retryPolicy;

  /// The memory cache for API responses.
  final MemoryCache cache;

  late final SearchService _searchService;
  late final ItemService _itemService;

  /// Creates a [PaapiClient].
  PaapiClient({
    required this.accessKey,
    required this.secretKey,
    required this.partnerTag,
    required this.marketplace,
    this.region = 'us-east-1',
    http.Client? httpClient,
    RateLimiter? rateLimiter,
    this.retryPolicy = const RetryPolicy(),
    MemoryCache? cache,
  })  : httpClient = httpClient ?? http.Client(),
        rateLimiter = rateLimiter ?? RateLimiter(),
        cache = cache ?? MemoryCache() {
    final signer = AwsV4Signer(
      accessKeyId: accessKey,
      secretAccessKey: secretKey,
      region: _determineRegion(marketplace, region),
    );

    _searchService = SearchService(
      signer: signer,
      partnerTag: partnerTag,
      marketplace: marketplace,
      httpClient: this.httpClient,
      rateLimiter: this.rateLimiter,
      retryPolicy: retryPolicy,
      cache: this.cache,
    );

    _itemService = ItemService(
      signer: signer,
      partnerTag: partnerTag,
      marketplace: marketplace,
      httpClient: this.httpClient,
      rateLimiter: this.rateLimiter,
      retryPolicy: retryPolicy,
      cache: this.cache,
    );
  }

  /// Searches for items on Amazon based on keywords or other parameters.
  Future<SearchResult> searchItems({
    required String keywords,
    List<String>? resources,
    int itemPage = 1,
  }) {
    return _searchService.searchItems(
      keywords: keywords,
      resources: resources,
      itemPage: itemPage,
    );
  }

  /// Retrieves specific items by their ASINs.
  Future<SearchResult> getItems({
    required List<String> itemIds,
    List<String>? resources,
  }) {
    return _itemService.getItems(
      itemIds: itemIds,
      resources: resources,
    );
  }

  /// Retrieves variations of an item by ASIN.
  Future<SearchResult> getVariations({
    required String asin,
    List<String>? resources,
  }) {
    return _itemService.getVariations(
      asin: asin,
      resources: resources,
    );
  }

  /// Retrieves browse nodes by IDs.
  Future<Map<String, dynamic>> getBrowseNodes({
    required List<String> browseNodeIds,
    List<String>? resources,
  }) {
    return _searchService.getBrowseNodes(
      browseNodeIds: browseNodeIds,
      resources: resources,
    );
  }

  /// Disposes the underlying HTTP client.
  void dispose() {
    httpClient.close();
  }

  String _determineRegion(String marketplace, String defaultRegion) {
    if (marketplace.contains('.in')) {
      return 'eu-west-1';
    }
    if (marketplace.contains('.co.uk') ||
        marketplace.contains('.de') ||
        marketplace.contains('.fr') ||
        marketplace.contains('.it') ||
        marketplace.contains('.es')) {
      return 'eu-west-1';
    }
    if (marketplace.contains('.com.au') || marketplace.contains('.co.jp')) {
      return 'us-west-2';
    }
    return defaultRegion;
  }
}
