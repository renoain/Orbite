# Peta Kode `lib/`

Folder ini masih kerangka. Belum ada implementasi fitur; yang ada sekarang adalah struktur folder dan rencana file. `lib/main.dart` masih aplikasi counter bawaan Flutter dan akan diganti saat fitur pertama dibangun.

Aturan lengkap ada di `.agents/rules/flutter.md`.

## Struktur target

```
lib/
  main.dart                          # entrypoint, hanya memanggil runApp
  app/
    orbite_app.dart                  # root widget, MaterialApp.router
    router.dart                      # go_router, route per fitur
    theme.dart                       # ThemeData dari docs/design-systems.md
  core/
    api/
      api_client.dart                # instance dio + interceptor token
      api_exception.dart             # mapping error HTTP ke AppFailure
      endpoints.dart                 # konstanta path /api/v1
    error/
      app_failure.dart               # sealed class: Network, Unauthorized, Server, Unknown
    storage/
      secure_token_store.dart        # token via flutter_secure_storage
  features/
    onboarding/
      presentation/onboarding_page.dart, onboarding_cubit.dart
      domain/entities/onboarding_slide.dart
      data/ (kosong selama data statis, nanti dipakai untuk slide dari API)
    auth/
      presentation/login_page.dart, login_cubit.dart
      domain/entities/user_session.dart, usecases/login.dart
      data/models/login_request.dart, login_response.dart, auth_repository_impl.dart, auth_data_source.dart
    solar_system/
      presentation/solar_system_page.dart, solar_system_cubit.dart, widgets/planet_orb.dart
      domain/entities/planet.dart, usecases/get_planets.dart
      data/models/planet_model.dart, planets_api_data_source.dart, planets_repository_impl.dart
    planet_detail/
      presentation/planet_detail_page.dart, planet_detail_cubit.dart
      domain/entities/planet_detail.dart, usecases/get_planet_detail.dart
      data/models/planet_detail_model.dart, planet_detail_api_data_source.dart, planet_detail_repository_impl.dart
    planet_interior/
      presentation/planet_interior_page.dart, planet_interior_cubit.dart, widgets/interior_hotspot.dart
      domain/entities/interior_layer.dart, usecases/get_interior_layers.dart
      data/models/interior_layer_model.dart, interior_api_data_source.dart, interior_repository_impl.dart
    trivia/
      presentation/trivia_page.dart, trivia_cubit.dart
      domain/entities/trivia_question.dart, usecases/submit_answer.dart
      data/models/trivia_model.dart, trivia_api_data_source.dart, trivia_repository_impl.dart
```

## Aturan lapisan

- `presentation` hanya boleh memanggil use case, bukan data source.
- `domain` tidak boleh import `dio`, `http`, atau `flutter/material.dart`.
- `data` menerjemahkan JSON API menjadi entity domain.
- Tiap layar yang mengambil data punya state loading, empty, error, dan success.

## Urutan pengerjaan yang disarankan

1. `core/api` + `core/error` + `core/storage`, lalu `app/theme` dan `app/router`.
2. `features/auth` dengan login dummy, lalu `features/onboarding`.
3. `features/solar_system` dengan data planet dari API, lalu `planet_detail`.
4. `features/planet_interior` dengan hotspot, lalu `features/trivia`.
