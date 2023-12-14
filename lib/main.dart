import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uwu_pixel_client/provider/game_config.dart';
import 'package:uwu_pixel_client/provider/socket_handler.dart';

extension HexColor on Color {
  /// shamelessly stolen from https://stackoverflow.com/questions/50081213/how-do-i-use-hexadecimal-color-strings-in-flutter
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'uwu pixel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Game(title: 'uwu pixel'),
    );
  }
}

class Game extends ConsumerWidget {
  final String title;
  const Game({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(gameConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: config.when(
        data: (config) => GameBoard(config: config),
        error: (_, __) => const Center(
          child: Text('an error occured please relaunch app'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class GameBoard extends HookConsumerWidget {
  final GameConfig config;
  GameBoard({super.key, required this.config});

  final GlobalKey canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketHandler = ref.watch(socketHandlerProvider.notifier);
    final pixels = ref.watch(socketHandlerProvider);
    final pickedColor = useState(const Color(0xffff0000));

    void colorPixelAt(TapUpDetails details) {
      final canvaSize = canvasKey.currentContext!.size;

      final cellSize =
          min(canvaSize!.width / config.width, canvaSize.height / config.height)
              .floor()
              .toDouble();

      RenderBox renderBox = context.findRenderObject() as RenderBox;

      Offset tapPositionInCanva =
          renderBox.globalToLocal(details.globalPosition);
      final pixelX = (tapPositionInCanva.dx / cellSize).floor();
      final pixelY = (tapPositionInCanva.dy / cellSize).floor();
      socketHandler
          .colorPixel(Pixel(pixelX, pixelY, pickedColor.value.toHex()));
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: GestureDetector(
            key: canvasKey,
            onTapUp: colorPixelAt,
            child: Container(
              width: double.infinity,
              color: Colors.grey,
              child: CustomPaint(
                painter: GameBoardPainter(
                  pixels: pixels,
                  config: config,
                ),
              ),
            ),
          ),
        ),
        ColorPicker(
          pickerColor: pickedColor.value,
          onColorChanged: (c) => pickedColor.value = c,
          enableAlpha: false,
        )
      ],
    );
  }
}

/// Custom painter to render pixels keeping aspect ratio with some math
class GameBoardPainter extends CustomPainter {
  final List<Pixel> pixels;
  final GameConfig config;

  GameBoardPainter({required this.pixels, required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = min(size.width / config.width, size.height / config.height)
        .floor()
        .toDouble();

    for (final pixel in pixels) {
      canvas.drawRect(
        Rect.fromLTWH(
          pixel.x * cellSize, // x
          pixel.y * cellSize, // y
          cellSize,
          cellSize,
        ),
        Paint()..color = HexColor.fromHex(pixel.color),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
