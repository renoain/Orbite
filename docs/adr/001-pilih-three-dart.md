# ADR 001: Memilih `three_dart` untuk Rendering 3D

## Konteks

Aplikasi membutuhkan rendering tata surya 3D yang interaktif.

## Keputusan

Menggunakan `three_dart` (bukan `flutter_3d_controller`) karena repo `Yczar/solar-system` sudah menggunakannya dan mendukung rotasi/zoom.

## Konsekuensi

- **Positif**: Kode 3D dari repo bisa diadaptasi.
- **Negatif**: `three_dart` kurang terdokumentasi; perlu komentar ekstra di kode.
