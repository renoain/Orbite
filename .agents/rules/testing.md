# Aturan Pengujian (Orbite)

Rujukan: `docs/testing-strategy.md`.

## Lapisan

- **Unit test** (`test/`): logika domain, use case, mapper JSON. Tanpa network.
- **Widget test** (`test/features/...`): rendering, state loading/empty/error/success, interaksi tombol.
- **Integration test** (`integration_test/`): alur nyata antar layar, memakai API lokal atau fake server.

## Aturan

- Test baru wajib ikut perubahan fitur. Fitur tanpa test dianggap belum selesai.
- Nama test menjelaskan perilaku: `should return empty state when planet list is empty`.
- Mock boundary, bukan implementasi internal. Cubit diuji lewat state yang dipublikasikan.
- Tidak ada angka permintaan jaringan sungguhan di test. Paket `http` di-mock.

## Gate sebelum menyatakan selesai

```bash
flutter analyze
flutter test
```

Backend (saat ada):

```bash
php artisan test
```
