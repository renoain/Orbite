# Kontrak API

## Base URL: `http://localhost:8000/api/v1`

## 1. `GET /planets`

**Deskripsi**: Mengambil daftar semua planet.

**Response (200)**:

```json
{
  "data": [
    {
      "id": "42287733-c713-4609-9e7b-9ebd751ea1ec",
      "name": "Earth",
      "name_id": "Bumi",
      "order": 3,
      "description": "Satu-satunya planet yang diketahui memiliki kehidupan...",
      "fun_fact": "Bumi adalah planet terpadat di tata surya.",
      "image_url": "assets/textures/earth.jpg",
      "texture_url": "assets/textures/earth.jpg",
      "distance": 149.6,
      "diameter_km": 12756,
      "day_length_hours": 24,
      "orbital_period_days": 365,
      "moons": 1,
      "gravity": 1
    }
  ]
}
```

`image_url` berisi URL cloud penuh di produksi; saat dev berisi path aset lokal. `texture_url` khusus untuk tekstur scene 3D (dev).

## 2. `GET /planets/{id}`

**Deskripsi**: Mengambil detail satu planet berdasarkan UUID.

**Response (200)**:

```json
{
  "data": {
    "id": "42287733-c713-4609-9e7b-9ebd751ea1ec",
    "name": "Earth",
    "name_id": "Bumi",
    "order": 3,
    "description": "Satu-satunya planet yang diketahui memiliki kehidupan...",
    "atmosphere": "Satu-satunya planet yang diketahui memiliki kehidupan...",
    "surface_temp": "",
    "fun_fact": "Bumi adalah planet terpadat di tata surya.",
    "image_url": "assets/textures/earth.jpg",
    "texture_url": "assets/textures/earth.jpg",
    "distance": 149.6,
    "diameter_km": 12756,
    "day_length_hours": 24,
    "orbital_period_days": 365,
    "moons": 1,
    "gravity": 1
  }
}
```

## 3. `GET /planets/{id}/layers`

**Deskripsi**: Mengambil lapisan interior planet berdasarkan UUID planet.

**Response (200)**:

```json
{
  "data": [
    {
      "layer_name": "Crust",
      "depth_km": "0-70",
      "temperature_c": "-20 to 50",
      "composition": "Earth's crust varies from 5-70km thick...",
      "description": "Earth's crust varies from 5-70km thick...",
      "image_url": "assets/images/earth_crust.webp",
      "fun_fact": "Earth's crust is the outermost solid shell of our planet."
    }
  ]
}
```

## 4. `POST /login` (nanti)

**Deskripsi**: Autentikasi user.

**Request**:

```json
{ "email": "user@example.com", "password": "secret" }
```

**Response (200)**:

```json
{ "token": "sanctum-token-here" }
```

## Catatan
- Semua endpoint menggunakan format UUID untuk ID planet
- CORS perlu dikonfigurasi untuk akses dari Flutter (mobile/web)
- Format tanggal menggunakan ISO 8601