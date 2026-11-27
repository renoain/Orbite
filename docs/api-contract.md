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
      "order": 3,
      "description": "The only known planet to support life...",
      "fun_fact": "Earth is the only planet not named after a Roman god.",
      "image_url": "assets/images/earth.webp"
    }
  ]
}
```

## 2. `GET /planets/{id}`

**Deskripsi**: Mengambil detail satu planet berdasarkan UUID.

**Response (200)**:

```json
{
  "data": {
    "id": "42287733-c713-4609-9e7b-9ebd751ea1ec",
    "name": "Earth",
    "description": "The only known planet to support life...",
    "atmosphere": "The only known planet to support life...",
    "surface_temp": "",
    "fun_fact": "Earth is the only planet not named after a Roman god."
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