-- =====================================================================
-- Pertemuan 6 - Skrip Skenario Uji Proyek Perpustakaan AHD
-- Nama : Abbiyu Hashfi Dzakwan | NPM : 25430009 | Kelas : A
-- Prasyarat : perpus_009 hasil P05 + p06_data_25430009.sql (MySQL 8.4.3, Laragon)
--
-- Setiap skenario dibungkus START TRANSACTION ... ROLLBACK sehingga data
-- sampel tidak berubah setelah pengujian. Di phpMyAdmin jalankan satu blok
-- UJ per eksekusi, karena phpMyAdmin berhenti pada galat pertama.
-- Di klien mysql dapat dijalankan sekaligus:
--   mysql -u dev_009 -p --force -t perpus_009 < p06_uji_25430009.sql
-- Dokumentasi hasil: p06_uji_25430009.md
-- =====================================================================

USE perpus_009;
SET NAMES utf8mb4;

-- UJ-01 (positif, AB-02): anggota aktif membuat transaksi baru -> diterima
START TRANSACTION;
INSERT INTO peminjaman (nomor_peminjaman, id_anggota, id_petugas, tgl_pinjam)
SELECT 'PJM-20261103-00901', a.id_anggota, p.id_petugas, '2026-11-03'
FROM anggota a JOIN petugas p ON p.kode_petugas = 'p03'
WHERE a.no_anggota = 'AGT011';
SELECT 'UJ-01' AS uji, nomor_peminjaman, status_peminjaman
FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261103-00901';
ROLLBACK;

-- UJ-02 (negatif, AB-02): anggota nonaktif (AGT017) membuat transaksi -> ditolak trigger
START TRANSACTION;
INSERT INTO peminjaman (nomor_peminjaman, id_anggota, id_petugas, tgl_pinjam)
SELECT 'PJM-20261103-00902', a.id_anggota, p.id_petugas, '2026-11-03'
FROM anggota a JOIN petugas p ON p.kode_petugas = 'p03'
WHERE a.no_anggota = 'AGT017';
ROLLBACK;

-- UJ-03 (negatif, AB-01 / uq_anggota_no_anggota): nomor anggota kembar (AGT001 dari data P05) -> ERROR 1062
START TRANSACTION;
INSERT INTO anggota (no_anggota, nama_anggota, tgl_daftar_anggota, status_anggota)
VALUES ('AGT001', 'Andi Saputra Duplikat', '2026-11-03', 'aktif');
ROLLBACK;

-- UJ-04 (negatif, AB-03 / uq_peminjaman_nomor_peminjaman): nomor transaksi kembar -> ERROR 1062
START TRANSACTION;
INSERT INTO peminjaman (nomor_peminjaman, id_anggota, id_petugas, tgl_pinjam)
SELECT 'PJM-20260914-00011', a.id_anggota, p.id_petugas, '2026-11-03'
FROM anggota a JOIN petugas p ON p.kode_petugas = 'p03'
WHERE a.no_anggota = 'AGT012';
ROLLBACK;

-- UJ-05 (positif, AB-04) dan UJ-06 (negatif, AB-04): 3 item diterima, item ke-4 ditolak
START TRANSACTION;
INSERT INTO peminjaman (nomor_peminjaman, id_anggota, id_petugas, tgl_pinjam)
SELECT 'PJM-20261103-00905', a.id_anggota, p.id_petugas, '2026-11-03'
FROM anggota a JOIN petugas p ON p.kode_petugas = 'p05'
WHERE a.no_anggota = 'AGT015';
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261103-00905');
SET @e2 = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS012');
SET @e4 = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS014');
SET @e6 = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS016');
SET @e8 = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS018');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo) VALUES
  (@pj, @e2, '2026-11-10'), (@pj, @e4, '2026-11-10'), (@pj, @e6, '2026-11-10');
SELECT 'UJ-05' AS uji, COUNT(*) AS jumlah_item FROM detail_peminjaman WHERE id_peminjaman = @pj;
-- UJ-06: item keempat
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
VALUES (@pj, @e8, '2026-11-10');
ROLLBACK;

-- UJ-07 (negatif, AB-05): eksemplar yang masih dipinjam (EKS019) dipinjam lagi -> ditolak trigger
START TRANSACTION;
INSERT INTO peminjaman (nomor_peminjaman, id_anggota, id_petugas, tgl_pinjam)
SELECT 'PJM-20261103-00907', a.id_anggota, p.id_petugas, '2026-11-03'
FROM anggota a JOIN petugas p ON p.kode_petugas = 'p05'
WHERE a.no_anggota = 'AGT014';
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261103-00907');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS019');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
VALUES (@pj, @e, '2026-11-10');
ROLLBACK;

-- UJ-08 (negatif, fk_peminjaman_petugas): petugas tidak dikenal -> ERROR 1452
START TRANSACTION;
INSERT INTO peminjaman (nomor_peminjaman, id_anggota, id_petugas, tgl_pinjam)
SELECT 'PJM-20261103-00908', a.id_anggota, 9999, '2026-11-03'
FROM anggota a WHERE a.no_anggota = 'AGT011';
ROLLBACK;

-- UJ-09 (negatif, AB-09 / fk_pengembalian_detail): pengembalian item yang tidak dipinjam -> ERROR 1452
START TRANSACTION;
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261020-00020');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS018');
SET @ptg = (SELECT id_petugas FROM petugas WHERE kode_petugas = 'p03');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
VALUES (@pj, @e, @ptg, '2026-11-03', 'baik');
ROLLBACK;

-- UJ-10 (negatif, AB-07 / ck_denda_tarif_harian): tarif harian 0 -> ERROR 3819 (MySQL)
START TRANSACTION;
SET @d = (SELECT MIN(id_denda) FROM denda);
UPDATE denda SET tarif_harian = 0 WHERE id_denda = @d;
ROLLBACK;

-- UJ-11 (negatif, ck_denda_status_tanggal): status lunas tanpa tanggal bayar -> ERROR 3819 (MySQL)
START TRANSACTION;
SET @d = (SELECT MAX(id_denda) FROM denda WHERE status_bayar = 'belum_bayar');
UPDATE denda SET status_bayar = 'lunas' WHERE id_denda = @d;
ROLLBACK;

-- UJ-12 (negatif, kebijakan lab) dan UJ-13 (positif): mode aman sql_safe_updates
SET SESSION sql_safe_updates = 1;
START TRANSACTION;
-- UJ-12: UPDATE tanpa WHERE -> ERROR 1175
UPDATE anggota SET alamat_anggota = TRIM(alamat_anggota);
-- UJ-13: UPDATE memakai kolom kunci unik -> diterima (1 baris)
UPDATE anggota SET no_hp_anggota = '089612340999' WHERE no_anggota = 'AGT015';
SELECT 'UJ-13' AS uji, no_anggota, no_hp_anggota FROM anggota WHERE no_anggota = 'AGT015';
ROLLBACK;
SET SESSION sql_safe_updates = 0;

-- UJ-14 (negatif, fk_peminjaman_petugas ON DELETE RESTRICT): hapus petugas p03 yang pernah melayani -> ERROR 1451
START TRANSACTION;
DELETE FROM petugas WHERE kode_petugas = 'p03';
ROLLBACK;

-- UJ-15 (negatif, fk_detail_peminjaman ON DELETE RESTRICT): hapus transaksi yang memiliki detail -> ERROR 1451
START TRANSACTION;
DELETE FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261020-00020';
ROLLBACK;

-- UJ-16 (uji yang DIPERKIRAKAN GAGAL, AB-06): jatuh tempo sebelum tanggal pinjam
-- Harapan: ditolak. Kenyataan: diterima karena belum ada constraint lintas tabel.
START TRANSACTION;
INSERT INTO peminjaman (nomor_peminjaman, id_anggota, id_petugas, tgl_pinjam)
SELECT 'PJM-20261103-00916', a.id_anggota, p.id_petugas, '2026-11-03'
FROM anggota a JOIN petugas p ON p.kode_petugas = 'p03'
WHERE a.no_anggota = 'AGT013';
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261103-00916');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS018');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
VALUES (@pj, @e, '2026-10-01');
SELECT 'UJ-16' AS uji, p.tgl_pinjam, dp.tgl_jatuh_tempo,
       DATEDIFF(dp.tgl_jatuh_tempo, p.tgl_pinjam) AS selisih_hari
FROM detail_peminjaman dp JOIN peminjaman p ON p.id_peminjaman = dp.id_peminjaman
WHERE dp.id_peminjaman = @pj;
ROLLBACK;

-- Pemeriksaan: jumlah baris tetap sama seperti setelah p06_data_25430009.sql
SELECT 'anggota' AS nama_tabel, COUNT(*) AS jumlah_baris FROM anggota
UNION ALL SELECT 'petugas',           COUNT(*) FROM petugas
UNION ALL SELECT 'buku',              COUNT(*) FROM buku
UNION ALL SELECT 'eksemplar_buku',    COUNT(*) FROM eksemplar_buku
UNION ALL SELECT 'peminjaman',        COUNT(*) FROM peminjaman
UNION ALL SELECT 'detail_peminjaman', COUNT(*) FROM detail_peminjaman
UNION ALL SELECT 'pengembalian',      COUNT(*) FROM pengembalian
UNION ALL SELECT 'denda',             COUNT(*) FROM denda;
