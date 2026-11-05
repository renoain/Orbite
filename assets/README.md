# Aset Aplikasi

Semua aset statis Flutter diletakkan di sini, bukan di `lib/`. Path yang dipakai Flutter selalu relatif ke root project.

```
assets/
  images/     # ilustrasi onboarding, placeholder, gambar UI
  textures/   # texture planet, matahari, bintang (PNG/WebP/KTX2)
  models/     # model 3D (.glb/.gltf) bila dipakai
  fonts/      # font bundling (Poppins, dll)
```

## Aturan

- Isi setiap folder hanya boleh berisi aset yang benar-benar dipakai. Jangan menaruh file contoh tanpa alasan.
- File biner besar (texture, model 3D) sebaiknya lewat **git-lfs**, atau diunduh saat runtime dari API/CDN memakai `cached_network_image`.
- Aset yang disajikan backend tidak ada di sini. Gambar planet dari Laravel ada di `backend/storage/app/public/planets/` dan diakses lewat `storage:link`.
- Sumber dan lisensi setiap aset dicatat di `docs/assets-inventory.md` sebelum aset dipakai.
- Nama file lowercase dengan tanda hubung: `planet-earth-texture.webp`.

## Deklarasi di pubspec

Folder yang dipakai harus terdaftar di `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/textures/
    - assets/models/
    - assets/fonts/
```
