#!/usr/bin/env python3

import json
import random
import subprocess
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFilter
except ImportError:
    print("Pillow is not installed. Add python3.withPackages(pillow).")
    sys.exit(0)


def run(args):
    return subprocess.run(
        args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )


def get_resolution():
    try:
        result = run(["hyprctl", "monitors", "-j"])
        if result.returncode == 0 and result.stdout.strip():
            monitors = json.loads(result.stdout)
            if monitors:
                return int(monitors[0]["width"]), int(monitors[0]["height"])
    except Exception:
        pass
    return 1920, 1080


def parse_hex(color):
    color = color.strip().lstrip("#")
    return int(color[0:2], 16), int(color[2:4], 16), int(color[4:6], 16)


def load_palette():
    default_bg = "#0a0e27"
    default_accents = ["#ff006e", "#00f0ff", "#9d4edd", "#ffea00"]
    palette_path = Path.home() / ".config/hypr/wallpaper-colors.json"
    if not palette_path.exists():
        return default_bg, default_accents
    try:
        palette = json.loads(palette_path.read_text())
        bg = palette.get("background", default_bg)
        accents = palette.get("accents", default_accents)
        if not accents:
            accents = default_accents
        return bg, accents
    except Exception:
        return default_bg, default_accents


def generate_wallpaper(path):
    width, height = get_resolution()
    bg_hex, accents = load_palette()

    bg_rgb = parse_hex(bg_hex)
    base = Image.new("RGBA", (width, height), (*bg_rgb, 255))
    layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    density = 0.00008
    count = max(120, int(width * height * density))
    min_radius = 4
    max_radius = 16

    for _ in range(count):
        radius = random.randint(min_radius, max_radius)
        x = random.randint(-radius, width + radius)
        y = random.randint(-radius, height + radius)
        color = parse_hex(random.choice(accents))
        alpha = random.randint(90, 160)
        draw.ellipse(
            (x - radius, y - radius, x + radius, y + radius),
            fill=(*color, alpha),
        )

    soft = layer.filter(ImageFilter.GaussianBlur(radius=4))

    soft_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    soft_draw = ImageDraw.Draw(soft_layer)
    for _ in range(int(count * 0.4)):
        radius = random.randint(min_radius, max_radius + 12)
        x = random.randint(-radius, width + radius)
        y = random.randint(-radius, height + radius)
        color = parse_hex(random.choice(accents))
        alpha = random.randint(50, 110)
        soft_draw.ellipse(
            (x - radius, y - radius, x + radius, y + radius),
            fill=(*color, alpha),
        )
    soft_layer = soft_layer.filter(ImageFilter.GaussianBlur(radius=10))

    composed = Image.alpha_composite(base, soft)
    composed = Image.alpha_composite(composed, soft_layer)

    path.parent.mkdir(parents=True, exist_ok=True)
    composed.save(path, format="PNG")


def set_wallpaper(path):
    if run(["swww", "query"]).returncode != 0:
        return
    run(
        [
            "swww",
            "img",
            str(path),
            "--transition-type",
            "fade",
            "--transition-duration",
            "1",
        ]
    )


def main():
    output = Path.home() / ".config/hypr/wallpapers/generated.png"
    generate_wallpaper(output)
    set_wallpaper(output)


if __name__ == "__main__":
    main()
