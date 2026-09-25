import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/home_controller.dart';
import '../theme/qc_theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeController();
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              QcColors.bg0,
              QcColors.bg1,
              QcColors.bg2,
              QcColors.bg3,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Bem vindo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: QcColors.text,
                    fontSize: size.width < 360 ? 34 : 40,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 18),
                const _WelcomeQuote(),
                const Expanded(
                  child: Center(child: _LiquidPulseCube()),
                ),
                _LoginButton(onTap: () => controller.irParaLogin(context)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mesma animação do CSS `liquidPulse` (login.css do QuebraCódigo).
class _LiquidPulseCube extends StatefulWidget {
  const _LiquidPulseCube();

  @override
  State<_LiquidPulseCube> createState() => _LiquidPulseCubeState();
}

class _LiquidPulseCubeState extends State<_LiquidPulseCube>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 0% scale(1) rotate(0)
    // 25% scale(1.03) rotate(1deg)
    // 50% scale(0.97) rotate(-1deg)
    // 75% scale(1.04) rotate(1deg)
    // 100% scale(1) rotate(0)
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.03).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.03, end: 0.97).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.97, end: 1.04).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.04, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    _rotate = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: -1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -1.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotate.value * (math.pi / 180),
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: Image.asset(
        'assets/home_cube.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

class _WelcomeQuote extends StatelessWidget {
  const _WelcomeQuote();

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      color: QcColors.text,
      fontSize: 15,
      height: 1.35,
      fontWeight: FontWeight.w500,
    );
    const accent = TextStyle(
      color: QcColors.cyan,
      fontSize: 15,
      height: 1.35,
      fontWeight: FontWeight.w700,
    );

    return Column(
      children: [
        Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            style: base,
            children: const [
              TextSpan(text: '"A '),
              TextSpan(text: 'lógica', style: accent),
              TextSpan(text: ' te leva de A a B.\nA '),
              TextSpan(text: 'imaginação', style: accent),
              TextSpan(text: ' te leva a qualquer lugar."'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            '(Albert Einstein)',
            style: TextStyle(
              color: QcColors.textDim,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginButton extends StatefulWidget {
  const _LoginButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.88 : 1,
          duration: const Duration(milliseconds: 90),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x663A1F78),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white24, width: 1.2),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                color: QcColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
