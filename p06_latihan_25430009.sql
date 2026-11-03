-- =====================================================================
-- Pertemuan 6 - Latihan E.1 (diterapkan pada proyek Perpustakaan AHD)
-- Nama : Abbiyu Hashfi Dzakwan | NPM : 25430009 | Kelas : A
-- Prasyarat : perpus_009 hasil P05 + p06_data_25430009.sql (MySQL 8.4.3, Laragon)
--
-- Memindahkan anggota berstatus nonaktif yang mendaftar sebelum 2025 ke
-- tabel anggota_arsip, lalu menghapusnya dari tabel asal. Anggota yang
-- masih memiliki riwayat peminjaman TIDAK dipindahkan/dihapus agar
-- riwayat transaksi tetap utuh (kebutuhan retensi data, P02 bagian 9.2).
-- Skrip aman dijalankan ulang.
-- =====================================================================

USE perpus_009;
SET NAMES utf8mb4;

-- Kandidat sebelum diarsipkan
SELECT a.no_anggota, a.nama_anggota, a.tgl_daftar_anggota, a.status_anggota,
       (SELECT COUNT(*) FROM peminjaman p WHERE p.id_anggota = a.id_anggota) AS jumlah_transaksi
FROM anggota a
WHERE a.status_anggota = 'nonaktif' AND a.tgl_daftar_anggota < '2025-01-01';

-- Struktur arsip disalin dari tabel anggota (kolom, PK, UNIQUE, CHECK; tanpa FK)
CREATE TABLE IF NOT EXISTS anggota_arsip LIKE anggota;

START TRANSACTION;

INSERT INTO anggota_arsip
SELECT a.*
FROM anggota a
WHERE a.status_anggota = 'nonaktif'
  AND a.tgl_daftar_anggota < '2025-01-01'
  AND NOT EXISTS (SELECT 1 FROM peminjaman p WHERE p.id_anggota = a.id_anggota)
  AND NOT EXISTS (SELECT 1 FROM anggota_arsip r WHERE r.id_anggota = a.id_anggota);

-- Hapus hanya baris yang sudah tersalin ke arsip (WHERE memakai kolom kunci)
DELETE FROM anggota
WHERE id_anggota IN (SELECT id_anggota FROM anggota_arsip)
  AND NOT EXISTS (SELECT 1 FROM peminjaman p WHERE p.id_anggota = anggota.id_anggota);

COMMIT;

-- Hasil
SELECT 'anggota_arsip' AS tabel, no_anggota, nama_anggota, tgl_daftar_anggota, status_anggota
FROM anggota_arsip;
SELECT 'anggota' AS tabel, no_anggota, nama_anggota, tgl_daftar_anggota, status_anggota
FROM anggota WHERE status_anggota = 'nonaktif';
