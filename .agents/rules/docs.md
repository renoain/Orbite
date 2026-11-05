# Aturan Dokumentasi (Orbite)

## Isi docs/ sebagai template

- Semua file di `docs/` masih kerangka. Isi bagian bertanda `[isi di sini]` sebelum fitur yang bergantung padanya dibangun.
- Placeholder ditulis apa adanya. Jangan mengarang data untuk mengisi tabel.
- Angka, fakta, dan statistik harus punya sumber nyata (lihat `docs/content-source.md`).

## Format

- Tanggal di changelog memakai ISO `YYYY-MM-DD`.
- Versi memakai semver, contoh `0.1.0`.
- Nama file ADR: `docs/adr/NNN-judul-singkat.md`, nomor berikutnya dari yang terakhir.
- Judul ADR memakai format: `# ADR NNN: Judul Keputusan`.

## Kapan dokumentasi berubah

| Perubahan | Dokumen yang diperbarui |
|---|---|
| Fitur baru atau scope berubah | `docs/prd.md` |
| Tabel atau kolom baru | `docs/database-schema.md` |
| Endpoint baru atau berubah | `docs/api-contract.md` |
| Cubit atau state baru | `docs/state-management.md` |
| Layar atau route baru | `docs/navigation-flow.md` |
| Token warna, font, komponen | `docs/design-systems.md` |
| Pola error baru | `docs/error-handling.md` |
| Keputusan besar | ADR baru di `docs/adr/` |
| Rilis fitur | `docs/changelog.md` |

## Catatan

- Buka dokumen yang relevan di `AGENTS.md` sebelum mengubah hal yang tercantum di tabel di atas.
