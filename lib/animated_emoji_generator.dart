import 'package:animated_emoji_generator/data.dart';
import 'package:animated_emoji_generator/emoji.dart';

class AnimatedEmojiDataGenerator {
  List<AnimatedEmojiData> generateEmojiData(EmojiApiData data) {
    // Group emojis by their common name
    final groupedEmojis = <String, List<IconData>>{};

    for (final emoji in data.icons) {
      final commonName = emoji.commonName;
      groupedEmojis.putIfAbsent(commonName, () => []).add(emoji);
    }

    final emojiData = <AnimatedEmojiData>[];

    for (final entry in groupedEmojis.entries) {
      final icons = entry.value;
      final baseIcon = icons.first;

      // If there's only one icon, create a regular AnimatedEmojiData
      if (icons.length == 1) {
        emojiData.add(AnimatedEmojiData(
          baseIcon.codepoint,
          name: baseIcon.commonName,
          categories: baseIcon.categories,
          tags: baseIcon.tags,
        ));
        continue;
      }

      // If there are multiple icons, create an AnimatedTonedEmojiData
      emojiData.add(AnimatedTonedEmojiData(
        baseIcon.codepoint,
        name: baseIcon.commonName,
        baseId: baseIcon.codepoint.split('_').first,
        categories: baseIcon.categories,
        tags: baseIcon.tags,
      ));
    }

    return emojiData;
  }

  String generateCode(List<AnimatedEmojiData> emojis) {
    final content = <String>[];

    for (final emoji in emojis) {
      if (emoji is AnimatedTonedEmojiData) {
        content.add(_Templates.generateTonedEmoji(emoji));
      } else {
        content.add(_Templates.generateRegularEmoji(emoji));
      }
    }

    content.add(_Templates.generateValues(emojis));

    return _Templates.baseClass(content);
  }
}

class _Templates {
  static String baseClass(List<String> content) {
    return '''
// Generated code. Do not modify. Generated at ${DateTime.now()}.

/// Identifiers for the supported [Noto Animated Emojis](https://googlefonts.github.io/noto-emoji-animation/).
///
/// Use with the [AnimatedEmoji] class to show specific emojis.
/// Emojis are identified by their name as listed below,
/// e.g. [AnimatedEmojis.smile].
///
/// Some of the emojis have skin tone variations.
///
/// Example usage:
/// ```dart
/// // An animated thumbs up emoji 👍.
/// AnimatedEmoji(AnimatedEmojis.thumbsUp)
/// // Go get a skin tone variation 👍🏿.
/// AnimatedEmoji(AnimatedEmojis.thumbsUp.dark)
/// ```
class AnimatedEmojis {
  AnimatedEmojis._();

  ${content.join("\n\n")}

  /// Returns the name of the emoji from the [id] in camel case.
  ///
  /// For example: `1f603` => smileWithBigEyes
  ///
  /// Throws a [EmojiNotFoundException] when no emoji with [id] exists.
  ///
  /// See also:
  /// - [getIdFromName]
  static String getCamelCaseName(String id) {
    return AnimatedEmojiDataUtil.getCamelCaseName(id);
  }

  /// Return the id of the emoji from its camel case name.
  ///
  /// For example: 'smileWithBigEyes' => `1f603`.
  ///
  /// Throws a [EmojiNotFoundException] when no emoji with [name] exists.
  ///
  /// See also:
  /// - [getCamelCaseName]
  static String? getIdFromName(String name) {
    return AnimatedEmojiDataUtil.getIdFromName(name);
  }

  /// Return the animated emoji that equals [id].
  ///
  /// When no emoji is found a [EmojiNotFoundException] is thrown.
  ///
  /// ```dart
  /// // Will return a firework emoji 🎆
  /// AnimatedEmojis.fromId('1f386')
  /// ```
  static AnimatedEmojiData fromId(String id) {
    return AnimatedEmojiDataUtil.fromId(id);
  }

  /// Return the animated emoji of [name].
  ///
  /// When no emoji is found a [EmojiNotFoundException] is thrown.
  ///
  /// ```dart
  /// // Will return a rose emoji 🌹
  /// AnimatedEmojis.fromName('rose')
  /// ```
  static AnimatedEmojiData fromName(String name) {
    return AnimatedEmojiDataUtil.fromName(name);
  }

  /// Return the animates emoji that equals a [emoji].
  ///
  /// When no matching animated emoji is found, `null` is returned.
  ///
  ///```dart
  /// // will return animated emoji of redHeart ❤️
  /// final animated = AnimatedEmojis.fromEmojiString('❤️') // returns AnimatedEmojis.redHeart
  /// ```
  static AnimatedEmojiData? fromEmojiString(String emoji) {
    return AnimatedEmojiDataUtil.fromEmojiString(emoji);
  }
}
''';
  }

  static String generateMetadata(AnimatedEmojiData emoji) {
    final categories = emoji.categories.map((e) => "'$e'").join(', ');
    final tags = emoji.tags.map((e) => "'$e'").join(', ');
    return 'categories: [$categories], tags: [$tags]';
  }

  static String generateRegularEmoji(AnimatedEmojiData emoji) {
    return '''
  ///<picture>
  ///  <source srcset="https://fonts.gstatic.com/s/e/notoemoji/latest/${emoji.id}/512.webp" type="image/webp">
  ///  <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/${emoji.id}/512.gif" alt="${emoji.name}" width="32" height="32">
  ///</picture>
  ///
  /// Animated emoji of ${emoji.name}.
  static const ${emoji.name} = AnimatedEmojiData('${emoji.id}', name: '${emoji.name}', ${generateMetadata(emoji)});
  ''';
  }

  static String generateTonedEmoji(AnimatedTonedEmojiData emoji) {
    return '''
  ///<picture>
  ///  <source srcset="https://fonts.gstatic.com/s/e/notoemoji/latest/${emoji.id}/512.webp" type="image/webp">
  ///  <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/${emoji.id}/512.gif" alt="${emoji.name}" width="32" height="32">
  ///</picture>
  ///
  /// Animated emoji of ${emoji.name}.
  /// 
  /// This emoji has skin tone variations.
  /// 
  /// See also:
  /// - [AnimatedTonedEmojiData] for an example on how to use skin tone variations.
  static const ${emoji.name} = AnimatedTonedEmojiData('${emoji.baseId}', name: '${emoji.name}', ${generateMetadata(emoji)});
  ''';
  }

  static String generateValues(List<AnimatedEmojiData> dat) {
    final values = <String>[];

    for (final emoji in dat) {
      if (emoji is AnimatedTonedEmojiData) {
        values.add(emoji.name);
      } else {
        values.add(emoji.name);
      }
    }

    return '''
  /// List of all supported [AnimatedEmoji]s.
  static const List<AnimatedEmojiData> values = [
    ${values.join(',\n    ')}
  ];
''';
  }
}
