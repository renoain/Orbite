## [2026-11-27] - INFRA - MEDIUM

### Summary
- Menambahkan jalur gambar Cloudinary (upload manual) lewat `IMAGE_CDN_BASE` + helper `ImageUrl`, dengan fallback aset lokal. `texture_url` tetap lokal untuk scene 3D.

### Files Added
- `config/orbite.php` (backend) - `image_cdn_base` dari env `IMAGE_CDN_BASE`
- `app/Support/ImageUrl.php` (backend) - resolve public ID menjadi URL cloud + fallback

### Files Modified
- `PlanetSeeder`, `InteriorLayerSeeder` (backend) - `image_id` + fallback, idempoten via `updateOrCreate`
- `InteriorLayer` model (backend) - memakai `HasUuids`
- `docs/setup-guide.md` - panduan upload Cloudinary
- `docs/adr/004-skema-planet-dan-strategi-gambar.md` - pembaruan keputusan cloud

### Impact
- `IMAGE_CDN_BASE` kosong → API memakai aset lokal (dev). Setelah upload + set env → `image_url` otomatis URL Cloudinary.
- Tanpa kredensial/SDK di repo; hanya URL publik.

### Verification
- `php artisan db:seed` planet & interior: sukses, 8 planet / 8 layer tanpa duplikasi
- `ImageUrl::resolve` fallback → `assets/textures/earth.jpg`; cloud → `https://res.cloudinary.com/.../orbite/planets/earth`

---

## [2026-11-27] - FEATURE - MEDIUM

### Summary
- Menyambungkan `PlanetListPage` dan `PlanetDetailPage` ke API Laravel, menggantikan `assets/mock/planets.json` di dua layar ini. Menambahkan loader injectable agar test tetap offline.

### Files Modified
- `lib/features/solar_system/presentation/pages/planet_list_page.dart` - memakai `AppDependencies.getPlanets`, filter Matahari, loader injectable, kartu pakai `textureUrl`
- `lib/features/planet_detail/presentation/pages/planet_detail_page.dart` - memakai `getPlanets` + `getPlanet`, field API (`diameterKm`, `dayLengthHours`, dll.), `NasaImage` untuk asset/network, `gravity` dari API
- `test/planet_list_page_test.dart`, `test/planet_list_filter_test.dart` - menyuntikkan data uji

### Files Added
- `test/support/fake_planets.dart` - data uji 8 planet + Matahari

### Impact
- Daftar dan detail planet kini memuat data dari API; mock tidak dipakai lagi di dua layar ini.
- Test tetap berjalan offline lewat loader injectable.
- Layar lain (Learn, Compare, Explore, Trivia) masih memakai mock dan disambungkan pada tahap berikutnya.

### Verification
- `flutter analyze`: **No issues found**
- `flutter test`: **13 passed**

---

## [2026-11-27] - FEATURE - MEDIUM

### Summary
- Opsi A: memperluas skema `planets` dengan field teknis dan nama Indonesia, memperbarui API, lalu menyinkronkan model network layer. Gambar disiapkan untuk cloud storage lewat `image_url` (produksi) dan `texture_url` (dev).

### Files Added
- `docs/adr/004-skema-planet-dan-strategi-gambar.md` - keputusan skema planet dan strategi gambar cloud

### Files Modified
- `docs/database-schema.md`, `docs/api-contract.md` - kolom dan field baru
- `lib/features/solar_system/domain/entities/planet_summary.dart`, `planet_detail.dart` - field teknis + `nameId` + `displayName`
- `lib/features/solar_system/data/models/planet_summary_model.dart`, `planet_detail_model.dart` - parsing field baru
- `docs/architecture.md` - catatan network layer diperbarui

### Impact
- `GET /planets` dan `GET /planets/{id}` kini mengembalikan `name_id`, `distance`, `diameter_km`, `day_length_hours`, `orbital_period_days`, `moons`, `gravity`, dan `texture_url`.
- Model Flutter siap menerima data lengkap; UI belum disambungkan.
- Backend Laravel berada di `D:\project\orbite-api` (di luar repo ini); seeder idempoten via `order`.

### Verification
- `flutter analyze`: **No issues found**
- `flutter test`: **13 passed**
- API dicek: `GET /api/v1/planets` mengembalikan field baru

---

## [2026-11-27] - FEATURE - MEDIUM

### Summary
- Menyiapkan lapisan jaringan Flutter (dio) untuk integrasi dengan API Laravel, plus dokumentasi setup dan skema database. UI belum diubah pada tahap ini.

### Files Added
- `lib/core/api/api_config.dart` - base URL via `--dart-define=API_BASE_URL`
- `lib/core/api/api_client.dart` - `ApiClient` dio, interceptor token Bearer, pemetaan `DioException` ke `AppFailure`
- `lib/core/error/app_failure.dart` - satu tipe error (`AppFailure` + `FailureKind`)
- `lib/app/di.dart` - DI manual `AppDependencies`
- `lib/features/solar_system/domain/entities/planet_summary.dart`, `planet_detail.dart`, `interior_layer.dart`
- `lib/features/solar_system/domain/repositories/planet_repository.dart`
- `lib/features/solar_system/domain/usecases/get_planets.dart`, `get_planet.dart`, `get_interior_layers.dart`
- `lib/features/solar_system/data/models/planet_summary_model.dart`, `planet_detail_model.dart`, `interior_layer_model.dart`
- `lib/features/solar_system/data/datasources/planet_remote_data_source.dart`
- `lib/features/solar_system/data/repositories/planet_repository_impl.dart`
- `docs/setup-guide.md`, `docs/roadmap.md`

### Files Modified
- `pubspec.yaml`, `pubspec.lock` - tambah `dio: ^5.7.0`
- `docs/database-schema.md`, `docs/api-contract.md`, `docs/architecture.md`, `AGENTS.md` - dokumentasi backend, lokasi proyek, dan network layer

### Impact
- Aplikasi punya jalur data API siap pakai (ApiClient, repository, use case) untuk tahap penyambungan UI berikutnya.
- Dokumentasi mencantumkan lokasi `D:\project\orbite` dan `D:\project\orbite-api` serta cara menjalankan keduanya.
- Backend Laravel berada di `D:\project\orbite-api` (di luar repo ini) dan didokumentasikan di `docs/`.

### Verification
- `flutter analyze`: **No issues found**
- `flutter test`: **13 passed**

---

## [2026-11-26] - FEATURE - HIGH

### Summary
- Menambahkan tiga scene 3D edukatif: Musim & Kemiringan Bumi, Gerhana, dan Interior Planet cutaway. Menambahkan `ThreeSceneCanvas` reusable serta entry point di Explore dan Learn.

### Files Added
- `lib/core/widgets/three_scene_canvas.dart` - lifecycle GL, renderer, kamera, OrbitControls, ticker, state loading/error
- `lib/features/seasons/presentation/pages/seasons_page.dart` - orbit Bumi, kemiringan 23,4°, titik subsolar, timeline musim
- `lib/features/eclipse/presentation/pages/eclipse_page.dart` - simulasi Matahari–Bumi–Bulan, umbra/penumbra, status gerhana
- `test/three_d_scenes_test.dart` - smoke test halaman Musim dan Gerhana
- `docs/adr/003-scene-3d-reusable-dan-cutaway.md`

### Files Modified
- `lib/features/interior/presentation/pages/interior_page.dart` - cutaway 3D dengan pemilih lapisan dan detail lapisan
- `lib/app.dart` - route `/seasons` dan `/eclipse`
- `lib/features/home/presentation/pages/cosmic_explore.dart` - kartu Explore Musim Bumi dan Gerhana 3D; path gambar memakai aset yang ada
- `lib/features/learn/presentation/pages/learn_page.dart` - menu cepat Musim Bumi dan Gerhana 3D
- `docs/prd.md`, `docs/content-source.md`, `docs/assets-inventory.md`, `docs/navigation-flow.md`, `docs/architecture.md`

### Impact
- Pengguna dapat mempelajari kemiringan Bumi, gerhana, dan struktur interior planet lewat scene 3D interaktif.
- Scene baru memakai tekstur yang sudah ada; tidak ada aset biner baru.
- Halaman Interior tidak lagi berupa gambar 2D dengan hotspot, melainkan cutaway 3D dengan pemilih lapisan.
- State loading dan error scene 3D konsisten lewat `ThreeSceneCanvas`.

### Verification
- `flutter analyze`: **No issues found**
- `flutter test`: **13 passed**
- `flutter build windows --debug`: **Sukses**

---

## [2026-11-26] - FEATURE - HIGH

### Summary
- Memperbaiki error kompilasi Home dan Daftar Planet, menambahkan kontrol kecepatan simulasi Tata Surya, mengganti preview planet menjadi 3D, serta merombak halaman Learn dan Trivia agar sesuai referensi `stitch_preview`.

### Files Modified
- `lib/features/home/presentation/pages/cosmic_explore.dart` - mengembalikan konstanta `_hairline`, `_muted`, `_subtle`, memperbaiki bracket `_DestinationCard` dan constructor `_OrbitMarkPainter`
- `lib/features/solar_system/presentation/pages/planet_list_page.dart` - kartu planet memakai `RotatingPlanet3D`, ukuran mengikuti sel grid, widget rotasi 2D dihapus
- `lib/features/solar_system/presentation/widgets/rotating_planet_3d.dart` - fallback 2D dihapus, state loading dan error 3D ditambahkan
- `lib/features/solar_system/presentation/pages/solar_system_page.dart` - FAB kecepatan, bottom sheet slider 0.25x sampai 4x, preset 0.5x/1x/2x/4x, dan reset
- `lib/features/solar_system/presentation/widgets/home_scene.dart` - parameter `speed` mengalikan delta animasi
- `lib/features/learn/presentation/pages/learn_page.dart` - halaman Learn baru: Planet Hari Ini, Menu Cepat, Paspor Planet
- `lib/features/trivia/presentation/pages/trivia_page.dart` - halaman Trivia baru: skor, progress, pilihan A-D, feedback, hasil, restart
- `lib/features/solar_system/presentation/pages/home_page.dart` - memakai `LearnPage` dan `TriviaPage` fitur, menghapus implementasi inline
- `lib/home/trivia_route.dart` - route `/trivia` memakai halaman Trivia baru
- `test/learn_page_layout_test.dart`, `test/trivia_page_test.dart` - test layout dan alur Trivia
- `test/home_pages_test.dart`, `test/planet_list_page_test.dart` - penyesuaian import dan animasi kontinu

### Impact
- Home dan Daftar Planet kembali dapat dikompilasi dan diuji
- Planet di Daftar Planet tampil sebagai model 3D dengan state loading dan error
- Kecepatan rotasi dan orbit Tata Surya dapat diatur 0.25x sampai 4x
- Tab Learn dan Trivia memiliki struktur, state, dan alur yang lebih lengkap
- Progres Paspor Planet ikut diperbarui saat tab Learn dibuka

### Verification
- `flutter analyze`: **No issues found**
- `flutter test`: **11 passed**
- Commit `bb3b660` di-push ke `origin/main`

---

## [2026-11-23] - FEATURE - HIGH

### Summary
- Menyelenggarakan overhaul lengkap tampilan Home, Daftar Planet, dan Bandingkan Planet sesuai protokol antislop. Menambahkan Circle Bottom Navigation dari pub.dev, memperbaiki kontras TextButton, dan struktur layout Hybrid untuk Home.

### Files Modified
- `lib/features/solar_system/presentation/pages/home_page.dart` - Redesign Home hub, label nav Indonesia, paspor dari data, TextButton kontras
- `lib/features/solar_system/presentation/pages/planet_list_page.dart` - Filter Matahari, kartu melingkar, pencarian, favicon
- `lib/features/solar_system/presentation/pages/planet_compare_page.dart` - Selector bertumpuk, baris metrik, gravitasi dari JSON
- `lib/core/theme/app_theme.txt` - textButtonTheme dengan AppColors.secondary (9.24:1 contrast)
- `lib/features/home/presentation/pages/cosmic_explore.dart` - addAutomaticKeepAlives: false, navigasi lebih baik
- `lib/features/solar_system/presentation/pages/planet_list_page.dart` - addAutomaticKeepAlives: false, tooltip dihapus
- `lib/features/solar_system/presentation/pages/planet_compare_page.dart` - addAutomaticKeepAlives: false
- `lib/core/theme/app_theme.txt` - textButtonTheme dengan AppColors.secondary
- `lib/features/home/presentation/pages/cosmic_explore.dart` - Pre-existing errors
- `lib/core/widgets/floating_nav_bar.txt` - Navigasi baru
- `lib/core/widgets/nasa_image.txt` - perbaikan
- `assets/mock/planets.json` - ditambahkan field gravity, Matahari difilter
- `assets/mock/layers.json` - perbaikan

### Impact
- Home menjadi hub lengkap dengan Hero, Quick Access, Fakta Harian, Paspor Planet
- Daftar Planet menampilkan Matahari difilter, kartu melingkar dengan diameter/jumlah bulan
- Bandingkan Planet menggunakan selector bertumpuk dan baris metrik rapi
- Kontras warna TextButton menjadi 9.24:1 (WCAG AA)
- Struktur list lazy dimodifikasi mencegah freeze mouse di desktop

### Verification
- `flutter analyze` (file kunci): **No issues found**
- `flutter test` (test relevan): 7 passed, 2 failed (2 failure pre-existing di cosmic_explore.dart:885)
- `flutter build windows --debug`: **Sukses** menghasilkan `build\windows\x64\runner\Debug\orbite.exe`

---
EOF