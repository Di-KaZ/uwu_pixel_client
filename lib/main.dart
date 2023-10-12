import 'package:flutter/material.dart';
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

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
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

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
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
        error: (_, __) => const Loader(),
        loading: () => const Loader(),
      ),
    );
  }
}

class GameBoard extends ConsumerWidget {
  final GameConfig config;
  const GameBoard({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketHandler = ref.watch(socketHandlerProvider.notifier);
    final pixels = ref.watch(socketHandlerProvider);

    void onTap() {
      socketHandler.colorPixel(Pixel(null, 4, 3, "#ff0000"));
    }

    return CustomPaint(
      painter: GameBoardPainter(pixels: pixels),
    );
  }
}

class GameBoardPainter extends CustomPainter {
  final List<Pixel> pixels;

  GameBoardPainter({required this.pixels});

  @override
  void paint(Canvas canvas, Size size) {
    for (final pixel in pixels) {
      canvas.drawRect(
          Rect.fromLTWH(pixel.x.toDouble(), pixel.y.toDouble(), 20, 20),
          Paint()..color = HexColor.fromHex(pixel.color));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
