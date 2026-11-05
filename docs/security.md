# Rencana Keamanan

1. **Auth**: Laravel Sanctum (nanti).
2. **Rate Limiting**: Terapkan di endpoint login dan trivia.
3. **Validasi Input**: Gunakan `FormRequest` di Laravel.
4. **API Resource**: Jangan return model mentah; gunakan `Resource` untuk menyembunyikan field sensitif.
5. **Token Storage**: Simpan token di `flutter_secure_storage` (bukan `SharedPreferences`).
