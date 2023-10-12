import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uwu_pixel_client/provider/socket_handler.dart';
import 'package:http/http.dart' as http;

part 'game_config.g.dart';

@JsonSerializable()
class GameConfig {
  const GameConfig(this.width, this.height, this.pixels);

  final int width;
  final int height;
  final List<Pixel> pixels;

  factory GameConfig.fromJson(Map<String, dynamic> json) =>
      _$GameConfigFromJson(json);

  Map<String, dynamic> toJson() => _$GameConfigToJson(this);
}

@riverpod
Future<GameConfig> gameConfig(GameConfigRef ref) async {
  final res = await http.get(Uri.parse('http://localhost:8080/initial_load'));
  final config = GameConfig.fromJson(jsonDecode(res.body));
  ref.read(socketHandlerProvider.notifier).init(config.pixels);
  return config;
}
