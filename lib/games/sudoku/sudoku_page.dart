import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/qc_theme.dart';
import '../core/game_scaffold.dart';
import '../core/game_widgets.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  final _rng = Random();

  late List<List<int>> _solution;
  late List<List<int>> _values;
  late List<List<bool>> _fixed;
  late List<List<Set<int>>> _notes;

  bool _notesMode = false;
  int _selectedRow = -1;
  int _selectedCol = -1;
  Set<String> _conflicts = {};
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    const puzzles = [
      (
        puzzle: [
          [5, 3, 0, 0, 7, 0, 0, 0, 0],
          [6, 0, 0, 1, 9, 5, 0, 0, 0],
          [0, 9, 8, 0, 0, 0, 0, 6, 0],
          [8, 0, 0, 0, 6, 0, 0, 0, 3],
          [4, 0, 0, 8, 0, 3, 0, 0, 1],
          [7, 0, 0, 0, 2, 0, 0, 0, 6],
          [0, 6, 0, 0, 0, 0, 2, 8, 0],
          [0, 0, 0, 4, 1, 9, 0, 0, 5],
          [0, 0, 0, 0, 8, 0, 0, 7, 9],
        ],
        solution: [
          [5, 3, 4, 6, 7, 8, 9, 1, 2],
          [6, 7, 2, 1, 9, 5, 3, 4, 8],
          [1, 9, 8, 3, 4, 2, 5, 6, 7],
          [8, 5, 9, 7, 6, 1, 4, 2, 3],
          [4, 2, 6, 8, 5, 3, 7, 9, 1],
          [7, 1, 3, 9, 2, 4, 8, 5, 6],
          [9, 6, 1, 5, 3, 7, 2, 8, 4],
          [2, 8, 7, 4, 1, 9, 6, 3, 5],
          [3, 4, 5, 2, 8, 6, 1, 7, 9],
        ],
      ),
      (
        puzzle: [
          [0, 0, 0, 2, 6, 0, 7, 0, 1],
          [6, 8, 0, 0, 7, 0, 0, 9, 0],
          [1, 9, 0, 0, 0, 4, 5, 0, 0],
          [8, 2, 0, 1, 0, 0, 0, 4, 0],
          [0, 0, 4, 6, 0, 2, 9, 0, 0],
          [0, 5, 0, 0, 0, 3, 0, 2, 8],
          [0, 0, 9, 3, 0, 0, 0, 7, 4],
          [0, 4, 0, 0, 5, 0, 0, 3, 6],
          [7, 0, 3, 0, 1, 8, 0, 0, 0],
        ],
        solution: [
          [4, 3, 5, 2, 6, 9, 7, 8, 1],
          [6, 8, 2, 5, 7, 1, 4, 9, 3],
          [1, 9, 7, 8, 3, 4, 5, 6, 2],
          [8, 2, 6, 1, 9, 5, 3, 4, 7],
          [3, 7, 4, 6, 8, 2, 9, 1, 5],
          [9, 5, 1, 7, 4, 3, 6, 2, 8],
          [5, 1, 9, 3, 2, 6, 8, 7, 4],
          [2, 4, 8, 9, 5, 7, 1, 3, 6],
          [7, 6, 3, 4, 1, 8, 2, 5, 9],
        ],
      ),
    ];

    final chosen = puzzles[_rng.nextInt(puzzles.length)];
    _solution = chosen.solution.map((r) => [...r]).toList();
    _values = chosen.puzzle.map((r) => [...r]).toList();
    _fixed = _values
        .map((row) => row.map((v) => v != 0).toList())
        .toList();
    _notes = List.generate(
      9,
      (_) => List.generate(9, (_) => <int>{}),
    );
    _selectedRow = -1;
    _selectedCol = -1;
    _notesMode = false;
    _completed = false;
    _recomputeConflicts();
    setState(() {});
  }

  void _select(int r, int c) {
    setState(() {
      _selectedRow = r;
      _selectedCol = c;
    });
  }

  void _setValue(int value) {
    if (_selectedRow < 0 || _selectedCol < 0) return;
    if (_fixed[_selectedRow][_selectedCol]) return;

    setState(() {
      if (_notesMode) {
        final noteSet = _notes[_selectedRow][_selectedCol];
        if (noteSet.contains(value)) {
          noteSet.remove(value);
        } else {
          noteSet.add(value);
        }
      } else {
        _values[_selectedRow][_selectedCol] = value;
        _notes[_selectedRow][_selectedCol].clear();
      }
      _recomputeConflicts();
      _completed = _isSolved();
    });
  }

  void _clearSelected() {
    if (_selectedRow < 0 || _selectedCol < 0) return;
    if (_fixed[_selectedRow][_selectedCol]) return;

    setState(() {
      _values[_selectedRow][_selectedCol] = 0;
      _notes[_selectedRow][_selectedCol].clear();
      _recomputeConflicts();
      _completed = false;
    });
  }

  void _applyHint() {
    if (_selectedRow >= 0 &&
        _selectedCol >= 0 &&
        !_fixed[_selectedRow][_selectedCol] &&
        _values[_selectedRow][_selectedCol] == 0) {
      setState(() {
        _values[_selectedRow][_selectedCol] = _solution[_selectedRow][_selectedCol];
        _notes[_selectedRow][_selectedCol].clear();
        _recomputeConflicts();
        _completed = _isSolved();
      });
      return;
    }

    final empties = <(int, int)>[];
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (_values[r][c] == 0 && !_fixed[r][c]) {
          empties.add((r, c));
        }
      }
    }
    if (empties.isEmpty) return;
    final pick = empties[_rng.nextInt(empties.length)];
    setState(() {
      _values[pick.$1][pick.$2] = _solution[pick.$1][pick.$2];
      _notes[pick.$1][pick.$2].clear();
      _recomputeConflicts();
      _completed = _isSolved();
    });
  }

  void _recomputeConflicts() {
    final conflicts = <String>{};

    void mark(int r, int c) => conflicts.add('$r-$c');

    for (var r = 0; r < 9; r++) {
      final seen = <int, int>{};
      for (var c = 0; c < 9; c++) {
        final v = _values[r][c];
        if (v == 0) continue;
        if (seen.containsKey(v)) {
          mark(r, c);
          mark(r, seen[v]!);
        } else {
          seen[v] = c;
        }
      }
    }

    for (var c = 0; c < 9; c++) {
      final seen = <int, int>{};
      for (var r = 0; r < 9; r++) {
        final v = _values[r][c];
        if (v == 0) continue;
        if (seen.containsKey(v)) {
          mark(r, c);
          mark(seen[v]!, c);
        } else {
          seen[v] = r;
        }
      }
    }

    for (var br = 0; br < 3; br++) {
      for (var bc = 0; bc < 3; bc++) {
        final seen = <int, (int, int)>{};
        for (var r = br * 3; r < br * 3 + 3; r++) {
          for (var c = bc * 3; c < bc * 3 + 3; c++) {
            final v = _values[r][c];
            if (v == 0) continue;
            if (seen.containsKey(v)) {
              mark(r, c);
              final prev = seen[v]!;
              mark(prev.$1, prev.$2);
            } else {
              seen[v] = (r, c);
            }
          }
        }
      }
    }

    _conflicts = conflicts;
  }

  bool _isSolved() {
    if (_conflicts.isNotEmpty) return false;
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (_values[r][c] != _solution[r][c]) return false;
      }
    }
    return true;
  }

  int get _filledCells {
    var n = 0;
    for (final row in _values) {
      for (final v in row) {
        if (v != 0) n++;
      }
    }
    return n;
  }

  bool _isSelected(int r, int c) => r == _selectedRow && c == _selectedCol;

  int get _selectedValue {
    if (_selectedRow < 0 || _selectedCol < 0) return 0;
    return _values[_selectedRow][_selectedCol];
  }

  bool _isRelated(int r, int c) {
    if (_selectedRow < 0 || _selectedCol < 0) return false;
    if (r == _selectedRow || c == _selectedCol) return true;
    return (r ~/ 3 == _selectedRow ~/ 3) && (c ~/ 3 == _selectedCol ~/ 3);
  }

  bool _isSameSelectedValue(int r, int c) {
    final sv = _selectedValue;
    if (sv == 0) return false;
    return _values[r][c] == sv;
  }

  Border _cellBorder(int r, int c, Color baseColor) {
    final top = r % 3 == 0 ? 2.2 : 0.8;
    final left = c % 3 == 0 ? 2.2 : 0.8;
    final right = c == 8 ? 2.2 : 0.8;
    final bottom = r == 8 ? 2.2 : 0.8;
    return Border(
      top: BorderSide(color: baseColor, width: top),
      left: BorderSide(color: baseColor, width: left),
      right: BorderSide(color: baseColor, width: right),
      bottom: BorderSide(color: baseColor, width: bottom),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _completed
        ? const GameStatusBanner(
            message: 'Parabens! Sudoku concluido.',
            accent: QcColors.green,
            icon: Icons.task_alt_rounded,
          )
        : _conflicts.isNotEmpty
            ? GameStatusBanner(
                message: '${_conflicts.length} celulas em conflito. Ajuste os valores destacados.',
                accent: Colors.redAccent,
                icon: Icons.error_outline_rounded,
              )
            : null;

    return GameScaffold(
      title: 'Sudoku',
      subtitle: 'Preencha os espacos vazios sem repetir numeros em linha, coluna e bloco 3x3.',
      stats: [
        GameStat(label: 'Preenchidas', value: '$_filledCells/81'),
        GameStat(label: 'Conflitos', value: '${_conflicts.length}'),
        GameStat(label: 'Modo notas', value: _notesMode ? 'Ativo' : 'Off'),
      ],
      actions: [
        GameActionButton(
          label: _notesMode ? 'Notas: ON' : 'Notas: OFF',
          icon: Icons.edit_note_rounded,
          onTap: () => setState(() => _notesMode = !_notesMode),
        ),
        GameActionButton(
          label: 'Dica',
          icon: Icons.lightbulb_outline_rounded,
          onTap: _applyHint,
        ),
        GameActionButton(
          label: 'Limpar',
          icon: Icons.backspace_outlined,
          onTap: _clearSelected,
        ),
        GameActionButton(
          label: 'Novo',
          icon: Icons.refresh_rounded,
          onTap: _reset,
          primary: true,
        ),
      ],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Text(
              'Dica visual: azul = selecionada, azul claro = mesma linha/coluna/bloco, ciano = mesmo numero, vermelho = conflito.',
              style: TextStyle(color: QcColors.textDim, fontSize: 12.5, height: 1.35),
            ),
          ),
          GlassPanel(
            padding: const EdgeInsets.all(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 81,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                ),
                itemBuilder: (context, index) {
                  final r = index ~/ 9;
                  final c = index % 9;
                  final value = _values[r][c];
                  final isFixed = _fixed[r][c];
                  final selected = _isSelected(r, c);
                  final related = _isRelated(r, c);
                  final sameValue = _isSameSelectedValue(r, c);
                  final conflict = _conflicts.contains('$r-$c');

                  final borderColor = selected
                      ? QcColors.cyan
                      : conflict
                          ? Colors.redAccent
                          : Colors.white24;
                  final bgColor = selected
                      ? QcColors.cyan.withValues(alpha: 0.22)
                      : sameValue
                          ? QcColors.cyan.withValues(alpha: 0.15)
                      : related
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.02);

                  return GestureDetector(
                    onTap: () => _select(r, c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 170),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: _cellBorder(r, c, borderColor),
                      ),
                      child: Center(
                        child: value != 0
                            ? Text(
                                '$value',
                                style: TextStyle(
                                  color: isFixed
                                      ? Colors.white
                                      : (conflict ? Colors.redAccent : QcColors.cyan),
                                  fontWeight: isFixed ? FontWeight.w900 : FontWeight.w700,
                                  fontSize: isFixed ? 20 : 19,
                                ),
                              )
                            : _NoteMiniGrid(notes: _notes[r][c]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              9,
              (i) {
                final n = i + 1;
                final active = _selectedValue == n;
                return GestureDetector(
                  onTap: () => _setValue(n),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: active ? QcColors.cyan : QcColors.panel,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active ? QcColors.cyan : Colors.white24,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$n',
                        style: TextStyle(
                          color: active ? QcColors.bg0 : QcColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      footer: status,
    );
  }
}

class _NoteMiniGrid extends StatelessWidget {
  final Set<int> notes;

  const _NoteMiniGrid({required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();
    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      children: List.generate(9, (i) {
        final n = i + 1;
        final show = notes.contains(n);
        return Center(
          child: Text(
            show ? '$n' : '',
            style: const TextStyle(fontSize: 8.5, color: QcColors.textMuted),
          ),
        );
      }),
    );
  }
}
