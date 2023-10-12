import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

class SocketHandler extends StateNotifier<List<Pixel>> {
  final uri = Uri.parse('ws://localhost:8080/update');
  late final channel = WebSocketChannel.connect(uri);

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
        print(e);
      }
    }
  }

  SocketHandler() : super([]) {
    channel.stream.listen(_handleServerMessage);
  }

  void colorPixel(Pixel pixel) {
    print('sending pixel ${pixel.toJson()}');
    channel.sink.add(jsonEncode(pixel.toJson()));
  }

  void init(List<Pixel> pixels) {
    state = pixels;
  }
}
