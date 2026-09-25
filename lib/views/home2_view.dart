import 'package:flutter/material.dart';

import '../controllers/home2_controller.dart';
import '../controllers/jogos_controller.dart';
import '../models/game_model.dart';
import '../theme/qc_theme.dart';
import '../widgets/qc_interactions.dart';
import 'cursos_view.dart';
import 'jogo_detalhe_view.dart';
import 'jogos_view.dart';

class Home2View extends StatelessWidget {
  const Home2View({super.key});

  void _openGame(BuildContext context, JogosController jogos, GameModel game) {
    final page = jogos.resolverPagina(game);
    if (page != null) {
      qcPushDetail(context, page);
    } else {
      qcPushDetail(context, JogoDetalheView(game: game));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Home2Controller();
    final jogos = controller.jogosController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quebra Codigo'),
        actions: [
          IconButton(
            onPressed: () => controller.abrirPerfil(context),
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Perfil',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: QcColors.bg1,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 14),
            children: [
              const ListTile(
                title: Text(
                  'Menu',
                  style: TextStyle(
                    color: QcColors.cyan,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_rounded, color: QcColors.cyan),
                title: const Text('Home'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.sports_esports_rounded, color: QcColors.cyan),
                title: const Text('Jogos'),
                onTap: () {
                  Navigator.pop(context);
                  controller.abrirJogos(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.school_rounded, color: QcColors.cyan),
                title: const Text('Cursos'),
                onTap: () {
                  Navigator.pop(context);
                  controller.abrirCursos(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text('Sair'),
                onTap: () async {
                  Navigator.pop(context);
                  await controller.sair(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [QcColors.bg0, QcColors.bg1, QcColors.bg2, QcColors.bg3],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: QcColors.glass,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo, ${controller.welcomeName}!',
                    style: const TextStyle(
                      color: QcColors.text,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Continue sua trilha com jogos e cursos no mesmo padrao visual da versao web.',
                    style: TextStyle(color: QcColors.textDim, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _SectionHeader(
              title: 'Jogos',
              actionLabel: 'Ver todos',
              onTap: () => qcPushDetail(context, const JogosView()),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.games.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final game = controller.games[index];
                  return _MiniGameCard(
                    game: game,
                    onTap: () => _openGame(context, jogos, game),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            _SectionHeader(
              title: 'Cursos',
              actionLabel: 'Ver todos',
              onTap: () => qcPushDetail(context, const CursosView()),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.courses.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final course = controller.courses[index];
                  return SizedBox(
                    width: 160,
                    child: QcPressable(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => qcPushDetail(context, const CursosView()),
                      child: Container(
                        decoration: BoxDecoration(
                          color: QcColors.panel,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                child: Image.asset(
                                  course.assetPath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                course.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: QcColors.text,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.abrirCursos(context),
        icon: const Icon(Icons.school_rounded),
        label: const Text('Cursos'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: QcColors.text,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionLabel,
            style: const TextStyle(color: QcColors.cyan, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _MiniGameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onTap;

  const _MiniGameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: QcPressable(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: QcColors.panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Hero(
                    tag: 'game-${game.id}',
                    child: Image.asset(game.assetPath, fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  game.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: QcColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
