# Aturan Flutter (Orbite)

## Struktur

```
lib/
  app/                       # router, tema, dependency injection, bootstrap
  core/                      # utilitas lintas fitur (api client, error, storage)
  features/<nama_fitur>/
    presentation/            # pages, widgets, cubit
    domain/                  # entity, repository interface, use case
    data/                    # model, data source, repository implementation
```

- Larangan: domain layer tidak boleh import `package:http`, `dio`, atau `flutter/material.dart`.
- Larangan: presentation layer tidak boleh memanggil data source langsung, hanya use case.

## API

- Satu `ApiClient` di `lib/core/api/` berbasis `dio` dengan interceptor token.
- Base URL lewat `--dart-define=API_BASE_URL=...`, bukan hardcode.
- Error API dipetakan ke satu tipe `AppFailure` di `lib/core/error/`.
- Serialisasi JSON memakai `fromJson`/`toJson` manual per model (lihat skill `flutter-implement-json-serialization`).

## State

- Cubit per layar atau per cakupan data, bukan satu cubit global.
- Empat state wajib pada layar yang mengambil data: loading, empty, error, success (lihat `docs/error-handling.md`).
- Loading boleh lewat skeleton untuk daftar, spinner untuk aksi tunggal.

## 3D dan performa

- `three_dart` untuk rendering tata surya. Render loop harus bisa dihentikan (pause) dan di-resize tanpa leak listener.
- Texture/aset besar dimuat lewat `cached_network_image`, bukan `Image.network` polos.
- Widget subtree yang tidak berubah tidak boleh rebuild: pakai `const` constructor, `Selector`, atau `BlocSelector` seperlunya.

## Gaya kode

- `analysis_options.yaml` adalah acuan. Jangan disables lint tanpa alasan di kode.
- Tanpa komentar yang mengulang nama kode. Komentar hanya untuk menjelaskan alasan.
- Format: `dart format .`

## Verifikasi wajib

```bash
flutter analyze
flutter test
```
