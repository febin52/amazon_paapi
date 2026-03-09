import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amazon_paapi5/amazon_paapi5.dart';

void main() {
  group('PaapiClient', () {
    test('searchItems parses result correctly', () async {
      final mockResponse = {
        'SearchResult': {
          'TotalResultCount': 100,
          'Items': [
            {
              'ASIN': 'B000000000',
              'ItemInfo': {
                'Title': {'DisplayValue': 'Test Item'}
              }
            }
          ]
        }
      };

      final client = PaapiClient(
        accessKey: 'ACCESS_KEY',
        secretKey: 'SECRET_KEY',
        partnerTag: 'mytag-21',
        marketplace: 'www.amazon.com',
        httpClient: MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        }),
      );

      final result = await client.searchItems(keywords: 'test');

      expect(result, isA<SearchResult>());
      expect(result.totalResultCount, equals(100));
      expect(result.items.first.asin, equals('B000000000'));
      expect(result.items.first.title, equals('Test Item'));
    });
  });
}
