#!/usr/bin/env python3
"""Genera `assets/brand/dt_wordmark.svg`: solo «DOLAR TRACKER», sin el icono.

El splash anima las dos piezas por separado —primero el icono, luego el texto
apareciendo debajo— y para eso necesita el wordmark como archivo propio.

Sale de los **contornos reales de la fuente**, igual que `flatten_brand_svg.py`,
no de recortar el logo: así el tipo es exactamente el mismo en los dos archivos.
El viewBox va ajustado a la caja del texto, de modo que quien lo pinte solo
tenga que dar un ancho y no calcular márgenes.

    python3 tool/make_wordmark_svg.py

Requiere `fonttools` y la fuente instalada.
"""

from __future__ import annotations

import io
from pathlib import Path

from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.ttLib import TTFont

FONT = Path("/System/Library/Fonts/Supplemental/Arial Narrow Bold.ttf")
TEXT = "DOLAR TRACKER"
OUT = Path("assets/brand/dt_wordmark.svg")


def main() -> None:
    font = TTFont(FONT)
    glyphs = font.getGlyphSet()
    cmap = font.getBestCmap()
    hmtx = font["hmtx"]

    paths: list[str] = []
    pen_x = 0.0
    top, bottom = None, None

    for char in TEXT:
        name = cmap[ord(char)]
        pen = SVGPathPen(glyphs)
        glyphs[name].draw(pen)
        d = pen.getCommands()
        if d:
            paths.append(f'    <path d="{d}" transform="translate({pen_x:.0f},0)"/>')
            bounds = BoundsPen(glyphs)
            glyphs[name].draw(bounds)
            if bounds.bounds:
                _, y_min, _, y_max = bounds.bounds
                top = y_max if top is None else max(top, y_max)
                bottom = y_min if bottom is None else min(bottom, y_min)
        pen_x += hmtx[name][0]

    width, height = pen_x, top - bottom

    # La `y` de la fuente crece hacia arriba y la del SVG hacia abajo: se voltea
    # y se sube la línea base para que la caja empiece en cero.
    svg = f"""<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- GENERADO por tool/make_wordmark_svg.py — no editar a mano.
     Contornos de {FONT.stem}, texto «{TEXT}». Negro: el color lo pone quien
     lo dibuja, con un colorFilter. -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width:.0f} {height:.0f}"
     width="100%" height="100%">
  <g transform="translate(0,{top:.0f}) scale(1,-1)">
{chr(10).join(paths)}
  </g>
</svg>
"""
    io.open(OUT, "w", encoding="utf-8").write(svg)
    print(f"{OUT}: {len(paths)} glifos, viewBox {width:.0f}x{height:.0f}")


if __name__ == "__main__":
    main()
