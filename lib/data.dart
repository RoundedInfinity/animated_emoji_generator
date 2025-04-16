import 'package:recase/recase.dart';

class EmojiApiData {
  final String host;
  final String assetUrlPattern;
  final List<String> families;
  final List<IconData> icons;

  EmojiApiData({
    required this.host,
    required this.assetUrlPattern,
    required this.families,
    required this.icons,
  });

  factory EmojiApiData.fromJson(Map<String, dynamic> json) {
    return EmojiApiData(
      host: json['host'] ?? '',
      assetUrlPattern: json['asset_url_pattern'] ?? '',
      families: List<String>.from(json['families'] ?? []),
      icons: (json['icons'] as List<dynamic>)
          .map((e) => IconData.fromJson(e))
          .toList(),
    );
  }
}

class IconData {
  final String name;
  final int version;
  final int popularity;
  final String codepoint;
  final List<String> unsupportedFamilies;
  final List<String> categories;
  final List<String> tags;
  final List<int> sizesPx;

  IconData({
    required this.name,
    required this.version,
    required this.popularity,
    required this.codepoint,
    required this.unsupportedFamilies,
    required this.categories,
    required this.tags,
    required this.sizesPx,
  });

  /// The common name of the icon (e.g. "thumbs_up").
  String get commonName {
    final name = tags.first.replaceAll(":", "");

    // Handle edge cases.
    switch (name) {
      case '100':
        return 'oneHundred';
      case 'new':
        return 'newSymbol';
      case 'up!':
        return 'upSymbol';
      case 'piñata':
        return 'pinata';
      case '8Ball':
        return 'eightBall';
      default:
        return name.camelCase;
    }
  }

  factory IconData.fromJson(Map<String, dynamic> json) {
    return IconData(
      name: json['name'] ?? '',
      version: json['version'] ?? 0,
      popularity: json['popularity'] ?? 0,
      codepoint: json['codepoint'] ?? '',
      unsupportedFamilies:
          List<String>.from(json['unsupported_families'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      sizesPx: List<int>.from(json['sizes_px'] ?? []),
    );
  }
}
