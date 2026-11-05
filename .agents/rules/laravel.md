# Aturan Backend Laravel (Orbite)

Belum ada folder backend di repo. Saat backend dibuat, aturan ini jadi acuan.

## Kontrak API

- Semua endpoint ada di `routes/api.php` dengan prefix `v1`, hasilnya `/api/v1/...`.
- Format sukses: `{ "data": ... }`. Format error: `{ "error": "...", "code": 500 }`.
- Endpoint baru wajib didokumentasikan di `docs/api-contract.md` sebelum rilis.
- Versi kontrak berubah besar -> buat ADR baru.

## Validasi dan keamanan

- Input tervalidasi lewat `FormRequest`, bukan validasi manual di controller.
- Jangan return model Eloquent mentah. Pakai `JsonResource` agar field sensitif tidak bocor.
- Auth: Laravel Sanctum. Endpoint yang butuh token pakai middleware `auth:sanctum`.
- Rate limit: `throttle` pada endpoint login dan trivia.
- Token Flutter disimpan di `flutter_secure_storage`, bukan `SharedPreferences`.

## Database

- Perubahan tabel hanya lewat migration baru, tidak pernah edit migration yang sudah jalan.
- Primary key UUID, kolom snake_case, foreign key selalu berindex.
- Nomor urut planet memakai kolom `order` (reserved word SQL, backtick di raw query).

## Error handling

- Service layer dibungkus try-catch, error diterjemahkan ke response JSON dengan status HTTP yang tepat (400, 401, 404, 422, 500).
- Jangan kirim stack trace atau pesan exception mentah ke client.

## Kualitas

```bash
php artisan test
./vendor/bin/pint --test
```
