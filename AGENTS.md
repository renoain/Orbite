# AGENTS.md

Proyek **Orbite**: aplikasi Flutter dengan backend Laravel (REST API) dan MySQL.
Status: codebase masih kerangka. Dokumen di `docs/` adalah template yang wajib diisi sebelum fitur dibangun.

## Dokumen Proyek

| Dokumen | Isi | Kapan dibaca |
|---|---|---|
| `docs/prd.md` | Tujuan, target pengguna, fitur MVP, kriteria sukses | Sebelum menambah fitur |
| `docs/architecture.md` | Batas lapisan, alur data, teknologi | Sebelum menambah modul atau package |
| `docs/database-schema.md` | Tabel dan kolom | Sebelum menambah kolom atau tabel |
| `docs/api-contract.md` | Endpoint, request/response | Sebelum menambah atau mengubah endpoint |
| `docs/state-management.md` | Cubit/BLoC per fitur | Sebelum menambah state |
| `docs/navigation-flow.md` | Alur layar | Sebelum menambah route |
| `docs/design-systems.md` | Warna, tipografi, komponen | Sebelum menambah UI |
| `docs/error-handling.md` | Empat state, format error | Sebelum menambah layar yang ambil data |
| `docs/security.md` | Auth, rate limit, validasi, storage token | Sebelum menyentuh auth atau input |
| `docs/testing-strategy.md` | Unit, widget, integration test | Sebelum menutup fitur |
| `docs/content-source.md` | Sumber data NASA dan lisensi | Sebelum menambah konten |
| `docs/assets-inventory.md` | Aset dan lisensinya | Sebelum menambah aset |
| `docs/changelog.md` | Riwayat versi | Setelah rilis fitur |
| `docs/adr/` | Keputusan arsitektur | Sebelum keputusan besar |

## Aturan Kerja

- Flutter: kode di `lib/features/<nama_fitur>/` dengan lapisan `presentation`, `domain`, `data`.
- UI tidak boleh mengakses database langsung. Semua data lewat API Laravel.
- Layar yang mengambil data wajib punya state loading, empty, error, dan success.
- Tanggal gunakan format ISO (`YYYY-MM-DD`) di changelog.
- Placeholder ditulis apa adanya, misalnya `[isi di sini]`, jangan diisi dengan data karangan.
- Setiap keputusan besar ditulis sebagai ADR baru di `docs/adr/` dengan nomor berikutnya.

## Panduan Agent (`.agents/`)

- `rules/` aturan yang selalu berlaku, baca sebelum menyentuh kode:
  - `.agents/rules/flutter.md` (struktur, API, state, performa 3D)
  - `.agents/rules/laravel.md` (kontrak API, validasi, keamanan, database)
  - `.agents/rules/testing.md` (unit, widget, integration test)
  - `.agents/rules/docs.md` (cara mengisi dan memperbarui `docs/`)
- `skills/` skill kerja, panggil sesuai jenis tugas (katalog lengkap di `.agents/README.md`).
- `.agents/README.md` berisi katalog skill dan kapan dipakai.

## Verifikasi

Jalankan sebelum menyatakan pekerjaan selesai:

```bash
flutter analyze
flutter test
```

<!-- antislop:start -->
## antislop
For UI, copy, people, mobile layout, or code comments work, read `.agents/skills/antislop/SKILL.md` (core) and then the skill for the task:
- UI / visual: `.agents/skills/antislop-ui/SKILL.md`
- Copy & text: `.agents/skills/antislop-copywriting/SKILL.md`
- People: `.agents/skills/antislop-human/SKILL.md`
- Mobile / responsive: `.agents/skills/antislop-layoutmobile/SKILL.md`
- Code comments: `.agents/skills/antislop-code/SKILL.md`
Before starting, follow the core's "Two Usage Modes" section in strict order: explicit session instruction first, then global preference, then ask. A session instruction always wins. For a resolved mode, say `antislop active: <mode> (session override).` or `antislop active: <mode> (global preference).` once before presenting findings or making edits, using the actual mode and source. Acknowledging the user's request without naming the source does not replace this notice.
Only an explicit choice of antislop during or after selects a session mode. A request to review, audit, or avoid file edits does not select a mode; read the global preference in that case. Another skill's mode does not select an antislop mode.
If the mode is unresolved, ask during/after and end the response; wait for the answer before any UI review, planning, or concept. For read-only tasks, put the active-mode notice only at the start of the final answer, never in progress messages. For editing tasks, announce before the first edit and omit it from the final answer.
To update antislop later: download `antislop.md` again, or run `npx antislop-ai --update` if it was installed as skill folders.
<!-- antislop:end -->
