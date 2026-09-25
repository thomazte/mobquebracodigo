import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/qc_theme.dart';
import '../core/game_scaffold.dart';
import '../core/game_widgets.dart';

class Game2048Page extends StatefulWidget {
  const Game2048Page({super.key});

  @override
  State<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends State<Game2048Page> {
  static const _size = 4;
  static const _padding = 12.0;
  static const _gap = 8.0;

  final _rng = Random();

  List<_Tile> _tiles = [];
  List<_Tile>? _undoTiles;
  int _undoScore = 0;

  int _nextId = 1;
  int _score = 0;
  int _best = 0;
  int _moves = 0;
  bool _won = false;
  bool _gameOver = false;

  Set<int> _newTileIds = {};
  Set<int> _mergedTileIds = {};

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _tiles = [];
    _undoTiles = null;
    _undoScore = 0;
    _score = 0;
    _moves = 0;
    _won = false;
    _gameOver = false;
    _newTileIds = {};
    _mergedTileIds = {};

    _addRandomTile();
    _addRandomTile();
    _gameOver = !_hasMoves(_tiles);
    setState(() {});
    _clearFxSoon();
  }

  void _undo() {
    if (_undoTiles == null) return;
    setState(() {
      _tiles = _cloneTiles(_undoTiles!);
      _score = _undoScore;
      _undoTiles = null;
      _newTileIds = {};
      _mergedTileIds = {};
      _won = _tiles.any((t) => t.value >= 2048);
      _gameOver = !_hasMoves(_tiles);
    });
  }

  List<_Tile> _cloneTiles(List<_Tile> src) =>
      src.map((t) => t.copyWith()).toList(growable: false);

  void _addRandomTile() {
    final occupied = {
      for (final t in _tiles) '${t.r}-${t.c}',
    };
    final empties = <Point<int>>[];
    for (var r = 0; r < _size; r++) {
      for (var c = 0; c < _size; c++) {
        if (!occupied.contains('$r-$c')) empties.add(Point(r, c));
      }
    }
    if (empties.isEmpty) return;
    final p = empties[_rng.nextInt(empties.length)];
    final tile = _Tile(
      id: _nextId++,
      r: p.x,
      c: p.y,
      value: _rng.nextDouble() < 0.9 ? 2 : 4,
    );
    _tiles = [..._tiles, tile];
    _newTileIds = {..._newTileIds, tile.id};
  }

  List<int> _traversal(_Direction d) {
    final idx = List.generate(_size, (i) => i);
    if (d == _Direction.down || d == _Direction.right) {
      return idx.reversed.toList();
    }
    return idx;
  }

  (_WorkTile moved, _WorkTile? consumed, int scoreGain)? _moveTile(
    List<List<_WorkTile?>> grid,
    int r,
    int c,
    _Direction dir,
  ) {
    final t = grid[r][c];
    if (t == null) return null;

    final v = _vector(dir);
    var farR = r;
    var farC = c;
    var nr = r + v.$1;
    var nc = c + v.$2;
    while (nr >= 0 &&
        nr < _size &&
        nc >= 0 &&
        nc < _size &&
        grid[nr][nc] == null) {
      farR = nr;
      farC = nc;
      nr += v.$1;
      nc += v.$2;
    }

    final inBounds = nr >= 0 && nr < _size && nc >= 0 && nc < _size;
    final next = inBounds ? grid[nr][nc] : null;

    if (next != null && next.value == t.value && !next.merged) {
      final merged = _WorkTile(
        id: t.id,
        r: nr,
        c: nc,
        value: t.value * 2,
        merged: true,
      );
      grid[nr][nc] = merged;
      grid[r][c] = null;
      return (merged, next, t.value * 2);
    }

    final moved = _WorkTile(
      id: t.id,
      r: farR,
      c: farC,
      value: t.value,
      merged: false,
    );
    grid[r][c] = null;
    grid[farR][farC] = moved;
    return (moved, null, 0);
  }

  (int, int) _vector(_Direction d) {
    switch (d) {
      case _Direction.up:
        return (-1, 0);
      case _Direction.down:
        return (1, 0);
      case _Direction.left:
        return (0, -1);
      case _Direction.right:
        return (0, 1);
    }
  }

  void _move(_Direction dir) {
    if (_gameOver) return;

    final before = _cloneTiles(_tiles);
    final grid = List.generate(
      _size,
      (_) => List<_WorkTile?>.filled(_size, null),
    );
    for (final t in _tiles) {
      grid[t.r][t.c] = _WorkTile(id: t.id, r: t.r, c: t.c, value: t.value, merged: false);
    }

    final rows = _traversal(dir);
    final cols = _traversal(dir);
    var scoreGain = 0;
    var moved = false;
    final mergedIds = <int>{};

    for (final r in rows) {
      for (final c in cols) {
        final res = _moveTile(grid, r, c, dir);
        if (res == null) continue;
        final movedTile = res.$1;
        final consumed = res.$2;
        scoreGain += res.$3;
        if (movedTile.r != r || movedTile.c != c || consumed != null) {
          moved = true;
        }
        if (movedTile.merged) {
          mergedIds.add(movedTile.id);
        }
      }
    }

    if (!moved) return;

    final after = <_Tile>[];
    for (var r = 0; r < _size; r++) {
      for (var c = 0; c < _size; c++) {
        final t = grid[r][c];
        if (t != null) {
          after.add(_Tile(id: t.id, r: r, c: c, value: t.value));
        }
      }
    }

    _undoTiles = before;
    _undoScore = _score;
    _tiles = after;
    _score += scoreGain;
    _best = max(_best, _score);
    _moves++;
    _mergedTileIds = mergedIds;
    _newTileIds = {};
    _addRandomTile();
    _won = _tiles.any((t) => t.value == 2048) || _won;
    _gameOver = !_hasMoves(_tiles);

    setState(() {});
    _clearFxSoon();
  }

  void _clearFxSoon() {
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      if (_newTileIds.isEmpty && _mergedTileIds.isEmpty) return;
      setState(() {
        _newTileIds = {};
        _mergedTileIds = {};
      });
    });
  }

  bool _hasMoves(List<_Tile> tiles) {
    final grid = List.generate(_size, (_) => List<int?>.filled(_size, null));
    for (final t in tiles) {
      grid[t.r][t.c] = t.value;
    }
    for (var r = 0; r < _size; r++) {
      for (var c = 0; c < _size; c++) {
        final v = grid[r][c];
        if (v == null) return true;
        if (r + 1 < _size && grid[r + 1][c] == v) return true;
        if (c + 1 < _size && grid[r][c + 1] == v) return true;
      }
    }
    return false;
  }

  Color _tileColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFF667EEA);
      case 4:
        return const Color(0xFFF093FB);
      case 8:
        return const Color(0xFF4FACFE);
      case 16:
        return const Color(0xFF43E97B);
      case 32:
        return const Color(0xFFFA709A);
      case 64:
        return const Color(0xFF30CFD0);
      case 128:
        return const Color(0xFFA8EDEA);
      case 256:
        return const Color(0xFFFF9A56);
      case 512:
        return const Color(0xFFFBC2EB);
      case 1024:
        return const Color(0xFFFDCBF1);
      case 2048:
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFFFF0080);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _gameOver
        ? const GameStatusBanner(
            message: 'Game over. Reinicie para tentar novamente.',
            accent: Colors.redAccent,
            icon: Icons.warning_amber_rounded,
          )
        : _won
            ? const GameStatusBanner(
                message: 'Voce venceu! Continue para bater seu recorde.',
                accent: QcColors.green,
                icon: Icons.emoji_events_rounded,
              )
            : null;

    return GameScaffold(
      title: '2048',
      subtitle: 'Deslize para mover todas as pecas e combine valores iguais.',
      stats: [
        GameStat(label: 'Pontos', value: '$_score'),
        GameStat(label: 'Melhor', value: '$_best'),
        GameStat(label: 'Jogadas', value: '$_moves'),
      ],
      actions: [
        GameActionButton(
          label: 'Desfazer',
          icon: Icons.undo_rounded,
          onTap: _undo,
        ),
        GameActionButton(
          label: 'Reiniciar',
          icon: Icons.refresh_rounded,
          onTap: _reset,
          primary: true,
        ),
      ],
      body: GestureDetector(
        onVerticalDragEnd: (d) {
          final vy = d.velocity.pixelsPerSecond.dy;
          if (vy.abs() < 120) return;
          _move(vy > 0 ? _Direction.down : _Direction.up);
        },
        onHorizontalDragEnd: (d) {
          final vx = d.velocity.pixelsPerSecond.dx;
          if (vx.abs() < 120) return;
          _move(vx > 0 ? _Direction.right : _Direction.left);
        },
        child: GlassPanel(
          padding: const EdgeInsets.all(8),
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final side = constraints.maxWidth;
                final cell = (side - (2 * _padding) - ((_size - 1) * _gap)) / _size;
                return Stack(
                  children: [
                    // Background grid
                    for (var r = 0; r < _size; r++)
                      for (var c = 0; c < _size; c++)
                        Positioned(
                          left: _padding + c * (cell + _gap),
                          top: _padding + r * (cell + _gap),
                          width: cell,
                          height: cell,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    // Tiles
                    ..._tiles.map((t) {
                      final isNew = _newTileIds.contains(t.id);
                      final isMerged = _mergedTileIds.contains(t.id);
                      return AnimatedPositioned(
                        key: ValueKey('tile-${t.id}'),
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeInOut,
                        left: _padding + t.c * (cell + _gap),
                        top: _padding + t.r * (cell + _gap),
                        width: cell,
                        height: cell,
                        child: _TileWidget(
                          value: t.value,
                          color: _tileColor(t.value),
                          isNew: isNew,
                          isMerged: isMerged,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      footer: status,
    );
  }
}

class _TileWidget extends StatelessWidget {
  final int value;
  final Color color;
  final bool isNew;
  final bool isMerged;

  const _TileWidget({
    required this.value,
    required this.color,
    required this.isNew,
    required this.isMerged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = value == 128 || value == 1024 ? const Color(0xFF333333) : Colors.white;
    final fontSize = value >= 1024 ? 21.0 : (value >= 128 ? 25.0 : 30.0);
    final targetScale = isMerged
        ? 1.08
        : (isNew ? 0.65 : 1.0);

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      scale: targetScale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: value >= 2048
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _Tile {
  final int id;
  final int r;
  final int c;
  final int value;

  const _Tile({
    required this.id,
    required this.r,
    required this.c,
    required this.value,
  });

  _Tile copyWith({
    int? id,
    int? r,
    int? c,
    int? value,
  }) {
    return _Tile(
      id: id ?? this.id,
      r: r ?? this.r,
      c: c ?? this.c,
      value: value ?? this.value,
    );
  }
}

class _WorkTile {
  final int id;
  final int r;
  final int c;
  final int value;
  final bool merged;

  const _WorkTile({
    required this.id,
    required this.r,
    required this.c,
    required this.value,
    required this.merged,
  });
}

enum _Direction { up, down, left, right }
