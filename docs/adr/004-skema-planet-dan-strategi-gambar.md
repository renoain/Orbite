# ADR 004: Skema Data Planet dan Strategi Gambar (Cloud Storage)

## Konteks

- UI Flutter membutuhkan data teknis per planet: `distance`, `diameter`, `dayLength`, `orbitalPeriod`, `moons`, `gravity`, dan `texture` (lihat `assets/mock/planets.json` dan `planet_compare_page.dart`).
- API awal hanya menyediakan `name` (Inggris), `order`, `description`, `fun_fact`, dan `image_url`, sehingga integrasi penuh belum mungkin.
- Nama tampilan di UI berbahasa Indonesia (mis. "Bumi"), sedangkan `name` di API berbahasa Inggris ("Earth").
- Gambar planet akan dipindah ke cloud storage (Cloudinary/Laravel storage) pada fase berikutnya (lihat `docs/roadmap.md` Fase 2).

## Keputusan

1. Perluas tabel `planets` dengan kolom: `name_id`, `distance`, `diameter_km`, `day_length_hours`, `orbital_period_days`, `moons`, `gravity`, `texture_url`.
2. Pisahkan peran gambar:
   - `image_url` = gambar produksi; nanti berisi **URL cloud penuh**.
   - `texture_url` = path aset lokal untuk tekstur scene 3D saat development.
3. Seeder idempoten memakai `updateOrCreate` berdasarkan `order` agar tidak menduplikasi baris dan tidak memutus foreign key `interior_layers`.
4. Endpoint `GET /planets` dan `GET /planets/{id}` mengembalikan seluruh field di atas.
5. Entity Flutter `PlanetSummary` dan `PlanetDetail` memuat field tersebut; `displayName` memakai `name_id` bila tersedia.
6. Strategi gambar dev/produksi: dev memakai `Image.asset` (path lokal), produksi memakai `cached_network_image`/`Image.network` dari URL cloud; pemilihan berdasarkan prefix `http`.

## Konsekuensi

- **Positif**:
  - UI dapat mengambil data lengkap langsung dari API.
  - Migrasi ke cloud cukup mengganti nilai `image_url`; skema tidak berubah lagi.
  - Nama Indonesia tetap terjaga lewat `name_id`.
- **Negatif**:
  - Ada duplikasi nama (`name` dan `name_id`).
  - Field teknis masih diisi manual di seeder sampai ada sumber data resmi.
  - `texture_url` tetap aset lokal; belum ikut cloud.
- **Tindak lanjut**:
  - Ganti `image_url` ke URL cloud saat proses upload siap.
  - Tambahkan validasi field di API dan pengisian dari sumber NASA terverifikasi.
  - Sinkronkan `docs/database-schema.md` dan `docs/api-contract.md` setiap kali kolom berubah.

## Pembaruan (2026-11-27): Cloudinary + Upload Manual

Keputusan penyedia gambar: **Cloudinary**, dengan **upload manual sekali** (tanpa SDK/API key di aplikasi).

- `config/orbite.php` menyimpan `image_cdn_base` dari env `IMAGE_CDN_BASE`.
- `App\Support\ImageUrl::resolve($publicId, $fallback)` membangun URL cloud; bila `IMAGE_CDN_BASE` kosong, kembali ke aset lokal.
- `PlanetSeeder` dan `InteriorLayerSeeder` memakai `image_id` (public ID Cloudinary) + fallback lokal, dan idempoten (`updateOrCreate`).
- `texture_url` tetap aset lokal untuk scene 3D.
- Public ID yang dipakai: `orbite/planets/<slug>` dan `orbite/interior/earth_crust`, `orbite/interior/mars_interior` (lapisan lain menyusul).
- Tanpa kredensial di repo; hanya URL publik. Ganti penyedia nanti cukup re-upload + update `IMAGE_CDN_BASE`/public ID, tanpa ubah skema.
