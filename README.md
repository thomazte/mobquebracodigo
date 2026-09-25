# MobQuebraCodigo

Versao mobile do QuebraCodigo — app Flutter com jogos interativos, trilhas de programacao e autenticacao, consumindo o mesmo back-end Spring Boot da plataforma web.

## Estrutura do repositorio

```text
mobquebracodigo/
├── lib/
│   ├── config/           # URL da API (ApiConfig)
│   ├── controllers/      # logica de telas
│   ├── games/            # jogos nativos (2048, memoria, sudoku)
│   ├── models/
│   ├── services/         # HTTP, auth e sessao
│   ├── theme/
│   ├── views/            # login, cadastro, home, cursos, jogos, perfil
│   ├── widgets/
│   └── main.dart
├── assets/               # imagens, icones, cursos e jogos
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

2. O app sobe no emulador ou aparelho conectado e usa, por padrao, a API da VPS.

### API local (mesmo back-end do QuebraCodigo)

Se o Spring Boot estiver rodando na sua maquina (porta `8150`):

```bash
flutter run --dart-define=API_BASE_URL=http://SEU_IP_LOCAL:8150
```

No emulador Android, `localhost` do host costuma ser `10.0.2.2`:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8150
```

### Build de APK debug

```bash
flutter build apk --debug
```

O arquivo fica em `build/app/outputs/flutter-apk/app-debug.apk`.

## Pre-requisitos

- Flutter SDK (canal stable; projeto com Dart `^3.13.3`)
- Android Studio / SDK Android (emulador ou aparelho com USB debugging)
- Xcode (apenas se for rodar no iOS / macOS)

Para apontar a uma API local, tambem e necessario o back-end do QuebraCodigo (Spring Boot) em execucao — veja o repositorio web/back-end.

## Backend

O app mobile **nao embute** o servidor: ele consome a API REST do QuebraCodigo.

- URL padrao (VPS): definida em `lib/config/api_config.dart`
- Override em tempo de execucao: `--dart-define=API_BASE_URL=...`

Funcionalidades cobertas no app:

- login e cadastro
- home e navegacao
- listagem de cursos e jogos
- jogos nativos (2048, memoria, sudoku)
- perfil do usuario

## Relacao com o QuebraCodigo web

Este repositorio e a **versao mobile** da plataforma. O modulo principal (Spring Boot, Docker, banco e docs detalhados) permanece no repositorio QuebraCodigo.

## Documentacao Flutter

- [Documentacao oficial](https://docs.flutter.dev/)
- [Codelab — primeiro app](https://docs.flutter.dev/get-started/codelab)
