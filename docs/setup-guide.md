# Panduan Setup Proyek

## 1. Prasyarat

### Flutter
- Flutter SDK: `^3.13.5`
- IDE: VS Code atau Android Studio
- Perangkat fisik atau emulator

### Laravel
- PHP: `^8.1`
- Composer
- MySQL/MariaDB (Laragon recommended)
- Node.js (untuk Vite)

### Sistem Operasi
- Windows 10/11 (dengan Laragon)
- atau macOS/Linux

## 2. Struktur Proyek

- **Flutter (Frontend):** `D:\project\orbite`
- **Laravel (Backend):** `D:\project\orbite-api`

## 3. Cara Menjalankan

### 1. Jalankan Laravel:
```bash
cd D:\project\orbite-api
php artisan serve
```
API akan berjalan di `http://localhost:8000/api/v1`.

### 2. Jalankan Flutter:
```bash
cd D:\project\orbite
flutter run -d chrome
```

### 3. Pastikan keduanya terhubung:
Flutter memanggil API Laravel di `http://localhost:8000/api/v1`.

### Catatan CORS
Jika ada error CORS, periksa `orbite-api/config/cors.php`.

## 4. Database Information

- **Database Name**: `orbite_db`
- **Tables**: `planets`, `interior_layers`, `trivia`, `users`, `user_progress`
- **Default Credentials**: `root`/`password` (kosong untuk Laragon)

## 5. Endpoint API Utama

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/planets` | Daftar semua planet |
| GET | `/api/v1/planets/{id}` | Detail planet |
| GET | `/api/v1/planets/{id}/layers` | Lapisan interior planet |

## 6. Troubleshooting

### Masalah Umum

1. **Flutter analyze errors**
   - Jalankan `flutter pub get`
   - Periksa `pubspec.yaml` untuk dependensi yang salah

2. **Laravel migrate errors**
   - Pastikan MySQL sedang berjalan
   - Periksa konfigurasi `.env`
   - Jalankan `php artisan config:clear`

3. **CORS issues**
   - Tambahkan header CORS di Laravel atau gunakan package `fruitcake/laravel-cors`

### Logs

- Laravel: `storage/logs/laravel.log`
- Flutter: `flutter doctor` untuk info sistem

## 7. Cloud Storage (Cloudinary) — Upload Manual

Gambar 2D (`image_url`) disajikan dari Cloudinary; tekstur 3D (`texture_url`) tetap lokal. Upload dilakukan manual sekali, lalu URL dibangun otomatis dari `IMAGE_CDN_BASE` + public ID.

### Langkah
1. Buat akun Cloudinary, catat **cloud name**.
2. Upload gambar ke folder/public ID berikut (harus sama dengan seeder):
   - Planet: `orbite/planets/mercury`, `venus`, `earth`, `mars`, `jupiter`, `saturn`, `uranus`, `neptune`.
   - Interior (yang ada file): `orbite/interior/earth_crust`, `orbite/interior/mars_interior`.
3. Set di `orbite-api/.env`:
   ```env
   IMAGE_CDN_BASE=https://res.cloudinary.com/<cloud_name>/image/upload/f_auto,q_auto
   ```
4. Terapkan:
   ```bash
   php artisan config:clear
   php artisan db:seed --class=PlanetSeeder
   php artisan db:seed --class=InteriorLayerSeeder
   ```
5. Verifikasi: `GET /api/v1/planets` → `image_url` berupa `https://...`.
6. Untuk kembali ke aset lokal (dev), kosongkan `IMAGE_CDN_BASE` lalu reseed.

### Catatan
- Tanpa SDK/API key di aplikasi; cukup URL publik (aman untuk repo).
- Lapisan interior planet selain Bumi/Mars belum punya public ID → masih memakai tekstur lokal. Tambahkan `image_id` di `InteriorLayerSeeder` bila gambarnya sudah diupload.
- `f_auto,q_auto` membuat Cloudinary otomatis memilih format/kompresi terbaik.