import 'package:flutter/material.dart';

import '../courses/try_it_runner.dart';
import '../theme/qc_theme.dart';

class LessonChallengeView extends StatefulWidget {
  final String languageKey;
  final String title;
  final String exampleCode;
  final bool isLast;

  const LessonChallengeView({
    super.key,
    required this.languageKey,
    required this.title,
    required this.exampleCode,
    this.isLast = false,
  });

  @override
  State<LessonChallengeView> createState() => _LessonChallengeViewState();
}

class _LessonChallengeViewState extends State<LessonChallengeView> {
  final _code = TextEditingController();
  late final RunResult _expected;
  LessonVerdict? _verdict;

  @override
  void initState() {
    super.initState();
    _expected = runCourseCode(widget.languageKey, widget.exampleCode);
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _verdict = validateLessonCode(
        languageKey: widget.languageKey,
        code: _code.text,
        exampleCode: widget.exampleCode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final verdict = _verdict;
    final passed = verdict?.correct ?? false;
    return Scaffold(
      backgroundColor: QcColors.bg0,
      appBar: AppBar(title: const Text('Desafio da aula')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [QcColors.bg0, QcColors.bg1],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.title,
              style: const TextStyle(color: QcColors.text, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escreva seu proprio codigo. Ele nao precisa ser igual ao exemplo, mas o resultado precisa ser o mesmo.',
              style: TextStyle(color: QcColors.textDim, height: 1.45),
            ),
            const SizedBox(height: 14),
            const Text(
              'Resultado esperado',
              style: TextStyle(color: QcColors.cyan, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _panel(
              Text(
                _expected.output,
                style: const TextStyle(color: QcColors.text, fontFamily: 'monospace', height: 1.45),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: QcColors.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _code,
                maxLines: null,
                minLines: 8,
                style: const TextStyle(
                  color: QcColors.green,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.45,
                ),
                decoration: const InputDecoration(
                  hintText: 'Escreva seu codigo aqui',
                  hintStyle: TextStyle(color: QcColors.textMuted, fontFamily: 'monospace'),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: QcColors.green,
                foregroundColor: QcColors.bg0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _validate,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Validar'),
            ),
            if (verdict != null) ...[
              const SizedBox(height: 14),
              _panel(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verdict.message,
                      style: TextStyle(
                        color: passed ? QcColors.green : Colors.redAccent,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                    if (!passed && verdict.output.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Seu resultado', style: TextStyle(color: QcColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(
                        verdict.output,
                        style: const TextStyle(color: QcColors.text, fontFamily: 'monospace', height: 1.45),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (passed) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: QcColors.cyan,
                  foregroundColor: QcColors.bg0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(widget.isLast ? 'Concluir tutorial' : 'Seguir para a proxima parte'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _panel(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: QcColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}
