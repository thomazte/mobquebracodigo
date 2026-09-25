import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../services/auth_session.dart';
import '../theme/qc_theme.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _controller = AuthController();
  late final AnimationController _animController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();

    if (AuthSession.instance.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.irParaHome(context);
      });
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final erro = _controller.mensagemErroLogin(
      _userController.text,
      _passController.text,
    );
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _loading = true);
    final ok = await _controller.login(_userController.text, _passController.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      _controller.irParaHome(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.lastError ?? 'Falha no login'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [QcColors.bg0, QcColors.bg1, QcColors.bg2, QcColors.bg3],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: QcColors.glass,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Bem-vindo!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: QcColors.text,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Entre com a mesma conta da versao web.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: QcColors.textDim,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 22),
                          TextField(
                            controller: _userController,
                            enabled: !_loading,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: QcColors.text),
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              labelStyle: const TextStyle(color: QcColors.textMuted),
                              prefixIcon: const Icon(Icons.person_outline, color: QcColors.cyan),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passController,
                            enabled: !_loading,
                            obscureText: true,
                            onSubmitted: (_) => _entrar(),
                            style: const TextStyle(color: QcColors.text),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              labelStyle: const TextStyle(color: QcColors.textMuted),
                              prefixIcon: const Icon(Icons.lock_outline, color: QcColors.cyan),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: _loading ? null : _entrar,
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
                                    'Entrar',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: _loading ? null : () => _controller.irParaCadastro(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: QcColors.text,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Criar conta'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
