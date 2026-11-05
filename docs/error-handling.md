# Penanganan Error dan Empat State

## 1. State di Flutter

Setiap layar yang mengambil data dari API wajib memiliki 4 state:

- **Loading**: Tampilkan `CircularProgressIndicator` atau skeleton.
- **Empty**: Tampilkan ilustrasi + teks "Belum ada data".
- **Error**: Tampilkan pesan error + tombol "Coba Lagi".
- **Success**: Tampilkan konten.

## 2. Error di Laravel

- Gunakan `try-catch` di Service Layer.
- Return JSON dengan format:

```json
{ "error": "Pesan error", "code": 500 }
```

- Gunakan HTTP status code yang sesuai (400, 404, 500).
