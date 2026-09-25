import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/qc_theme.dart';
import '../core/game_scaffold.dart';
import '../core/game_widgets.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  final _rng = Random();
  final List<String> _symbols = const [
    'assets/jogos/memory_cards/1.png',
    'assets/jogos/memory_cards/2.png',
    'assets/jogos/memory_cards/3.png',
    'assets/jogos/memory_cards/4.png',
    'assets/jogos/memory_cards/5.png',
    'assets/jogos/memory_cards/6.png',
    'assets/jogos/memory_cards/7.png',
    'assets/jogos/memory_cards/8.png',
  ];
  static const String _cardBack = 'assets/jogos/memory_cards/versoCarta.png';

  late List<_MemoryCardData> _cards;
  int? _first;
  int? _second;
  bool _lock = false;
  int _attempts = 0;
  int _matches = 0;
  int _elapsedSec = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimerIfNeeded() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSec++;
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    _elapsedSec = 0;
    _attempts = 0;
    _matches = 0;
    _first = null;
    _second = null;
    _lock = false;

    final deck = [..._symbols, ..._symbols]
        .asMap()
        .entries
        .map((e) => _MemoryCardData(id: e.key, symbol: e.value))
        .toList();
    deck.shuffle(_rng);

    setState(() {
      _cards = deck;
    });
  }

  void _flip(int index) {
    if (_lock) return;
    if (_cards[index].isMatched || _cards[index].isFaceUp) return;

    _startTimerIfNeeded();

    setState(() {
      _cards[index] = _cards[index].copyWith(isFaceUp: true);
      if (_first == null) {
        _first = index;
      } else if (_second == null) {
        _second = index;
        _attempts++;
        _resolvePair();
      }
    });
  }

  void _resolvePair() {
    final first = _first;
    final second = _second;
    if (first == null || second == null) return;

    _lock = true;
    final same = _cards[first].symbol == _cards[second].symbol;
    Future.delayed(const Duration(milliseconds: 620), () {
      if (!mounted) return;
      setState(() {
        if (same) {
          _cards[first] = _cards[first].copyWith(isMatched: true);
          _cards[second] = _cards[second].copyWith(isMatched: true);
          _matches++;
          if (_matches == _symbols.length) {
            _timer?.cancel();
          }
        } else {
          _cards[first] = _cards[first].copyWith(isFaceUp: false);
          _cards[second] = _cards[second].copyWith(isFaceUp: false);
        }
        _first = null;
        _second = null;
        _lock = false;
      });
    });
  }

  String get _formattedTime {
    final min = (_elapsedSec ~/ 60).toString().padLeft(2, '0');
    final sec = (_elapsedSec % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final won = _matches == _symbols.length;
    final status = won
        ? const GameStatusBanner(
            message: 'Excelente! Todos os pares encontrados.',
            accent: QcColors.green,
            icon: Icons.celebration_rounded,
          )
        : null;

    return GameScaffold(
      title: 'Memory',
      subtitle: 'Encontre todos os pares no menor numero de tentativas.',
      stats: [
        GameStat(label: 'Tempo', value: _formattedTime),
        GameStat(label: 'Tentativas', value: '$_attempts'),
        GameStat(label: 'Pares', value: '$_matches/${_symbols.length}'),
      ],
      actions: [
        GameActionButton(
          label: 'Reiniciar',
          icon: Icons.refresh_rounded,
          onTap: _reset,
          primary: true,
        ),
      ],
      body: GlassPanel(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            return _MemoryCard(
              data: _cards[index],
              onTap: () => _flip(index),
            );
          },
        ),
      ),
      footer: status,
    );
  }
}

class _MemoryCardData {
  final int id;
  final String symbol;
  final bool isFaceUp;
  final bool isMatched;

  const _MemoryCardData({
    required this.id,
    required this.symbol,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  _MemoryCardData copyWith({
    bool? isFaceUp,
    bool? isMatched,
  }) {
    return _MemoryCardData(
      id: id,
      symbol: symbol,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final _MemoryCardData data;
  final VoidCallback onTap;

  const _MemoryCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final faceUp = data.isFaceUp || data.isMatched;
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 380),
        tween: Tween(begin: 0, end: faceUp ? 1 : 0),
        curve: Curves.easeInOutCubic,
        builder: (context, value, child) {
          final angle = value * pi;
          final showFront = angle < pi / 2;
          final elev = data.isMatched ? 0.6 : 1.0;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: showFront
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [QcColors.bg1, QcColors.bg3],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: data.isMatched
                            ? [const Color(0xFF184428), const Color(0xFF0F2A18)]
                            : [const Color(0xFF0C1738), const Color(0xFF0A1028)],
                      ),
                border: Border.all(
                  color: showFront
                      ? Colors.white24
                      : (data.isMatched ? QcColors.green : QcColors.cyan.withValues(alpha: 0.7)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8 * elev,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: showFront
                    ? Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          _MemoryPageState._cardBack,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            data.symbol,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
