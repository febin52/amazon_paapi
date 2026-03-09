# amazon_paapi5

A production-ready Dart and Flutter SDK for the **Amazon Product Advertising API 5 (PAAPI 5)**.

Search for products, retrieve pricing data, fetch images, and handle affiliate data seamlessly with pure Dart AWS Signature V4 authentication.

## Features

- **Full PAAPI 5 Support**: Implementations for `SearchItems`, `GetItems`, `GetVariations`, and `GetBrowseNodes`.
- **Pure Dart AWS V4 Signer**: Built-in AWS Signature Version 4 signing (no external AWS dependencies).
- **Strongly Typed Models**: Parses responses into strictly typed Dart objects (`Item`, `Offer`, `Price`, `Image`, etc.).
- **Built-in Rate Limiting**: Ensures compliance with PAAPI account limits (e.g. 1 request/second).
- **Automatic Retries**: Exponential backoff retry policy for 429 and 5xx errors.
- **In-Memory Caching**: Basic TTL and LRU-based memory caching out of the box.

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  amazon_paapi5: ^1.0.0
```

## Quick Start
```dart
import 'package:amazon_paapi5/amazon_paapi5.dart';

void main() async {
  final client = PaapiClient(
    accessKey: "YOUR_ACCESS_KEY",
    secretKey: "YOUR_SECRET_KEY",
    partnerTag: "YOUR_PARTNER_TAG",
    marketplace: "www.amazon.com", // e.g., www.amazon.in, www.amazon.co.uk
  );

  try {
    final result = await client.searchItems(
      keywords: "flutter development",
      resources: [
        'ItemInfo.Title',
        'Offers.Listings.Price',
        'Images.Primary.Medium',
      ],
    );

    for (var item in result.items) {
      print('Title: ${item.title}');
      print('Price: ${item.offers?.firstOrNull?.price?.displayAmount}');
    }
  } on PaapiException catch (e) {
    print('Failed to search: ${e.message} (Code: ${e.errorCode})');
  } finally {
    client.dispose();
  }
}
```

## API Methods

The `PaapiClient` exposes the following main methods:
- `searchItems(keywords: String, resources: List<String>?, itemPage: int)`
- `getItems(itemIds: List<String>, resources: List<String>?)`
- `getVariations(asin: String, resources: List<String>?)`
- `getBrowseNodes(browseNodeIds: List<String>, resources: List<String>?)`

## Architecture
This package maintains a clean architecture:
- `assets/` models for Data Transfer Objects.
- `utils/` RateLimiter, RetryPolicy.
- `auth/` pure pure AWS V4 signatures.

## Security Best Practices
**Do not hardcode** your secret keys in client-side applications. For production apps, consider proxying requests through your own secure backend, or use Firebase Remote Config / Secret servers to inject keys at runtime if absolute client-side usage is required.

## Contributing
Issues and Pull Requests are welcome!

## License
MIT License.

# amazon_paapi
