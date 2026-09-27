import 'package:flutter/material.dart';

import '../courses/try_it_runner.dart';
import '../theme/qc_theme.dart';

class TryItView extends StatefulWidget {
  final String languageKey;
  final String title;
  final String initialCode;

  const TryItView({
    super.key,
    required this.languageKey,
    required this.title,
    required this.initialCode,
  });

  @override
  State<TryItView> createState() => _TryItViewState();
}

class _TryItViewState extends State<TryItView> {
  late final TextEditingController _code;
  RunResult? _result;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(text: widget.initialCode);
    _result = runCourseCode(widget.languageKey, widget.initialCode);
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _run() {
    setState(() {
      _result = runCourseCode(widget.languageKey, _code.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      backgroundColor: QcColors.bg0,
      appBar: AppBar(title: const Text('Experimente voce mesmo')),
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
            const SizedBox(height: 6),
            const Text(
              'Edite o exemplo e execute para ver o resultado, como no tutorial.',
              style: TextStyle(color: QcColors.textDim, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: QcColors.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white12)),
                    ),
                    child: const Text(
                      'Codigo',
                      style: TextStyle(color: QcColors.cyan, fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextField(
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
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: QcColors.green,
                foregroundColor: QcColors.bg0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _run,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Executar'),
            ),
            const SizedBox(height: 14),
            const Text(
              'Resultado',
              style: TextStyle(color: QcColors.cyan, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _ResultPanel(result: result),
          ],
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final RunResult? result;

  const _ResultPanel({required this.result});

  @override
  Widget build(BuildContext context) {
    final current = result;
    if (current == null) return const SizedBox.shrink();
    if (!current.ok) {
      return _box(
        child: Text(current.output, style: const TextStyle(color: Colors.redAccent, height: 1.4)),
      );
    }
    if (current.preview.isNotEmpty) {
      return _box(
        color: const Color(0xFFF8FAFC),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final piece in current.preview) _htmlPiece(piece),
          ],
        ),
      );
    }
    return _box(
      child: Text(
        current.output,
        style: const TextStyle(color: QcColors.text, fontFamily: 'monospace', height: 1.45),
      ),
    );
  }

  Widget _htmlPiece(HtmlPiece piece) {
    switch (piece.tag) {
      case 'h1':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(piece.text, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 28, fontWeight: FontWeight.w800)),
        );
      case 'h2':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(piece.text, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w800)),
        );
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(piece.text, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w700)),
        );
      case 'a':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            piece.text,
            style: const TextStyle(color: Color(0xFF2563EB), decoration: TextDecoration.underline, fontSize: 16),
          ),
        );
      case 'li':
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text('• ${piece.text}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, height: 1.4)),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(piece.text, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, height: 1.45)),
        );
    }
  }

  Widget _box({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color ?? QcColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}
