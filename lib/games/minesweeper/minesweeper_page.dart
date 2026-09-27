import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/qc_theme.dart';
import '../core/game_scaffold.dart';
import '../core/game_widgets.dart';

class MinesweeperPage extends StatefulWidget {
  const MinesweeperPage({super.key});

  @override
  State<MinesweeperPage> createState() => _MinesweeperPageState();
}

class _MinesweeperPageState extends State<MinesweeperPage> {
  final _rng = Random();

  late List<List<_Cell>> _grid;
  int _rows = 9;
  int _cols = 9;
  int _mines = 10;
  int _opened = 0;
  int _flags = 0;
  int _seconds = 0;
  bool _started = false;
  bool _won = false;
  bool _lost = false;
  (int, int)? _hit;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _prepare(_rows, _cols, _mines);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _newGame(int rows, int cols, int mines) {
    setState(() => _prepare(rows, cols, mines));
  }

  void _prepare(int rows, int cols, int mines) {
    _timer?.cancel();
    _rows = rows;
    _cols = cols;
    _mines = mines;
    _grid = List.generate(rows, (_) => List.generate(cols, (_) => _Cell()));
    _opened = 0;
    _flags = 0;
    _seconds = 0;
    _started = false;
    _won = false;
    _lost = false;
    _hit = null;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _won || _lost) return;
      setState(() => _seconds++);
    });
  }

  void _placeMines(int safeRow, int safeCol) {
    final spots = <(int, int)>[];
    for (var row = 0; row < _rows; row++) {
      for (var col = 0; col < _cols; col++) {
        if (row == safeRow && col == safeCol) continue;
        spots.add((row, col));
      }
    }
    spots.shuffle(_rng);
    for (var i = 0; i < _mines; i++) {
      final (row, col) = spots[i];
      _grid[row][col].mine = true;
    }
    for (var row = 0; row < _rows; row++) {
      for (var col = 0; col < _cols; col++) {
        if (_grid[row][col].mine) continue;
        _grid[row][col].near = _countMines(row, col);
      }
    }
  }

  int _countMines(int row, int col) {
    var total = 0;
    for (final (nr, nc) in _neighbors(row, col)) {
      if (_grid[nr][nc].mine) total++;
    }
    return total;
  }

  Iterable<(int, int)> _neighbors(int row, int col) sync* {
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = row + dr;
        final nc = col + dc;
        if (nr < 0 || nc < 0 || nr >= _rows || nc >= _cols) continue;
        yield (nr, nc);
      }
    }
  }

  void _open(int row, int col) {
    if (_won || _lost) return;
    final cell = _grid[row][col];
    if (cell.open || cell.flag) return;

    if (!_started) {
      _started = true;
      _placeMines(row, col);
      _startTimer();
    }

    if (cell.mine) {
      _lost = true;
      _hit = (row, col);
      cell.open = true;
      _timer?.cancel();
      setState(() {});
      return;
    }

    _reveal(row, col);
    if (_opened == _rows * _cols - _mines) {
      _won = true;
      _timer?.cancel();
    }
    setState(() {});
  }

  void _reveal(int row, int col) {
    final stack = <(int, int)>[(row, col)];
    while (stack.isNotEmpty) {
      final (cr, cc) = stack.removeLast();
      final cell = _grid[cr][cc];
      if (cell.open || cell.flag || cell.mine) continue;
      cell.open = true;
      _opened++;
      if (cell.near != 0) continue;
      stack.addAll(_neighbors(cr, cc));
    }
  }

  void _toggleFlag(int row, int col) {
    if (_won || _lost || !_started) return;
    final cell = _grid[row][col];
    if (cell.open) return;
    cell.flag = !cell.flag;
    _flags += cell.flag ? 1 : -1;
    setState(() {});
  }

  String _clock() {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final message = _lost
        ? 'Voce abriu uma mina. Reinicie para tentar de novo.'
        : _won
            ? 'Campo limpo. Todas as casas seguras foram abertas.'
            : 'Toque para revelar. Segure para marcar uma bandeira.';
    final accent = _lost
        ? Colors.redAccent
        : _won
            ? QcColors.green
            : const Color(0xFFF59E0B);

    return GameScaffold(
      title: 'Minesweeper',
      subtitle: 'Os numeros mostram quantas minas existem ao redor da casa.',
      stats: [
        GameStat(label: 'Minas', value: '$_mines'),
        GameStat(label: 'Bandeiras', value: '$_flags'),
        GameStat(label: 'Tempo', value: _clock()),
      ],
      actions: [
        GameActionButton(
          label: 'Facil',
          onTap: () => _newGame(9, 9, 10),
          primary: _rows == 9,
        ),
        GameActionButton(
          label: 'Medio',
          onTap: () => _newGame(12, 12, 22),
          primary: _rows == 12,
        ),
        GameActionButton(
          label: 'Reiniciar',
          icon: Icons.refresh_rounded,
          onTap: () => _newGame(_rows, _cols, _mines),
        ),
      ],
      body: GlassPanel(
        padding: const EdgeInsets.all(8),
        child: AspectRatio(
          aspectRatio: _cols / _rows,
          child: Column(
            children: [
              for (var row = 0; row < _rows; row++)
                Expanded(
                  child: Row(
                    children: [
                      for (var col = 0; col < _cols; col++)
                        Expanded(child: _tile(row, col)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      footer: GameStatusBanner(
        message: message,
        accent: accent,
        icon: _lost
            ? Icons.warning_amber_rounded
            : _won
                ? Icons.emoji_events_rounded
                : Icons.flag_outlined,
      ),
    );
  }

  Widget _tile(int row, int col) {
    final cell = _grid[row][col];
    final showMine = cell.mine && (cell.open || _lost || _won);
    final wrongFlag = _lost && cell.flag && !cell.mine;
    final hit = _hit != null && _hit!.$1 == row && _hit!.$2 == col;

    Color bg;
    if (hit) {
      bg = const Color(0xFFE11D48);
    } else if (cell.open || showMine) {
      bg = const Color(0xFF10183A);
    } else {
      bg = const Color(0xFF24356F);
    }

    Widget mark;
    if (wrongFlag) {
      mark = const FittedBox(
        child: Icon(Icons.close_rounded, color: Colors.redAccent),
      );
    } else if (cell.flag && !cell.open) {
      mark = const FittedBox(
        child: Icon(Icons.flag_rounded, color: Color(0xFFF59E0B)),
      );
    } else if (showMine) {
      mark = FittedBox(
        child: Icon(
          Icons.circle,
          color: hit ? Colors.white : const Color(0xFF94A3B8),
        ),
      );
    } else if (cell.open && cell.near > 0) {
      mark = FittedBox(
        child: Text(
          '${cell.near}',
          style: TextStyle(
            color: _numberColor(cell.near),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      );
    } else {
      mark = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => _open(row, col),
          onLongPress: () => _toggleFlag(row, col),
          child: Center(child: mark),
        ),
      ),
    );
  }

  Color _numberColor(int value) {
    switch (value) {
      case 1:
        return const Color(0xFF60A5FA);
      case 2:
        return const Color(0xFF34D399);
      case 3:
        return const Color(0xFFF87171);
      case 4:
        return const Color(0xFFA78BFA);
      case 5:
        return const Color(0xFFF59E0B);
      case 6:
        return const Color(0xFF22D3EE);
      case 7:
        return Colors.white;
      default:
        return const Color(0xFF94A3B8);
    }
  }
}

class _Cell {
  bool mine = false;
  bool open = false;
  bool flag = false;
  int near = 0;
}
