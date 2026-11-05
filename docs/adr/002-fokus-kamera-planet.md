# ADR 002: Fokus Kamera pada Planet yang Diklik

## Konteks

Pada scene 3D, klik planet harus memfokuskan kamera ke planet tersebut, bukan ke pusat tata surya (Matahari).

## Keputusan

Gunakan animasi lerp posisi kamera dan target OrbitControls ke posisi world planet (getWorldPosition), dengan jarak tetap (25 unit untuk planet, 60 untuk Matahari). Animasi 800ms dengan Curves.easeOutCubic.

## Konsekuensi

- **Positif**: Pengguna langsung melihat planet target.
- **Negatif**: Posisi planet berubah karena orbit; animasi dihitung ulang setiap klik.
