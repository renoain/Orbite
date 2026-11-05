# Kontrak API

## Base URL: `/api/v1`

### 1. `GET /planets`

**Deskripsi**: Mengambil daftar planet.

**Response (200)**:

```json
{
  "data": [
    {
      "id": "uuid-1",
      "name": "Earth",
      "order": 3,
      "image_url": "https://.../earth.webp",
      "description_short": "Planet biru dengan kehidupan."
    }
  ]
}
```

### 2. `GET /planets/{id}`

**Deskripsi**: Mengambil detail planet.

**Response (200)**:

```json
{
  "data": {
    "id": "uuid-1",
    "name": "Earth",
    "description": "Bumi adalah...",
    "atmosphere": "78% nitrogen, 21% oksigen...",
    "surface_temp": "15°C (rata-rata)",
    "fun_fact": "Satu-satunya planet yang diketahui memiliki air cair."
  }
}
```

### 3. `GET /planets/{id}/interior`

**Deskripsi**: Mengambil lapisan interior planet.

**Response (200)**:

```json
{
  "data": [
    {
      "layer_name": "Crust",
      "depth_km": "8-40",
      "temperature_c": "0-400",
      "composition": "Batuan silikat",
      "description": "Lapisan terluar tempat kita hidup."
    }
  ]
}
```

### 4. `POST /login` (nanti)

**Deskripsi**: Autentikasi user.

**Request**:

```json
{ "email": "user@example.com", "password": "secret" }
```

**Response (200)**:

```json
{ "token": "sanctum-token-here" }
```
