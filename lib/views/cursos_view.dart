import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/cursos_controller.dart';
import '../models/course_model.dart';
import '../theme/qc_theme.dart';
import '../widgets/qc_interactions.dart';
import 'lesson_challenge_view.dart';
import 'try_it_view.dart';

class CursosView extends StatefulWidget {
  const CursosView({super.key});

  @override
  State<CursosView> createState() => _CursosViewState();
}

class _CursosViewState extends State<CursosView> {
  final _controller = CursosController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleCourses = _controller.filteredCourses;

    return Scaffold(
      backgroundColor: QcColors.bg0,
      appBar: AppBar(
        title: const Text(
          'Cursos - Quebra Código',
          style: TextStyle(
            color: QcColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: QcColors.glass,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [QcColors.cyan, QcColors.violet],
                    ).createShader(bounds),
                    child: const Text(
                      'Trilha de Cursos',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Domine linguagens de programação do básico ao avançado com aulas práticas estilo W3Schools.',
                    style: TextStyle(
                      color: QcColors.textDim,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: _controller.setQuery,
              decoration: InputDecoration(
                hintText: 'Buscar curso (Python, Java, SQL...)',
                hintStyle: const TextStyle(color: QcColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: QcColors.cyan),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (visibleCourses.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: QcColors.panel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Text(
                  'Nenhum curso encontrado. Tente outro termo de busca.',
                  style: TextStyle(color: QcColors.textDim),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleCourses.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final course = visibleCourses[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 200 + (index * 40)),
                    tween: Tween(begin: 0, end: 1),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - value) * 12),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: QcPressable(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => qcPushDetail(context, CursoDetalheView(course: course)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: QcColors.panel,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(width: 5, color: course.accentColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Hero(
                                        tag: 'course-${course.key}',
                                        child: Image.asset(
                                          course.assetPath,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) => const Icon(
                                            Icons.code,
                                            color: QcColors.cyan,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            course.title,
                                            style: const TextStyle(
                                              color: QcColors.text,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            course.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: QcColors.textMuted,
                                              fontSize: 13,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'Acessar Curso →',
                                            style: TextStyle(
                                              color: QcColors.cyan,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class CursoDetalheView extends StatefulWidget {
  final CourseModel course;

  const CursoDetalheView({super.key, required this.course});

  @override
  State<CursoDetalheView> createState() => _CursoDetalheViewState();
}

class _CursoDetalheViewState extends State<CursoDetalheView> {
  final _controller = CursosController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _passed = <int>{};

  String get _progressKey => 'course_passed_${widget.course.key}';

  @override
  void initState() {
    super.initState();
    _controller.resetLesson();
    _controller.addListener(() => setState(() {}));
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_progressKey) ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _passed
        ..clear()
        ..addAll(stored.map(int.tryParse).whereType<int>().where((index) => index >= 0));
    });
  }

  Future<void> _markPassed(int index) async {
    if (!_passed.add(index)) return;
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    final saved = _passed.toList()..sort();
    await prefs.setStringList(_progressKey, saved.map((value) => '$value').toList());
  }

  bool _canOpen(int index) => index == 0 || _passed.contains(index - 1);

  Future<void> _openChallenge(LessonModel lesson, int index) async {
    final passed = await qcPushDetail<bool>(
      context,
      LessonChallengeView(
        languageKey: widget.course.key,
        title: lesson.title,
        exampleCode: lesson.codeExample,
        isLast: index == widget.course.lessons.length - 1,
      ),
    );
    if (!mounted || passed != true) return;
    await _markPassed(index);
    if (!mounted) return;
    if (index < widget.course.lessons.length - 1) {
      _controller.nextLesson(widget.course.lessons.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = _controller.selectedLessonIndex;
    final lessons = widget.course.lessons;
    final currentLesson = lessons[index];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: QcColors.bg0,
      appBar: AppBar(
        title: Text(
          widget.course.title,
          style: const TextStyle(color: QcColors.text, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Aulas',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.list_rounded),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: QcColors.bg1,
        child: SafeArea(child: _lessonMenu(closeOnTap: true)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showMenu = constraints.maxWidth >= 900;
          return Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showMenu)
                      Container(
                        width: 280,
                        decoration: const BoxDecoration(
                          color: QcColors.bg1,
                          border: Border(right: BorderSide(color: Colors.white12)),
                        ),
                        child: _lessonMenu(closeOnTap: false),
                      ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        children: [
                          Text(
                            'Aula ${index + 1} de ${lessons.length}',
                            style: const TextStyle(
                              color: QcColors.cyan,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentLesson.title,
                            style: const TextStyle(
                              color: QcColors.text,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentLesson.content,
                            style: const TextStyle(color: QcColors.textDim, fontSize: 15, height: 1.6),
                          ),
                          const SizedBox(height: 18),
                          _exampleCard(currentLesson),
                          const SizedBox(height: 16),
                          const Text(
                            'Resultado',
                            style: TextStyle(color: QcColors.cyan, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: QcColors.bg1,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              currentLesson.outputExample,
                              style: const TextStyle(
                                color: QcColors.text,
                                fontFamily: 'monospace',
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _passed.contains(index) ? QcColors.bg2 : QcColors.green,
                                foregroundColor: _passed.contains(index) ? QcColors.text : QcColors.bg0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => _openChallenge(currentLesson, index),
                              icon: Icon(_passed.contains(index) ? Icons.check_circle_outline : Icons.edit_note_rounded),
                              label: Text(_passed.contains(index) ? 'Desafio concluido' : 'Resolver desafio'),
                            ),
                          ),
                          if (!_passed.contains(index))
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'A proxima parte abre quando o seu codigo produzir o resultado esperado.',
                                style: TextStyle(color: QcColors.textMuted, height: 1.4),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _lessonNav(index, lessons.length),
            ],
          );
        },
      ),
    );
  }

  Widget _exampleCard(LessonModel lesson) {
    return Container(
      decoration: BoxDecoration(
        color: QcColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                const Text(
                  'Exemplo',
                  style: TextStyle(color: QcColors.text, fontWeight: FontWeight.w800),
                ),
                TextButton.icon(
                  onPressed: () {
                    qcPushDetail(
                      context,
                      TryItView(
                        languageKey: widget.course.key,
                        title: lesson.title,
                        initialCode: lesson.codeExample,
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, color: QcColors.bg0, size: 18),
                  label: const Text(
                    'Experimente voce mesmo',
                    style: TextStyle(color: QcColors.bg0, fontWeight: FontWeight.w800),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: QcColors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: QcColors.bg0,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              lesson.codeExample,
              style: const TextStyle(color: QcColors.green, fontFamily: 'monospace', height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lessonMenu({required bool closeOnTap}) {
    final index = _controller.selectedLessonIndex;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Tutorial',
            style: TextStyle(color: QcColors.cyan, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
        for (var lessonIndex = 0; lessonIndex < widget.course.lessons.length; lessonIndex++)
          ListTile(
            enabled: _canOpen(lessonIndex),
            selected: lessonIndex == index,
            selectedTileColor: QcColors.cyan.withValues(alpha: 0.12),
            leading: Icon(
              _passed.contains(lessonIndex)
                  ? Icons.check_circle_rounded
                  : _canOpen(lessonIndex)
                      ? Icons.circle_outlined
                      : Icons.lock_outline_rounded,
              color: _passed.contains(lessonIndex) ? QcColors.green : QcColors.textMuted,
              size: 18,
            ),
            title: Text(
              widget.course.lessons[lessonIndex].title,
              style: TextStyle(
                color: lessonIndex == index ? QcColors.cyan : QcColors.text,
                fontWeight: lessonIndex == index ? FontWeight.w800 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            onTap: _canOpen(lessonIndex)
                ? () {
                    _controller.selectLesson(lessonIndex);
                    if (closeOnTap) Navigator.pop(context);
                  }
                : null,
          ),
      ],
    );
  }

  Widget _lessonNav(int index, int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: QcColors.bg1,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: index > 0 ? _controller.previousLesson : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Anterior'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: QcColors.cyan,
                  foregroundColor: QcColors.bg0,
                ),
                onPressed: index < total - 1 && _passed.contains(index)
                    ? () => _controller.nextLesson(total)
                    : null,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Proximo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
