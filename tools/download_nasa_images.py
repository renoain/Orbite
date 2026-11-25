#!/usr/bin/env python3
"""Download NASA images for planet layer content into assets/images/."""

import os
import sys
from pathlib import Path

try:
    import requests
except ImportError:
    print("Missing dependency: requests. Install with: pip install requests")
    sys.exit(1)

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "assets" / "images"
OUT_DIR.mkdir(parents=True, exist_ok=True)

IMAGES = [
    ("https://images-assets.nasa.gov/image/PIA25063/PIA25063~orig.jpg", "earth_core.jpg"),
    ("https://images-assets.nasa.gov/image/PIA25063/PIA25063~orig.jpg", "earth_mantle.jpg"),
    ("https://images-assets.nasa.gov/image/PIA25063/PIA25063~orig.jpg", "earth_crust.jpg"),
    ("https://www.nasa.gov/wp-content/uploads/2023/03/earth20140425_0_1.jpg", "earth_atmosphere.jpg"),
    ("https://images-assets.nasa.gov/image/GSFC_20171208_Archive_e002131/GSFC_20171208_Archive_e002131~large.jpg", "earth_surface.jpg"),
    ("https://science.nasa.gov/wp-content/uploads/2024/03/pia16078.jpg", "mars_interior.jpg"),
    ("https://images-assets.nasa.gov/image/as11-37-5545/as11-37-5545~large.jpg", "moon_surface.jpg"),
]

HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; OrbiteImageDownloader/1.0)"}


def download(url, filename):
    dest = OUT_DIR / filename
    try:
        with requests.get(url, headers=HEADERS, timeout=60, stream=True) as r:
            r.raise_for_status()
            with open(dest, "wb") as f:
                for chunk in r.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
        size = dest.stat().st_size
        print(f"[OK] {filename} ({size} bytes) <- {url}")
        return True
    except Exception as e:
        print(f"[FAIL] {filename}: {e}")
        return False


def main():
    ok = 0
    fail = 0
    for url, filename in IMAGES:
        if download(url, filename):
            ok += 1
        else:
            fail += 1
    print(f"\nDone: {ok} succeeded, {fail} failed.")


if __name__ == "__main__":
    main()