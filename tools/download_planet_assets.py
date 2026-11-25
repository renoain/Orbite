#!/usr/bin/env python3
"""Download planet interior images and prepare surface images."""

import os
import shutil
import sys
from pathlib import Path

try:
    import requests
except ImportError:
    print("Missing dependency: requests. Install with: pip install requests")
    sys.exit(1)

ROOT = Path(__file__).resolve().parent.parent
INTERIOR = ROOT / "assets" / "images" / "interior"
SURFACE = ROOT / "assets" / "images" / "surface"
INTERIOR.mkdir(parents=True, exist_ok=True)
SURFACE.mkdir(parents=True, exist_ok=True)

HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; OrbiteImageDownloader/1.0)"}

# Interior images downloaded from NASA
INTERIOR_DOWNLOADS = [
    ("https://images-assets.nasa.gov/image/PIA25063/PIA25063~orig.jpg", "earth_interior.jpg"),
    ("https://science.nasa.gov/wp-content/uploads/2024/03/pia16078.jpg", "mars_interior.jpg"),
    ("https://images-assets.nasa.gov/image/PIA25062/PIA25062~orig.jpg", "jupiter_interior.jpg"),
    ("https://images-assets.nasa.gov/image/PIA22573/PIA22573~orig.jpg", "venus_interior.jpg"),
    ("https://images-assets.nasa.gov/image/PIA22573/PIA22573~orig.jpg", "mercury_interior.jpg"),
    ("https://images-assets.nasa.gov/image/PIA22573/PIA22573~orig.jpg", "moon_interior.jpg"),
    ("https://images-assets.nasa.gov/image/PIA25062/PIA25062~orig.jpg", "saturn_interior.jpg"),
    ("https://images-assets.nasa.gov/image/PIA25062/PIA25062~orig.jpg", "uranus_interior.jpg"),
    ("https://images-assets.nasa.gov/image/PIA25062/PIA25062~orig.jpg", "neptune_interior.jpg"),
]

# Surface images: copy from existing textures (NASA-sourced, high-res)
TEXTURES = ROOT / "assets" / "textures"
SURFACE_COPIES = [
    ("2k_mercury.jpg", "mercury_surface.jpg"),
    ("2k_venus_surface.jpg", "venus_surface.jpg"),
    ("2k_earth_daymap.jpg", "earth_surface.jpg"),
    ("2k_mars.jpg", "mars_surface.jpg"),
    ("2k_jupiter.jpg", "jupiter_surface.jpg"),
    ("2k_saturn.jpg", "saturn_surface.jpg"),
    ("2k_uranus.jpg", "uranus_surface.jpg"),
    ("2k_neptune.jpg", "neptune_surface.jpg"),
    ("2k_sun.jpg", "sun_surface.jpg"),
    ("2k_moon.jpg", "moon_surface.jpg"),
]


def download(url, dest):
    try:
        with requests.get(url, headers=HEADERS, timeout=60, stream=True) as r:
            r.raise_for_status()
            with open(dest, "wb") as f:
                for chunk in r.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
        print("[OK] " + dest.name + " (" + str(dest.stat().st_size) + " bytes)")
        return True
    except Exception as e:
        print("[FAIL] " + dest.name + ": " + str(e))
        return False


def main():
    ok = 0
    fail = 0
    for url, name in INTERIOR_DOWNLOADS:
        dest = INTERIOR / name
        if download(url, dest):
            ok += 1
        else:
            fail += 1
    # Sun interior uses sun texture as fallback
    sun_tex = TEXTURES / "2k_sun.jpg"
    sun_int = INTERIOR / "sun_interior.jpg"
    if sun_tex.exists():
        shutil.copyfile(sun_tex, sun_int)
        print("[OK] sun_interior.jpg (copied from texture)")
        ok += 1
    else:
        print("[FAIL] sun_interior.jpg: texture missing")
        fail += 1
    for src_name, dst_name in SURFACE_COPIES:
        src = TEXTURES / src_name
        dst = SURFACE / dst_name
        if src.exists():
            shutil.copyfile(src, dst)
            print("[OK] " + dst_name + " (copied from texture)")
            ok += 1
        else:
            print("[FAIL] " + dst_name + ": texture missing")
            fail += 1
    print("\nDone: " + str(ok) + " succeeded, " + str(fail) + " failed.")


if __name__ == "__main__":
    main()