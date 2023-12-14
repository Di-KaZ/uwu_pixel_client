import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uwu_pixel_client/provider/game_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:json_annotation/json_annotation.dart';

part 'socket_handler.g.dart';

/// Represent a pixel in the grid
@immutable
@JsonSerializable()
class Pixel {
  const Pixel(this.x, this.y, this.color);

  final int x;
  final int y;
  final String color;

  Map<String, dynamic> toJson() => _$PixelToJson(this);
  factory Pixel.fromJson(Map<String, dynamic> json) => _$PixelFromJson(json);
}

final socketHandlerProvider =
    StateNotifierProvider<SocketHandler, List<Pixel>>((ref) {
  return SocketHandler();
});

/// handle socket message to update the game board with newly added pixels
class SocketHandler extends StateNotifier<List<Pixel>> {
  final uri = Uri.parse('ws://localhost:8080/update');
  late final channel = WebSocketChannel.connect(uri);

  /// recive a message server containting a json seiralized [Pixel]
  /// and update the app state with the new point
  void _handleServerMessage(dynamic data) {
    if (data is String) {
      try {
        final newPixel = Pixel.fromJson(jsonDecode(data));

        final existingPixelIndex =
            state.indexWhere((p) => p.x == newPixel.x && p.y == newPixel.y);

        if (existingPixelIndex != -1) {
          state = List.from(state)
            ..replaceRange(
                existingPixelIndex, existingPixelIndex + 1, [newPixel]);
        } else {
          state = List.from(state)..add(newPixel);
        }
      } catch (e) {
        /// silently ignore error ( ˘ ɜ˘) ♬ ♪ ♫
        print(e);
      }
    }
  }

  SocketHandler() : super([]) {
    channel.stream.listen(_handleServerMessage);
  }

  /// send a message to the server telling him to color the given pixel
  void colorPixel(Pixel pixel) {
    channel.sink.add(jsonEncode(pixel.toJson()));
  }

  /// load initial data see [gameConfigProvider] for usage
  void init(List<Pixel> pixels) {
    state = pixels;
  }
}
