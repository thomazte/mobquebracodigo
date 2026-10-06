# Ícone do app

O ícone é o cubo do QuebraCódigo centralizado sobre o mesmo degradê azul → roxo da capa do projeto no portfólio (`#0A0F2C` → `#5C2D91`, de cima para baixo).

## Origem

`scripts/source/cube-1024.png` é o mesmo cubo de `assets/home_cube.png`, em 1024 px, copiado do front-end web (`app/frontend/public/img/home/logoQuebraCodigo.png`). Fica fora de `assets/` para não entrar no pacote do app.

## Gerar de novo

Da raiz do projeto, com o Pillow instalado:

```bash
python3 scripts/build-app-icon.py
```

O script sobrescreve:

- Android: `ic_launcher.png` em cada `mipmap-*` e o ícone adaptativo (`mipmap-anydpi-v26/ic_launcher.xml`, com `ic_launcher_foreground.png` e `ic_launcher_background.png`). No adaptativo o cubo ocupa metade da camada para caber na área segura de qualquer formato de máscara.
- iOS: todos os tamanhos listados em `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`, sem transparência.
- Web: `web/icons/Icon-*.png`, as versões `maskable` com mais margem, e `web/favicon.png`.

Para o aparelho mostrar o ícone novo, reinstale o app (`flutter run` ou o APK novo). Alguns launchers guardam o ícone antigo em cache até o app ser desinstalado.
