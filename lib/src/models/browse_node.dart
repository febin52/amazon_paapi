/// Represents a browse node (category) in the Amazon catalog.
class BrowseNode {
  /// The unique identifier of the browse node.
  final String? id;

  /// The display name of the browse node.
  final String? displayName;

  /// The context free name of the browse node.
  final String? contextFreeName;

  /// The sales rank of the item within this browse node.
  final int? salesRank;

  /// Creates a [BrowseNode] instance.
  const BrowseNode({
    this.id,
    this.displayName,
    this.contextFreeName,
    this.salesRank,
  });

  /// Parses a [BrowseNode] from a JSON map.
  factory BrowseNode.fromJson(Map<String, dynamic> json) {
    return BrowseNode(
      id: json['Id'] as String?,
      displayName: json['DisplayName'] as String?,
      contextFreeName: json['ContextFreeName'] as String?,
      salesRank: json['SalesRank'] as int?,
    );
  }
}
