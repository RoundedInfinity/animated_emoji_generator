import 'dart:io';

import 'package:animated_emoji_generator/animated_emoji_generator.dart';
import 'package:args/args.dart';
import 'package:dart_animated_emoji/dart_animated_emoji.dart';
import 'package:mason_logger/mason_logger.dart';

import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

const emojiMetadataUrl =
    'https://raw.githubusercontent.com/googlefonts/emoji-metadata/main/emoji_15_1_ordering.json';

const emojiBaseUrl = 'https://fonts.gstatic.com/s/e/notoemoji/latest/';

void main(List<String> arguments) async {
  var parser = ArgParser();

  parser.addFlag('verbose', abbr: 'v');
  parser.addFlag('download', abbr: 'd', defaultsTo: null);

  parser.addFlag(
    'format',
    abbr: 'f',
    defaultsTo: true,
    help: 'If the output file should be formatted following dartfm.',
  );

  final results = parser.parse(arguments);

  final logger = Logger(level: results['verbose'] ? Level.verbose : Level.info);

  final emojis = AnimatedEmoji.all;

  logger.info('Generating class for ${emojis.length} emojis...');

  final generator = AnimatedEmojiDataGenerator(emojis);

  final content = generator.generate(format: results['format']);

  logger.detail('Generated content. Writing to file...');

  final file = await File(path.join(path.current, 'gen', 'emojis.g.dart'))
      .create(recursive: true);

  await file.writeAsString(content);
  logger.success('Generated emojis.g.dart');

  var shouldDownload = results['download'] as bool?;

  shouldDownload ??=
      logger.confirm('Do you want to download the emoji lottie files?');

  if (shouldDownload) {
    logger.detail('Downloading lottie files');
    int downloadCount = 0;
    final progress = logger
        .progress('Downloaded $downloadCount / ${emojis.length} lottie files');

    for (final emoji in emojis) {
      final content = await http
          .get(Uri.parse('$emojiBaseUrl${emoji.codepoint}/lottie.json'));

      final file = await File(path.join(
              path.current, 'gen', 'lottie', '${emoji.fileName}.json'))
          .create(recursive: true);

      await file.writeAsString(content.body);

      downloadCount++;

      logger.detail('Saved ${emoji.fileName}');
      progress
          .update('Downloaded $downloadCount / ${emojis.length} lottie files');
    }

    progress.complete();
  }

  logger.success('Successfully generated assets for animated emojis.');
}
