import 'package:flutter/material.dart';

import '../controllers/cursos_controller.dart';
import '../models/course_model.dart';
import '../theme/qc_theme.dart';
import '../widgets/qc_interactions.dart';

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

  @override
  void initState() {
    super.initState();
    _controller.resetLesson();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = _controller.selectedLessonIndex;
    final currentLesson = widget.course.lessons[index];

    return Scaffold(
      backgroundColor: QcColors.bg0,
      appBar: AppBar(
        title: Text(
          widget.course.title,
          style: const TextStyle(
            color: QcColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 900;
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: QcColors.bg1.withValues(alpha: 0.85),
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.course.lessons.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, lessonIndex) {
                      final isSelected = lessonIndex == index;
                      return _LessonChip(
                        label: _controller.lessonChipLabel(widget.course, lessonIndex),
                        selected: isSelected,
                        onTap: () => _controller.selectLesson(lessonIndex),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isCompact ? 14 : 20),
                  color: const Color(0xFF060818),
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: QcColors.panel,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Hero(
                            tag: 'course-${widget.course.key}',
                            child: Image.asset(
                              widget.course.assetPath,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(
                            begin: const Offset(0.03, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(position: offset, child: child),
                          );
                        },
                        child: Column(
                          key: ValueKey(index),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.course.title,
                              style: const TextStyle(
                                color: QcColors.cyan,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentLesson.title,
                              style: const TextStyle(
                                color: QcColors.text,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentLesson.content,
                              style: const TextStyle(
                                color: QcColors.textDim,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Exemplo de Código:',
                              style: TextStyle(
                                color: QcColors.cyan,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: QcColors.bg0,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(
                                currentLesson.codeExample,
                                style: const TextStyle(
                                  color: QcColors.green,
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Resultado / Saída:',
                              style: TextStyle(
                                color: QcColors.cyan,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: QcColors.bg1,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(
                                currentLesson.outputExample,
                                style: const TextStyle(
                                  color: QcColors.text,
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: QcColors.bg2,
                              foregroundColor: QcColors.text,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: index > 0 ? _controller.previousLesson : null,
                            icon: const Icon(Icons.arrow_left),
                            label: const Text('Anterior'),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: QcColors.violet,
                              foregroundColor: QcColors.text,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: index < widget.course.lessons.length - 1
                                ? () => _controller.nextLesson(widget.course.lessons.length)
                                : null,
                            icon: const Icon(Icons.arrow_right),
                            label: const Text('Próximo'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LessonChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LessonChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return QcPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? QcColors.cyan : QcColors.bg0,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? QcColors.cyan : Colors.white12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: QcColors.cyan.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            color: selected ? QcColors.bg0 : QcColors.textDim,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
