#!/usr/bin/env python3
"""Draw docs/*.png: the follower sprites, as they ship.

Every sprite in every sheet is a frame cut straight out of assets/sprites/ and
scaled by a whole number with no resampling.  Nothing is redrawn, recoloured
or touched up -- this is the art the mod hands the renderer.

    python3 tools/make_showcase.py           # redraw every sheet
    python3 tools/make_showcase.py sizes     # ... or just the ones named

Sheets:
    species   the standing frame of all 251 species, in Pokedex order
    frames    a few whole 16x96 sheets, all six frames each
    sizes     what POKEDEX SIZES does, at the scales the mod computes

Labels are set in Inter (SIL Open Font Licence 1.1, Rasmus Andersson), fetched
once into tools/.cache/.  The sprites themselves are the Crystal Clear /
PokePC / Followers EX lineage's -- see THIRD_PARTY_NOTICES.md, and carry those
names with any of this art.

Needs Pillow:  pip install Pillow
"""

import pathlib
import re
import sys
import urllib.request

from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
SPRITES = ROOT / "assets" / "sprites"
CACHE = ROOT / "tools" / ".cache"
DOCS = ROOT / "docs"

CELL = 16            # one frame, in source pixels
FRAMES = 6           # frames in every sheet
SPECIES_COUNT = 251

BG = (0x4a, 0x55, 0x60)      # a mid slate: these sprites are black-outlined,
PANEL = (0x3d, 0x46, 0x50)   # and vanish on a dark page
TEXT = (0xf2, 0xf5, 0xf7)
MUTED = (0xc2, 0xcc, 0xd4)


def gfont(weight, size):
    """Inter, fetched once and kept in tools/.cache/."""
    path = CACHE / f"Inter-{weight}.ttf"
    if not path.exists():
        CACHE.mkdir(parents=True, exist_ok=True)
        css = f"https://fonts.googleapis.com/css2?family=Inter:wght@{weight}"
        with urllib.request.urlopen(css, timeout=30) as r:
            sheet = r.read().decode()
        m = re.search(r"url\((https://[^)]+\.ttf)\)", sheet)
        if not m:
            raise SystemExit(f"no TrueType URL for Inter {weight}")
        with urllib.request.urlopen(m.group(1), timeout=30) as r:
            path.write_bytes(r.read())
    return ImageFont.truetype(str(path), size)


def frame(dex, index=0):
    """One frame out of a species' sheet."""
    path = SPRITES / f"follower_{dex:03d}.png"
    sheet = Image.open(path).convert("RGBA")
    return sheet.crop((0, index * CELL, CELL, index * CELL + CELL))


SHEETS = {}


def sheet(fn):
    SHEETS[fn.__name__] = fn
    return fn


@sheet
def species():
    """All 251, in Pokedex order, at the size the overworld draws them."""
    scale, cols, gap, pad = 3, 21, 4, 18
    tile = CELL * scale
    rows = (SPECIES_COUNT + cols - 1) // cols

    width = pad * 2 + cols * tile + (cols - 1) * gap
    height = pad * 2 + rows * tile + (rows - 1) * gap
    img = Image.new("RGB", (width, height), BG)

    for i in range(SPECIES_COUNT):
        tab = frame(i + 1).resize((tile, tile), Image.NEAREST)
        img.paste(tab, (pad + (i % cols) * (tile + gap),
                        pad + (i // cols) * (tile + gap)), tab)

    DOCS.mkdir(exist_ok=True)
    img.save(DOCS / "species.png")
    print(f"  docs/species.png  {width}x{height}  ({SPECIES_COUNT} species)")


@sheet
def frames():
    """A whole sheet is six frames; here are a few of them, end to end."""
    picks = [(1, "BULBASAUR"), (25, "PIKACHU"), (95, "ONIX"),
             (130, "GYARADOS"), (143, "SNORLAX"), (249, "LUGIA")]
    scale, gap, pad, lab = 4, 10, 20, 14
    tile = CELL * scale
    bold = gfont(600, lab)

    width = pad * 2 + FRAMES * tile + (FRAMES - 1) * gap
    row = tile + 8 + lab + 12
    height = pad * 2 + len(picks) * row
    img = Image.new("RGB", (width, height), BG)
    draw = ImageDraw.Draw(img)

    for r, (dex, name) in enumerate(picks):
        y = pad + r * row
        draw.text((pad, y), f"#{dex:03d}  {name}", font=bold, fill=MUTED)
        for f in range(FRAMES):
            tab = frame(dex, f).resize((tile, tile), Image.NEAREST)
            img.paste(tab, (pad + f * (tile + gap), y + lab + 8), tab)

    img.save(DOCS / "frames.png")
    print(f"  docs/frames.png  {width}x{height}  ({len(picks)} sheets)")


# Pokedex heights in metres, as printed in the Pokedex entry the mod reads at
# runtime.  The scale beside each one is not a guess: it is this repository's
# own formula from main.lua, reproduced in follower_scale() below.
HEIGHTS = [
    (25, "PIKACHU", 0.4),
    (66, "MACHOP", 0.8),
    (34, "NIDOKING", 1.4),
    (6, "CHARIZARD", 1.7),
    (143, "SNORLAX", 2.1),
    (149, "DRAGONITE", 2.2),
    (130, "GYARADOS", 6.5),
    (95, "ONIX", 8.8),
]

REFERENCE_METRES = 1.70
EXPONENT = 0.40
MIN_SCALE, MAX_SCALE = 0.6875, 2.50
QUANTUM = 0.0625


def follower_scale(metres):
    """main.lua's followerVisualScale, at FOLLOWER SIZE 100%."""
    scale = (metres / REFERENCE_METRES) ** EXPONENT
    scale = min(max(scale, MIN_SCALE), MAX_SCALE)
    return int(scale / QUANTUM + 0.5) * QUANTUM


@sheet
def sizes():
    """POKEDEX SIZES: a follower is as big as its Pokedex entry says."""
    zoom, gap, pad, lab = 5, 18, 22, 13
    bold, plain = gfont(600, lab), gfont(400, lab - 1)
    tallest = max(follower_scale(m) for _, _, m in HEIGHTS)
    band = int(CELL * tallest * zoom)
    cell_w = int(CELL * tallest * zoom)

    width = pad * 2 + len(HEIGHTS) * cell_w + (len(HEIGHTS) - 1) * gap
    height = pad * 2 + band + 10 + (lab + 4) * 2
    img = Image.new("RGB", (width, height), BG)
    draw = ImageDraw.Draw(img)
    baseline = pad + band

    for i, (dex, name, metres) in enumerate(HEIGHTS):
        scale = follower_scale(metres)
        side = int(CELL * scale * zoom)
        tab = frame(dex).resize((side, side), Image.NEAREST)
        x = pad + i * (cell_w + gap)
        img.paste(tab, (x + (cell_w - side) // 2, baseline - side), tab)
        draw.text((x + cell_w / 2, baseline + 10), name,
                  font=bold, fill=TEXT, anchor="ma")
        draw.text((x + cell_w / 2, baseline + 10 + lab + 4),
                  f"{metres:g} m  ->  {scale:g}x", font=plain, fill=MUTED,
                  anchor="ma")

    img.save(DOCS / "sizes.png")
    print(f"  docs/sizes.png  {width}x{height}  ({len(HEIGHTS)} species)")


def main(argv):
    wanted = [a.lower() for a in argv] or list(SHEETS)
    unknown = [w for w in wanted if w not in SHEETS]
    if unknown:
        print(f"no such sheet: {', '.join(unknown)}", file=sys.stderr)
        print(f"try: {', '.join(SHEETS)}", file=sys.stderr)
        return 1
    DOCS.mkdir(exist_ok=True)
    for name in wanted:
        SHEETS[name]()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
