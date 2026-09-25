import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/auth_controller.dart';
import '../theme/qc_theme.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final _controller = AuthController();
  final _primeiroNome = TextEditingController();
  final _ultimoNome = TextEditingController();
  final _email = TextEditingController();
  final _nascimento = TextEditingController();
  final _usuario = TextEditingController();
  final _senha = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _primeiroNome.dispose();
    _ultimoNome.dispose();
    _email.dispose();
    _nascimento.dispose();
    _usuario.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final erro = _controller.mensagemErroCadastro(
      primeiroNome: _primeiroNome.text,
      ultimoNome: _ultimoNome.text,
      email: _email.text,
      dataNascimento: _nascimento.text,
      usuario: _usuario.text,
      senha: _senha.text,
    );
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _loading = true);
    final ok = await _controller.register(
      primeiroNome: _primeiroNome.text,
      ultimoNome: _ultimoNome.text,
      email: _email.text,
      dataNascimento: _nascimento.text,
      usuario: _usuario.text,
      senha: _senha.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      _controller.irParaHome(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.lastError ?? 'Falha no cadastro'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: QcColors.textMuted),
      prefixIcon: Icon(icon, color: QcColors.cyan),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [QcColors.bg0, QcColors.bg1, QcColors.bg2, QcColors.bg3],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: QcColors.glass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Cadastro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: QcColors.text,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Os dados sao salvos no mesmo banco da versao web.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: QcColors.textDim, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _primeiroNome,
                      enabled: !_loading,
                      style: const TextStyle(color: QcColors.text),
                      decoration: _decoration('Primeiro nome', Icons.badge_outlined),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _ultimoNome,
                      enabled: !_loading,
                      style: const TextStyle(color: QcColors.text),
                      decoration: _decoration('Sobrenome', Icons.badge_outlined),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _email,
                      enabled: !_loading,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: QcColors.text),
                      decoration: _decoration('E-mail', Icons.email_outlined),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nascimento,
                      enabled: !_loading,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_DateMaskFormatter()],
                      style: const TextStyle(color: QcColors.text),
                      decoration: _decoration('Nascimento (dd/mm/aaaa)', Icons.cake_outlined),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _usuario,
                      enabled: !_loading,
                      style: const TextStyle(color: QcColors.text),
                      decoration: _decoration('Usuario', Icons.person_outline),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _senha,
                      enabled: !_loading,
                      obscureText: true,
                      style: const TextStyle(color: QcColors.text),
                      decoration: _decoration('Senha (min. 4)', Icons.lock_outline),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _loading ? null : _cadastrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QcColors.cyan,
                        foregroundColor: QcColors.bg0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : const Text(
                              'Criar conta',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(capped[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
