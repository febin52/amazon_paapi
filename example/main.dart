import 'package:flutter/material.dart';
import 'package:paapi5_flutter/paapi5_flutter.dart' hide Image;

void main() {
  runApp(const PaapiExampleApp());
}

class PaapiExampleApp extends StatelessWidget {
  const PaapiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PAAPI 5 Example',
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _client = PaapiClient(
    accessKey: 'YOUR_ACCESS_KEY',
    secretKey: 'YOUR_SECRET_KEY',
    partnerTag: 'YOUR_PARTNER_TAG',
    marketplace: 'www.amazon.com',
  );

  final _searchController = TextEditingController(text: 'flutter programming');
  bool _isLoading = false;
  SearchResult? _result;
  String? _error;

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _client.searchItems(
        keywords: _searchController.text,
        resources: [
          'ItemInfo.Title',
          'Offers.Listings.Price',
          'Images.Primary.Medium',
        ],
      );
      setState(() {
        _result = result;
      });
    } on PaapiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amazon PAAPI 5 Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Keywords',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Error: $_error',
                  style: const TextStyle(color: Colors.red)),
            ),
          if (_result != null)
            Expanded(
              child: ListView.builder(
                itemCount: _result!.items.length,
                itemBuilder: (context, index) {
                  final item = _result!.items[index];
                  return ListTile(
                    leading: item.primaryImage?.url != null
                        ? Image.network(item.primaryImage!.url!)
                        : const Icon(Icons.shopping_bag),
                    title: Text(item.title ?? 'Unknown Title'),
                    subtitle: Text(
                        item.offers?.firstOrNull?.price?.displayAmount ??
                            'Price unavailable'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
