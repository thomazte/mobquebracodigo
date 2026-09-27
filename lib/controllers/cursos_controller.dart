import 'package:flutter/foundation.dart';

import '../models/course_model.dart';

/// Controla busca e navegação entre lições de cursos.
class CursosController extends ChangeNotifier {
  String _query = '';
  int _selectedLessonIndex = 0;

  String get query => _query;
  int get selectedLessonIndex => _selectedLessonIndex;

  List<CourseModel> get filteredCourses {
    if (_query.trim().isEmpty) return kCourses;
    final q = _query.toLowerCase();
    return kCourses
        .where(
          (course) =>
              course.title.toLowerCase().contains(q) ||
              course.description.toLowerCase().contains(q),
        )
        .toList();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void selectLesson(int index) {
    _selectedLessonIndex = index;
    notifyListeners();
  }

  void previousLesson() {
    if (_selectedLessonIndex > 0) {
      _selectedLessonIndex--;
      notifyListeners();
    }
  }

  void nextLesson(int totalLessons) {
    if (_selectedLessonIndex < totalLessons - 1) {
      _selectedLessonIndex++;
      notifyListeners();
    }
  }

  void resetLesson() {
    _selectedLessonIndex = 0;
  }
}
