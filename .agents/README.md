# .agents: Panduan Kerja untuk Orbite

Folder ini berisi panduan yang dipakai AI agent (OpenCode, Claude Code, dan sejenisnya) saat mengerjakan proyek.

```
.agents/
  rules/     # aturan project yang selalu berlaku
  skills/    # skill kerja, dipanggil saat mengerjakan tugas tertentu
```

## Rules (wajib dibaca)

| File | Isi |
|---|---|
| `rules/flutter.md` | Struktur folder, lapisan, API client, state, performa 3D, gate verifikasi |
| `rules/laravel.md` | Kontrak API, validasi, keamanan, database, error handling backend |
| `rules/testing.md` | Unit, widget, integration test dan syarat lulus |
| `rules/docs.md` | Cara mengisi dan memperbarui dokumen di `docs/` |

## Katalog skill

### Flutter dan Dart

| Skill | Dipakai saat |
|---|---|
| `flutter-apply-architecture-best-practices` | Menata lapisan UI, logika, data |
| `flutter-build-responsive-layout` | Layout harus adapts di berbagai ukuran layar |
| `flutter-fix-layout-issues` | Error overflow atau unbounded constraints |
| `flutter-add-widget-test` | Menulis test komponen dan interaksi |
| `flutter-add-integration-test` | Alur aplikasi end to end |
| `flutter-add-widget-preview` | Preview interaktif untuk komponen baru |
| `flutter-implement-json-serialization` | Model dengan `fromJson`/`toJson` |
| `flutter-setup-declarative-routing` | Routing berbasis URL (go_router) |
| `flutter-setup-localization` | `flutter_localizations`, `intl`, `l10n.yaml` |
| `flutter-use-http-package` | Permintaan REST dari Flutter |
| `dart-add-unit-test` | Unit test fungsi, method, class |
| `dart-run-static-analysis` | `dart analyze` dan `dart fix --apply` |
| `dart-resolve-package-conflicts` | `pub get` gagal karena versi bentrok |
| `dart-use-pattern-matching` | Parsing JSON dan switch idiomatis |
| `dart-use-primary-constructors` | Constructor syntax Dart modern |
| `dart-use-path-package` | Manipulasi path lintas platform |
| `dart-write-documentation` | Doc comment Dart |
| `dart-collect-coverage` | Coverage report dan LCOV |
| `dart-generate-test-mocks` | Mock objek dengan mockito dan build_runner |

### Kualitas UI (antislop)

| Skill | Dipakai saat |
|---|---|
| `antislop` | Filter inti, selalu dibaca sebelum kerja UI |
| `antislop-ui` | Warna, layout, komponen, motion, performa halaman |
| `antislop-copywriting` | Copy aplikasi: judul, CTA, tone |
| `antislop-human` | Kontras, fokus keyboard, ukuran target sentuh |
| `antislop-layoutmobile` | Layout phone ke desktop tanpa overflow |
| `antislop-code` | Kebersihan komentar kode |

### Alur kerja engineering

| Skill | Dipakai saat |
|---|---|
| `implement` | Menjalankan pekerjaan dari spec atau ticket |
| `implement-spec` | Menjalankan hasil spec yang sudah dipecah jadi ticket |
| `lean-build` | Feature baru dengan risiko overbuilding tinggi |
| `tdd` | Bangun fitur atau perbaiki bug dengan test lebih dulu |
| `diagnosing-bugs` | Bug sulit atau error yang belum jelas penyebabnya |
| `investigate-first` | Diagnosis sebelum menyentuh kode |
| `dart-fix-runtime-errors` | Error runtime aktif dengan stack trace |
| `surgical-patch` | Perbaikan bug di lapisan paling sempit |
| `safe-refactor` | Refactor tanpa mengubah perilaku |
| `verify-and-stop` | Bukti bahwa pekerjaan memenuhi syarat, tanpa perluas scope |
| `code-review` | Review perubahan terhadap standar project dan spec |
| `research` | Riset sumber primer, hasilnya ditulis ke repo |
| `domain-modeling` | Istilah domain, glossary, ADR |
| `codebase-design` | Desain antarmuka modul dan titik pemisahan |
| `migration` | Perubahan skema, data, API, atau konfigurasi yang bisa dibalik |
| `prototype` | Uji coba sekali pakai untuk menjawab pertanyaan desain |
| `writing-for-agents` | Menulis aturan dan dokumen untuk agent |
| `retro` | Retrospektif sesi kerja |
| `handoff` | Serah terima ke agent lain |
| `ask-matt` | Memilih skill atau alur yang tepat |

## Skill yang tidak ikut

Skill khusus TypeScript/Node, CLI Dart, FFI, backend cloud, dan variant penulisan tidak relevan untuk Orbite (Flutter + Laravel), jadi tidak disalin.
