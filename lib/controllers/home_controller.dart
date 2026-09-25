import 'package:flutter/material.dart';

/// Controla a navegação da tela inicial (landing).
class HomeController {
  void irParaLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}
