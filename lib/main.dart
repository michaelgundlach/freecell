import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'util/deck-style.dart';
import 'util/sound.dart';
import 'views/game-mat.dart';
import 'views/intro-screen.dart';
import 'views/settings-panel.dart';

final deckStyleProvider = Provider<DeckStyle>((ref) {
  const radius = kIsWeb ? 8.0 : 4.0;
  return DeckStyle(
    radius: radius,
    elevation: 2,
    shape: RoundedRectangleBorder(
      // Can't express radius as a % of width; give smaller on small screens
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
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Freecell',
      theme: ThemeData(
        primaryColor: Colors.blue[700],
        primaryColorDark: Colors.blue[900],
        backgroundColor: Colors.blue[300],
      ),
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      routerDelegate: _router.routerDelegate,
    );
  }

  final _router = GoRouter(routes: [
    GoRoute(
      path: "/oldhome",
      builder: (context, state) => WillPopScope(
        onWillPop: () async => false,
        child: const IntroScreen(),
      ),
    ),
    GoRoute(
      path: "/",
      builder: (_, __) => const GameSurface(),
    ),
    GoRoute(
      path: "/oldgame",
      builder: (context, state) => Container(
        padding: const EdgeInsets.all(10),
        color: Theme.of(context).backgroundColor,
        child: const GameMat(),
      ),
    ),
  ]);
}

class GameSurface extends StatelessWidget {
  const GameSurface({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
      color: Theme.of(context).backgroundColor,
      child: Row(children: const [
        Expanded(child: GameMat()),
        SettingsPanel(),
      ]),
    );
  }
}
