import 'dart:io';
import 'package:animated_emoji_generator/emoji.dart';
import 'package:http/http.dart' as http;
import 'package:animated_emoji_generator/animated_emoji_client.dart';
import 'package:animated_emoji_generator/animated_emoji_generator.dart';
import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';

/// Base URL for Google's Noto Emoji font assets
const emojiBaseUrl = 'https://fonts.gstatic.com/s/e/notoemoji/latest/';

/// Entry point of the animated emoji generator CLI tool.
/// This script fetches emoji data, generates Dart code, and optionally downloads Lottie assets.
void main(List<String> arguments) async {
  // Set up command line argument parsing
  var parser = ArgParser();

  // Add verbose flag for detailed logging
  parser.addFlag('verbose', abbr: 'v', help: "Enable verbose logging");
  // Add download flag to control Lottie file downloading
  parser.addFlag('download',
      abbr: 'd', defaultsTo: null, help: "Download lottie files");

  // Add help flag
  parser.addFlag('help',
      abbr: 'h', help: 'Display this help message', negatable: false);

  final results = parser.parse(arguments);

  // Handle help flag
  if (results['help']) {
    print('Animated Emoji Generator\n');
    print('A tool to generate Flutter animated emoji assets.\n');
    print('Usage: dart run animated_emoji_generator [options]\n');
    print('Options:');
    print(parser.usage);
    exit(0);
  }

  // Initialize logger with appropriate verbosity level
  final logger = Logger(level: results['verbose'] ? Level.verbose : Level.info);

  // Initialize the emoji API client
  final api = EmojiApi();

  logger.info('Generating animated emojis...');

  // Start progress indicator for fetching emoji data
  final progress = logger.progress("Fetching emoji data");

  /// Fetch emoji metadata from the API
  final data = await api.fetchEmojiData();

  logger.detail('Fetched ${data.icons.length} animated emojis');

  progress.update("Generating animated emojis");

  // Generate Dart code from emoji data
  final generator = AnimatedEmojiDataGenerator();
  final emojis = generator.generateEmojiData(data);

  final code = generator.generateCode(emojis);

  progress.update("Creating output file");

  // Write the generated code to a file
  final outputFile = File('lib/generated/animated_emoji.g.dart');
  await outputFile.writeAsString(code);

  progress.complete();

  // Provide a clickable link to the generated file
  final outputLink = link(
    message: "animated_emoji.g.dart",
    uri: Uri.parse(outputFile.absolute.path),
  );

  logger.success("Generated animated emojis at $outputLink");

  // Determine whether to download Lottie files based on user input or flag
  var shouldDownload = results['download'] as bool?;

  shouldDownload ??=
      logger.confirm('Do you want to download the emoji lottie files?');

  if (shouldDownload) {
    // Download and save Lottie animation files for each emoji
    logger.detail('Downloading lottie files');
    int downloadCount = 0;
    final progress = logger
        .progress('Downloaded $downloadCount / ${emojis.length} lottie files');

    for (final emoji in emojis) {
      for (final variation in emoji.variations) {
        // Fetch Lottie JSON from Google's servers
        final content = await http
            .get(Uri.parse('$emojiBaseUrl${variation.id}/lottie.json'));

        // Save Lottie file to local filesystem
        final file =
            await File('lib/generated/lottie/${variation.name}.json').create(
          recursive: true,
        );
        await file.writeAsString(content.body);

        downloadCount++;
      }

      logger.detail('Saved ${emoji.name} lottie file');
      progress
          .update('Downloaded $downloadCount / ${emojis.length} lottie files');
    }

    progress.complete();
  }
  logger.success('Successfully generated assets for animated emojis.');
}
