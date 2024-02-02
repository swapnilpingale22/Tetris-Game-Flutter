// grid dimensions

import 'dart:ui';

int rowLength = 10;
int colLength = 15;

enum Direction {
  left,
  right,
  down,
}

enum Tetromino {
  L,
  J,
  I,
  O,
  S,
  Z,
  T,
}

Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: const Color(0xfff18701),
  Tetromino.J: const Color(0xff00bbf9),
  Tetromino.I: const Color(0xfff15bb5),
  Tetromino.O: const Color(0xfffee440),
  Tetromino.S: const Color(0xff80ed99),
  Tetromino.Z: const Color(0xffc9184a),
  Tetromino.T: const Color(0xff9b5de5),
};
