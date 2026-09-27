import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/qc_theme.dart';
import '../core/game_scaffold.dart';
import '../core/game_widgets.dart';

typedef _Pt = (int, int);

class FlowPage extends StatefulWidget {
  const FlowPage({super.key});

  @override
  State<FlowPage> createState() => _FlowPageState();
}

class _FlowPageState extends State<FlowPage> {
  static const _colors = <Color>[
    Color(0xFFFF4D4D),
    Color(0xFF3DDC97),
    Color(0xFF3B82F6),
    Color(0xFFF5C518),
    Color(0xFFFF8A3D),
    Color(0xFFF472B6),
    Color(0xFF22D3EE),
    Color(0xFFA78BFA),
    Color(0xFFE7F07A),
  ];

  late int _levelIndex;
  late int _size;
  late List<List<_Pt>> _solutions;
  late List<(_Pt, _Pt)> _ends;
  late List<List<_Pt>> _paths;
  int? _active;
  bool _won = false;
  _Pt? _cursor;

  @override
  void initState() {
    super.initState();
    _applyLevel(0);
  }

  void _load(int index) {
    setState(() => _applyLevel(index));
  }

  void _applyLevel(int index) {
    final level = _levels[index];
    _levelIndex = index;
    _size = level.size;
    _solutions = level.paths.map((path) => [...path]).toList();
    _ends = [
      for (final path in _solutions) (path.first, path.last),
    ];
    _paths = List.generate(_solutions.length, (_) => <_Pt>[]);
    _active = null;
    _won = false;
    _cursor = null;
  }

  void _clear() => _load(_levelIndex);

  void _pointer(Offset local, double cell, bool start) {
    if (_won) return;
    final col = local.dx ~/ cell;
    final row = local.dy ~/ cell;
    if (row < 0 || col < 0 || row >= _size || col >= _size) return;
    final point = (row, col);
    if (!start && _cursor == point) return;
    setState(() {
      _cursor = point;
      if (start) {
        _begin(row, col);
      } else {
        _moveTo(row, col);
      }
      _won = _checkWin();
    });
  }

  void _begin(int row, int col) {
    final endpoint = _endpointIndex(row, col);
    if (endpoint != null) {
      _active = endpoint;
      _paths[endpoint] = [(row, col)];
      return;
    }
    final owner = _pathIndex(row, col);
    if (owner != null) {
      _active = owner;
      final path = _paths[owner];
      final index = path.indexOf((row, col));
      _paths[owner] = path.sublist(0, index + 1);
      return;
    }
    _active = null;
  }

  void _moveTo(int row, int col) {
    final color = _active;
    if (color == null) return;
    final target = (row, col);
    var guard = 0;
    while (guard++ < _size * _size) {
      final path = _paths[color];
      if (path.isEmpty) return;
      final last = path.last;
      if (last == target) return;

      if (path.contains(target)) {
        _paths[color] = path.sublist(0, path.indexOf(target) + 1);
        return;
      }
      if (_connected(color)) return;

      final dr = target.$1 - last.$1;
      final dc = target.$2 - last.$2;
      var nr = last.$1;
      var nc = last.$2;
      if (dr != 0 && (dc == 0 || dr.abs() >= dc.abs())) {
        nr += dr.sign;
      } else if (dc != 0) {
        nc += dc.sign;
      } else {
        return;
      }

      final step = (nr, nc);
      if (path.contains(step)) {
        _paths[color] = path.sublist(0, path.indexOf(step) + 1);
        return;
      }
      if (_blocked(color, nr, nc)) return;
      path.add(step);
      final ends = _ends[color];
      if (step == ends.$1 || step == ends.$2) return;
    }
  }

  bool _blocked(int color, int row, int col) {
    final point = (row, col);
    final endpoint = _endpointIndex(row, col);
    if (endpoint != null && endpoint != color) return true;
    for (var i = 0; i < _paths.length; i++) {
      if (i == color) continue;
      if (_paths[i].contains(point)) return true;
    }
    return false;
  }

  int? _endpointIndex(int row, int col) {
    final point = (row, col);
    for (var i = 0; i < _ends.length; i++) {
      final ends = _ends[i];
      if (ends.$1 == point || ends.$2 == point) return i;
    }
    return null;
  }

  int? _pathIndex(int row, int col) {
    final point = (row, col);
    for (var i = 0; i < _paths.length; i++) {
      if (_paths[i].contains(point)) return i;
    }
    return null;
  }

  bool _connected(int color) {
    final path = _paths[color];
    if (path.length < 2) return false;
    final ends = _ends[color];
    return (path.first == ends.$1 && path.last == ends.$2) ||
        (path.first == ends.$2 && path.last == ends.$1);
  }

  bool _matchesSolution(int color) {
    final path = _paths[color];
    final solution = _solutions[color];
    if (path.length != solution.length) return false;
    var forward = true;
    var backward = true;
    for (var i = 0; i < path.length; i++) {
      if (path[i] != solution[i]) forward = false;
      if (path[i] != solution[solution.length - 1 - i]) backward = false;
    }
    return forward || backward;
  }

  bool _checkWin() {
    final seen = <_Pt>{};
    for (var i = 0; i < _paths.length; i++) {
      if (!_connected(i)) return false;
      for (final cell in _paths[i]) {
        if (!seen.add(cell)) return false;
      }
    }
    return seen.length == _size * _size;
  }

  void _hint() {
    if (_won) return;
    setState(() {
      for (var i = 0; i < _solutions.length; i++) {
        if (_matchesSolution(i)) continue;
        final cells = _solutions[i].toSet();
        for (var j = 0; j < _paths.length; j++) {
          if (j == i) continue;
          final cut = _paths[j].indexWhere(cells.contains);
          if (cut >= 0) _paths[j] = _paths[j].sublist(0, cut);
        }
        _paths[i] = [..._solutions[i]];
        _won = _checkWin();
        return;
      }
    });
  }

  int get _linked {
    var total = 0;
    for (var i = 0; i < _paths.length; i++) {
      if (_connected(i)) total++;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final lastLevel = _levelIndex == _levels.length - 1;
    return GameScaffold(
      scrollable: false,
      title: 'Flow Free',
      subtitle: 'Arraste de um ponto ate o par da mesma cor, sem cruzar trilhas.',
      stats: [
        GameStat(label: 'Fase', value: '${_levelIndex + 1}/${_levels.length}'),
        GameStat(label: 'Grade', value: '${_size}x$_size'),
        GameStat(label: 'Trilhas', value: '$_linked/${_paths.length}'),
      ],
      actions: [
        GameActionButton(
          label: 'Limpar',
          icon: Icons.refresh_rounded,
          onTap: _clear,
          primary: !_won,
        ),
        GameActionButton(
          label: 'Dica',
          icon: Icons.lightbulb_outline_rounded,
          onTap: _hint,
        ),
        if (_won && !lastLevel)
          GameActionButton(
            label: 'Proxima',
            icon: Icons.arrow_forward_rounded,
            onTap: () => _load(_levelIndex + 1),
            primary: true,
          ),
        if (_won && lastLevel)
          GameActionButton(
            label: 'Do inicio',
            icon: Icons.replay_rounded,
            onTap: () => _load(0),
            primary: true,
          ),
      ],
      body: GlassPanel(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = math.min(constraints.maxWidth, constraints.maxHeight);
            return Center(
              child: SizedBox(
                width: side,
                height: side,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) => _pointer(details.localPosition, side / _size, true),
                  onPanUpdate: (details) => _pointer(details.localPosition, side / _size, false),
                  child: CustomPaint(
                    painter: _FlowPainter(
                      size: _size,
                      colors: _colors,
                      ends: _ends,
                      paths: _paths,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      footer: GameStatusBanner(
        message: _won
            ? (lastLevel
                ? 'Todas as fases concluidas. O tabuleiro ficou preenchido.'
                : 'Fase concluida. Avance para a proxima.')
            : 'Preencha o tabuleiro inteiro. Cada cor liga apenas os dois pontos dela.',
        accent: _won ? QcColors.green : const Color(0xFFF472B6),
        icon: _won ? Icons.emoji_events_rounded : Icons.gesture_rounded,
      ),
    );
  }
}

class _FlowLevel {
  final int size;
  final List<List<_Pt>> paths;

  const _FlowLevel(this.size, this.paths);
}

const _levels = <_FlowLevel>[
  _FlowLevel(5, [
    [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4)],
    [(1, 1), (1, 0), (2, 0), (3, 0), (4, 0), (4, 1)],
    [(1, 2), (1, 3), (2, 3)],
    [(1, 4), (2, 4), (3, 4), (4, 4), (4, 3)],
    [(2, 2), (2, 1), (3, 1)],
    [(3, 3), (3, 2), (4, 2)],
  ]),
  _FlowLevel(5, [
    [(0, 1), (0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (4, 1), (4, 2)],
    [(0, 2), (0, 3), (0, 4), (1, 4), (2, 4), (3, 4)],
    [(1, 3), (1, 2), (1, 1), (2, 1), (3, 1)],
    [(2, 3), (2, 2), (3, 2)],
    [(3, 3), (4, 3), (4, 4)],
  ]),
  _FlowLevel(6, [
    [(0, 0), (0, 1), (0, 2), (1, 2), (1, 3), (2, 3)],
    [(0, 3), (0, 4), (0, 5)],
    [(1, 1), (1, 0), (2, 0), (3, 0), (4, 0), (5, 0), (5, 1)],
    [(1, 5), (1, 4), (2, 4), (3, 4)],
    [(2, 2), (2, 1), (3, 1), (4, 1)],
    [(2, 5), (3, 5), (4, 5), (5, 5), (5, 4)],
    [(3, 3), (3, 2), (4, 2), (5, 2)],
    [(4, 4), (4, 3), (5, 3)],
  ]),
  _FlowLevel(7, [
    [(0, 1), (0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (5, 0), (6, 0), (6, 1), (6, 2)],
    [(0, 2), (0, 3), (1, 3)],
    [(2, 4), (1, 4), (0, 4), (0, 5), (0, 6), (1, 6), (2, 6), (3, 6), (4, 6), (5, 6)],
    [(1, 2), (1, 1), (2, 1), (3, 1), (4, 1), (5, 1)],
    [(1, 5), (2, 5), (3, 5)],
    [(2, 3), (2, 2), (3, 2), (4, 2), (5, 2)],
    [(3, 4), (3, 3), (4, 3), (5, 3), (6, 3)],
    [(4, 5), (4, 4), (5, 4), (6, 4)],
    [(5, 5), (6, 5), (6, 6)],
  ]),
];

class _FlowPainter extends CustomPainter {
  final int size;
  final List<Color> colors;
  final List<(_Pt, _Pt)> ends;
  final List<List<_Pt>> paths;

  const _FlowPainter({
    required this.size,
    required this.colors,
    required this.ends,
    required this.paths,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cell = canvasSize.width / size;
    final gap = cell * 0.08;
    final background = Paint()..color = const Color(0xFF162454);
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            col * cell + gap,
            row * cell + gap,
            cell - gap * 2,
            cell - gap * 2,
          ),
          Radius.circular(cell * 0.18),
        );
        canvas.drawRRect(rect, background);
      }
    }

    for (var i = 0; i < paths.length; i++) {
      final path = paths[i];
      if (path.length < 2) continue;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * 0.34
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final line = Path()..moveTo(_cx(path.first, cell), _cy(path.first, cell));
      for (final point in path.skip(1)) {
        line.lineTo(_cx(point, cell), _cy(point, cell));
      }
      canvas.drawPath(line, paint);
    }

    for (var i = 0; i < ends.length; i++) {
      final paint = Paint()..color = colors[i];
      for (final point in [ends[i].$1, ends[i].$2]) {
        canvas.drawCircle(Offset(_cx(point, cell), _cy(point, cell)), cell * 0.28, paint);
      }
    }
  }

  double _cx(_Pt point, double cell) => (point.$2 + 0.5) * cell;
  double _cy(_Pt point, double cell) => (point.$1 + 0.5) * cell;

  @override
  bool shouldRepaint(covariant _FlowPainter oldDelegate) => true;
}
