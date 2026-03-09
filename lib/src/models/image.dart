/// Represents an image provided by the PAAPI 5 API.
class Image {
  /// The URL of the image.
  final String? url;

  /// The height of the image in pixels.
  final int? height;

  /// The width of the image in pixels.
  final int? width;

  /// Creates an [Image] instance.
  const Image({
    this.url,
    this.height,
    this.width,
  });

  /// Parses an [Image] from a JSON map.
  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      url: json['URL'] as String?,
      height: json['Height']?['Pixels'] as int?,
      width: json['Width']?['Pixels'] as int?,
    );
  }
}
