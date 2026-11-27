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