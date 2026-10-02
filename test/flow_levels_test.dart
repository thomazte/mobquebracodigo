import 'package:flutter_test/flutter_test.dart';
import 'package:mobquebracodigo/games/flow/flow_levels.dart';

void main() {
  test('Flow Free tem 100 fases validas, unicas e progressivas', () {
    expect(kFlowLevelCount, 100);

    final seen = <String>{};
    int? previousSize;
    int? previousFlows;
    for (var index = 0; index < kFlowLevelCount; index++) {
      final level = flowLevelAt(index);
      expect(level.size, inInclusiveRange(5, 10));
      expect(level.paths, isNotEmpty);
      if (previousSize != null) {
        expect(level.size, greaterThanOrEqualTo(previousSize));
      }
      if (previousFlows != null) {
        expect(level.paths.length, greaterThanOrEqualTo(previousFlows));
      }
      previousSize = level.size;
      previousFlows = level.paths.length;

      final covered = <FlowPoint>{};
      for (final path in level.paths) {
        expect(path.length, greaterThanOrEqualTo(2));
        for (var i = 0; i < path.length; i++) {
          expect(covered.add(path[i]), isTrue, reason: 'fase ${index + 1} repete celula');
          if (i > 0) {
            final distance =
                (path[i].$1 - path[i - 1].$1).abs() + (path[i].$2 - path[i - 1].$2).abs();
            expect(distance, 1, reason: 'fase ${index + 1} tem salto');
          }
        }
      }
      expect(covered.length, level.size * level.size);
      expect(seen.add(_geometry(level)), isTrue, reason: 'fase ${index + 1} repetida');
    }

    expect(flowLevelAt(0).size, 5);
    expect(flowLevelAt(0).paths.length, 3);
    expect(flowLevelAt(11).size, 5);
    expect(flowLevelAt(11).paths.length, 5);
    expect(flowLevelAt(12).size, 6);
    expect(flowLevelAt(99).size, 10);
    expect(flowLevelAt(99).paths.length, 10);
    expect(_bends(flowLevelAt(99)), greaterThan(_bends(flowLevelAt(0))));
  });
}

int _bends(FlowLevel level) {
  var total = 0;
  for (final path in level.paths) {
    for (var i = 1; i < path.length - 1; i++) {
      final previous = (path[i].$1 - path[i - 1].$1, path[i].$2 - path[i - 1].$2);
      final next = (path[i + 1].$1 - path[i].$1, path[i + 1].$2 - path[i].$2);
      if (previous != next) total++;
    }
  }
  return total;
}

String _geometry(FlowLevel level) {
  final parts = level.paths.map((path) {
    final forward = path.map((point) => '${point.$1},${point.$2}').join('-');
    final backward = path.reversed.map((point) => '${point.$1},${point.$2}').join('-');
    return forward.compareTo(backward) <= 0 ? forward : backward;
  }).toList()
    ..sort();
  return '${level.size}:${parts.join('|')}';
}
