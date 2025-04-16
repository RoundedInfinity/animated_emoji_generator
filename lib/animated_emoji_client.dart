import 'dart:convert';
import 'dart:io';

import 'package:animated_emoji_generator/data.dart';
import 'package:http/http.dart' as http;

class EmojiApi {
  final String baseUrl;

  EmojiApi({
    this.baseUrl = "https://googlefonts.github.io/noto-emoji-animation",
  });

  Future<EmojiApiData> fetchEmojiData() async {
    final response = await http.get(Uri.parse('$baseUrl/data/api.json'));

    if (response.statusCode == HttpStatus.ok) {
      return EmojiApiData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load emoji data');
    }
  }
}
