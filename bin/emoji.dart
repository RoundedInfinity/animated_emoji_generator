/// A description of an animated emoji.
class AnimatedEmojiData {
  /// A description of an animated emoji.
  const AnimatedEmojiData(this.id, {required this.name});

  /// The identifier of the emoji.
  ///
  /// See [Noto Animated Emoji](https://googlefonts.github.io/noto-emoji-animation/) for the available ids.
  final String id;

  final String name;

  /// Return the unicode emoji associated with this emoji.
  ///
  /// Example:
  /// ```dart
  /// final emoji = AnimatedEmojis.angry.toUnicodeEmoji();
  /// print(emoji); // Prints 😠
  /// ```
  String toUnicodeEmoji() {
    final codes = <int>[];

    final parts = id.substring(1).split('_');
    for (final part in parts) {
      codes.add(int.parse(part, radix: 16));
    }
    return String.fromCharCodes(codes);
  }

  @override
  String toString() {
    return 'AnimatedEmojiData(${toUnicodeEmoji()})';
  }

  @override
  bool operator ==(covariant AnimatedEmojiData other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class AnimatedTonedEmojiData extends AnimatedEmojiData {
  const AnimatedTonedEmojiData(
    super.id, {
    required super.name,
    this.baseId,
  });

  final String? baseId;

  String get _baseId => baseId ?? id.split('_').first;

  AnimatedEmojiData get light =>
      AnimatedEmojiData('${_baseId}_1f3fb', name: name);
  AnimatedEmojiData get mediumLight =>
      AnimatedEmojiData('${_baseId}_1f3fc', name: name);
  AnimatedEmojiData get medium =>
      AnimatedEmojiData('${_baseId}_1f3fd', name: name);
  AnimatedEmojiData get mediumDark =>
      AnimatedEmojiData('${_baseId}_1f3fe', name: name);
}
