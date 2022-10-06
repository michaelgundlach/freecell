import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'model/game-state.dart';
import 'util/deck-style.dart';
import 'views/ui/game-mat.dart';
import 'views/ui/intro-screen.dart';
import 'views/ui/settings-panel.dart';

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
      home: const FreecellApp(),
    );
  }
}

class FreecellApp extends ConsumerWidget {
  const FreecellApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gs = ref.watch(GameState.provider);
    if (gs.stage == "intro") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
            context,
            PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => const IntroScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: const Duration(milliseconds: 4500),
                transitionsBuilder: (context, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child)));
      });
    }
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
      color: Theme.of(context).backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          SizedBox(width: 100),
          Flexible(child: GameMat()),
          SizedBox(width: 100, child: SettingsPanel()),
        ],
      ),
    );
  }
}
