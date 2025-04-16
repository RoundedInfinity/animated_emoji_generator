import 'package:test/test.dart';
import 'package:animated_emoji_generator/animated_emoji_generator.dart';
import 'package:animated_emoji_generator/data.dart';
import 'package:animated_emoji_generator/emoji.dart';

void main() {
  group('EmojiApiData', () {
    test('should create EmojiApiData from JSON', () {
      final json = {
        'host': 'test.com',
        'asset_url_pattern': 'test/{id}',
        'families': ['family1', 'family2'],
        'icons': [
          {
            'name': 'smile',
            'version': 1,
            'popularity': 100,
            'codepoint': '1f603',
            'unsupported_families': [],
            'categories': ['Smileys & Emotion'],
            'tags': [':smile:'],
            'sizes_px': [32, 64, 128]
          }
        ]
      };

      final data = EmojiApiData.fromJson(json);

      expect(data.host, 'test.com');
      expect(data.assetUrlPattern, 'test/{id}');
      expect(data.families, ['family1', 'family2']);
      expect(data.icons.length, 1);
    });
  });

  group('IconData', () {
    test('should create IconData from JSON', () {
      final json = {
        'name': 'smile',
        'version': 1,
        'popularity': 100,
        'codepoint': '1f603',
        'unsupported_families': [],
        'categories': ['Smileys & Emotion'],
        'tags': [':smile:'],
        'sizes_px': [32, 64, 128]
      };

      final icon = IconData.fromJson(json);

      expect(icon.name, 'smile');
      expect(icon.version, 1);
      expect(icon.popularity, 100);
      expect(icon.codepoint, '1f603');
      expect(icon.categories, ['Smileys & Emotion']);
      expect(icon.tags, [':smile:']);
      expect(icon.sizesPx, [32, 64, 128]);
    });

    test('should handle edge cases in commonName', () {
      final testCases = {
        '100': 'oneHundred',
        'new': 'newSymbol',
        'up!': 'upSymbol',
        'piñata': 'pinata',
        '8Ball': 'eightBall',
        'regular_name': 'regularName',
      };

      for (final entry in testCases.entries) {
        final icon = IconData(
          name: 'test',
          version: 1,
          popularity: 1,
          codepoint: '1f000',
          unsupportedFamilies: [],
          categories: [],
          tags: [':${entry.key}:'],
          sizesPx: [],
        );

        expect(icon.commonName, entry.value);
      }
    });
  });

  group('AnimatedEmojiData', () {
    test('should create basic emoji data', () {
      const emoji = AnimatedEmojiData(
        '1f603',
        name: 'smile',
        categories: ['Smileys & Emotion'],
        tags: [':smile:', ':happy:'],
      );

      expect(emoji.id, '1f603');
      expect(emoji.name, 'smile');
      expect(emoji.categories, ['Smileys & Emotion']);
      expect(emoji.tags, [':smile:', ':happy:']);
      expect(emoji.hasSkinTones, false);
    });

    test('should convert to unicode emoji', () {
      const emoji = AnimatedEmojiData('1f603', name: 'smile');
      expect(emoji.toUnicodeEmoji(), '😃');
    });

    test('should handle compound unicode emoji', () {
      const emoji = AnimatedEmojiData('1f468_1f3fd', name: 'man');
      expect(emoji.toUnicodeEmoji(), '👨🏽');
    });
  });

  group('AnimatedTonedEmojiData', () {
    late AnimatedTonedEmojiData tonedEmoji;

    setUp(() {
      tonedEmoji = const AnimatedTonedEmojiData(
        '1f44d',
        name: 'thumbsUp',
        categories: ['People & Body'],
        tags: [':thumbsup:'],
      );
    });

    test('should have skin tone variations', () {
      expect(tonedEmoji.hasSkinTones, true);
      expect(tonedEmoji.light.id, '1f44d_1f3fb');
      expect(tonedEmoji.mediumLight.id, '1f44d_1f3fc');
      expect(tonedEmoji.medium.id, '1f44d_1f3fd');
      expect(tonedEmoji.mediumDark.id, '1f44d_1f3fe');
      expect(tonedEmoji.dark.id, '1f44d_1f3ff');
    });

    test('should create skin tone variation with withSkinTone method', () {
      final variation = tonedEmoji.withSkinTone(SkinTone.dark);
      expect(variation.id, '1f44d_1f3ff');
      expect(variation.name, 'thumbsUpDark');
    });
  });

  group('AnimatedEmojiDataGenerator', () {
    late AnimatedEmojiDataGenerator generator;
    late EmojiApiData testData;

    setUp(() {
      generator = AnimatedEmojiDataGenerator();
      testData = EmojiApiData(
        host: '',
        assetUrlPattern: '',
        families: [''],
        icons: [
          IconData(
            name: 'smile',
            version: 1,
            popularity: 100,
            codepoint: '1f603',
            unsupportedFamilies: [],
            categories: ['Smileys & Emotion'],
            tags: [':smile:'],
            sizesPx: [],
          ),
          IconData(
            name: 'thumbs_up',
            version: 1,
            popularity: 100,
            codepoint: '1f44d_1f3fb',
            unsupportedFamilies: [],
            categories: ['People & Body'],
            tags: [':thumbs-up:'],
            sizesPx: [],
          ),
          IconData(
            name: 'thumbs_up',
            version: 1,
            popularity: 100,
            codepoint: '1f44d',
            unsupportedFamilies: [],
            categories: ['People & Body'],
            tags: [':thumbsup:'],
            sizesPx: [],
          ),
        ],
      );
    });

    test('should generate emoji data from API data', () {
      final emojiData = generator.generateEmojiData(testData);

      expect(emojiData.length, 2); // One regular emoji and one toned emoji

      final regularEmoji = emojiData.firstWhere((e) => e.id == '1f603');
      expect(regularEmoji.hasSkinTones, false);

      final tonedEmoji =
          emojiData.firstWhere((e) => e is AnimatedTonedEmojiData);
      expect(tonedEmoji.hasSkinTones, true);
    });

    test('should generate valid Dart code', () {
      final emojiData = generator.generateEmojiData(testData);
      final code = generator.generateCode(emojiData);

      expect(code, contains('class AnimatedEmojis'));
      expect(code, contains('static const smile'));
      expect(code, contains('static const thumbsUp'));
      expect(code, contains('static const List<AnimatedEmojiData> values'));
    });
  });
}
