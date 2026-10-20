# Normalisasi Basis Data - Proyek Perpustakaan AHD

**Nama:** Abbiyu Hashfi Dzakwan  
**NPM:** 25430009  
**Kelas:** A  
**Pertemuan:** 4  
**Basis data:** `perpus_009`  
**Organisasi:** Perpustakaan AHD

## 1. Tujuan

Dokumen ini menguji rancangan ERD Perpustakaan AHD dari Pertemuan 3 melalui normalisasi. Proses dimulai dari slip peminjaman yang dipakai pada Pertemuan 2, dilanjutkan dengan identifikasi dependensi fungsional, pemisahan relasi sampai 3NF, pemeriksaan BCNF, serta keputusan tentang nilai yang dihitung dan nilai yang perlu disimpan.

## 2. Dokumen Sumber dan Aturan yang Digunakan

Dokumen sumber yang dianalisis adalah **Slip Peminjaman Buku Perpustakaan AHD** dari `p02_kebutuhan_data_25430009.md`. Elemen yang muncul pada contoh slip meliputi nomor peminjaman, tanggal peminjaman, ID dan nama anggota, ID dan nama petugas, kode dan judul buku, kode eksemplar, serta tanggal jatuh tempo.

Satu transaksi peminjaman dapat memuat maksimal tiga item karena parameter NPM menghasilkan `P = (09 mod 9) + 1 = 1`, sehingga `P + 2 = 3`. Untuk analisis UNF, grup berulang pada satu slip ditulis sebagai grup eksemplar yang dipinjam. Entitas pengembalian dan denda tetap dipertahankan pada skema akhir karena keduanya dibutuhkan oleh dokumen kebutuhan data dan ERD Pertemuan 2–3, meskipun tidak semuanya tercetak pada contoh slip peminjaman.

Aturan bisnis utama yang relevan:

| Kode | Aturan bisnis | Dampak terhadap rancangan |
|---|---|---|
| AB-01 | Setiap anggota memiliki nomor anggota unik. | `no_anggota` harus menjadi kunci alternatif yang unik. |
| AB-02 | Hanya anggota berstatus aktif yang dapat meminjam buku. | Status disimpan pada tabel `anggota` dan diperiksa saat proses peminjaman. |
| AB-03 | Setiap transaksi peminjaman memiliki nomor peminjaman unik. | `nomor_peminjaman` harus disimpan dan unik pada `peminjaman`. |
| AB-04 | Satu transaksi peminjaman maksimal berisi tiga item buku. | Item disimpan satu per baris di `detail_peminjaman`; batas jumlah baris tidak cukup dijaga dengan CHECK satu kolom. |
| AB-05 | Satu eksemplar tidak boleh dipinjam oleh lebih dari satu transaksi aktif pada waktu yang sama. | Status ketersediaan eksemplar dan detail pinjaman harus dikelola konsisten. |
| AB-06 | Setiap peminjaman memiliki tanggal jatuh tempo. | `tgl_jatuh_tempo` disimpan pada detail agar setiap eksemplar dapat diperiksa tersendiri. |
| AB-07 | Denda adalah Rp1.000 per hari per buku. | Tarif denda awal mengikuti `P = 1`; tarif yang digunakan saat denda dinilai disimpan sebagai snapshot. |
| AB-08 | Satu judul buku dapat memiliki lebih dari satu eksemplar. | Data judul dipisahkan dari data fisik eksemplar. |
| AB-09 | Setiap pengembalian harus mengacu pada peminjaman yang telah tercatat. | Pengembalian merujuk pada pasangan peminjaman–eksemplar yang valid. |
| AB-10 | Total denda dihitung dari hari keterlambatan dikalikan tarif harian. | Hari keterlambatan dan total denda diperlakukan sebagai nilai turunan, bukan kolom operasional yang disalin berulang. |

## 3. Identifikasi Anomali pada Relasi yang Belum Dinormalisasi

Jika data anggota, petugas, buku, eksemplar, dan peminjaman dicatat dalam satu tabel besar, informasi master akan berulang untuk setiap item yang dipinjam. Kondisi ini dapat menimbulkan tiga anomali:

1. **Anomali ubah (update):** jika nama anggota atau judul buku berubah, banyak baris harus diperbarui. Jika sebagian baris tidak diubah, satu anggota atau satu judul buku akan mempunyai lebih dari satu versi informasi.
2. **Anomali sisip (insert):** buku atau anggota baru sulit dicatat jika tabel hanya mengizinkan baris yang sekaligus memiliki transaksi peminjaman.
3. **Anomali hapus (delete):** menghapus satu-satunya baris transaksi yang memuat suatu buku dapat ikut menghilangkan informasi buku tersebut apabila tidak ada tabel master terpisah.

Normalisasi memisahkan fakta berdasarkan objek yang dijelaskannya, sehingga informasi anggota berada pada `anggota`, informasi judul berada pada `buku`, unit fisik berada pada `eksemplar_buku`, dan satu kejadian peminjaman dipisahkan dari daftar item pinjamnya.

## 4. Tahap UNF (Unnormalized Form)

Pada bentuk UNF, satu slip menampung data kepala transaksi dan grup item yang berulang. Grup ini tidak atomik karena satu transaksi bisa berisi satu sampai tiga eksemplar.

```text
SLIP_PEMINJAMAN_UNF(
  nomor_peminjaman,
  tgl_pinjam,
  id_anggota,
  no_anggota,
  nama_anggota,
  alamat_anggota,
  no_hp_anggota,
  status_anggota,
  id_petugas,
  kode_petugas,
  nama_petugas,
  peran_petugas,
  status_peminjaman,
  { kode_eksemplar,
    kode_buku,
    isbn_buku,
    judul_buku,
    penulis_buku,
    penerbit_buku,
    tahun_terbit_buku,
    kategori_buku,
    kondisi_eksemplar,
    status_eksemplar,
    tgl_jatuh_tempo,
    status_detail }
)
```

Tanda kurung kurawal menunjukkan grup berulang. Dalam spreadsheet yang tidak dinormalisasi, grup tersebut dapat muncul sebagai beberapa pasangan kolom barang atau ditulis sebagai daftar dalam satu sel. Kedua cara itu belum menjadi representasi relasional yang baik.

## 5. Tahap 1NF (First Normal Form)

Untuk mencapai 1NF, grup berulang dikeluarkan menjadi baris-baris terpisah. Setiap baris mewakili satu eksemplar dalam satu peminjaman dan semua nilai kolom harus atomik. Kunci komposit sementara adalah `(nomor_peminjaman, kode_eksemplar)`.

```text
PEMINJAMAN_1NF(
  nomor_peminjaman,
  kode_eksemplar,
  tgl_pinjam,
  id_anggota,
  no_anggota,
  nama_anggota,
  alamat_anggota,
  no_hp_anggota,
  status_anggota,
  id_petugas,
  kode_petugas,
  nama_petugas,
  peran_petugas,
  status_peminjaman,
  kode_buku,
  isbn_buku,
  judul_buku,
  penulis_buku,
  penerbit_buku,
  tahun_terbit_buku,
  kategori_buku,
  kondisi_eksemplar,
  status_eksemplar,
  tgl_jatuh_tempo,
  status_detail,
  PK (nomor_peminjaman, kode_eksemplar)
)
```

Relasi di atas sudah 1NF, tetapi belum 2NF dan 3NF. Sebagian atribut bergantung hanya pada nomor peminjaman, sementara atribut lain bergantung hanya pada kode eksemplar atau kode buku. Informasi anggota dan petugas juga masih berulang setiap kali mereka terkait dengan transaksi.

## 6. Dependensi Fungsional

Dependensi fungsional diturunkan dari identitas objek dan aturan bisnis, bukan hanya dari nilai contoh pada slip. Pada notasi `A → B`, setiap nilai A menentukan satu nilai B.

| Kode | Dependensi fungsional | Dasar |
|---|---|---|
| FD-01 | `no_anggota → nama_anggota, alamat_anggota, no_hp_anggota, tgl_daftar_anggota, status_anggota` | AB-01: nomor anggota unik. |
| FD-02 | `kode_petugas → nama_petugas, peran_petugas` | Kamus data petugas dan kode identitas petugas. |
| FD-03 | `kode_buku → isbn_buku, judul_buku, penulis_buku, penerbit_buku, tahun_terbit_buku, kategori_buku` | Kode katalog mengidentifikasi satu judul/edisi yang dicatat. |
| FD-04 | `kode_eksemplar → kode_buku, kondisi_eksemplar, status_eksemplar` | Satu kode eksemplar mengidentifikasi satu unit fisik; AB-08 membedakan judul dan unit. |
| FD-05 | `nomor_peminjaman → id_anggota, id_petugas, tgl_pinjam, status_peminjaman` | AB-03: nomor transaksi unik. |
| FD-06 | `(nomor_peminjaman, kode_eksemplar) → tgl_jatuh_tempo, status_detail` | Satu detail menjelaskan satu unit pada satu transaksi; terkait AB-04 dan AB-06. |
| FD-07 | `id_pengembalian → id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali` | AB-09: pengembalian tercatat untuk item pinjaman tertentu. |
| FD-08 | `id_pengembalian → tarif_harian, status_pembayaran, tgl_bayar` | Satu pengembalian paling banyak memiliki satu catatan denda pada rancangan ini. |

Dalam rancangan fisik, tabel juga memakai kunci pengganti seperti `id_anggota` dan `id_peminjaman`. Kunci pengganti memudahkan relasi antartabel, tetapi tidak menggantikan keunikan kunci bisnis seperti `no_anggota`, `kode_buku`, `kode_eksemplar`, dan `nomor_peminjaman`.

## 7. Tahap 2NF (Second Normal Form)

Relasi 1NF menggunakan kunci komposit `(nomor_peminjaman, kode_eksemplar)`. Atribut kepala transaksi bergantung pada bagian `nomor_peminjaman`, sedangkan informasi unit fisik bergantung pada `kode_eksemplar`. Ketergantungan parsial ini dihilangkan dengan memisahkan data kepala transaksi, eksemplar, dan detail peminjaman.

```text
PEMINJAMAN_2NF(
  nomor_peminjaman PK,
  tgl_pinjam,
  id_anggota,
  no_anggota,
  nama_anggota,
  alamat_anggota,
  no_hp_anggota,
  status_anggota,
  id_petugas,
  kode_petugas,
  nama_petugas,
  peran_petugas,
  status_peminjaman
)

EKSEMPLAR_2NF(
  kode_eksemplar PK,
  kode_buku,
  isbn_buku,
  judul_buku,
  penulis_buku,
  penerbit_buku,
  tahun_terbit_buku,
  kategori_buku,
  kondisi_eksemplar,
  status_eksemplar
)

DETAIL_PEMINJAMAN_2NF(
  nomor_peminjaman PK/FK,
  kode_eksemplar PK/FK,
  tgl_jatuh_tempo,
  status_detail
)
```

Tahap ini menghilangkan ketergantungan parsial pada kunci komposit. Namun, `PEMINJAMAN_2NF` masih menyimpan atribut anggota dan petugas yang ditentukan oleh kunci masing-masing, sedangkan `EKSEMPLAR_2NF` masih menyimpan informasi judul yang ditentukan oleh `kode_buku`. Karena itu, relasi hasil 2NF tersebut belum sepenuhnya 3NF.

## 8. Tahap 3NF (Third Normal Form)

Untuk mencapai 3NF, ketergantungan transitif dihilangkan. Data anggota dan petugas dipisah ke tabel master masing-masing. Informasi judul buku dipisahkan dari eksemplar fisik. Tabel `detail_peminjaman` tetap menjadi entitas asosiatif karena menghubungkan transaksi dengan eksemplar, dan memiliki atribut sendiri berupa tanggal jatuh tempo serta status item.

### 8.1 Skema relasional akhir

```text
ANGGOTA(
  id_anggota PK,
  no_anggota AK UNIQUE,
  nama_anggota,
  alamat_anggota,
  no_hp_anggota,
  tgl_daftar_anggota,
  status_anggota
)

PETUGAS(
  id_petugas PK,
  kode_petugas AK UNIQUE,
  nama_petugas,
  peran_petugas
)

BUKU(
  id_buku PK,
  kode_buku AK UNIQUE,
  isbn_buku UNIQUE (opsional bila tersedia),
  judul_buku,
  penulis_buku,
  penerbit_buku,
  tahun_terbit_buku,
  kategori_buku
)

EKSEMPLAR_BUKU(
  id_eksemplar PK,
  id_buku FK -> BUKU.id_buku,
  kode_eksemplar AK UNIQUE,
  kondisi_eksemplar,
  status_eksemplar
)

PEMINJAMAN(
  id_peminjaman PK,
  nomor_peminjaman AK UNIQUE,
  id_anggota FK -> ANGGOTA.id_anggota,
  id_petugas FK -> PETUGAS.id_petugas,
  tgl_pinjam,
  status_peminjaman
)

DETAIL_PEMINJAMAN(
  id_peminjaman PK/FK -> PEMINJAMAN.id_peminjaman,
  id_eksemplar PK/FK -> EKSEMPLAR_BUKU.id_eksemplar,
  tgl_jatuh_tempo,
  status_detail,
  PK (id_peminjaman, id_eksemplar)
)

PENGEMBALIAN(
  id_pengembalian PK,
  id_peminjaman,
  id_eksemplar,
  id_petugas FK -> PETUGAS.id_petugas,
  tgl_kembali,
  kondisi_kembali,
  FK (id_peminjaman, id_eksemplar)
    -> DETAIL_PEMINJAMAN(id_peminjaman, id_eksemplar)
)

DENDA(
  id_denda PK,
  id_pengembalian FK UNIQUE -> PENGEMBALIAN.id_pengembalian,
  tarif_harian,
  status_pembayaran,
  tgl_bayar
)
```

`PK` berarti primary key, `FK` berarti foreign key, dan `AK` berarti alternate key atau kunci bisnis unik selain primary key. `DETAIL_PEMINJAMAN` menggunakan primary key komposit agar eksemplar yang sama tidak tercatat dua kali pada transaksi yang sama. Relasi komposit dari `PENGEMBALIAN` ke `DETAIL_PEMINJAMAN` memastikan pasangan peminjaman dan eksemplar memang pernah dicatat sebagai satu detail pinjaman.

### 8.2 Tabel dan hubungan

| Tabel | Fungsi | Kunci penting | Relasi utama |
|---|---|---|---|
| `anggota` | Menyimpan identitas dan status anggota. | PK `id_anggota`; UNIQUE `no_anggota`. | Direferensikan `peminjaman`. |
| `petugas` | Menyimpan identitas dan peran petugas. | PK `id_petugas`; UNIQUE `kode_petugas`. | Direferensikan `peminjaman` dan `pengembalian`. |
| `buku` | Menyimpan informasi judul/edisi. | PK `id_buku`; UNIQUE `kode_buku`. | Satu judul memiliki banyak `eksemplar_buku`. |
| `eksemplar_buku` | Menyimpan unit fisik, kondisi, dan status. | PK `id_eksemplar`; UNIQUE `kode_eksemplar`. | Direferensikan `detail_peminjaman`. |
| `peminjaman` | Menyimpan kepala transaksi pinjam. | PK `id_peminjaman`; UNIQUE `nomor_peminjaman`. | Memiliki detail peminjaman. |
| `detail_peminjaman` | Menghubungkan transaksi dan eksemplar; menyimpan jatuh tempo per item. | PK komposit `(id_peminjaman, id_eksemplar)`. | Menjadi rujukan pengembalian. |
| `pengembalian` | Mencatat pengembalian satu item, petugas, tanggal, dan kondisi. | PK `id_pengembalian`; FK komposit ke detail. | Dapat memiliki satu catatan denda. |
| `denda` | Menyimpan tarif harian yang berlaku saat denda dinilai serta status pembayaran. | PK `id_denda`; UNIQUE FK `id_pengembalian`. | Satu pengembalian memiliki nol atau satu catatan denda. |

## 9. Pemeriksaan BCNF

BCNF diperiksa setelah skema mencapai 3NF. Untuk setiap tabel, penentu dari dependensi fungsional harus merupakan kunci kandidat.

| Tabel | Penentu/kunci kandidat yang diperiksa | Hasil |
|---|---|---|
| `anggota` | `id_anggota`, `no_anggota` | Lolos: kedua kunci mengidentifikasi satu baris anggota. |
| `petugas` | `id_petugas`, `kode_petugas` | Lolos: kode petugas unik. |
| `buku` | `id_buku`, `kode_buku` | Lolos: kode katalog unik; ISBN dibuat unik bila dicatat. |
| `eksemplar_buku` | `id_eksemplar`, `kode_eksemplar` | Lolos: masing-masing mengidentifikasi satu eksemplar. |
| `peminjaman` | `id_peminjaman`, `nomor_peminjaman` | Lolos: nomor peminjaman unik. |
| `detail_peminjaman` | `(id_peminjaman, id_eksemplar)` | Lolos: pasangan tersebut adalah identitas tiap detail. |
| `pengembalian` | `id_pengembalian` | Lolos: atribut lain ditentukan oleh primary key. |
| `denda` | `id_denda`, `id_pengembalian` (unik) | Lolos: satu pengembalian memiliki paling banyak satu baris denda. |

Kesimpulan pemeriksaan: berdasarkan dependensi yang ditetapkan dari aturan proyek, semua penentu nontrivial dalam skema akhir merupakan kunci kandidat. Karena itu, rancangan akhir memenuhi BCNF sepanjang constraint keunikan dan kunci tamu benar-benar diterapkan pada tahap DDL.

## 10. Keputusan Penyimpanan Nilai Turunan

| Nilai | Keputusan | Alasan |
|---|---|---|
| `hari_terlambat` | Tidak disimpan sebagai kolom tetap; dihitung dari tanggal kembali dan jatuh tempo. | Menghindari perbedaan angka hari jika tanggal sumber berubah akibat koreksi yang sah. |
| `total_denda` / `jumlah_denda` | Tidak disimpan sebagai kolom operasional; dihitung dari hari keterlambatan dikali `tarif_harian`. | AB-10 menyatakan nilai ini merupakan hasil perhitungan. Menyimpan hasil yang sama di beberapa tempat berisiko menimbulkan nilai tidak konsisten. |
| `tarif_harian` | Disimpan pada `denda` saat denda dinilai. | Tarif awal Rp1.000 mengikuti `P = 1`. Menyimpan tarif yang benar-benar dipakai mempertahankan jejak historis bila kebijakan berubah pada masa depan. |
| `tgl_bayar` | Disimpan. | Ini adalah fakta kejadian pembayaran, bukan nilai yang dihitung dari kolom lain. Nilainya boleh `NULL` selama belum dibayar. |
| `status_peminjaman` dan `status_detail` | Disimpan dengan arti berbeda. | Status transaksi menggambarkan keadaan pinjaman secara keseluruhan, sedangkan status detail menggambarkan keadaan satu eksemplar. Perubahannya harus dijaga konsisten oleh proses aplikasi/transaksi. |

Perhitungan total denda dapat dirumuskan sebagai:

```text
hari_terlambat = maksimum(0, DATEDIFF(tgl_kembali, tgl_jatuh_tempo))
total_denda = hari_terlambat * tarif_harian
```

Denda hanya dibuat untuk pengembalian yang terkena denda. Pada tahap kueri nanti, nilai total dapat dihitung dengan menghubungkan `denda`, `pengembalian`, dan `detail_peminjaman` menggunakan pasangan `id_peminjaman` serta `id_eksemplar`.

## 11. Perbandingan dengan ERD Pertemuan 3 dan Perubahan yang Dicatat

Normalisasi tidak berarti menghapus ERD sebelumnya. ERD diperiksa, kemudian diperbarui hanya pada bagian yang belum mencakup kebutuhan data atau aturan bisnis.

| Bagian | Temuan pada berkas Pertemuan 2–3 | Keputusan Pertemuan 4 |
|---|---|---|
| `peminjaman` | Dokumen kebutuhan data menyebut `nomor_peminjaman` unik, tetapi atribut tersebut belum tampak pada ERD Pertemuan 3. | Tambahkan `nomor_peminjaman` sebagai atribut wajib dan kunci alternatif UNIQUE pada `peminjaman`. |
| `buku` | Slip dan dokumen kebutuhan data memakai `kode_buku` seperti `BUK-001`, sedangkan ERD menampilkan `isbn_buku`. | Tambahkan `kode_buku` sebagai kode katalog unik. `isbn_buku` dapat tetap menjadi atribut terpisah bila datanya tersedia; jangan mengganti kode pada slip tanpa pemetaan. |
| `tgl_jatuh_tempo` | Dokumen kebutuhan awal menempatkan tanggal jatuh tempo pada peminjaman, tetapi ERD menempatkannya pada detail. | Pertahankan di `detail_peminjaman` agar tanggal jatuh tempo bisa ditelusuri untuk masing-masing eksemplar dan perhitungan denda per buku. |
| `pengembalian` | ERD memuat `id_peminjaman` dan `id_eksemplar` sebagai dua FK, tetapi dua FK terpisah belum menjamin bahwa pasangan tersebut merupakan detail pinjaman yang sama. | Jadikan pasangan `(id_peminjaman, id_eksemplar)` sebagai FK komposit menuju `detail_peminjaman`. |
| `denda` | ERD memuat `jumlah_denda`, sedangkan kamus data menyebut hari terlambat, tarif harian, dan total denda sebagai data perhitungan. | Untuk mencegah duplikasi nilai turunan, hapus `jumlah_denda` dari skema operasional dan simpan `tarif_harian`, `status_pembayaran`, serta `tgl_bayar`. `id_pengembalian` dibuat UNIQUE untuk menerapkan relasi 0..1. |
| Penamaan status denda | Dokumen kebutuhan data memakai `status_pembayaran`, sementara ERD memakai `status_bayar`. | Gunakan `status_pembayaran` supaya konsisten dengan dokumen kebutuhan data. |

Perubahan tersebut perlu digambar pada sumber ERD, diekspor kembali ke PNG, dan dicatat di riwayat Git. Jangan mengubah isi diagram tanpa menyimpan versi sumber yang dapat diedit.

## 12. Ringkasan

Skema akhir tetap memuat delapan entitas yang telah dirancang pada Pertemuan 3, tetapi ketergantungan datanya ditegaskan melalui kunci dan relasi. Informasi anggota, petugas, buku, dan eksemplar tidak lagi diulang pada setiap transaksi. Penambahan kunci bisnis yang belum tercantum dan perbaikan hubungan pengembalian membuat rancangan lebih sesuai dengan kebutuhan data yang sudah dicatat sejak Pertemuan 2.
