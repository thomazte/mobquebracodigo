import 'package:flutter_test/flutter_test.dart';
import 'package:mobquebracodigo/courses/try_it_runner.dart';

void main() {
  test('aceita codigo diferente com o mesmo resultado', () {
    const example = 'nome = "Maria"\nidade = 25\nprint("Nome:", nome, "| Idade:", idade)';
    const other = 'pessoa = "Maria"\nanos = 25\nprint("Nome:", pessoa, "| Idade:", anos)';
    final verdict = validateLessonCode(languageKey: 'python', code: other, exampleCode: example);
    expect(verdict.correct, isTrue);
  });

  test('recusa resultado diferente e codigo vazio', () {
    const example = 'print("Olá, mundo!")';
    final wrong = validateLessonCode(
      languageKey: 'python',
      code: 'print("outra coisa")',
      exampleCode: example,
    );
    expect(wrong.correct, isFalse);
    expect(wrong.output, 'outra coisa');

    final empty = validateLessonCode(languageKey: 'python', code: '   ', exampleCode: example);
    expect(empty.correct, isFalse);
  });

  test('python percorre os exemplos do tutorial', () {
    expect(
      runCourseCode('python', 'print("Olá, mundo!")\nprint("Bem-vindo ao curso de Python!")').output,
      'Olá, mundo!\nBem-vindo ao curso de Python!',
    );
    expect(
      runCourseCode('python', 'nome = "Maria"\nidade = 25\nprint("Nome:", nome, "| Idade:", idade)').output,
      'Nome: Maria | Idade: 25',
    );
    expect(
      runCourseCode(
        'python',
        'idade = 18\nif idade >= 18:\n    print("Maior de idade")\nelse:\n    print("Menor de idade")',
      ).output,
      'Maior de idade',
    );
    expect(
      runCourseCode('python', 'for i in range(1, 4):\n    print("Número", i)').output,
      'Número 1\nNúmero 2\nNúmero 3',
    );
  });

  test('javascript e typescript executam o exemplo', () {
    expect(
      runCourseCode('javascript', 'let idade = 18;\nif (idade >= 18) {\n  console.log("Maior de idade");\n} else {\n  console.log("Menor de idade");\n}').output,
      'Maior de idade',
    );
    expect(
      runCourseCode('typescript', 'let nome: string = "Carlos";\nlet idade: number = 30;\nconsole.log(nome, idade);').output,
      'Carlos 30',
    );
  });

  test('java, c++ e php imprimem a saida', () {
    expect(
      runCourseCode(
        'java',
        'public class Main {\n  public static void main(String[] args) {\n    String msg = "Aprendendo Java";\n    System.out.println(msg);\n  }\n}',
      ).output,
      'Aprendendo Java',
    );
    expect(
      runCourseCode(
        'cpp',
        '#include <iostream>\nusing namespace std;\nint main() {\n  cout << "Olá, C++!";\n  return 0;\n}',
      ).output,
      'Olá, C++!',
    );
    expect(runCourseCode('php', '<?php\necho "Olá, PHP!";\n?>').output, 'Olá, PHP!');
    expect(
      runCourseCode('php', '<?php\n\$nome = "Maria";\necho "Ola, " . \$nome;\n?>').output,
      'Ola, Maria',
    );
    expect(runCourseCode('python', 'texto = "Python"\nprint("Tamanho:", len(texto))').output, 'Tamanho: 6');
  });

  test('sql devolve a tabela e html monta a previa', () {
    final sql = runCourseCode('sql', 'SELECT * FROM usuarios WHERE ativo = 1;');
    expect(sql.output, contains('Ana'));
    expect(sql.output, isNot(contains('Bruno')));

    final html = runCourseCode(
      'html',
      '<h1>Olá, HTML!</h1>\n<p>Meu primeiro parágrafo.</p>',
    );
    expect(html.preview.map((piece) => piece.tag), ['h1', 'p']);
    expect(html.output, contains('Olá, HTML!'));
  });
}
