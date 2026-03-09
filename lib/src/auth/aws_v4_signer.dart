import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

/// Implements AWS Signature Version 4 signing for the PAAPI.
/// Follows the official AWS signing specification.
class AwsV4Signer {
  /// The AWS Access Key ID.
  final String accessKeyId;

  /// The AWS Secret Access Key.
  final String secretAccessKey;

  /// The AWS region (e.g. 'us-east-1', 'eu-west-1').
  final String region;

  /// The AWS service name (PAAPI uses 'ProductAdvertisingAPI').
  final String service;

  /// Creates an [AwsV4Signer].
  AwsV4Signer({
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.region,
    this.service = 'ProductAdvertisingAPI',
  });

  /// Signs a request and returns the headers map including the
  /// 'Authorization' header and 'X-Amz-Date' header.
  Map<String, String> sign({
    required String method,
    required String uri,
    required Map<String, String> headers,
    required String payload,
  }) {
    final now = DateTime.now().toUtc();
    final amzDateFormatter = DateFormat("yyyyMMdd'T'HHmmss'Z'");
    final dateOnlyFormatter = DateFormat('yyyyMMdd');

    final amzDate = amzDateFormatter.format(now);
    final dateStamp = dateOnlyFormatter.format(now);

    final updatedHeaders = Map<String, String>.from(headers);
    updatedHeaders['x-amz-date'] = amzDate;

    // 1. Create a Canonical Request
    final canonicalUri = Uri.encodeFull(uri);
    const canonicalQueryString =
        ''; // PAAPI POST requests typically have no query string

    final sortedHeaderKeys =
        updatedHeaders.keys.map((k) => k.toLowerCase()).toList()..sort();
    final canonicalHeaders = sortedHeaderKeys.map((k) {
      final value = updatedHeaders.entries
          .firstWhere((e) => e.key.toLowerCase() == k)
          .value;
      return '$k:${value.trim()}\n';
    }).join('');

    final signedHeaders = sortedHeaderKeys.join(';');
    final payloadHash = _hash(utf8.encode(payload));

    final canonicalRequest = [
      method,
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    // 2. Create the String to Sign
    const algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope = '$dateStamp/$region/$service/aws4_request';
    final stringToSign = [
      algorithm,
      amzDate,
      credentialScope,
      _hash(utf8.encode(canonicalRequest)),
    ].join('\n');

    // 3. Calculate the Signature
    final kSecret = utf8.encode('AWS4$secretAccessKey');
    final kDate = _hmac(kSecret, utf8.encode(dateStamp));
    final kRegion = _hmac(kDate, utf8.encode(region));
    final kService = _hmac(kRegion, utf8.encode(service));
    final kSigning = _hmac(kService, utf8.encode('aws4_request'));
    final signature = _hmac(kSigning, utf8.encode(stringToSign))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    // 4. Create the Authorization Header
    updatedHeaders['Authorization'] =
        '$algorithm Credential=$accessKeyId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    return updatedHeaders;
  }

  String _hash(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  List<int> _hmac(List<int> key, List<int> data) {
    return Hmac(sha256, key).convert(data).bytes;
  }
}
