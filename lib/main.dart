import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

import 'deck-style.dart';
import 'freecell-stack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Freecell!!!!!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var deckStyle = DeckStyle(
      cardHeight: 200,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
    );

    final deck = standardFiftyTwoCardDeck()..shuffle();
    var i = 0;
    FreecellStack stack(int n) {
      i = i + n;
      return FreecellStack(deckStyle: deckStyle, children: deck.sublist(i - n, i));
    }

    p() {
      setState(() {
        print("hi");
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        // GestureDetector(
        // onTap: p
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: double.infinity, height: double.infinity),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [for (var i = 0; i < 8; i++) stack(i >= 4 ? 6 : 7)],
          ),
        ),
      ),
    );
  }
}
