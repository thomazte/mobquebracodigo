import 'package:flutter/material.dart';

import '../controllers/jogos_controller.dart';
import '../models/game_model.dart';
import '../theme/qc_theme.dart';
import '../widgets/qc_interactions.dart';

class JogoDetalheView extends StatelessWidget {
  final GameModel game;

  const JogoDetalheView({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = JogosController();
    final page = controller.resolverPagina(game);

    return Scaffold(
      appBar: AppBar(title: Text(game.title)),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [QcColors.bg0, QcColors.bg1],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: game.accent.withValues(alpha: 0.55), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: game.accent.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Hero(
                tag: 'game-${game.id}',
                child: Image.asset(
                  game.assetPath,
                  width: double.infinity,
                  height: 230,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              game.title,
              style: TextStyle(
                color: game.accent,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              game.subtitle,
              style: const TextStyle(color: QcColors.textDim, fontSize: 15),
            ),
            const SizedBox(height: 14),
            Text(
              page == null
                  ? 'Esse jogo entra na proxima entrega. Ja deixamos o layout preparado.'
                  : 'Este jogo ja possui versao jogavel completa.',
              style: const TextStyle(color: QcColors.textMuted, height: 1.5),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: game.accent,
                  foregroundColor: QcColors.bg0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (page != null) {
                    qcPushDetail(context, page);
                  } else {
                    controller.mostrarIndisponivel(context);
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Jogar agora'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
