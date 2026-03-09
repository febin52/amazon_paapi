import 'dart:convert';
import 'package:http/http.dart' as http;

import '../auth/aws_v4_signer.dart';
import '../cache/memory_cache.dart';
import '../exceptions/api_exception.dart';
import '../models/search_result.dart';
import '../utils/rate_limiter.dart';
import '../utils/retry_policy.dart';

/// Handles SearchItems and GetBrowseNodes operations.
class SearchService {
  /// The configured signer for requests.
  final AwsV4Signer signer;

  /// The partner tag.
  final String partnerTag;

  /// The specific amazon marketplace.
  final String marketplace;

  /// Underlying HTTP client.
  final http.Client httpClient;

  /// The rate limiter.
  final RateLimiter rateLimiter;

  /// The retry policy for requests.
  final RetryPolicy retryPolicy;

  /// In memory cache to avoid redundant requests.
  final MemoryCache cache;

  /// Creates a [SearchService].
  SearchService({
    required this.signer,
    required this.partnerTag,
    required this.marketplace,
    required this.httpClient,
    required this.rateLimiter,
    required this.retryPolicy,
    required this.cache,
  });

  /// Searches for items.
  Future<SearchResult> searchItems({
    required String keywords,
    List<String>? resources,
    int itemPage = 1,
  }) async {
    final payload = {
      'Keywords': keywords,
      'PartnerTag': partnerTag,
      'PartnerType': 'Associates',
      'Marketplace': marketplace,
      'ItemPage': itemPage,
      if (resources != null) 'Resources': resources,
    };

    final cacheKey = 'SearchItems_${jsonEncode(payload)}';
    final cached = cache.get<SearchResult>(cacheKey);
    if (cached != null) {
      return cached;
    }

    final response = await _sendRequest('SearchItems', payload);
    final result = SearchResult.fromJson(response);

    cache.set(cacheKey, result);
    return result;
  }

  /// Gets browse nodes.
  Future<Map<String, dynamic>> getBrowseNodes({
    required List<String> browseNodeIds,
    List<String>? resources,
  }) async {
    final payload = {
      'BrowseNodeIds': browseNodeIds,
      'PartnerTag': partnerTag,
      'PartnerType': 'Associates',
      'Marketplace': marketplace,
      if (resources != null) 'Resources': resources,
    };

    final cacheKey = 'GetBrowseNodes_${jsonEncode(payload)}';
    final cached = cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    final response = await _sendRequest('GetBrowseNodes', payload);
    cache.set(cacheKey, response);
    return response;
  }

  Future<Map<String, dynamic>> _sendRequest(
      String operation, Map<String, dynamic> payload) async {
    final host = 'webservices.amazon.${marketplace.split('amazon.')[1]}';
    final uri = 'https://$host/paapi5/$operation';
    final payloadString = jsonEncode(payload);

    final headers = {
      'content-type': 'application/json; charset=utf-8',
      'content-encoding': 'amz-1.0',
      'host': host,
      'x-amz-target': 'com.amazon.paapi5.v1.ProductAdvertisingAPIv1.$operation',
    };

    final signedHeaders = signer.sign(
      method: 'POST',
      uri: uri,
      headers: headers,
      payload: payloadString,
    );

    return retryPolicy.execute(() async {
      await rateLimiter.acquire();

      final response = await httpClient.post(
        Uri.parse(uri),
        headers: signedHeaders,
        body: payloadString,
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 400 || decoded['Errors'] != null) {
        final errors = decoded['Errors'] as List<dynamic>?;
        final error = errors?.first as Map<String, dynamic>?;

        throw PaapiException(
          statusCode: response.statusCode,
          errorCode: error?['Code'] as String? ?? 'UnknownError',
          message: error?['Message'] as String? ?? 'An unknown error occurred.',
          requestId: decoded['__type'] as String?, // Approximated
        );
      }

      return decoded;
    }, (e) {
      if (e is PaapiException) {
        return e.statusCode == 429 || e.statusCode >= 500;
      }
      return true; // Retry network errors
    });
  }
}
