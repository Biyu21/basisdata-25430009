# Dokumen Kebutuhan Data - Perpustakaan AHD

## 1. Latar Belakang dan Aktivitas Organisasi

Perpustakaan AHD merupakan organisasi fiktif yang menyediakan layanan
pengelolaan anggota, koleksi buku, peminjaman, pengembalian, dan denda.
Sistem basis data digunakan untuk menyimpan dan mengelola data perpustakaan
secara terstruktur sehingga proses pelayanan dapat dilakukan dengan lebih
teratur dan informasi dapat digunakan untuk kebutuhan operasional.

Aktivitas utama Perpustakaan AHD meliputi pengelolaan data anggota,
pengelolaan data buku dan eksemplar, proses peminjaman buku, proses
pengembalian buku, serta pengelolaan denda akibat keterlambatan pengembalian.

### Parameter Proyek

NPM: `25430009`

Dua digit terakhir NPM: `09`

Perhitungan parameter:

`P = (09 mod 9) + 1 = 1`

Dengan demikian:

- Maksimal item per transaksi = `P + 2 = 3` item.
- Denda harian = `P = Rp1.000` per hari per buku.
- Perkiraan volume transaksi harian = `40 + (5 × P) = 45` transaksi per hari.

---

## 2. Aktor dan Proses Bisnis

### Aktor

| Aktor | Peran |
|---|---|
| Petugas Perpustakaan | Mengelola data anggota, buku, eksemplar, peminjaman, pengembalian, dan denda |
| Anggota | Menggunakan layanan peminjaman dan pengembalian buku |
| Kepala Perpustakaan | Melihat informasi dan laporan kegiatan perpustakaan |

### Proses Bisnis

| Kode | Proses Bisnis | Aktor Utama | Deskripsi |
|---|---|---|---|
| PB-01 | Mengelola Data Anggota | Petugas | Mencatat, mengubah, membaca, dan menghapus data anggota |
| PB-02 | Mengelola Koleksi Buku | Petugas | Mengelola data buku dan eksemplar yang tersedia |
| PB-03 | Melayani Peminjaman Buku | Petugas, Anggota | Mencatat transaksi peminjaman buku anggota |
| PB-04 | Melayani Pengembalian dan Denda | Petugas, Anggota | Mencatat pengembalian dan menghitung denda keterlambatan |

---

## 3. Dokumen Sumber yang Dianalisis

Dokumen sumber fiktif yang digunakan sebagai dasar analisis adalah:

**Slip Peminjaman Buku Perpustakaan AHD**

### Contoh Slip Peminjaman

| Elemen | Contoh Nilai |
|---|---|
| Nomor Peminjaman | PJM-20261002-001 |
| Tanggal Peminjaman | 02-10-2026 |
| ID Anggota | AGT-0001 |
| Nama Anggota | Ahmad |
| ID Petugas | PTG-001 |
| Nama Petugas | Siti |
| Kode Buku | BUK-001 |
| Judul Buku | Dasar Pemrograman |
| Kode Eksemplar | EXP-001 |
| Tanggal Jatuh Tempo | 09-10-2026 |

### Analisis Dokumen

Slip peminjaman digunakan sebagai sumber untuk mengidentifikasi data
anggota, petugas, transaksi peminjaman, buku, dan eksemplar buku.

Nomor peminjaman digunakan sebagai identitas transaksi. Data anggota
digunakan untuk mengetahui pihak yang melakukan peminjaman. Data petugas
digunakan untuk mengetahui petugas yang melayani transaksi.

Kode buku dan kode eksemplar digunakan untuk membedakan judul buku dengan
salinan fisik buku. Satu judul buku dapat memiliki lebih dari satu eksemplar.

Tanggal peminjaman dan tanggal jatuh tempo digunakan untuk menentukan batas
pengembalian buku. Data tersebut juga dapat digunakan untuk menentukan
keterlambatan dan perhitungan denda.

---

## 4. Entitas Kandidat dan Elemen Data

| Entitas Kandidat | Elemen Data Utama |
|---|---|
| Anggota | id_anggota, nomor_anggota, nama, alamat, nomor_hp, status |
| Buku | id_buku, kode_buku, judul, penulis, penerbit, tahun_terbit, kategori |
| Eksemplar | id_eksemplar, kode_eksemplar, id_buku, kondisi, status |
| Petugas | id_petugas, kode_petugas, nama, peran, nomor_hp |
| Peminjaman | id_peminjaman, nomor_peminjaman, id_anggota, id_petugas, tanggal_peminjaman, tanggal_jatuh_tempo |
| Detail Peminjaman | id_peminjaman, id_eksemplar |
| Pengembalian | id_pengembalian, id_peminjaman, tanggal_pengembalian, kondisi_kembali |
| Denda | id_denda, id_pengembalian, hari_terlambat, tarif_harian, total_denda, status_pembayaran |

---

## 5. Aturan Bisnis

| Kode | Aturan Bisnis |
|---|---|
| AB-01 | Setiap anggota memiliki nomor anggota yang unik. |
| AB-02 | Hanya anggota dengan status aktif yang dapat melakukan peminjaman buku. |
| AB-03 | Setiap transaksi peminjaman memiliki nomor peminjaman yang unik. |
| AB-04 | Satu transaksi peminjaman maksimal terdiri dari 3 item buku. |
| AB-05 | Satu eksemplar buku tidak boleh dipinjam oleh lebih dari satu transaksi aktif pada waktu yang sama. |
| AB-06 | Setiap peminjaman memiliki tanggal jatuh tempo yang digunakan sebagai dasar pemeriksaan keterlambatan. |
| AB-07 | Keterlambatan pengembalian dikenakan denda sebesar Rp1.000 per hari per buku. |
| AB-08 | Satu judul buku dapat memiliki lebih dari satu eksemplar. |
| AB-09 | Setiap pengembalian harus mengacu pada transaksi peminjaman yang telah tercatat. |
| AB-10 | Total denda dihitung berdasarkan jumlah hari keterlambatan dikalikan tarif denda harian. |

---

## 6. Kebutuhan Informasi

| Kode | Kebutuhan Informasi | Data yang Diperlukan |
|---|---|---|
| KI-01 | Daftar anggota aktif perpustakaan | Anggota |
| KI-02 | Daftar koleksi buku dan jumlah eksemplarnya | Buku, Eksemplar |
| KI-03 | Daftar buku yang sedang dipinjam | Anggota, Peminjaman, Detail Peminjaman, Eksemplar, Buku |
| KI-04 | Daftar peminjaman yang terlambat dikembalikan | Peminjaman, Pengembalian, Anggota |
| KI-05 | Laporan denda anggota | Anggota, Pengembalian, Denda |

---

## 7. Matriks CRUD

Keterangan:

- C = Create
- R = Read
- U = Update
- D = Delete

| Proses | Anggota | Buku | Eksemplar | Petugas | Peminjaman | Detail Peminjaman | Pengembalian | Denda |
|---|---|---|---|---|---|---|---|---|
| PB-01 Mengelola Data Anggota | C/R/U/D |  |  |  |  |  |  |  |
| PB-02 Mengelola Koleksi Buku |  | C/R/U/D | C/R/U/D |  |  |  |  |  |
| PB-03 Melayani Peminjaman Buku | R | R | R/U | R | C/R | C/R |  |  |
| PB-04 Melayani Pengembalian dan Denda | R | R | R/U | R | R/U | R | C/R/U | C/R/U |

---

## 8. Kamus Data Awal

| No | Elemen Data | Arti | Contoh Nilai | Sumber | Aturan | Penanggung Jawab |
|---|---|---|---|---|---|---|
| 1 | id_anggota | Identitas internal anggota | 1 | Formulir anggota | Unik | Petugas |
| 2 | nomor_anggota | Nomor identitas anggota | AGT-0001 | Formulir anggota | Tidak boleh sama | Petugas |
| 3 | nama_anggota | Nama lengkap anggota | Ahmad | Formulir anggota | Wajib diisi | Petugas |
| 4 | alamat | Alamat anggota | Metro | Formulir anggota | Dapat diperbarui | Petugas |
| 5 | nomor_hp | Nomor telepon anggota | 081234567890 | Formulir anggota | Data pribadi | Petugas |
| 6 | status_anggota | Status keaktifan anggota | Aktif | Formulir anggota | Aktif/Tidak Aktif | Petugas |
| 7 | id_buku | Identitas internal buku | 1 | Data katalog | Unik | Petugas |
| 8 | kode_buku | Kode buku | BUK-001 | Data katalog | Tidak boleh sama | Petugas |
| 9 | judul_buku | Judul buku | Dasar Pemrograman | Data katalog | Wajib diisi | Petugas |
| 10 | penulis | Penulis buku | Budi Santoso | Data katalog | Wajib diisi | Petugas |
| 11 | penerbit | Penerbit buku | Penerbit A | Data katalog | Wajib diisi | Petugas |
| 12 | tahun_terbit | Tahun buku diterbitkan | 2025 | Data katalog | Berupa tahun | Petugas |
| 13 | kode_eksemplar | Kode salinan fisik buku | EXP-001 | Data eksemplar | Unik | Petugas |
| 14 | kondisi_eksemplar | Kondisi fisik buku | Baik | Data eksemplar | Baik/Rusak | Petugas |
| 15 | status_eksemplar | Status penggunaan eksemplar | Tersedia | Data eksemplar | Tersedia/Dipinjam | Petugas |
| 16 | id_petugas | Identitas internal petugas | 1 | Data petugas | Unik | Kepala Perpustakaan |
| 17 | kode_petugas | Kode identitas petugas | PTG-001 | Data petugas | Tidak boleh sama | Kepala Perpustakaan |
| 18 | nama_petugas | Nama petugas | Siti | Data petugas | Wajib diisi | Kepala Perpustakaan |
| 19 | nomor_peminjaman | Nomor transaksi peminjaman | PJM-20261002-001 | Slip peminjaman | Unik | Petugas |
| 20 | tanggal_peminjaman | Tanggal buku dipinjam | 02-10-2026 | Slip peminjaman | Wajib diisi | Petugas |
| 21 | tanggal_jatuh_tempo | Batas pengembalian buku | 09-10-2026 | Slip peminjaman | Setelah tanggal peminjaman | Petugas |
| 22 | tanggal_pengembalian | Tanggal buku dikembalikan | 10-10-2026 | Form pengembalian | Tidak sebelum peminjaman | Petugas |
| 23 | hari_terlambat | Jumlah hari keterlambatan | 1 | Perhitungan sistem | Minimal 0 | Petugas |
| 24 | tarif_harian | Tarif denda setiap hari | 1000 | Aturan bisnis | Rp1.000 per hari per buku | Petugas |
| 25 | total_denda | Total denda keterlambatan | 1000 | Perhitungan sistem | Hari terlambat × tarif | Petugas |
| 26 | status_pembayaran | Status pembayaran denda | Belum Lunas | Data pembayaran denda | Lunas/Belum Lunas | Petugas |

---

## 9. Kebutuhan Non-Fungsional Data

### 9.1 Volume Data

Perkiraan volume transaksi perpustakaan adalah 45 transaksi per hari
berdasarkan parameter P = 1.

Setiap transaksi peminjaman maksimal memiliki 3 item buku.

### 9.2 Retensi Data

Data anggota, buku, eksemplar, peminjaman, pengembalian, dan denda perlu
disimpan sebagai data historis agar aktivitas perpustakaan dapat ditelusuri.

Data transaksi yang telah selesai tidak dihapus secara sembarangan karena
dapat digunakan untuk kebutuhan laporan dan pemeriksaan riwayat.

### 9.3 Data Pribadi

Data yang termasuk data pribadi antara lain:

- nama anggota;
- alamat anggota;
- nomor HP anggota.

Data tersebut tidak boleh diakses oleh pengguna yang tidak memiliki
kewenangan.

### 9.4 Hak Akses

| Peran | Hak Akses |
|---|---|
| Petugas | Membuat, membaca, dan memperbarui data operasional perpustakaan |
| Anggota | Melihat informasi koleksi dan informasi peminjaman miliknya |
| Kepala Perpustakaan | Melihat data dan laporan perpustakaan |

### 9.5 Konsistensi Data

Data harus memiliki identitas yang unik untuk menghindari data ganda,
terutama nomor anggota, kode buku, kode eksemplar, kode petugas, dan nomor
peminjaman.

---

## 10. Isu Kualitas Data yang Diantisipasi

Beberapa masalah kualitas data yang mungkin terjadi antara lain:

1. Data anggota tercatat lebih dari satu kali.
2. Nomor anggota tidak unik.
3. Kode buku tercatat lebih dari satu kali.
4. Kode eksemplar tidak sesuai dengan buku yang dimiliki.
5. Status eksemplar tidak diperbarui setelah peminjaman atau pengembalian.
6. Tanggal jatuh tempo tidak sesuai dengan tanggal peminjaman.
7. Data pengembalian tidak memiliki transaksi peminjaman yang sesuai.
8. Total denda tidak sesuai dengan jumlah hari keterlambatan.
9. Data pribadi anggota dapat diakses oleh pihak yang tidak berwenang.
10. Data transaksi lama terhapus sehingga riwayat peminjaman tidak dapat ditelusuri.