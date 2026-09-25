import 'package:flutter/material.dart';

import '../games/game_2048/game_2048_page.dart';
import '../games/memory/memory_page.dart';
import '../games/sudoku/sudoku_page.dart';
import '../models/game_model.dart';

/// Controla listagem e resolução de jogos jogáveis.
class JogosController {
  List<GameModel> get games => kGames;

  Widget? resolverPagina(GameModel game) {
    switch (game.id) {
      case '2048':
        return const Game2048Page();
      case 'sudoku':
        return const SudokuPage();
      case 'memory':
        return const MemoryPage();
      default:
        return null;
    }
  }

  void mostrarIndisponivel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Este jogo entra na proxima fase.')),
    );
  }
}
