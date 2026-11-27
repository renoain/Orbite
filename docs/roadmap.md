# Roadmap Proyek Orbite

## Fase 1: Lokal (Sedang Dikerjakan)
- [x] Setup Laravel API dengan database MySQL
- [x] Membuat migrasi dan seeders untuk planets, interior_layers, trivia
- [x] Membuat API endpoints: GET /planets, GET /planets/{id}, GET /planets/{id}/layers
- [x] Setup Flutter project dengan arsitektur Clean Architecture
- [x] Membuat dokumentasi di docs/
- [ ] Uji coba API dengan Flutter

## Fase 2: Cloud Storage (Masa Depan)
- [ ] Integrasi Cloudinary untuk upload dan serving gambar planet
- [ ] Replace `assets/images/` URL dengan `Image.network()` ke Cloudinary
- [ ] Implementasi fitur user authentication dengan Laravel Sanctum
- [ ] Setup CI/CD pipeline

## Fase 3: Hosting & Deploy
- [ ] Deploy Laravel ke Laravel Vapor atau Forge
- [ ] Deploy Flutter ke Google Play Store & App Store
- [ ] Setup domain dan SSL certificate
- [ ] Monitoring dan analytics

## Fitur Masa Depan
- [ ] 3D Solar System dengan interaksi lengkap
- [ ] Fitur trivia dengan skor dan leaderboard
- [ ] User progress tracking
- [ ] Favorit planet
- [ ] Dark mode support
- [ ] Multi-language support (i18n)