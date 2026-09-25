import 'package:flutter/material.dart';

class LessonModel {
  final String title;
  final String content;
  final String codeExample;
  final String outputExample;

  const LessonModel({
    required this.title,
    required this.content,
    required this.codeExample,
    required this.outputExample,
  });
}

class CourseModel {
  final String key;
  final String title;
  final String description;
  final String assetPath;
  final Color accentColor;
  final List<LessonModel> lessons;

  const CourseModel({
    required this.key,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.accentColor,
    required this.lessons,
  });
}

final List<CourseModel> kCourses = [
  CourseModel(
    key: 'python',
    title: 'Curso de Python',
    description: 'Aprenda Python do zero, passo a passo com sintaxe limpa e poderosa.',
    assetPath: 'assets/cursos/PYTHON.png',
    accentColor: const Color(0xFFFFE873),
    lessons: [
      LessonModel(
        title: '1. Introdução ao Python',
        content:
            'Python é uma linguagem de alto nível, interpretada e de propósito geral. Muito usada em IA, automação e desenvolvimento web.',
        codeExample: 'print("Olá, mundo!")\nprint("Bem-vindo ao curso de Python!")',
        outputExample: 'Olá, mundo!\nBem-vindo ao curso de Python!',
      ),
      LessonModel(
        title: '2. Variáveis e Tipos',
        content:
            'Em Python, variáveis são criadas no momento em que você atribui um valor a elas. Não é preciso declarar tipos explicitamente.',
        codeExample: 'nome = "Maria"\nidade = 25\nprint("Nome:", nome, "| Idade:", idade)',
        outputExample: 'Nome: Maria | Idade: 25',
      ),
      LessonModel(
        title: '3. Condicionais (if/else)',
        content: 'Use estruturas condicionais para tomar decisões no código com base em comparações.',
        codeExample:
            'idade = 18\nif idade >= 18:\n    print("Maior de idade")\nelse:\n    print("Menor de idade")',
        outputExample: 'Maior de idade',
      ),
      LessonModel(
        title: '4. Loops (for)',
        content:
            'O comando for em Python é usado para iterar sobre uma sequência (como uma lista ou intervalo).',
        codeExample: 'for i in range(1, 4):\n    print("Número", i)',
        outputExample: 'Número 1\nNúmero 2\nNúmero 3',
      ),
    ],
  ),
  CourseModel(
    key: 'javascript',
    title: 'Curso de JavaScript',
    description: 'A linguagem da web. Crie aplicações interativas e dinâmicas.',
    assetPath: 'assets/cursos/JAVASCRIPT.png',
    accentColor: const Color(0xFFF7DF1E),
    lessons: [
      LessonModel(
        title: '1. Introdução ao JS',
        content: 'JavaScript é a linguagem padrão para criar comportamento interativo nas páginas web.',
        codeExample:
            'console.log("Olá, mundo!");\nconsole.log("Bem-vindo ao curso de JavaScript!");',
        outputExample: 'Olá, mundo!\nBem-vindo ao curso de JavaScript!',
      ),
      LessonModel(
        title: '2. Variáveis (let, const)',
        content: 'Use let para variáveis reatribuíveis e const para constantes em JavaScript.',
        codeExample:
            'let nome = "Maria";\nlet idade = 25;\nconsole.log("Nome:", nome, "| Idade:", idade);',
        outputExample: 'Nome: Maria | Idade: 25',
      ),
      LessonModel(
        title: '3. Condicionais',
        content: 'Estruturas if/else permitem executar diferentes blocos de código conforme condições.',
        codeExample:
            'let idade = 18;\nif (idade >= 18) {\n  console.log("Maior de idade");\n} else {\n  console.log("Menor de idade");\n}',
        outputExample: 'Maior de idade',
      ),
    ],
  ),
  CourseModel(
    key: 'typescript',
    title: 'Curso de TypeScript',
    description: 'JavaScript com tipagem estática para projetos robustos.',
    assetPath: 'assets/cursos/TYPESCRIPT.png',
    accentColor: const Color(0xFF3178C6),
    lessons: [
      LessonModel(
        title: '1. Introdução ao TypeScript',
        content:
            'TypeScript adiciona tipos estáticos ao JavaScript, ajudando a pegar erros antes da execução.',
        codeExample: 'console.log("Olá, TypeScript!");',
        outputExample: 'Olá, TypeScript!',
      ),
      LessonModel(
        title: '2. Tipagem Básica',
        content: 'Defina tipos explicitamente para variáveis, parâmetros e retornos de funções.',
        codeExample: 'let nome: string = "Carlos";\nlet idade: number = 30;\nconsole.log(nome, idade);',
        outputExample: 'Carlos 30',
      ),
    ],
  ),
  CourseModel(
    key: 'java',
    title: 'Curso de Java',
    description: 'Linguagem orientada a objetos robusta, usada em enterprise e Android.',
    assetPath: 'assets/cursos/JAVA.png',
    accentColor: const Color(0xFFF89820),
    lessons: [
      LessonModel(
        title: '1. Introdução ao Java',
        content:
            'Java é amplamente utilizada para aplicações corporativas, servidores e desenvolvimento mobile Android.',
        codeExample:
            'public class Main {\n  public static void main(String[] args) {\n    System.out.println("Olá, Java!");\n  }\n}',
        outputExample: 'Olá, Java!',
      ),
      LessonModel(
        title: '2. Variáveis e Tipos',
        content:
            'Em Java, cada variável deve ter um tipo declarado explicitamente (int, String, boolean, etc.).',
        codeExample:
            'public class Main {\n  public static void main(String[] args) {\n    String msg = "Aprendendo Java";\n    System.out.println(msg);\n  }\n}',
        outputExample: 'Aprendendo Java',
      ),
    ],
  ),
  CourseModel(
    key: 'cpp',
    title: 'Curso de C++',
    description: 'Desempenho máximo para jogos, sistemas e algoritmos avançados.',
    assetPath: 'assets/cursos/C++.png',
    accentColor: const Color(0xFF00599C),
    lessons: [
      LessonModel(
        title: '1. Introdução ao C++',
        content:
            'C++ é uma extensão da linguagem C com suporte a orientação a objetos, famosa por alta performance.',
        codeExample:
            '#include <iostream>\nusing namespace std;\nint main() {\n  cout << "Olá, C++!";\n  return 0;\n}',
        outputExample: 'Olá, C++!',
      ),
    ],
  ),
  CourseModel(
    key: 'html',
    title: 'Curso de HTML',
    description: 'A estrutura fundamental de qualquer página web moderna.',
    assetPath: 'assets/cursos/HTML.png',
    accentColor: const Color(0xFFE34F26),
    lessons: [
      LessonModel(
        title: '1. Estrutura HTML',
        content: 'HTML (HyperText Markup Language) usa tags para estruturar conteúdo em páginas web.',
        codeExample:
            '<!DOCTYPE html>\n<html>\n<body>\n  <h1>Olá, HTML!</h1>\n  <p>Meu primeiro parágrafo.</p>\n</body>\n</html>',
        outputExample: 'Renderiza título e parágrafo na web.',
      ),
    ],
  ),
  CourseModel(
    key: 'php',
    title: 'Curso de PHP',
    description: 'Linguagem de script voltada para o desenvolvimento web backend.',
    assetPath: 'assets/cursos/PHP.png',
    accentColor: const Color(0xFF777BB4),
    lessons: [
      LessonModel(
        title: '1. Introdução ao PHP',
        content: 'PHP é amplamente utilizado no desenvolvimento web server-side.',
        codeExample: '<?php\necho "Olá, PHP!";\n?>',
        outputExample: 'Olá, PHP!',
      ),
    ],
  ),
  CourseModel(
    key: 'sql',
    title: 'Curso de SQL',
    description: 'Gerencie e consulte bancos de dados relacionais com eficiência.',
    assetPath: 'assets/cursos/SQL.png',
    accentColor: const Color(0xFF00758F),
    lessons: [
      LessonModel(
        title: '1. Introdução ao SQL',
        content: 'SQL é a linguagem padrão para interagir com bancos de dados relacionais.',
        codeExample: 'SELECT * FROM usuarios WHERE ativo = 1;',
        outputExample: 'Retorna registros de usuários ativos.',
      ),
    ],
  ),
];
