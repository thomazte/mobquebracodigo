import 'package:flutter/material.dart';

import '../controllers/jogos_controller.dart';
import '../models/game_model.dart';
import '../theme/qc_theme.dart';
import '../widgets/qc_interactions.dart';
import 'jogo_detalhe_view.dart';

class JogosView extends StatelessWidget {
  const JogosView({super.key});

  void _openGame(BuildContext context, JogosController controller, GameModel game) {
    final page = controller.resolverPagina(game);
    if (page != null) {
      qcPushDetail(context, page);
    } else {
      qcPushDetail(context, JogoDetalheView(game: game));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = JogosController();

    return Scaffold(
      appBar: AppBar(title: const Text('Jogos')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [QcColors.bg0, QcColors.bg1, QcColors.bg2],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: QcColors.glass,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biblioteca de Jogos',
                    style: TextStyle(
                      color: QcColors.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Escolha um jogo para abrir. Cada card leva para uma tela de detalhe.',
                    style: TextStyle(color: QcColors.textDim, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.games.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
              itemBuilder: (context, index) {
                final game = controller.games[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 220 + (index * 35)),
                  tween: Tween(begin: 0, end: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - value) * 12),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _GameCard(
                    game: game,
                    onTap: () => _openGame(context, controller, game),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onTap;

  const _GameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return QcPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: QcColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Hero(
                  tag: 'game-${game.id}',
                  child: Image.asset(game.assetPath, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: QcColors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: QcColors.textMuted, fontSize: 11.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Abrir jogo →',
                    style: TextStyle(
                      color: game.accent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
