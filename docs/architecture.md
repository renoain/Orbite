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
