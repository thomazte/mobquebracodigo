import 'dart:math' as math;

typedef FlowPoint = (int, int);

class FlowLevel {
  final int size;
  final List<List<FlowPoint>> paths;

  const FlowLevel(this.size, this.paths);
}

const int kFlowLevelCount = 100;

List<FlowLevel>? _cache;

FlowLevel flowLevelAt(int index) {
  final levels = _cache ??= _buildAll();
  return levels[index];
}

List<FlowLevel> _buildAll() {
  final levels = <FlowLevel>[];
  final seen = <String>{};
  for (var index = 0; index < kFlowLevelCount; index++) {
    var salt = 0;
    while (true) {
      final level = _buildLevel(index, salt);
      if (seen.add(_geometry(level))) {
        levels.add(level);
        break;
      }
      salt++;
      if (salt > 40) {
        throw StateError('Nao foi possivel gerar uma fase unica em ${index + 1}');
      }
    }
  }
  return levels;
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

class _Band {
  final int until;
  final int size;
  final int minFlows;
  final int maxFlows;
  final double minTwist;
  final double maxTwist;

  const _Band(
    this.until,
    this.size,
    this.minFlows,
    this.maxFlows,
    this.minTwist,
    this.maxTwist,
  );
}

const _bands = <_Band>[
  _Band(12, 5, 3, 5, 0.0, 0.22),
  _Band(26, 6, 5, 6, 0.25, 0.42),
  _Band(42, 7, 6, 7, 0.38, 0.58),
  _Band(60, 8, 7, 8, 0.52, 0.74),
  _Band(78, 9, 8, 9, 0.66, 0.88),
  _Band(100, 10, 9, 10, 0.8, 1.0),
];

class _Spec {
  final int size;
  final int flows;
  final double twist;

  const _Spec(this.size, this.flows, this.twist);
}

_Spec _specFor(int index) {
  var start = 0;
  for (final band in _bands) {
    if (index < band.until) {
      final span = band.until - start;
      final step = index - start;
      final denom = span <= 1 ? 1 : span - 1;
      final flows = band.minFlows + ((band.maxFlows - band.minFlows) * step) ~/ denom;
      final t = step / denom;
      final twist = band.minTwist + (band.maxTwist - band.minTwist) * t;
      return _Spec(band.size, flows, twist);
    }
    start = band.until;
  }
  throw RangeError.range(index, 0, kFlowLevelCount - 1, 'index');
}

FlowLevel _buildLevel(int index, int salt) {
  final spec = _specFor(index);
  final rng = math.Random(0xF10F + index * 9973 + salt * 104729);
  final path = _basePath(spec.size, spec.twist, rng);
  final mutations = (spec.twist * spec.size * 2).round();
  for (var i = 0; i < mutations; i++) {
    if (!_applyTwoOpt(path, rng)) break;
  }
  final paths = _split(path, spec.flows, spec.twist, rng);
  final level = FlowLevel(spec.size, paths);
  _validate(level);
  return level;
}

List<FlowPoint> _basePath(int size, double twist, math.Random rng) {
  if (twist < 0.12) {
    final path = _snake(size, rng.nextInt(8));
    if (rng.nextBool()) return path.reversed.toList();
    return path;
  }
  final variant = rng.nextInt(8);
  final turned = [for (final point in _spiral(size)) _map(point, size, variant)];
  if (rng.nextBool()) return turned.reversed.toList();
  return turned;
}

List<FlowPoint> _snake(int size, int variant) {
  final vertical = variant & 1 == 1;
  final flip = variant & 2 == 2;
  final reverseMinor = variant & 4 == 4;
  final path = <FlowPoint>[];
  for (var i = 0; i < size; i++) {
    final major = flip ? size - 1 - i : i;
    final reverse = major.isOdd != reverseMinor;
    for (var j = 0; j < size; j++) {
      final minor = reverse ? size - 1 - j : j;
      path.add(vertical ? (minor, major) : (major, minor));
    }
  }
  return path;
}

List<FlowPoint> _spiral(int size) {
  final path = <FlowPoint>[];
  var top = 0;
  var bottom = size - 1;
  var left = 0;
  var right = size - 1;
  while (top <= bottom && left <= right) {
    for (var col = left; col <= right; col++) {
      path.add((top, col));
    }
    top++;
    for (var row = top; row <= bottom; row++) {
      path.add((row, right));
    }
    right--;
    if (top <= bottom) {
      for (var col = right; col >= left; col--) {
        path.add((bottom, col));
      }
      bottom--;
    }
    if (left <= right) {
      for (var row = bottom; row >= top; row--) {
        path.add((row, left));
      }
      left++;
    }
  }
  return path;
}

FlowPoint _map(FlowPoint point, int size, int variant) {
  var row = point.$1;
  var col = point.$2;
  if (variant & 4 != 0) col = size - 1 - col;
  switch (variant & 3) {
    case 1:
      return (col, size - 1 - row);
    case 2:
      return (size - 1 - row, size - 1 - col);
    case 3:
      return (size - 1 - col, row);
    default:
      return (row, col);
  }
}

bool _adjacent(FlowPoint a, FlowPoint b) {
  return (a.$1 - b.$1).abs() + (a.$2 - b.$2).abs() == 1;
}

bool _applyTwoOpt(List<FlowPoint> path, math.Random rng) {
  final candidates = <(int, int)>[];
  final n = path.length;
  for (var i = 0; i < n - 3; i++) {
    for (var j = i + 2; j < n - 1; j++) {
      if (_adjacent(path[i], path[j]) && _adjacent(path[i + 1], path[j + 1])) {
        candidates.add((i, j));
      }
    }
  }
  if (candidates.isEmpty) return false;
  final (i, j) = candidates[rng.nextInt(candidates.length)];
  var lo = i + 1;
  var hi = j;
  while (lo < hi) {
    final tmp = path[lo];
    path[lo] = path[hi];
    path[hi] = tmp;
    lo++;
    hi--;
  }
  return true;
}

List<List<FlowPoint>> _split(List<FlowPoint> path, int flows, double twist, math.Random rng) {
  final cells = path.length;
  var minSeg = twist < 0.45 ? 4 : 3;
  while (flows * minSeg > cells) {
    minSeg--;
  }
  final lengths = List<int>.filled(flows, minSeg);
  var extra = cells - flows * minSeg;
  if (twist < 0.55) {
    final offset = rng.nextInt(flows);
    for (var i = 0; i < extra; i++) {
      lengths[(offset + i) % flows]++;
    }
  } else {
    while (extra > 0) {
      lengths[rng.nextInt(flows)]++;
      extra--;
    }
  }

  final paths = <List<FlowPoint>>[];
  var cursor = 0;
  for (final length in lengths) {
    paths.add(List<FlowPoint>.unmodifiable(path.sublist(cursor, cursor + length)));
    cursor += length;
  }
  paths.shuffle(rng);
  return List<List<FlowPoint>>.unmodifiable(paths);
}

void _validate(FlowLevel level) {
  final seen = <FlowPoint>{};
  for (final path in level.paths) {
    if (path.length < 2) {
      throw StateError('Trilha com menos de dois pontos na fase ${level.size}');
    }
    for (var i = 0; i < path.length; i++) {
      final point = path[i];
      if (point.$1 < 0 || point.$2 < 0 || point.$1 >= level.size || point.$2 >= level.size) {
        throw StateError('Ponto fora do tabuleiro');
      }
      if (!seen.add(point)) throw StateError('Celula repetida');
      if (i > 0 && !_adjacent(path[i - 1], point)) {
        throw StateError('Trilha com salto');
      }
    }
  }
  if (seen.length != level.size * level.size) {
    throw StateError('Tabuleiro incompleto');
  }
}
