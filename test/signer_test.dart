import 'package:flutter_test/flutter_test.dart';
import 'package:paapi5_flutter/paapi5_flutter.dart';

void main() {
  group('AwsV4Signer', () {
    test('creates correct authorization header structure', () {
      final signer = AwsV4Signer(
        accessKeyId: 'ACCESS_KEY',
        secretAccessKey: 'SECRET_KEY',
        region: 'us-east-1',
      );

      final signedHeaders = signer.sign(
        method: 'POST',
        uri: 'https://webservices.amazon.com/paapi5/SearchItems',
        headers: {
          'host': 'webservices.amazon.com',
          'content-type': 'application/json; charset=utf-8',
        },
        payload: '{"Keywords":"test"}',
      );

      expect(signedHeaders.containsKey('Authorization'), isTrue);
      expect(signedHeaders.containsKey('x-amz-date'), isTrue);

      final auth = signedHeaders['Authorization']!;
      expect(
          auth.startsWith('AWS4-HMAC-SHA256 Credential=ACCESS_KEY/'), isTrue);
      expect(
          auth.contains('SignedHeaders=content-type;host;x-amz-date'), isTrue);
      expect(auth.contains('Signature='), isTrue);
    });
  });
}
