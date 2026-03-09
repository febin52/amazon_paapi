import 'dart:convert';
import 'package:http/http.dart' as http;

import '../auth/aws_v4_signer.dart';
import '../cache/memory_cache.dart';
import '../exceptions/api_exception.dart';
import '../models/search_result.dart';
import '../utils/rate_limiter.dart';
import '../utils/retry_policy.dart';

/// Handles GetItems and GetVariations operations.
class ItemService {
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

  /// Creates an [ItemService].
  ItemService({
    required this.signer,
    required this.partnerTag,
    required this.marketplace,
    required this.httpClient,
    required this.rateLimiter,
    required this.retryPolicy,
    required this.cache,
  });

  /// Retrieves specific items by ASIN.
  Future<SearchResult> getItems({
    required List<String> itemIds,
    List<String>? resources,
  }) async {
    final payload = {
      'ItemIds': itemIds,
      'PartnerTag': partnerTag,
      'PartnerType': 'Associates',
      'Marketplace': marketplace,
      if (resources != null) 'Resources': resources,
    };

    final cacheKey = 'GetItems_${jsonEncode(payload)}';
    final cached = cache.get<SearchResult>(cacheKey);
    if (cached != null) {
      return cached;
    }

    final response = await _sendRequest('GetItems', payload);
    final result = SearchResult.fromJson(response);

    cache.set(cacheKey, result);
    return result;
  }

  /// Retrieves variations for a given ASIN.
  Future<SearchResult> getVariations({
    required String asin,
    List<String>? resources,
  }) async {
    final payload = {
      'ASIN': asin,
      'PartnerTag': partnerTag,
      'PartnerType': 'Associates',
      'Marketplace': marketplace,
      if (resources != null) 'Resources': resources,
    };

    final cacheKey = 'GetVariations_${jsonEncode(payload)}';
    final cached = cache.get<SearchResult>(cacheKey);
    if (cached != null) {
      return cached;
    }

    final response = await _sendRequest('GetVariations', payload);
    final result = SearchResult.fromJson(response);

    cache.set(cacheKey, result);
    return result;
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
          requestId: decoded['__type'] as String?,
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
