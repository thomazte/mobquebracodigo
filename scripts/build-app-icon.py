"""Gera os ícones do app (Android, iOS e web) a partir de scripts/source/cube-1024.png.

O ícone é o cubo centralizado sobre o mesmo degradê da capa do projeto no
portfólio. Rodar da raiz do projeto: python3 scripts/build-app-icon.py
"""

import json
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
# Mesmo cubo de assets/home_cube.png, em 1024 px (vem do front-end web).
CUBE = ROOT / "scripts" / "source" / "cube-1024.png"

# Mesmas paradas do capaGradient do portfólio (180deg, de cima para baixo).
GRADIENT = [
    (0.00, "#0A0F2C"),
    (0.20, "#111A3A"),
    (0.45, "#1C2E6C"),
    (0.70, "#3A1F78"),
    (1.00, "#5C2D91"),
]

MASTER = 1024


def hex_rgb(value):
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


def gradient(size):
    stops = [(pos, hex_rgb(color)) for pos, color in GRADIENT]
    img = Image.new("RGB", (size, size))
    draw = ImageDraw.Draw(img)
    for y in range(size):
        t = y / (size - 1)
        for (p0, c0), (p1, c1) in zip(stops, stops[1:]):
            if p0 <= t <= p1:
                k = (t - p0) / (p1 - p0)
                color = tuple(round(a + (b - a) * k) for a, b in zip(c0, c1))
                break
        draw.line([(0, y), (size, y)], fill=color)
    return img


def cube_layer(size, scale):
    """Cubo centralizado, ocupando `scale` do lado, com fundo transparente."""
    cube = Image.open(CUBE).convert("RGBA")
    # Recorta pelo que é visível: a borda da imagem tem pixels quase transparentes.
    cube = cube.crop(cube.getchannel("A").point(lambda a: 255 if a > 24 else 0).getbbox())
    side = round(size * scale)
    ratio = side / max(cube.size)
    cube = cube.resize((round(cube.width * ratio), round(cube.height * ratio)), Image.LANCZOS)
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    layer.paste(cube, ((size - cube.width) // 2, (size - cube.height) // 2), cube)
    return layer


def compose(scale):
    img = gradient(MASTER).convert("RGBA")
    img.alpha_composite(cube_layer(MASTER, scale))
    return img.convert("RGB")


def save(img, path, size):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.resize((size, size), Image.LANCZOS).save(path, optimize=True)


def android(full):
    res = ROOT / "android" / "app" / "src" / "main" / "res"
    densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}

    # Ícone adaptativo: camada de 108dp, só os 72dp centrais aparecem garantidos.
    foreground = cube_layer(MASTER, 0.50)
    background = gradient(MASTER)
    for name, factor in densities.items():
        save(full, res / f"mipmap-{name}" / "ic_launcher.png", round(48 * factor))
        save(foreground, res / f"mipmap-{name}" / "ic_launcher_foreground.png", round(108 * factor))
        save(background, res / f"mipmap-{name}" / "ic_launcher_background.png", round(108 * factor))

    adaptive = res / "mipmap-anydpi-v26" / "ic_launcher.xml"
    adaptive.parent.mkdir(parents=True, exist_ok=True)
    adaptive.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@mipmap/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        "</adaptive-icon>\n"
    )


def ios(full):
    folder = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    contents = json.loads((folder / "Contents.json").read_text())
    for entry in contents["images"]:
        base = float(entry["size"].split("x")[0])
        factor = int(entry["scale"].rstrip("x"))
        save(full, folder / entry["filename"], round(base * factor))


def web(full, maskable):
    icons = ROOT / "web" / "icons"
    save(full, icons / "Icon-192.png", 192)
    save(full, icons / "Icon-512.png", 512)
    save(maskable, icons / "Icon-maskable-192.png", 192)
    save(maskable, icons / "Icon-maskable-512.png", 512)
    save(full, ROOT / "web" / "favicon.png", 32)


def main():
    full = compose(0.78)
    maskable = compose(0.62)
    android(full)
    ios(full)
    web(full, maskable)


if __name__ == "__main__":
    main()
