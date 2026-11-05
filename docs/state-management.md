# State Management

## Pola: BLoC/Cubit

- **SolarSystemCubit**: Mengelola state animasi (playing/paused), planet yang dipilih.
- **PlanetDetailCubit**: Mengelola state loading/error/success data planet.
- **InteriorCubit**: Mengelola state hotspot yang dipilih.

## Alur Data

User Tap → Cubit Event → UseCase → Repository → API → State → UI.
