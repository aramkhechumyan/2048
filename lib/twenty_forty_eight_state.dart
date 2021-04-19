import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_game/tile.dart';
import 'package:my_game/twenty_forty_eight_widget.dart';

const Color lightBrown = Color.fromARGB(255, 205, 193, 180);
const Color darkBrown = Color.fromARGB(255, 187, 173, 160);
const Color tan = Color.fromARGB(255, 238, 228, 218);
const Color greyText = Color.fromARGB(255, 119, 110, 101);

const Map<int, Color> numTileColor = {
  2: tan,
  4: tan,
  8: Color.fromARGB(255, 242, 177, 121),
  16: Color.fromARGB(255, 245, 149, 99),
  32: Color.fromARGB(255, 246, 124, 95),
  64: Color.fromARGB(255, 246, 95, 64),
  128: Color.fromARGB(255, 235, 208, 117),
  256: Color.fromARGB(255, 237, 203, 103),
  512: Color.fromARGB(255, 236, 201, 85),
  1024: Color.fromARGB(255, 229, 194, 90),
  2048: Color.fromARGB(255, 232, 192, 70),
};

class TwentyFortyEightState extends State<TwentyFortyEightWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  List<List<Tile>> _grid =
      List.generate(4, (y) => List.generate(4, (x) => EmptyTile(x, y)));
  List<Tile> _toAdd = [];

  Iterable<Tile> get _flattenedGrid => _grid.expand((e) => e);

  List<List<Tile>> get _cols =>
      List.generate(4, (x) => List.generate(4, (y) => _grid[y][x]));

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _toAdd.forEach((element) {
          _grid[element.y][element.x].val = element.val;
        });
        _flattenedGrid.forEach((element) {
          element.resetAnimations();
        });
        _toAdd.clear();
      }
    });

    _grid[1][2].val = 2;
    _grid[0][2].val = 2;

    _flattenedGrid.forEach((element) => element.resetAnimations());
  }

  void addNewTile() {
    List<Tile> empty = _flattenedGrid.where((e) => e.val == 0).toList();
    empty.shuffle();
    _toAdd.add(Tile(empty.first.x, empty.first.y, 2)..appear(_controller));
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width - 16.0 * 2;
    double tileSize = (gridSize - 4.0 * 2) / 4;
    List<Widget> stackItems = [];
    addBackgroundGrid(stackItems, tileSize);
    addTileElements(stackItems, tileSize);

    return Scaffold(
      backgroundColor: tan,
      body: Center(
          child: Container(
        width: gridSize,
        height: gridSize,
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0), color: darkBrown),
        child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy < -250 && canSwipeUp()) {
                doSwipe(swipeUp);
              } else if (details.velocity.pixelsPerSecond.dy > 250 &&
                  canSwipeDown()) {
                doSwipe(swipeDown);
              }
            },
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx < -1000 &&
                  canSwipeLeft()) {
                doSwipe(swipeLeft);
              } else if (details.velocity.pixelsPerSecond.dx > 1000 &&
                  canSwipeRight()) {
                doSwipe(swipeRight);
              }
            },
            child: Stack(
              children: stackItems,
            )),
      )),
    );
  }

  void addTileElements(List<Widget> stackItems, double tileSize) {
    stackItems.addAll(
        [_flattenedGrid, _toAdd].expand((e) => e).map((e) => AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => e.animatedValue.value == 0
                ? SizedBox()
                : Positioned(
                    left: e.animatedX.value * tileSize,
                    top: e.animatedY.value * tileSize,
                    width: tileSize,
                    height: tileSize,
                    child: Center(
                        child: Container(
                      width: (tileSize - 4.0 * 2) * e.scale.value,
                      height: (tileSize - 4.0 * 2) * e.scale.value,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: numTileColor[e.animatedValue.value]),
                      child: Center(
                        child: Text(
                          "${e.animatedValue.value}",
                          style: TextStyle(
                              color: e.animatedValue.value <= 4
                                  ? greyText
                                  : Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    )),
                  ))));
  }

  void addBackgroundGrid(List<Widget> stackItems, double tileSize) {
    stackItems.addAll(_flattenedGrid.map((e) => Positioned(
          left: e.x * tileSize,
          top: e.y * tileSize,
          width: tileSize,
          height: tileSize,
          child: Center(
              child: Container(
            width: tileSize - 4.0 * 2,
            height: tileSize - 4.0 * 2,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0), color: lightBrown),
          )),
        )));
  }

  void doSwipe(void Function() swipenFn) {
    setState(() {
      swipenFn();
      addNewTile();
      _controller.forward(from: 0);
    });
  }

  bool canSwipeLeft() => _grid.any(canSwipe);

  bool canSwipeRight() => _grid.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipeUp() => _cols.any(canSwipe);

  bool canSwipeDown() => _cols.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipe(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i].val == 0) {
        if (tiles.skip(i + 1).any((e) => e.val != 0)) {
          return true;
        }
      } else {
        Tile nextNonZero =
            tiles.skip(i + 1).firstWhere((e) => e.val != 0, orElse: () => null);
        if (nextNonZero != null && nextNonZero.val == tiles[i].val) {
          return true;
        }
      }
    }
    return false;
  }

  void swipeLeft() => _grid.forEach(mergeTiles);

  void swipeRight() =>
      _grid.map((e) => e.reversed.toList()).forEach(mergeTiles);

  void swipeUp() => _cols.forEach(mergeTiles);

  void swipeDown() => _cols.map((e) => e.reversed.toList()).forEach(mergeTiles);

  void mergeTiles(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      Iterable<Tile> toCheck = skipIfEmpty(tiles, i);
      if (toCheck.isNotEmpty) {
        Tile firstTile = toCheck.first;
        Tile merge =
            toCheck.skip(1).firstWhere((t) => t.val != 0, orElse: () => null);
        if (merge != null && merge.val != firstTile.val) {
          merge = null;
        }
        if (tiles[i] != firstTile || merge != null) {
          int resultValue = firstTile.val;
          firstTile.moveTo(_controller, tiles[i].x, tiles[i].y);
          if (merge != null) {
            resultValue += merge.val;
            merge.moveTo(_controller, tiles[i].x, tiles[i].y);
            merge.jump(_controller);
            merge.changeNumber(_controller, resultValue);
            merge.val = 0;
            firstTile.changeNumber(_controller, 0);
          }
          firstTile.val = 0;
          tiles[i].val = resultValue;
        }
      }
    }
  }

  Iterable<Tile> skipIfEmpty(List<Tile> tiles, int i) =>
      tiles.skip(i).skipWhile((value) => value.val == 0);
}
