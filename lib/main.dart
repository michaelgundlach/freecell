import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'util/deck-style.dart';
import 'views/ui/intro-screen.dart';

final deckStyleProvider = Provider<DeckStyle>((ref) {
  // Can't express radius as a % of width; give smaller on small screens
  const radius = kIsWeb ? 8.0 : 4.0;
  return DeckStyle(
    radius: radius,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: const BorderSide(color: Colors.black45, width: 1),
    ),
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Don't show Android UI overlays
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Force to landscape mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freecell',
      theme: ThemeData(
        primaryColor: Colors.blue[700],
        primaryColorDark: Colors.blue[900],
        backgroundColor: Colors.blue[300],
      ),
      home: const IntroScreen(),
    );
  }
}

void _main() async {
  runApp(ProviderScope(child: MaterialApp(home: TestScreen())));
}

class TestNotifier extends StateNotifier<int> {
  TestNotifier() : super(0);
  ping() {
    print("Ping ${++state}");
  }
}

final testProvider = StateNotifierProvider<TestNotifier, int>((ref) => TestNotifier());

class TestScreen extends ConsumerWidget {
  static int _instances = 0;
  late final int id;
  TestScreen({super.key}) {
    id = ++_instances;
    print("Construct TestScreen $id");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("    Build TestScreen $id");
    ref.watch(testProvider);
    return LayoutBuilder(builder: (p0, p1) {
      print("Layoutbuild TestScreen $id");
      return Column(children: [
        TestItem(),
        ElevatedButton(
          child: Text("Ping", style: TextStyle()),
          onPressed: () => ref.read(testProvider.notifier).ping(),
        ),
      ]);
    });
  }
}

class TestItem extends ConsumerWidget {
  static int _instances = 0;
  late final int id;
  TestItem({super.key}) {
    id = ++_instances;
    print("                              Construct TestItem $id");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(testProvider);
    print("                                  Build TestItem $id");
    return UnconstrainedBox(child: Container(width: 10, height: 10, color: Colors.yellow));
  }
}
