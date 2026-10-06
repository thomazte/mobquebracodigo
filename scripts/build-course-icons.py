"""Padroniza os ícones dos cursos a partir de scripts/source/cursos/.

Cada logo é recortada pelo que é visível e centralizada num quadrado
transparente de 512 px. A escala iguala a área ocupada (média geométrica de
largura e altura), para logos largas como a do PHP não ficarem miúdas, sem
deixar nenhum lado passar da margem. Rodar da raiz do projeto:
python3 scripts/build-course-icons.py
"""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "scripts" / "source" / "cursos"
OUTPUT = ROOT / "assets" / "cursos"

SIZE = 512
# Lado de referência de uma logo quadrada e o limite para qualquer lado.
TARGET = 0.80
MAX_SIDE = 0.92


def normalize(path):
    img = Image.open(path).convert("RGBA")
    # Ignora o brilho quase transparente que algumas artes têm em volta.
    img = img.crop(img.getchannel("A").point(lambda a: 255 if a > 24 else 0).getbbox())
    w, h = img.size
    scale = min(SIZE * TARGET / (w * h) ** 0.5, SIZE * MAX_SIDE / max(w, h))
    img = img.resize((round(w * scale), round(h * scale)), Image.LANCZOS)
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    canvas.paste(img, ((SIZE - img.width) // 2, (SIZE - img.height) // 2), img)
    return canvas


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for path in sorted(SOURCE.glob("*.png")):
        normalize(path).save(OUTPUT / path.name, optimize=True)


if __name__ == "__main__":
    main()
