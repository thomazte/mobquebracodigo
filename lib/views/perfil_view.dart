import 'package:flutter/material.dart';

import '../controllers/perfil_controller.dart';
import '../theme/qc_theme.dart';
import '../widgets/qc_interactions.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> with SingleTickerProviderStateMixin {
  final _perfilController = PerfilController();
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _senhaCtrl;

  @override
  void initState() {
    super.initState();
    final user = _perfilController.user;
    _nomeCtrl = TextEditingController(text: user.nome);
    _emailCtrl = TextEditingController(text: user.email);
    _bioCtrl = TextEditingController(text: user.bio);
    _senhaCtrl = TextEditingController();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(_fade);
    _controller.forward();

    _perfilController.addListener(_onPerfilChanged);
    _carregarPerfil();
  }

  void _onPerfilChanged() {
    if (!mounted) return;
    final user = _perfilController.user;
    if (_nomeCtrl.text != user.nome) _nomeCtrl.text = user.nome;
    if (_emailCtrl.text != user.email) _emailCtrl.text = user.email;
    setState(() {});
  }

  Future<void> _carregarPerfil() async {
    await _perfilController.carregar();
    if (!mounted) return;
    final user = _perfilController.user;
    _nomeCtrl.text = user.nome;
    _emailCtrl.text = user.email;
  }

  @override
  void dispose() {
    _perfilController.removeListener(_onPerfilChanged);
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    _senhaCtrl.dispose();
    _controller.dispose();
    _perfilController.dispose();
    super.dispose();
  }

  Future<void> _salvarPerfil() async {
    FocusScope.of(context).unfocus();
    final ok = await _perfilController.salvar(
      nome: _nomeCtrl.text,
      email: _emailCtrl.text,
      bio: _bioCtrl.text,
      novaSenha: _senhaCtrl.text.trim().isEmpty ? null : _senhaCtrl.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Perfil salvo com sucesso.'
              : (_perfilController.error ?? 'Falha ao salvar perfil.'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (ok) _senhaCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = _perfilController.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [QcColors.bg0, QcColors.bg1, QcColors.bg2, QcColors.bg3],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: QcColors.glass,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: QcColors.cyan.withValues(alpha: 0.75), width: 1.6),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [QcColors.cyan, QcColors.violet],
                          ),
                        ),
                        child: const Icon(Icons.person_rounded, color: QcColors.bg0, size: 38),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seu perfil',
                              style: TextStyle(
                                color: QcColors.text,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Mantenha seus dados e preferencias atualizados.',
                              style: TextStyle(color: QcColors.textDim, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Dados da conta',
                  child: Column(
                    children: [
                      _ProfileField(
                        controller: _nomeCtrl,
                        label: 'Nome de usuario',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 10),
                      _ProfileField(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 10),
                      _ProfileField(
                        controller: _bioCtrl,
                        label: 'Bio (local)',
                        icon: Icons.edit_note_rounded,
                        minLines: 2,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 10),
                      _ProfileField(
                        controller: _senhaCtrl,
                        label: 'Nova senha (opcional)',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                if (_perfilController.loading) ...[
                  const SizedBox(height: 12),
                  const Center(child: CircularProgressIndicator()),
                ],
                if (_perfilController.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _perfilController.error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Preferencias',
                  child: Column(
                    children: [
                      _SwitchRow(
                        title: 'Tema escuro',
                        subtitle: 'Visual neon com alto contraste.',
                        value: user.temaEscuro,
                        onChanged: _perfilController.setTemaEscuro,
                      ),
                      const SizedBox(height: 8),
                      _SwitchRow(
                        title: 'Animacoes',
                        subtitle: 'Transicoes e efeitos visuais da interface.',
                        value: user.animacoesAtivas,
                        onChanged: _perfilController.setAnimacoesAtivas,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                QcPressable(
                  onTap: _perfilController.loading ? null : _salvarPerfil,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [QcColors.cyan, QcColors.violet],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: QcColors.cyan.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: QcColors.bg0),
                        SizedBox(width: 8),
                        Text(
                          'Salvar alteracoes',
                          style: TextStyle(
                            color: QcColors.bg0,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: QcColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: QcColors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int minLines;
  final int maxLines;
  final bool obscureText;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: obscureText ? 1 : minLines,
      maxLines: obscureText ? 1 : maxLines,
      obscureText: obscureText,
      style: const TextStyle(color: QcColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: QcColors.textMuted),
        prefixIcon: Icon(icon, color: QcColors.cyan),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: QcColors.text, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: QcColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: QcColors.cyan,
            activeTrackColor: QcColors.cyan.withValues(alpha: 0.45),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
