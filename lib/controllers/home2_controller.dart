import 'package:flutter/material.dart';

import '../models/course_model.dart';
import '../models/game_model.dart';
import '../services/auth_session.dart';
import 'jogos_controller.dart';

/// Controla a home autenticada: menu, seções e abertura de jogos/cursos.
class Home2Controller {
  final JogosController jogosController = JogosController();
  final AuthSession session;

  Home2Controller({AuthSession? session})
      : session = session ?? AuthSession.instance;

  List<GameModel> get games => kGames;
  List<CourseModel> get courses => kCourses;

  String get welcomeName => session.user?.displayName ?? 'jogador';

  void abrirPerfil(BuildContext context) {
    Navigator.pushNamed(context, '/perfil');
  }

  void abrirJogos(BuildContext context) {
    Navigator.pushNamed(context, '/jogos');
  }

  void abrirCursos(BuildContext context) {
    Navigator.pushNamed(context, '/cursos');
  }

  Future<void> sair(BuildContext context) async {
    await session.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
