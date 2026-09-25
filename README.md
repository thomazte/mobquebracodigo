# MobQuebraCodigo

Versão mobile do QuebraCódigo — app Flutter com jogos interativos, trilhas de programação e autenticação, consumindo o mesmo back-end Spring Boot da plataforma web.

## Estrutura do repositório

```text
mobquebracodigo/
├── lib/
│   ├── config/            # URL da API (ApiConfig)
│   ├── controllers/       # lógica de telas
│   ├── games/             # jogos nativos (2048, memória, sudoku)
│   ├── models/
│   ├── services/          # HTTP, auth e sessão
│   ├── theme/
│   ├── views/             # login, cadastro, home, cursos, jogos, perfil
│   ├── widgets/
│   └── main.dart
├── assets/                # imagens, ícones, cursos e jogos
├── android/
├── ios/
├── web/
├── test/
├── pubspec.yaml
└── README.md
```

## Como executar

### Emulador / dispositivo (recomendado)

1. Na raiz do projeto:

```bash
flutter pub get
flutter run
```

2. O app sobe no emulador ou aparelho conectado e usa, por padrão, a API da VPS.

### API local (mesmo back-end do QuebraCódigo)

Se o Spring Boot estiver rodando na sua máquina (porta `8150`):

```bash
flutter run --dart-define=API_BASE_URL=http://SEU_IP_LOCAL:8150
```

No emulador Android, `localhost` do host costuma ser `10.0.2.2`:

```bash
flutter run --dart-define=API_BASE_URL=[http://10.0.2.2:8150](http://10.0.2.2:8150)
```

### Build de APK debug

```bash
flutter build apk --debug
```

O arquivo fica em `build/app/outputs/flutter-apk/app-debug.apk`.

## Pré-requisitos

- Flutter SDK (canal stable; projeto com Dart `^3.13.3`)
- Android Studio / SDK Android (emulador ou aparelho com USB debugging)
- Xcode (apenas se for rodar no iOS / macOS)

Para apontar a uma API local, também é necessário o back-end do QuebraCódigo (Spring Boot) em execução — veja o repositório web/back-end.

## Backend

O app mobile **não embute** o servidor: ele consome a API REST do QuebraCódigo.

- URL padrão (VPS): definida em `lib/config/api_config.dart`
- Override em tempo de execução: `--dart-define=API_BASE_URL=...`

Funcionalidades cobertas no app:

- login e cadastro
- home e navegação
- listagem de cursos e jogos
- jogos nativos (2048, memória, sudoku)
- perfil do usuário

## Relação com o QuebraCódigo web

Este repositório é a **versão mobile** da plataforma. O módulo principal (Spring Boot, Docker, banco e docs detalhados) permanece no repositório QuebraCódigo.

## Documentação Flutter

- [Documentação oficial](https://docs.flutter.dev/)
- [Codelab — primeiro app](https://docs.flutter.dev/get-started/codelab)
