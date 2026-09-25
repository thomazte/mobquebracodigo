import 'package:flutter/material.dart';

import '../services/auth_session.dart';

/// Controla autenticação e navegação de login/cadastro.
class AuthController {
  final AuthSession session;

  AuthController({AuthSession? session}) : session = session ?? AuthSession.instance;

  bool get busy => session.busy;
  String? get lastError => session.lastError;
  bool get isAuthenticated => session.isAuthenticated;

  String? mensagemErroLogin(String usuario, String senha) {
    if (usuario.trim().isEmpty || senha.trim().isEmpty) {
      return 'Preencha usuario e senha para continuar.';
    }
    return null;
  }

  String? mensagemErroCadastro({
    required String primeiroNome,
    required String ultimoNome,
    required String email,
    required String dataNascimento,
    required String usuario,
    required String senha,
  }) {
    if (primeiroNome.trim().isEmpty || ultimoNome.trim().isEmpty) {
      return 'Preencha nome e sobrenome.';
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      return 'Informe um e-mail valido.';
    }
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dataNascimento.trim())) {
      return 'Use a data no formato dd/mm/aaaa.';
    }
    if (usuario.trim().length < 2) {
      return 'O usuario deve ter pelo menos 2 caracteres.';
    }
    if (senha.length < 4) {
      return 'A senha deve ter pelo menos 4 caracteres.';
    }
    return null;
  }

  Future<bool> login(String usuario, String senha) {
    return session.login(usuario, senha);
  }

  Future<bool> register({
    required String primeiroNome,
    required String ultimoNome,
    required String email,
    required String dataNascimento,
    required String usuario,
    required String senha,
  }) {
    return session.register(
      primeiroNome: primeiroNome,
      ultimoNome: ultimoNome,
      email: email,
      dataNascimento: dataNascimento,
      usuario: usuario,
      senha: senha,
    );
  }

  Future<void> logout() => session.logout();

  void irParaHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/home2');
  }

  void irParaCadastro(BuildContext context) {
    Navigator.pushNamed(context, '/cadastro');
  }

  void irParaLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> sair(BuildContext context) async {
    await logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
