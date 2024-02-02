import 'package:flutter/material.dart';
import 'package:flutter_tetris_game/board.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Tetris',
      debugShowCheckedModeBanner: false,
      home: GameBoard(),
    );
  }
}
