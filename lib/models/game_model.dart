import 'package:flutter/material.dart';

class GameModel {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final Color accent;

  const GameModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.accent,
  });

  bool get isPlayable =>
      id == '2048' || id == 'sudoku' || id == 'memory';
}

const List<GameModel> kGames = [
  GameModel(
    id: 'memory',
    title: 'Jogo da Memoria',
    subtitle: 'Treine foco e associacao visual.',
    assetPath: 'assets/jogos/memory.png',
    accent: Color(0xFF00EAFF),
  ),
  GameModel(
    id: 'connect4',
    title: 'Connect 4',
    subtitle: 'Estrategia rapida em partidas curtas.',
    assetPath: 'assets/jogos/connect4.png',
    accent: Color(0xFF8B5CF6),
  ),
  GameModel(
    id: 'sudoku',
    title: 'Sudoku',
    subtitle: 'Logica numerica e concentracao.',
    assetPath: 'assets/jogos/sudoku.png',
    accent: Color(0xFF34D399),
  ),
  GameModel(
    id: 'minesweeper',
    title: 'Minesweeper',
    subtitle: 'Deducao e leitura de padroes.',
    assetPath: 'assets/jogos/MINESWEEPER.png',
    accent: Color(0xFFF59E0B),
  ),
  GameModel(
    id: '2048',
    title: '2048',
    subtitle: 'Planejamento de movimentos.',
    assetPath: 'assets/jogos/2048.png',
    accent: Color(0xFF93C5FD),
  ),
  GameModel(
    id: 'flow',
    title: 'Flow Free',
    subtitle: 'Conecte trilhas sem cruzar.',
    assetPath: 'assets/jogos/FLOW FREE.png',
    accent: Color(0xFFF472B6),
  ),
];
