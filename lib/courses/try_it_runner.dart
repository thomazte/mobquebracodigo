class HtmlPiece {
  final String tag;
  final String text;

  const HtmlPiece(this.tag, this.text);
}

class RunResult {
  final bool ok;
  final String output;
  final List<HtmlPiece> preview;

  const RunResult.ok(this.output, {this.preview = const []}) : ok = true;

  const RunResult.fail(this.output)
      : ok = false,
        preview = const [];
}

class LessonVerdict {
  final bool correct;
  final String message;
  final String output;
  final String expected;

  const LessonVerdict({
    required this.correct,
    required this.message,
    required this.output,
    required this.expected,
  });
}

LessonVerdict validateLessonCode({
  required String languageKey,
  required String code,
  required String exampleCode,
}) {
  final expected = runCourseCode(languageKey, exampleCode);
  if (!expected.ok) {
    return LessonVerdict(
      correct: false,
      message: 'Nao foi possivel preparar o resultado desta aula.',
      output: '',
      expected: expected.output,
    );
  }
  if (code.trim().isEmpty) {
    return LessonVerdict(
      correct: false,
      message: 'Escreva um codigo antes de validar.',
      output: '',
      expected: expected.output,
    );
  }
  final attempt = runCourseCode(languageKey, code);
  if (!attempt.ok) {
    return LessonVerdict(
      correct: false,
      message: attempt.output,
      output: '',
      expected: expected.output,
    );
  }
  if (_sameOutput(attempt.output, expected.output)) {
    return LessonVerdict(
      correct: true,
      message: 'Codigo correto. O resultado confere e voce pode seguir.',
      output: attempt.output,
      expected: expected.output,
    );
  }
  return LessonVerdict(
    correct: false,
    message: 'O codigo rodou, mas o resultado ainda nao e o esperado.',
    output: attempt.output,
    expected: expected.output,
  );
}

bool _sameOutput(String left, String right) {
  String normalize(String value) => value
      .replaceAll('\r\n', '\n')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join('\n');
  return normalize(left) == normalize(right);
}

RunResult runCourseCode(String languageKey, String code) {
  try {
    switch (languageKey) {
      case 'python':
        return RunResult.ok(_runPython(code));
      case 'javascript':
        return RunResult.ok(_runJavaScript(code, typed: false));
      case 'typescript':
        return RunResult.ok(_runJavaScript(code, typed: true));
      case 'java':
        return RunResult.ok(_runJava(code));
      case 'cpp':
        return RunResult.ok(_runCpp(code));
      case 'php':
        return RunResult.ok(_runPhp(code));
      case 'sql':
        return RunResult.ok(_runSql(code));
      case 'html':
        final preview = _parseHtml(code);
        if (preview.isEmpty) {
          return const RunResult.fail('Nenhuma tag reconhecida. Use h1, p, a ou li.');
        }
        return RunResult.ok(
          preview.map((piece) => piece.text).join('\n'),
          preview: preview,
        );
      default:
        return const RunResult.fail('Essa linguagem ainda nao tem executor.');
    }
  } on FormatException catch (error) {
    return RunResult.fail(error.message);
  }
}

String _runPython(String code) {
  final lines = code.replaceAll('\r\n', '\n').split('\n');
  final env = <String, Object>{};
  final out = StringBuffer();
  _pyBlock(lines, 0, lines.length, 0, env, out);
  return _finish(out, 'Nada para executar. Use print(...).');
}

int _pyBlock(
  List<String> lines,
  int start,
  int end,
  int indent,
  Map<String, Object> env,
  StringBuffer out,
) {
  var index = start;
  while (index < end) {
    final raw = lines[index];
    if (raw.trim().isEmpty || raw.trimLeft().startsWith('#')) {
      index++;
      continue;
    }
    final current = _indentOf(raw);
    if (current < indent) return index;
    if (current > indent) {
      throw FormatException('Indentacao invalida perto de: ${raw.trim()}');
    }
    final line = raw.trim();
    if (line.startsWith('for ') && line.endsWith(':')) {
      index = _pyFor(lines, index, end, indent, env, out);
      continue;
    }
    if (line.startsWith('if ') && line.endsWith(':')) {
      index = _pyIf(lines, index, end, indent, env, out);
      continue;
    }
    if (line == 'else:' || line.startsWith('elif ')) return index;
    if (line.startsWith('print(') && line.endsWith(')')) {
      final inner = line.substring(6, line.length - 1);
      final values = _splitArgs(inner).map((part) => _eval(part, env));
      out.writeln(values.map((value) => '$value').join(' '));
      index++;
      continue;
    }
    final eq = _assignIndex(line);
    if (eq > 0) {
      env[line.substring(0, eq).trim()] = _eval(line.substring(eq + 1), env);
      index++;
      continue;
    }
    throw FormatException('Comando nao suportado: $line');
  }
  return index;
}

int _pyFor(
  List<String> lines,
  int index,
  int end,
  int indent,
  Map<String, Object> env,
  StringBuffer out,
) {
  final line = lines[index].trim();
  final match = RegExp(r'^for\s+(\w+)\s+in\s+range\(([^)]+)\):$').firstMatch(line);
  if (match == null) {
    throw const FormatException('Use for variavel in range(inicio, fim):');
  }
  final name = match.group(1)!;
  final args = match.group(2)!.split(',').map((part) => _eval(part, env)).toList();
  final startN = args.length == 1 ? 0 : args[0] as int;
  final endN = args.length == 1 ? args[0] as int : args[1] as int;
  final bodyStart = index + 1;
  final bodyEnd = _pyBodyEnd(lines, bodyStart, end, indent);
  final bodyIndent = _firstIndent(lines, bodyStart, bodyEnd);
  if (bodyIndent == null) throw const FormatException('O for precisa de um bloco indentado.');
  for (var value = startN; value < endN; value++) {
    env[name] = value;
    _pyBlock(lines, bodyStart, bodyEnd, bodyIndent, env, out);
  }
  return bodyEnd;
}

int _pyIf(
  List<String> lines,
  int index,
  int end,
  int indent,
  Map<String, Object> env,
  StringBuffer out,
) {
  final line = lines[index].trim();
  final condition = line.substring(3, line.length - 1).trim();
  final bodyStart = index + 1;
  final bodyEnd = _pyBodyEnd(lines, bodyStart, end, indent);
  var after = bodyEnd;
  int? elseStart;
  var elseEnd = bodyEnd;
  if (bodyEnd < end &&
      lines[bodyEnd].trim() == 'else:' &&
      _indentOf(lines[bodyEnd]) == indent) {
    elseStart = bodyEnd + 1;
    elseEnd = _pyBodyEnd(lines, elseStart, end, indent);
    after = elseEnd;
  }
  if (_evalCond(condition, env)) {
    final bodyIndent = _firstIndent(lines, bodyStart, bodyEnd);
    if (bodyIndent != null) _pyBlock(lines, bodyStart, bodyEnd, bodyIndent, env, out);
  } else if (elseStart != null) {
    final elseIndent = _firstIndent(lines, elseStart, elseEnd);
    if (elseIndent != null) _pyBlock(lines, elseStart, elseEnd, elseIndent, env, out);
  }
  return after;
}

int _pyBodyEnd(List<String> lines, int start, int end, int indent) {
  var cursor = start;
  while (cursor < end) {
    final raw = lines[cursor];
    if (raw.trim().isEmpty || raw.trimLeft().startsWith('#')) {
      cursor++;
      continue;
    }
    if (_indentOf(raw) <= indent) break;
    cursor++;
  }
  return cursor;
}

int? _firstIndent(List<String> lines, int start, int end) {
  for (var index = start; index < end; index++) {
    final raw = lines[index];
    if (raw.trim().isEmpty || raw.trimLeft().startsWith('#')) continue;
    return _indentOf(raw);
  }
  return null;
}

int _indentOf(String line) => line.length - line.trimLeft().length;

String _runJavaScript(String code, {required bool typed}) {
  var source = _stripLineComments(code);
  if (typed) {
    source = source.replaceAll(RegExp(r':\s*(string|number|boolean|any)\b'), '');
  }
  source = source.replaceAll(RegExp(r'\b(let|const|var)\s+'), '');
  final env = <String, Object>{};
  final out = StringBuffer();
  _runBrace(source, env, out);
  return _finish(out, 'Nada para executar. Use console.log(...).');
}

String _runJava(String code) {
  final body = _blockAfter(code, 'main');
  final source = body
      .replaceAll('System.out.println', 'console.log')
      .replaceAll(RegExp(r'\b(String|int|double|boolean)\s+'), '');
  final env = <String, Object>{};
  final out = StringBuffer();
  _runBrace(source, env, out);
  return _finish(out, 'Nada para executar. Use System.out.println(...).');
}

void _runBrace(String code, Map<String, Object> env, StringBuffer out) {
  var index = 0;

  void skipSpace() {
    while (index < code.length && _isSpace(code[index])) {
      index++;
    }
  }

  while (true) {
    skipSpace();
    if (index >= code.length) return;
    if (code.startsWith('if', index) && _isBoundary(code, index + 2)) {
      index += 2;
      skipSpace();
      if (index >= code.length || code[index] != '(') {
        throw const FormatException('O if precisa de uma condicao entre parenteses.');
      }
      final close = _match(code, index, '(', ')');
      final condition = code.substring(index + 1, close);
      index = close + 1;
      skipSpace();
      if (index >= code.length || code[index] != '{') {
        throw const FormatException('O if precisa de um bloco entre chaves.');
      }
      final endIf = _match(code, index, '{', '}');
      final whenTrue = code.substring(index + 1, endIf);
      index = endIf + 1;
      skipSpace();
      String? whenFalse;
      if (code.startsWith('else', index) && _isBoundary(code, index + 4)) {
        index += 4;
        skipSpace();
        if (index >= code.length || code[index] != '{') {
          throw const FormatException('O else precisa de um bloco entre chaves.');
        }
        final endElse = _match(code, index, '{', '}');
        whenFalse = code.substring(index + 1, endElse);
        index = endElse + 1;
      }
      if (_evalCond(condition, env)) {
        _runBrace(whenTrue, env, out);
      } else if (whenFalse != null) {
        _runBrace(whenFalse, env, out);
      }
      continue;
    }
    if (code.startsWith('console.log', index)) {
      index += 'console.log'.length;
      skipSpace();
      if (index >= code.length || code[index] != '(') {
        throw const FormatException('Use console.log(...).');
      }
      final close = _match(code, index, '(', ')');
      final values = _splitArgs(code.substring(index + 1, close)).map((part) => _eval(part, env));
      out.writeln(values.map((value) => '$value').join(' '));
      index = close + 1;
      skipSpace();
      if (index < code.length && code[index] == ';') index++;
      continue;
    }
    final semi = _statementEnd(code, index);
    final statement = code.substring(index, semi).trim();
    index = semi + 1;
    if (statement.isEmpty || statement == '{' || statement == '}') continue;
    final eq = _assignIndex(statement);
    if (eq > 0) {
      env[statement.substring(0, eq).trim()] = _eval(statement.substring(eq + 1), env);
      continue;
    }
    throw FormatException('Comando nao suportado: $statement');
  }
}

String _runCpp(String code) {
  final env = <String, Object>{};
  final out = StringBuffer();
  for (final raw in code.replaceAll('\r\n', '\n').split('\n')) {
    var line = raw.trim();
    if (line.isEmpty ||
        line.startsWith('#') ||
        line.startsWith('using ') ||
        line.startsWith('int main') ||
        line == '{' ||
        line == '}' ||
        line.startsWith('return')) {
      continue;
    }
    if (line.endsWith(';')) line = line.substring(0, line.length - 1).trim();
    if (line.startsWith('cout')) {
      final pieces = line
          .substring(4)
          .split('<<')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty && part != 'endl');
      out.writeln(pieces.map((part) => '${_eval(part, env)}').join());
      continue;
    }
    line = line.replaceAll(RegExp(r'^(int|double|bool|string)\s+'), '');
    final eq = _assignIndex(line);
    if (eq > 0) {
      env[line.substring(0, eq).trim()] = _eval(line.substring(eq + 1), env);
      continue;
    }
    throw FormatException('Comando nao suportado: $line');
  }
  return _finish(out, 'Nada para executar. Use cout << ...;');
}

String _runPhp(String code) {
  final env = <String, Object>{};
  final out = StringBuffer();
  final source = code.replaceAll(RegExp(r'<\?(php)?|\?>'), '');
  for (final raw in source.replaceAll('\r\n', '\n').split('\n')) {
    var line = raw.trim();
    if (line.isEmpty || line.startsWith('//') || line.startsWith('#')) continue;
    if (line.endsWith(';')) line = line.substring(0, line.length - 1).trim();
    if (line.startsWith('echo ')) {
      final values = _splitArgs(line.substring(5)).map((part) => _eval(part, env, concat: '.'));
      out.writeln(values.map((value) => '$value').join());
      continue;
    }
    final eq = _assignIndex(line);
    if (eq > 0) {
      env[line.substring(0, eq).trim()] = _eval(line.substring(eq + 1), env, concat: '.');
      continue;
    }
    throw FormatException('Comando nao suportado: $line');
  }
  return _finish(out, 'Nada para executar. Use echo ...;');
}

String _runSql(String code) {
  final rows = <Map<String, String>>[
    {'id': '1', 'nome': 'Ana', 'ativo': '1'},
    {'id': '2', 'nome': 'Bruno', 'ativo': '0'},
    {'id': '3', 'nome': 'Clara', 'ativo': '1'},
  ];
  final out = StringBuffer();
  for (final statement in code.split(';')) {
    final sql = statement.trim();
    if (sql.isEmpty) continue;
    if (out.isNotEmpty) out.writeln();
    out.write(_oneSql(sql, rows));
  }
  if (out.isEmpty) throw const FormatException('Escreva um SELECT ou INSERT.');
  return out.toString();
}

String _oneSql(String sql, List<Map<String, String>> rows) {
  final compact = sql.replaceAll(RegExp(r'\s+'), ' ').trim();
  final lower = compact.toLowerCase();
  if (lower.startsWith('select')) {
    final match = RegExp(
      r'^select\s+(.+)\s+from\s+usuarios(?:\s+where\s+(\w+)\s*=\s*(\d+))?(?:\s+order\s+by\s+(\w+))?$',
      caseSensitive: false,
    ).firstMatch(compact);
    if (match == null) {
      throw const FormatException('Consulta nao suportada. Use SELECT em usuarios.');
    }
    var result = [...rows];
    final whereColumn = match.group(2)?.toLowerCase();
    final whereValue = match.group(3);
    if (whereColumn != null && whereValue != null) {
      result = result.where((row) => row[whereColumn] == whereValue).toList();
    }
    final orderColumn = match.group(4)?.toLowerCase();
    if (orderColumn != null) {
      result.sort((a, b) => (a[orderColumn] ?? '').compareTo(b[orderColumn] ?? ''));
    }
    final selected = match.group(1)!.trim();
    final columns = selected == '*'
        ? ['id', 'nome', 'ativo']
        : selected.split(',').map((column) => column.trim().toLowerCase()).toList();
    final lines = <String>[columns.join(' | ')];
    if (result.isEmpty) {
      lines.add('(nenhuma linha)');
    } else {
      for (final row in result) {
        lines.add(columns.map((column) => row[column] ?? '').join(' | '));
      }
    }
    return lines.join('\n');
  }
  if (lower.startsWith('insert')) {
    final match = RegExp(
      r'^insert\s+into\s+usuarios\s*\(([^)]+)\)\s*values\s*\(([^)]+)\)$',
      caseSensitive: false,
    ).firstMatch(compact);
    if (match == null) throw const FormatException('INSERT nao suportado.');
    final columns = match.group(1)!.split(',').map((column) => column.trim().toLowerCase()).toList();
    final values = _splitArgs(match.group(2)!).map(_sqlLiteral).toList();
    if (columns.length != values.length) {
      throw const FormatException('Colunas e valores do INSERT nao batem.');
    }
    final row = {'id': '', 'nome': '', 'ativo': ''};
    for (var index = 0; index < columns.length; index++) {
      row[columns[index]] = values[index];
    }
    rows.add(row);
    return '1 linha inserida.';
  }
  throw const FormatException('Use SELECT ou INSERT.');
}

String _sqlLiteral(String token) {
  final value = token.trim();
  if ((value.startsWith("'") && value.endsWith("'")) ||
      (value.startsWith('"') && value.endsWith('"'))) {
    return value.substring(1, value.length - 1);
  }
  return value;
}

List<HtmlPiece> _parseHtml(String code) {
  final source = code
      .replaceAll(RegExp(r'<!DOCTYPE[^>]*>', caseSensitive: false), '')
      .replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
  final pattern = RegExp(r'<(/?)([a-zA-Z0-9]+)([^>]*)>|([^<]+)');
  final pieces = <HtmlPiece>[];
  final stack = <String>[];
  final buffers = <StringBuffer>[StringBuffer()];
  for (final match in pattern.allMatches(source)) {
    final text = match.group(4);
    if (text != null) {
      buffers.last.write(text);
      continue;
    }
    final closing = match.group(1)!.isNotEmpty;
    final tag = match.group(2)!.toLowerCase();
    if (!closing) {
      stack.add(tag);
      buffers.add(StringBuffer());
      continue;
    }
    if (buffers.length <= 1) continue;
    final inner = buffers.removeLast().toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (stack.isNotEmpty && stack.last == tag) stack.removeLast();
    const visible = {'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'a', 'li'};
    if (visible.contains(tag) && inner.isNotEmpty) {
      pieces.add(HtmlPiece(tag, inner));
    }
    if (inner.isNotEmpty) buffers.last.write(inner);
  }
  return pieces;
}

String _blockAfter(String code, String keyword) {
  final at = code.indexOf(keyword);
  if (at < 0) return code;
  final open = code.indexOf('{', at);
  if (open < 0) return code;
  final close = _match(code, open, '{', '}');
  return code.substring(open + 1, close);
}

bool _evalCond(String condition, Map<String, Object> env) {
  var text = condition.trim();
  if (text.startsWith('(') && text.endsWith(')')) {
    text = text.substring(1, text.length - 1).trim();
  }
  for (final op in ['>=', '<=', '==', '!=', '>', '<']) {
    final index = text.indexOf(op);
    if (index <= 0) continue;
    final left = _eval(text.substring(0, index), env);
    final right = _eval(text.substring(index + op.length), env);
    if (left is int && right is int) {
      switch (op) {
        case '>=':
          return left >= right;
        case '<=':
          return left <= right;
        case '==':
          return left == right;
        case '!=':
          return left != right;
        case '>':
          return left > right;
        case '<':
          return left < right;
      }
    }
    final comparison = '$left'.compareTo('$right');
    switch (op) {
      case '>=':
        return comparison >= 0;
      case '<=':
        return comparison <= 0;
      case '==':
        return comparison == 0;
      case '!=':
        return comparison != 0;
      case '>':
        return comparison > 0;
      case '<':
        return comparison < 0;
    }
  }
  final value = _eval(text, env);
  if (value is int) return value != 0;
  return '$value'.isNotEmpty;
}

Object _eval(String expression, Map<String, Object> env, {String? concat}) {
  final text = expression.trim();
  if (text.isEmpty) throw const FormatException('Expressao vazia.');
  if (concat != null) {
    final parts = _splitTop(text, concat);
    if (parts.length > 1) {
      return parts.map((part) => '${_eval(part, env, concat: concat)}').join();
    }
  }
  final summed = _splitTop(text, '+');
  if (summed.length > 1) {
    final values = summed.map((part) => _eval(part, env, concat: concat)).toList();
    if (values.every((value) => value is int)) {
      return values.fold<int>(0, (sum, value) => sum + (value as int));
    }
    return values.map((value) => '$value').join();
  }
  if (text.startsWith('len(') && text.endsWith(')')) {
    return '${_eval(text.substring(4, text.length - 1), env, concat: concat)}'.length;
  }
  if ((text.startsWith('"') && text.endsWith('"')) || (text.startsWith("'") && text.endsWith("'"))) {
    return text.substring(1, text.length - 1);
  }
  if (RegExp(r'^-?\d+$').hasMatch(text)) return int.parse(text);
  if (env.containsKey(text)) return env[text]!;
  throw FormatException('Nao entendi: $text');
}

int _assignIndex(String line) {
  var quote = '';
  for (var index = 0; index < line.length; index++) {
    final char = line[index];
    if (quote.isNotEmpty) {
      if (char == quote) quote = '';
      continue;
    }
    if (char == '"' || char == "'") {
      quote = char;
      continue;
    }
    final previous = index > 0 ? line[index - 1] : '';
    final next = index + 1 < line.length ? line[index + 1] : '';
    if (char == '=' && !'!<>='.contains(previous) && next != '=') return index;
  }
  return -1;
}

List<String> _splitArgs(String input) => _splitTop(input, ',');

List<String> _splitTop(String input, String separator) {
  final parts = <String>[];
  final buffer = StringBuffer();
  var quote = '';
  var depth = 0;
  for (var index = 0; index < input.length; index++) {
    final char = input[index];
    if (quote.isNotEmpty) {
      buffer.write(char);
      if (char == quote) quote = '';
      continue;
    }
    if (char == '"' || char == "'") {
      quote = char;
      buffer.write(char);
      continue;
    }
    if (char == '(') depth++;
    if (char == ')') depth--;
    if (depth == 0 && input.startsWith(separator, index)) {
      parts.add(buffer.toString().trim());
      buffer.clear();
      index += separator.length - 1;
      continue;
    }
    buffer.write(char);
  }
  final tail = buffer.toString().trim();
  if (tail.isNotEmpty) parts.add(tail);
  return parts.where((part) => part.isNotEmpty).toList();
}

int _match(String code, int open, String start, String end) {
  var depth = 0;
  var quote = '';
  for (var index = open; index < code.length; index++) {
    final char = code[index];
    if (quote.isNotEmpty) {
      if (char == quote) quote = '';
      continue;
    }
    if (char == '"' || char == "'") {
      quote = char;
      continue;
    }
    if (char == start) depth++;
    if (char == end) {
      depth--;
      if (depth == 0) return index;
    }
  }
  throw FormatException('Faltou fechar $start');
}

int _statementEnd(String code, int start) {
  var quote = '';
  var depth = 0;
  for (var index = start; index < code.length; index++) {
    final char = code[index];
    if (quote.isNotEmpty) {
      if (char == quote) quote = '';
      continue;
    }
    if (char == '"' || char == "'") {
      quote = char;
      continue;
    }
    if (char == '(') depth++;
    if (char == ')') depth--;
    if (char == ';' && depth == 0) return index;
  }
  return code.length;
}

String _stripLineComments(String code) {
  return code
      .replaceAll('\r\n', '\n')
      .split('\n')
      .where((line) => !line.trimLeft().startsWith('//'))
      .join('\n');
}

String _finish(StringBuffer out, String emptyMessage) {
  final text = out.toString().trimRight();
  if (text.isEmpty) throw FormatException(emptyMessage);
  return text;
}

bool _isSpace(String char) => char == ' ' || char == '\n' || char == '\r' || char == '\t';

bool _isBoundary(String code, int index) => index >= code.length || !_isName(code[index]);

bool _isName(String char) {
  final value = char.codeUnitAt(0);
  return (value >= 48 && value <= 57) || (value >= 65 && value <= 90) || (value >= 97 && value <= 122) || char == '_';
}
