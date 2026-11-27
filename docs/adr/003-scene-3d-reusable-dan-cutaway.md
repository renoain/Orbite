# ADR 003: Scene 3D Reusable dan Cutaway Interior

## Konteks

Orbite menambahkan tiga scene 3D edukatif:

- Musim & Kemiringan Bumi.
- Gerhana Matahari/Bulan.
- Interior planet cutaway.

Scene 3D sebelumnya (`home_scene.dart` dan `moon_phases_page.dart`) menduplikasi lifecycle `FlutterGlPlugin`, renderer, kamera, `OrbitControls`, ticker, serta state loading/error. Interior planet sebelumnya masih berupa gambar 2D dengan hotspot.

## Keputusan

1. Ekstrak `ThreeSceneCanvas` ke `lib/core/widgets/three_scene_canvas.dart`.
   - Canvas menangani inisialisasi GL, renderer, kamera, `OrbitControls`, ticker, dan state loading/error.
   - Halaman fitur hanya menyediakan `setup` dan `onTick` lewat `ThreeSceneController`.
2. Implementasikan cutaway interior dengan setengah bola dan cakram lapisan.
   - `SphereGeometry` memakai `phiLength = π` untuk membuka satu sisi.
   - Cakram `CircleGeometry` dan garis `RingGeometry` disusun berlapis sebagai bidang potong.
   - Tidak memakai clipping plane karena dukungan `three_dart` belum terbukti lengkap.
3. Gunakan tekstur yang sudah ada untuk Bumi, Mars, planet lain, Matahari, dan Bulan.
   - Tidak menambah aset biner baru.
4. Model gerhana memakai pendekatan ideal: orbit Bulan dianggap sejajar bidang ekliptika.
   - Keterbatasan ini ditampilkan di layar, bukan disembunyikan.

## Konsekuensi

- **Positif**:
  - Lifecycle 3D terpusat dan konsisten antar fitur.
  - State loading dan error tersedia di semua scene baru.
  - Cutaway tetap kompatibel dengan `three_dart` tanpa bergantung pada clipping plane.
  - Tidak ada biaya lisensi aset baru.
- **Negatif**:
  - Ticker render berjalan selama scene terlihat agar `OrbitControls` tetap halus; tombol pause menghentikan simulasi, bukan render.
  - Ketebalan lapisan pada cutaway disederhanakan, bukan skala presisi.
  - Model gerhana tidak memperhitungkan kemiringan orbit Bulan dan titik simpul.
- **Tindak lanjut**:
  - Ukur performa scene baru di perangkat menengah sebelum rilis.
  - Tinjau kembali clipping plane jika dukungan `three_dart` sudah stabil.
