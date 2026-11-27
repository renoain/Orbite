# Arsitektur Aplikasi

## 1. Gambaran Umum

Aplikasi ini menggunakan arsitektur **client-server**:

- **Frontend**: Flutter (dengan `three_dart` untuk rendering 3D)
- **Backend**: Laravel (REST API)
- **Database**: MySQL

## 2. Prinsip Arsitektur

- **Separation of Concerns**: UI (Flutter) tidak boleh mengakses database langsung. Semua data melalui API Laravel.
- **Feature-First**: Kode Flutter diorganisir berdasarkan fitur (`features/solar_system/`, `features/planet_detail/`, dan seterusnya).
- **Clean Architecture**: Lapisan `presentation`, `domain`, `data` dipisahkan.

## 3. Alur Data (UDF)

User Tap → Event → UseCase → Repository → API Laravel → Response → State → UI

## 4. Teknologi

- Flutter: `three_dart`, `flutter_gl`, `cached_network_image`, `dio`
- Laravel: `sanctum`, `api-resource`, `rate-limiting`
- MySQL: tabel `planets`, `interior_layers`, `trivia`, `users`

## 5. Diagram

[isi di sini: bisa berupa gambar diagram arsitektur]

## 6. Struktur Folder `lib/` (Feature-First + Clean Architecture)

Struktur ini mengikuti prinsip **Separation of Concerns** dan **Dependency Rule** (PDF halaman 4): dependensi hanya boleh mengarah ke dalam (`presentation` → `domain` ← `data`).

```
lib/
├── core/                          # Kode yang dipakai bersama
│   ├── errors/                    # Custom exception & failure
│   ├── network/                   # Dio client, interceptors, API config
│   ├── utils/                     # Helper, formatter, constants
│   └── di/                        # Dependency Injection (get_it / riverpod)
│
├── features/
│   ├── onboarding/                # Fitur onboarding (3 slide)
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── auth/                      # Fitur login (dummy dulu, Sanctum nanti)
│   │   ├── data/
│   │   │   ├── datasources/       # API datasource (dummy/real)
│   │   │   ├── models/            # DTO (UserModel)
│   │   │   └── repositories/      # Implementasi AuthRepository
│   │   ├── domain/
│   │   │   ├── entities/          # User entity (murni, tanpa framework)
│   │   │   ├── repositories/      # Abstract AuthRepository
│   │   │   └── usecases/          # LoginUseCase
│   │   └── presentation/
│   │       ├── bloc/              # AuthCubit / AuthBloc
│   │       ├── pages/             # LoginPage
│   │       └── widgets/           # LoginForm
│   │
│   ├── solar_system/              # Fitur utama: tata surya 3D
│   │   ├── data/
│   │   │   ├── datasources/       # API datasource (planet)
│   │   │   ├── models/            # PlanetModel (fromJson/toJson)
│   │   │   └── repositories/      # Implementasi PlanetRepository
│   │   ├── domain/
│   │   │   ├── entities/          # Planet entity
│   │   │   ├── repositories/      # Abstract PlanetRepository
│   │   │   └── usecases/          # GetPlanetsUseCase
│   │   └── presentation/
│   │       ├── bloc/              # SolarSystemCubit (animasi play/pause)
│   │       ├── pages/             # SolarSystemPage (three_dart scene)
│   │       └── widgets/           # PlanetCard, ControlButtons
│   │
│   ├── planet_focus/             # Fitur fokus planet (Focus Mode)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│
│   ├── planet_detail/             # Fitur detail planet
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── interior/                  # Fitur interior planet (cross-section)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── trivia/                    # Fitur trivia
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── app.dart                       # MaterialApp, routing, theme
└── main.dart                      # Entry point
```

### 🔒 Aturan Dependensi (Sesuai PDF Halaman 4)
- `presentation` hanya boleh bergantung pada `domain` (bukan `data`).
- `data` bergantung pada `domain` (untuk mengimplementasikan repository interface).
- `domain` **tidak boleh** bergantung pada Flutter, Laravel, atau package eksternal. Ini adalah lapisan aturan bisnis murni.
- `core` boleh dipakai oleh semua lapisan, tapi tidak boleh bergantung pada `features`.

### 📌 Catatan untuk OpenCode
Saat membuat file baru, letakkan sesuai struktur di atas. Jangan menaruh logika API di `presentation/`. Jangan menaruh widget Flutter di `domain/`.

## 7. Scene 3D Reusable

Scene 3D baru memakai `ThreeSceneCanvas` di `lib/core/widgets/three_scene_canvas.dart`.

- `ThreeSceneCanvas` menangani `FlutterGlPlugin`, `WebGLRenderer`, kamera, `OrbitControls`, ticker render, serta state loading dan error.
- Halaman fitur hanya menyediakan `setup` (membangun objek scene) dan `onTick` (memperbarui simulasi).
- `ThreeSceneController` memberi akses terbatas untuk render sekali dan mengatur posisi kamera.
- `core` tidak mengimpor `features`; opsi renderer dibuat langsung di canvas.

Fitur 3D yang memakai canvas ini:

- `features/seasons/` — Musim & Kemiringan Bumi.
- `features/eclipse/` — Gerhana Matahari/Bulan.
- `features/interior/` — Interior planet cutaway.

## 8. Catatan Implementasi 3D

- Cutaway interior memakai setengah bola (`SphereGeometry` dengan `phiLength = π`) dan cakram lapisan, bukan clipping plane, karena dukungan clipping di `three_dart` belum terbukti lengkap.
- Ketebalan lapisan disederhanakan; data ilmiah tetap mengacu ke NASA.
- Scene gerhana memakai model ideal dengan orbit Bulan sejajar bidang ekliptika; keterbatasan ini ditampilkan di layar.
- Semua scene memakai tekstur yang sudah ada; tidak ada aset biner baru.
- Starfield memakai `Float32Array` dari `flutter_gl`.

## 9. Network Layer (Flutter ↔ Laravel API)

Lapisan jaringan disiapkan sebelum penyambungan UI. UI belum diubah pada tahap ini.

- `lib/core/api/api_config.dart` — base URL dari `--dart-define=API_BASE_URL`, default `http://localhost:8000/api/v1`.
- `lib/core/api/api_client.dart` — `ApiClient` berbasis `dio`; menyisipkan token Bearer lewat interceptor; memetakan `DioException` ke `AppFailure`.
- `lib/core/error/app_failure.dart` — satu tipe error (`AppFailure` + `FailureKind`) untuk seluruh lapisan data.
- Fitur `solar_system` menjadi pemilik data planet:
  - `domain/entities/` — `PlanetSummary`, `PlanetDetail`, `InteriorLayer` (nama dibedakan dari entity 3D `Planet` yang berisi `BaseMesh`).
  - `domain/repositories/planet_repository.dart` — antarmuka repository.
  - `domain/usecases/` — `GetPlanets`, `GetPlanet`, `GetInteriorLayers`.
  - `data/models/` — model `fromJson`/`toJson` manual.
  - `data/datasources/planet_remote_data_source.dart` — panggilan endpoint `/planets`, `/planets/{id}`, `/planets/{id}/layers`.
  - `data/repositories/planet_repository_impl.dart` — implementasi repository.
- `lib/app/di.dart` — `AppDependencies` (DI manual) menyediakan `ApiClient`, repository, dan use case.

Catatan model data: API mengembalikan `name` (Inggris) dan belum memuat field teknis (`distance`, `diameter`, `day_length`, `orbital_period`, `moons`, `texture`). Field tersebut masih berasal dari mock lokal sampai skema database diperluas.
