import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tetris_game/piece.dart';
import 'package:flutter_tetris_game/pixel.dart';
import 'package:flutter_tetris_game/values.dart';

// Game Board 2x2 grid
List<List<Tetromino?>> gameBoard = List.generate(
  colLength,
  (i) => List.generate(
    rowLength,
    (j) => null,
  ),
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // current tetris piece
  Piece currentPiece = Piece(type: Tetromino.L);

  // current score
  int currentScore = 0;

  //game over status
  bool gameOver = false;

  @override
  void initState() {
    super.initState();

    // start the game
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();

    //frame refresh rate
    Duration frameRate = const Duration(milliseconds: 500);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        //clear lines
        clearLines();
        // check landing
        checkLanding();

        //check if game is over
        if (gameOver == true) {
          timer.cancel();
          showGameOverDialog();
        }
        // move current piece down
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your score is: $currentScore'),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.pop(context);
              },
              child: const Text('Play Again'),
            )
          ],
        );
      },
    );
  }

  //reset game
  void resetGame() {
    gameBoard = List.generate(
      colLength,
      (i) => List.generate(
        rowLength,
        (j) => null,
      ),
    );
    //
    // new game
    gameOver = false;
    currentScore = 0;
    createNewPiece();
    startGame();
  }

  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      //loop through each position of current piece
      //calculate the row & colomn of the current position
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = (currentPiece.position[i] % rowLength);

      //adjsut the row & col based on the direction
      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }
      //check if the piece is out of bounds
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }
      // check if the next position is occupied by a landed piece
      else if (col >= 0 && row >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    //if no collisions are detected
    return false;
  }

  void checkLanding() {
    //if going down is occupied
    if (checkCollision(Direction.down)) {
      //mark position as occupied on the gameboard
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = (currentPiece.position[i] % rowLength);
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      //once landed, create the next piece
      createNewPiece();
    }
  }

  void createNewPiece() {
    //crete a random object
    Random random = Random();

    //create a new piece with random type
    Tetromino randomType =
        Tetromino.values[random.nextInt(Tetromino.values.length)];

    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    if (isGameOver()) {
      gameOver = true;
    }
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  //clear lines
  void clearLines() {
    //step 1
    for (int row = colLength - 1; row >= 0; row--) {
      //step 2
      bool rowIsFull = true;
      //step 3
      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }
      //step 4
      if (rowIsFull) {
        //step 5
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        //step 6
        gameBoard[0] = List.generate(row, (index) => null);
        //step 7
        currentScore++;
      }
    }
  }

  //game over method
  bool isGameOver() {
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: rowLength * colLength,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowLength,
              ),
              itemBuilder: (context, index) {
                //get row & col of each index
                int row = (index / rowLength).floor();
                int col = index % rowLength;

                //current piece
                if (currentPiece.position.contains(index)) {
                  return Pixel(
                    color: currentPiece.color,
                  );
                } else if (gameBoard[row][col] != null) {
                  final Tetromino? tetrominoType = gameBoard[row][col];

                  return Pixel(
                    color: tetrominoColors[tetrominoType]!,
                  );
                } else {
                  //blank pixel
                  return const Pixel(
                    color: Color(0xff0d1b2a),
                  );
                }
              },
            ),
          ),
          Text(
            'Score: $currentScore',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: moveLeft,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                IconButton(
                  onPressed: rotatePiece,
                  icon: const Icon(
                    Icons.rotate_right,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                IconButton(
                  onPressed: moveRight,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
