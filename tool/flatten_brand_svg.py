#!/usr/bin/env python3
"""Deja los SVG de marca en algo que Flutter pueda dibujar.

`flutter_svg` 2.x renderiza con `vector_graphics`, al que le faltan dos cosas
que traen los exports de diseño:

1. **`<text>`**: no lo soporta. «DOLAR TRACKER» salía como dos barras negras
   sólidas, una por palabra.
2. **`<use>` apuntando a un `<image>` dentro de `<defs>`**: no lo resuelve, y no
   avisa — simplemente no dibuja. Es donde vive el anillo con el dólar.

Este script arregla las dos: convierte el texto a trazados leyendo los
contornos reales de la fuente (no los dibuja a mano) e incrusta la imagen en el
sitio del `<use>`.

    python3 tool/flatten_brand_svg.py assets/brand/dt_logo.svg

Es **idempotente**: si ya no hay `<text>` ni `<use>`, no toca nada. Vuelve a
pasarlo cada vez que diseño reexporte.

Requiere `fonttools` (`pip3 install fonttools`) y que la fuente del `<text>`
esté instalada en el sistema.
"""

from __future__ import annotations

import io
import re
import sys
from pathlib import Path

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.ttLib import TTFont

# Dónde buscar la fuente que pide el `font-family`. El nombre del archivo suele
# ser el de la familia con los espacios puestos: 'ArialNarrow-Bold' -> 'Arial
# Narrow Bold.ttf'.
FONT_DIRS = [
    Path("/System/Library/Fonts/Supplemental"),
    Path("/Library/Fonts"),
    Path.home() / "Library/Fonts",
]


def find_font(family: str) -> Path:
    """Localiza el .ttf de [family], probando variantes del nombre."""
    stem = family.replace("-", " ")
    candidates = {stem, stem.replace(" ", ""), family}
    for directory in FONT_DIRS:
        if not directory.is_dir():
            continue
        for path in directory.glob("*.ttf"):
            if path.stem.lower().replace(" ", "") in {
                c.lower().replace(" ", "") for c in candidates
            }:
                return path
    raise SystemExit(f"no encuentro la fuente '{family}' en {FONT_DIRS}")


def text_to_paths(match: re.Match[str]) -> str:
    """Devuelve un `<g>` de trazados equivalente al `<text>` de [match]."""
    attrs, content = match.group(1), match.group(2).strip()

    x = float(re.search(r'x="([-\d.]+)px?"', attrs).group(1))
    y = float(re.search(r'y="([-\d.]+)px?"', attrs).group(1))
    size = float(re.search(r"font-size:\s*([\d.]+)px", attrs).group(1))
    family = re.search(r"font-family:\s*'([^']+)'", attrs).group(1)

    font = TTFont(find_font(family))
    upm = font["head"].unitsPerEm
    cmap = font.getBestCmap()
    glyphs = font.getGlyphSet()
    hmtx = font["hmtx"]

    parts, pen_x = [], 0.0
    for char in content:
        name = cmap.get(ord(char))
        if name is None:
            raise SystemExit(f"la fuente no trae el glifo '{char}'")
        pen = SVGPathPen(glyphs)
        glyphs[name].draw(pen)
        d = pen.getCommands()
        if d:  # el espacio no dibuja nada, pero sí avanza
            parts.append(f'            <path d="{d}" transform="translate({pen_x:.0f},0)"/>')
        pen_x += hmtx[name][0]

    # La `y` de la fuente crece hacia arriba y la del SVG hacia abajo, de ahí el
    # signo negativo en la escala vertical.
    scale = size / upm
    body = "\n".join(parts)
    return (
        f'        <g transform="matrix({scale:.8f},0,0,{-scale:.8f},{x},{y})">\n'
        f"{body}\n"
        f"        </g>"
    )


def inline_used_images(svg: str) -> str:
    """Reescribe `<use xlink:href="#id"/>` como el `<image>` al que apunta."""
    hrefs = {
        m.group(1): m.group(2)
        for m in re.finditer(
            r'<image\s+id="([^"]+)"[^>]*?xlink:href="(data:[^"]+)"', svg, re.S
        )
    }

    def swap(m: re.Match[str]) -> str:
        href = hrefs.get(m.group(1))
        return m.group(0) if href is None else f'<image{m.group(2)} xlink:href="{href}"/>'

    return re.sub(r'<use\s+xlink:href="#([^"]+)"([^/>]*)/>', swap, svg)


def main(path: Path) -> None:
    svg = io.open(path, encoding="utf-8").read()
    before = svg

    svg = re.sub(r"<text([^>]*)>(.*?)</text>", text_to_paths, svg, flags=re.S)
    # El export deja un `<g>` vacío junto al texto; sin contenido no pinta nada,
    # pero ensucia el archivo.
    svg = re.sub(r"\n\s*<g transform=\"matrix\([^\"]*\)\">\s*</g>", "", svg)
    svg = inline_used_images(svg)

    if svg == before:
        print(f"{path}: ya estaba aplanado, sin cambios")
        return

    io.open(path, "w", encoding="utf-8").write(svg)
    print(f"{path}: texto a trazados e imagen incrustada")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    main(Path(sys.argv[1]))
