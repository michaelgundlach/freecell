import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'util/deck-style.dart';
import 'views/game-board.dart';
import 'views/intro-screen.dart';

final deckStyleProvider = Provider<DeckStyle>((ref) {
  return DeckStyle(
    elevation: 2,
    shape: RoundedRectangleBorder(
      // Can't express radius as a % of width; give smaller on small screens
      borderRadius: BorderRadius.circular(kIsWeb ? 8 : 4),
      side: const BorderSide(color: Colors.black45, width: 1),
    ),
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Don't show Android UI overlays
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  // Force to landscape mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.green[700],
        primaryColorDark: Colors.green[900],
        backgroundColor: Colors.green[500],
      ),
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      routerDelegate: _router.routerDelegate,
    );
  }

  final _router = GoRouter(routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => WillPopScope(
        onWillPop: () async => false,
        child: const IntroScreen(),
      ),
    ),
    GoRoute(
      path: "/game",
      builder: (context, state) => Container(
        padding: const EdgeInsets.all(10),
        color: Theme.of(context).backgroundColor,
        child: const GameBoard(),
      ),
    ),
  ]);
}
