# Alur Navigasi

1. **Onboarding** (3 slide) → Tombol "Mulai" → Login.
2. **Login** (dummy dulu) → Tombol "Masuk" → Home.
3. **Home** (Tata Surya 3D) → Klik Planet → Detail Planet.
4. **Detail Planet** → Tombol "Lihat Interior" → Interior.
5. **Interior** → Klik Hotspot → Bottom Sheet Info.
6. **Trivia** (dari Detail/Interior) → Jawab → Skor (nanti).

## Navigasi

### 1.1 Dua Mode Navigasi

- **Overview Mode**: Menampilkan tata surya 3D (model dari `three_dart`). Pengguna dapat memutar, zoom, dan mengklik planet.
- **Focus Mode**: Setelah planet diklik, masuk ke mode fokus pada planet tersebut.

### 1.2 Transisi Overview → Focus

- Gunakan animasi **Hero** dari planet yang diklik menuju halaman Focus.
- Saat transisi, tampilkan **loading popup** singkat (0.5-1 detik) sambil memuat data planet dari API.
- Setelah data siap, tampilkan **layer permukaan planet** sebagai titik awal Focus Mode.

### 1.3 Gesture di Focus Mode

- **Scroll Vertikal (Atas/Bawah)**:
  - **Ke Bawah**: Menembus permukaan → kerak → mantel → inti planet. Setiap layer menampilkan gambar irisan (cross-section) dengan hotspot.
  - **Ke Atas**: Permukaan → atmosfer → luar angkasa (Bulan, planet lain).
  - **Aturan**: Scroll vertikal harus **seamless** (tanpa loading popup). Pre-load gambar layer berikutnya menggunakan `precacheImage`.

- **Swipe Horizontal (Kiri/Kanan)**:
  - Hanya aktif saat berada di **layer permukaan planet**.
  - Berfungsi untuk berpindah ke planet lain (Mars, Jupiter, dll.).
  - Saat berpindah, tampilkan **loading popup** singkat (karena memuat aset planet baru).

- **Info Card**:
  - Muncul di sisi kiri/kanan layar (bukan menutupi planet).
  - Berisi teks ilmiah, trivia, dan tombol "Lihat Detail".
  - Card muncul dengan animasi *slide* dari samping.

### 1.4 Minimap Navigasi (VerticalMiniMap)

- Widget garis vertikal di sisi kanan layar.
- Menampilkan titik-titik layer (Inti Bumi, Kerak, Permukaan, Atmosfer, Bulan, Luar Angkasa).
- **Fungsi**:
  - Menunjukkan posisi layer saat ini (titik aktif).
  - Memungkinkan tap/geser ke titik tertentu untuk lompat ke layer tersebut (tanpa scroll manual).
- **UX**: Minimap harus selalu terlihat di Focus Mode, dengan opasitas rendah agar tidak mengganggu visual planet.

### 1.5 State Loading

- **Loading popup** hanya digunakan saat:
  1. Pertama kali aplikasi dibuka (splash screen).
  2. Berpindah planet (swipe horizontal).
  3. Memuat trivia dari API.
- **Tidak ada loading popup** saat scroll vertikal antar layer (harus seamless).

## Tombol Kembali

- Setiap layar punya tombol "Kembali" di pojok kiri atas.
