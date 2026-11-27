# Product Requirements Document (PRD)

## Nama Aplikasi: Orbite

## 1. Latar Belakang

[isi di sini: kenapa aplikasi ini dibuat? Misal: "Banyak aplikasi edukasi tata surya yang hanya berupa teks statis. Aplikasi ini menghadirkan visualisasi 3D interaktif agar pengguna dapat menjelajah tata surya secara imersif."]

## 2. Tujuan

- Menyediakan visualisasi tata surya 3D yang dapat diputar dan di-zoom.
- Menyajikan konten ilmiah dari NASA secara terstruktur.
- Memberikan pengalaman belajar yang interaktif melalui trivia.

## 3. Target Pengguna

[isi di sini: misal "Mahasiswa, pelajar, dan masyarakat umum yang tertarik pada astronomi."]

## 4. Fitur Utama (MVP)

- Onboarding (3 slide)
- Login (dummy dulu, auth nanti)
- Home: Tata surya 3D interaktif (rotasi, zoom, stop/play, fullscreen)
- Detail Planet: Gambar, deskripsi, atmosfer, suhu, fakta unik
- Interior Planet 3D: Cutaway lapisan dengan pemilih lapisan dan data kedalaman, suhu, serta komposisi
- Musim & Kemiringan Bumi 3D: Orbit Bumi, kemiringan 23,4°, titik subsolar, dan timeline solstis/ekuinoks
- Gerhana 3D: Simulasi Matahari–Bumi–Bulan, bayangan umbra/penumbra, dan status gerhana Matahari/Bulan
- Trivia: Pertanyaan pilihan ganda (validasi di Laravel)

## 5. Fitur di Luar MVP (Backlog)

- Auth asli (Sanctum)
- Progress user dan leaderboard
- Multiplayer (jika ada)
- Konten audio narasi

## 6. Kriteria Sukses

[isi di sini: misal "Aplikasi dapat menampilkan tata surya 3D tanpa lag di perangkat menengah, dan pengguna dapat menyelesaikan minimal 1 planet dengan trivia."]
