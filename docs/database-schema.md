# Skema Database

## Database: `orbite_db`

## Tabel `planets`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | CHAR(36) / UUID | Primary key |
| name | VARCHAR(255) | Nama planet (Inggris) |
| name_id | VARCHAR(255) | Nama Indonesia untuk tampilan |
| description | TEXT | Deskripsi planet |
| fun_fact | TEXT | Fakta unik |
| image_url | VARCHAR(255) | URL gambar planet (URL cloud di produksi, path aset saat dev) |
| order | INT | Urutan dari Matahari |
| distance | DOUBLE | Jarak dari Matahari (juta km) |
| diameter_km | INT UNSIGNED | Diameter (km) |
| day_length_hours | DOUBLE | Lama hari (jam) |
| orbital_period_days | INT UNSIGNED | Periode orbit (hari) |
| moons | INT UNSIGNED | Jumlah bulan |
| gravity | DOUBLE | Gravitasi (x Bumi) |
| texture_url | VARCHAR(255) | Path tekstur lokal untuk scene 3D (dev) |
| created_at | TIMESTAMP | Waktu dibuat |
| updated_at | TIMESTAMP | Waktu diperbarui |

## Tabel `interior_layers`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | CHAR(36) / UUID | Primary key |
| planet_id | CHAR(36) | FK ke `planets.id` |
| layer_name | VARCHAR(255) | Nama lapisan (Kerak, Mantel, Inti) |
| description | TEXT | Deskripsi ilmiah |
| depth_km | VARCHAR(255) | Kedalaman |
| temperature_c | VARCHAR(255) | Suhu |
| image_url | VARCHAR(255) | URL gambar lapisan |
| fun_fact | TEXT | Fakta unik lapisan |
| created_at | TIMESTAMP | Waktu dibuat |
| updated_at | TIMESTAMP | Waktu diperbarui |

**Foreign Key**: `planet_id` → `planets.id` ON DELETE CASCADE

## Tabel `trivia`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | CHAR(36) / UUID | Primary key |
| planet_id | CHAR(36) | FK ke `planets.id` |
| question | TEXT | Pertanyaan |
| options | JSON | Array pilihan jawaban |
| correct_answer | CHAR(1) | Kunci jawaban |
| created_at | TIMESTAMP | Waktu dibuat |
| updated_at | TIMESTAMP | Waktu diperbarui |

**Foreign Key**: `planet_id` → `planets.id` ON DELETE CASCADE

## Tabel `users` (bawaan Laravel)

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | BIGINT UNSIGNED | Primary key, auto-increment |
| name | VARCHAR(255) | Nama pengguna |
| email | VARCHAR(255) | Email (unique) |
| email_verified_at | TIMESTAMP | Waktu verifikasi email |
| password | VARCHAR(255) | Password (hash) |
| remember_token | VARCHAR(100) | Token remember me |
| created_at | TIMESTAMP | Waktu dibuat |
| updated_at | TIMESTAMP | Waktu diperbarui |

## Tabel `user_progress`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | BIGINT UNSIGNED | Primary key, auto-increment |
| user_id | BIGINT UNSIGNED | FK ke `users.id` |
| planet_id | VARCHAR(255) | ID planet |
| is_completed | BOOLEAN | Status selesai |
| last_explored_at | DATETIME | Waktu terakhir dijelajahi |
| created_at | TIMESTAMP | Waktu dibuat |
| updated_at | TIMESTAMP | Waktu diperbarui |

**Foreign Key**: `user_id` → `users.id` ON DELETE CASCADE

## Tabel Bawaan Laravel
- `cache` - Cache data
- `cache_locks` - Cache lock
- `jobs` - Queue jobs
- `job_batches` - Batch jobs
- `failed_jobs` - Failed jobs
- `sessions` - Session data
- `password_reset_tokens` - Reset password