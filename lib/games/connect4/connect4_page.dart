import 'package:flutter/material.dart';

import '../../theme/qc_theme.dart';
import '../core/game_widgets.dart';

class Connect4Page extends StatefulWidget {
  const Connect4Page({super.key});

  @override
  State<Connect4Page> createState() => _Connect4PageState();
}

class _Connect4PageState extends State<Connect4Page> {
  static const _rows = 6;
  static const _cols = 7;
  static const _player = 1;
  static const _cpu = 2;
  static const _you = Color(0xFF3B82F6);
  static const _opponent = Color(0xFFFF8A3D);

  late List<List<int>> _board;
  int _turn = _player;
  int _winner = 0;
  int _moves = 0;
  bool _draw = false;
  bool _vsCpu = true;
  bool _busy = false;
  int _epoch = 0;
  (int, int)? _last;

  @override
  void initState() {
    super.initState();
    _clearBoard();
  }

  void _reset() {
    setState(_clearBoard);
  }

  void _clearBoard() {
    _epoch++;
    _board = List.generate(_rows, (_) => List.filled(_cols, 0));
    _turn = _player;
    _winner = 0;
    _moves = 0;
    _draw = false;
    _busy = false;
    _last = null;
  }

  void _setMode(bool vsCpu) {
    if (_vsCpu == vsCpu) return;
    _vsCpu = vsCpu;
    _reset();
  }

  int? _landing(List<List<int>> board, int col) {
    for (var row = _rows - 1; row >= 0; row--) {
      if (board[row][col] == 0) return row;
    }
    return null;
  }

  bool _drop(int col, int player) {
    final row = _landing(_board, col);
    if (row == null) return false;
    _board[row][col] = player;
    _last = (row, col);
    _moves++;
    if (_hasWin(_board, row, col, player)) {
      _winner = player;
    } else if (_board[0].every((cell) => cell != 0)) {
      _draw = true;
    } else {
      _turn = player == _player ? _cpu : _player;
    }
    return true;
  }

  void _tap(int col) {
    if (_busy || _winner != 0 || _draw) return;
    if (_vsCpu && _turn != _player) return;
    if (!_drop(col, _turn)) return;
    setState(() {});
    if (_vsCpu && _winner == 0 && !_draw) {
      _cpuTurn(_epoch);
    }
  }

  Future<void> _cpuTurn(int epoch) async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted || epoch != _epoch || _winner != 0 || _draw) return;
    final col = _bestColumn(_board);
    setState(() {
      _drop(col, _cpu);
      _busy = false;
    });
  }

  int _bestColumn(List<List<int>> board) {
    final moves = _orderedMoves(board);
    var bestCol = moves.first;
    var bestScore = -1 << 30;
    for (final col in moves) {
      final row = _landing(board, col)!;
      final next = _copy(board);
      next[row][col] = _cpu;
      if (_hasWin(next, row, col, _cpu)) return col;
      final score = _minimax(next, 3, -1 << 30, 1 << 30, false);
      if (score > bestScore) {
        bestScore = score;
        bestCol = col;
      }
    }
    return bestCol;
  }

  int _minimax(
    List<List<int>> board,
    int depth,
    int alpha,
    int beta,
    bool maximizing,
  ) {
    final winner = _winnerOf(board);
    if (winner == _cpu) return 100000 + depth;
    if (winner == _player) return -100000 - depth;
    final moves = _orderedMoves(board);
    if (moves.isEmpty) return 0;
    if (depth == 0) return _evaluate(board);

    if (maximizing) {
      var value = -1 << 30;
      for (final col in moves) {
        final row = _landing(board, col)!;
        final next = _copy(board);
        next[row][col] = _cpu;
        value = _max(value, _minimax(next, depth - 1, alpha, beta, false));
        alpha = _max(alpha, value);
        if (alpha >= beta) break;
      }
      return value;
    }

    var value = 1 << 30;
    for (final col in moves) {
      final row = _landing(board, col)!;
      final next = _copy(board);
      next[row][col] = _player;
      value = _min(value, _minimax(next, depth - 1, alpha, beta, true));
      beta = _min(beta, value);
      if (alpha >= beta) break;
    }
    return value;
  }

  List<int> _orderedMoves(List<List<int>> board) {
    const preference = [3, 2, 4, 1, 5, 0, 6];
    return [
      for (final col in preference)
        if (board[0][col] == 0) col,
    ];
  }

  List<List<int>> _copy(List<List<int>> board) =>
      board.map((row) => [...row]).toList();

  int _max(int a, int b) => a > b ? a : b;
  int _min(int a, int b) => a < b ? a : b;

  int _evaluate(List<List<int>> board) {
    var score = 0;
    for (var row = 0; row < _rows; row++) {
      for (var col = 0; col < _cols; col++) {
        if (col + 3 < _cols) {
          score += _window([
            board[row][col],
            board[row][col + 1],
            board[row][col + 2],
            board[row][col + 3],
          ]);
        }
        if (row + 3 < _rows) {
          score += _window([
            board[row][col],
            board[row + 1][col],
            board[row + 2][col],
            board[row + 3][col],
          ]);
        }
        if (row + 3 < _rows && col + 3 < _cols) {
          score += _window([
            board[row][col],
            board[row + 1][col + 1],
            board[row + 2][col + 2],
            board[row + 3][col + 3],
          ]);
        }
        if (row + 3 < _rows && col - 3 >= 0) {
          score += _window([
            board[row][col],
            board[row + 1][col - 1],
            board[row + 2][col - 2],
            board[row + 3][col - 3],
          ]);
        }
      }
    }
    for (var row = 0; row < _rows; row++) {
      if (board[row][3] == _cpu) score += 6;
      if (board[row][3] == _player) score -= 6;
    }
    return score;
  }

  int _window(List<int> cells) {
    final cpu = cells.where((cell) => cell == _cpu).length;
    final human = cells.where((cell) => cell == _player).length;
    if (cpu > 0 && human > 0) return 0;
    if (cpu == 3) return 50;
    if (cpu == 2) return 10;
    if (cpu == 1) return 1;
    if (human == 3) return -80;
    if (human == 2) return -12;
    if (human == 1) return -1;
    return 0;
  }

  int _winnerOf(List<List<int>> board) {
    for (var row = 0; row < _rows; row++) {
      for (var col = 0; col < _cols; col++) {
        final player = board[row][col];
        if (player != 0 && _hasWin(board, row, col, player)) return player;
      }
    }
    return 0;
  }

  bool _hasWin(List<List<int>> board, int row, int col, int player) {
    const directions = [(0, 1), (1, 0), (1, 1), (1, -1)];
    for (final (dr, dc) in directions) {
      var count = 1;
      for (final sign in const [1, -1]) {
        var r = row + dr * sign;
        var c = col + dc * sign;
        while (r >= 0 &&
            r < _rows &&
            c >= 0 &&
            c < _cols &&
            board[r][c] == player) {
          count++;
          r += dr * sign;
          c += dc * sign;
        }
      }
      if (count >= 4) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final finished = _winner != 0 || _draw;
    final message = _draw
        ? 'Empate. O tabuleiro encheu sem quatro em linha.'
        : _winner == _player
            ? (_vsCpu ? 'Voce conectou 4 pecas.' : 'Jogador 1 conectou 4 pecas.')
            : _winner == _cpu
                ? (_vsCpu ? 'A CPU conectou 4 pecas.' : 'Jogador 2 conectou 4 pecas.')
                : _busy
                    ? 'A CPU esta escolhendo a coluna.'
                    : _vsCpu
                        ? 'Sua vez. Toque uma coluna para soltar a peca.'
                        : 'Vez do jogador ${_turn == _player ? 1 : 2}. Toque uma coluna.';

    final accent = finished
        ? (_draw
            ? QcColors.textMuted
            : _winner == _player
                ? QcColors.green
                : Colors.redAccent)
        : QcColors.cyan;

    final yourTurn = !finished && !_busy && _turn == _player;
    final opponentLabel = _vsCpu ? 'CPU' : 'Jogador 2';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect 4'),
        actions: [
          IconButton(
            tooltip: 'Reiniciar',
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [QcColors.bg0, QcColors.bg1, QcColors.bg2],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: QcColors.panel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _modeButton(
                          'Contra CPU',
                          Icons.smart_toy_outlined,
                          _vsCpu,
                          () => _setMode(true),
                        ),
                      ),
                      Expanded(
                        child: _modeButton(
                          '2 jogadores',
                          Icons.people_outline_rounded,
                          !_vsCpu,
                          () => _setMode(false),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(child: _playerChip('Voce', _you, yourTurn)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_moves jogadas',
                        style: const TextStyle(color: QcColors.textMuted, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _playerChip(
                          opponentLabel,
                          _opponent,
                          !finished && !_busy && _turn == _cpu,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(child: LayoutBuilder(builder: (context, constraints) => _boardView(constraints, finished))),
                const SizedBox(height: 10),
                GameStatusBanner(
                  message: message,
                  accent: accent,
                  icon: finished ? Icons.emoji_events_rounded : Icons.touch_app_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeButton(String label, IconData icon, bool selected, VoidCallback onTap) {
    final foreground = selected ? QcColors.bg0 : QcColors.text;
    return Material(
      color: selected ? QcColors.cyan : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: foreground, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playerChip(String label, Color color, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: active ? 0.22 : 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: active ? 1 : 0.45),
          width: active ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.4),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: QcColors.text, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boardView(BoxConstraints constraints, bool finished) {
    const indicator = 34.0;
    var boardW = constraints.maxWidth;
    var holesH = boardW * _rows / _cols;
    if (holesH + indicator > constraints.maxHeight) {
      holesH = constraints.maxHeight - indicator;
      boardW = holesH * _cols / _rows;
    }
    final arrowColor = (_turn == _player ? _you : _opponent).withValues(
      alpha: finished || _busy ? 0.28 : 1,
    );

    return Center(
      child: SizedBox(
        width: boardW,
        height: holesH + indicator,
        child: Column(
          children: [
            SizedBox(
              height: indicator,
              child: Row(
                children: [
                  for (var col = 0; col < _cols; col++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _tap(col),
                        child: Icon(Icons.arrow_drop_down_rounded, color: arrowColor, size: 34),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: QcColors.panel,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      for (var col = 0; col < _cols; col++)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _tap(col),
                            child: Column(
                              children: [
                                for (var row = 0; row < _rows; row++)
                                  Expanded(child: _slot(row, col)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slot(int row, int col) {
    final value = _board[row][col];
    final last = _last != null && _last!.$1 == row && _last!.$2 == col;
    final disc = value == _player
        ? _you
        : value == _cpu
            ? _opponent
            : null;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: QcColors.bg0,
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: disc == null
            ? const SizedBox.expand()
            : Padding(
                padding: const EdgeInsets.all(2),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: disc,
                    border: last ? Border.all(color: Colors.white, width: 3) : null,
                    boxShadow: [
                      BoxShadow(
                        color: disc.withValues(alpha: 0.45),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: const Alignment(-0.35, -0.45),
                    child: FractionallySizedBox(
                      widthFactor: 0.34,
                      heightFactor: 0.2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
