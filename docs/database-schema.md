# Skema Database

## Tabel `planets`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID | Primary key |
| name | VARCHAR(100) | Nama planet |
| order | INT | Urutan dari Matahari |
| orbit_radius | FLOAT | Radius orbit (untuk animasi) |
| orbit_speed | FLOAT | Kecepatan orbit (detik per putaran) |
| image_url | VARCHAR(255) | URL gambar planet |
| description_short | TEXT | Deskripsi singkat untuk card |
| atmosphere | TEXT | Komposisi atmosfer |
| surface_temp | VARCHAR(50) | Suhu permukaan |
| fun_fact | TEXT | Fakta unik |

## Tabel `interior_layers`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID | Primary key |
| planet_id | UUID | FK ke `planets.id` |
| layer_name | VARCHAR(100) | Nama lapisan (Kerak, Mantel, dan seterusnya) |
| depth_km | VARCHAR(50) | Kedalaman |
| temperature_c | VARCHAR(50) | Suhu |
| composition | TEXT | Komposisi |
| description | TEXT | Deskripsi ilmiah |

## Tabel `trivia`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID | Primary key |
| planet_id | UUID | FK ke `planets.id` |
| question | TEXT | Pertanyaan |
| option_a | VARCHAR(255) | Pilihan A |
| option_b | VARCHAR(255) | Pilihan B |
| option_c | VARCHAR(255) | Pilihan C |
| option_d | VARCHAR(255) | Pilihan D |
| correct_answer | CHAR(1) | Kunci jawaban (A/B/C/D) |

## Tabel `users` (untuk auth nanti)

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID | Primary key |
| name | VARCHAR(100) | Nama pengguna |
| email | VARCHAR(100) | Email (opsional) |
| password | VARCHAR(255) | Password (hash) |
