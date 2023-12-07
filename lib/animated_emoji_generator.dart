import 'package:dart_animated_emoji/generated/emoji_list.g.dart';
import 'package:dart_style/dart_style.dart';
import 'package:recase/recase.dart';

extension EmojiName on AnimatedEmoji {
  String get commonName {
    final tag = tags.first;

    // Handle edge cases.
    if (tag == '100') {
      return 'oneHundred';
    }
    if (tag == 'piñata') {
      return 'pinata';
    }
    if (tag == 'up!') {
      return 'upSymbol';
    }
    if (tag == 'new') {
      return 'newSymbol';
    }
    return tag.camelCase;
  }

  String get fileName {
    final name = commonName;
    String variant = '';

    if (codepoint.contains('_')) {
      final skinVariation = codepoint.split('_').last;
      if (skinVariation == '1f3fb') {
        variant = 'Light';
      }
      if (skinVariation == '1f3fc') {
        variant = 'MediumLight';
      }
      if (skinVariation == '1f3fd') {
        variant = 'Medium';
      }
      if (skinVariation == '1f3fe') {
        variant = 'MediumDark';
      }
      if (skinVariation == '1f3ff') {
        variant = 'Dark';
      }
    }
    return '$name$variant';
  }
}

class AnimatedEmojiDataGenerator {
  final List<AnimatedEmoji> emojis;

  AnimatedEmojiDataGenerator(this.emojis);

  static const String _utilityFunctions = '''
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
''';

  String _emojiData(AnimatedEmoji emoji) {
    return '''
  ///<picture>
  ///  <source srcset="https://fonts.gstatic.com/s/e/notoemoji/latest/${emoji.codepoint}/512.webp" type="image/webp">
  ///  <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/${emoji.codepoint}/512.gif" alt="${emoji.commonName}" width="32" height="32">
  ///</picture>
  ///
  /// Animated emoji of ${emoji.commonName}.
  static const ${emoji.commonName} = AnimatedEmojiData('${emoji.codepoint}',name: '${emoji.commonName}');

''';
  }

  String _tonedEmojiData(AnimatedEmoji emoji) {
    return '''
  ///<picture>
  ///  <source srcset="https://fonts.gstatic.com/s/e/notoemoji/latest/${emoji.codepoint}/512.webp" type="image/webp">
  ///  <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/${emoji.codepoint}/512.gif" alt="${emoji.commonName}" width="32" height="32">
  ///</picture>
  ///
  /// Animated emoji of ${emoji.commonName}.
  static const ${emoji.commonName} = AnimatedTonedEmojiData('${emoji.codepoint}',name: '${emoji.commonName}');

''';
  }

  String _baseClass(String content) {
    return '''
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

$content
}
''';
  }

  String _emojiVariables() {
    final buffer = StringBuffer();

    final Set<String> addedVariations = {};

    for (final emoji in emojis) {
      if (addedVariations.contains(emoji.commonName)) continue;

      final variations = emojis
          .where((element) => element.commonName == emoji.commonName)
          .toList();

      // No variations of this emoji exist.
      if (variations.length == 1) {
        buffer.writeln(_emojiData(emoji));
      } else {
        addedVariations.add(emoji.commonName);
        buffer.writeln(_tonedEmojiData(emoji));
      }
    }

    return buffer.toString();
  }

  String _emojiList() {
    final buffer = StringBuffer();

    final Set<String> addedVariations = {};

    for (final emoji in emojis) {
      if (addedVariations.contains(emoji.commonName)) continue;

      addedVariations.add(emoji.commonName);
      buffer.writeln('${emoji.commonName},');
    }

    return '''
/// All available values.
/// 
/// Does not contain all skin tone variations separately.
static const values = [${buffer.toString()}];''';
  }

  String generate({bool format = true}) {
    final emojiVariables = _emojiVariables();
    final values = _emojiList();
    final content =
        _baseClass('$emojiVariables \n $values \n $_utilityFunctions');

    // Formatting the file is performance heavy.
    if (format) return DartFormatter().format(content);

    return content;
  }
}
