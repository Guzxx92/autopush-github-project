### Auto Push & Release Script (GitHub)

Skrip Bash (`deploy.sh`) untuk mengotomatiskan proses *push* kode ke repositori GitHub, manajemen *tag* versi, hingga pembuatan GitHub Release secara langsung menggunakan Personal Access Token.

## Fitur Utama
* **Inisialisasi Otomatis**: Mengatur `git init`, *branch* (`main`), dan *remote origin* secara otomatis jika folder belum terhubung dengan Git.
* **Autentikasi Aman**: Meminta GitHub Token secara tersembunyi dan menggunakan variabel `GIT_ASKPASS` sementara yang langsung dihapus setelah skrip selesai dijalankan.
* **Sinkronisasi Repositori**: Melakukan `git pull --rebase` atau *merge* otomatis agar perubahan lokal tetap sinkron dengan *remote* tanpa konflik riwayat.
* **Overwrite Tag & Release**: Menghapus *tag* lokal, *tag* remote, dan GitHub Release lama jika menggunakan nomor versi yang sama, lalu menggantinya dengan yang baru.

## Prasyarat
* **Git** sudah terinstal di sistem.
* **GitHub CLI (`gh`)** *(Opsional)*: Diperlukan jika ingin skrip otomatis membuat halaman **GitHub Release** di repositori.
* **GitHub Personal Access Token**:
  * **Classic Token**: Centang izin `repo`.
  * **Fine-grained Token**: Berikan akses *Read and write* pada bagian **Contents**.

## Konfigurasi
Sebelum menjalankan skrip, sesuaikan variabel di bagian atas file `deploy.sh`:
```bash
BRANCH="main" #sesuai selera
REPO_URL="https://github.com/Guzxx92/Anby-MD.git"
```

## Cara Penggunaan

1. Simpan kode skrip dengan nama `deploy.sh` di dalam folder utama proyek.
2. Berikan izin eksekusi pada file:
   ```bash
   chmod +x deploy.sh
   ```
3. Jalankan skrip dengan menyertakan **nomor versi** (wajib) dan **pesan commit** (opsional):
   ```bash
   # Menggunakan pesan commit kustom
   bash deploy.sh v1.0.0 "Update fitur baru dan perbaikan bug"

   # Menggunakan pesan commit default
   bash deploy.sh v1.0.0
   ```
4. Masukkan **GitHub Token** saat diminta pada terminal (teks tidak akan muncul di layar demi keamanan), lalu tekan **Enter**.

## Alur Kerja Skrip
1. Memvalidasi argumen versi dan input token.
2. Membuat skrip kredensial sementara (`ASKPASS`) yang otomatis terhapus saat proses selesai (`trap`).
3. Menyiapkan konfigurasi Git lokal dan menghubungkannya ke `REPO_URL`.
4. Mengecek dan menghapus *tag* atau *release* lama dengan versi yang sama.
5. Melakukan `git add`, `git commit`, dan sinkronisasi dengan *branch* `main` di GitHub.
6. Mengunggah kode (*push*), membuat *tag* versi baru, dan menerbitkan GitHub Release.
