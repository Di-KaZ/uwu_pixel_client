import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uwu_pixel_client/provider/socket_handler.dart';

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

class Game extends ConsumerWidget {
  final String title;
  const Game({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketHandler = ref.watch(socketHandlerProvider.notifier);

    void onTap() {
      socketHandler.colorPixel(Pixel(null, 4, 3, "#ff0000"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: TextButton(
          onPressed: onTap,
          child: const Text('Test'),
        ),
      ),
    );
  }
}
