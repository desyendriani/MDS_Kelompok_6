## 🎡 Pariwisata Jawa Barat 🏞️

Eksplorasi Destinasi Wisata Jawa Barat dengan Dashboard Interaktif RShiny </p>
📌 *Jelajahi keindahan alam, budaya, dan sejarah Jawa Barat dalam satu platform!*

<p align="center">
  <img width="900" height="500" src="https://github.com/desyendriani/MDS_Kelompok_6/blob/main/Image/Biru%20dan%20Putih%20Simpel%20Selamat%20Datang%20Bali%20YouTube%20Intro%20Video%20(1).gif">
</p>

## :classical_building: Menu

- [Welcome](#basecampy-welcome)
- [Tampilan Menu Utama](#clapper-tampilan-menu-utama)
- [Demo](#film_projector-demo)
- [Features](#sparkles-fitur-aplikasi)
- [Skema](#atom-skema)
- [ERD](#books-erd)
- [Data Description](#open_book-deskripsi-data)
- [Folder Structure](#file_folder-struktur-project)
- [Our Team](#owl-tim-pengembang)

## :basecampy: Welcome

Selamat datang di **Pariwisata Jawa Barat**! </p>
Jawa Barat merupakan salah satu provinsi yang terletak di pulau Jawa dengan motto "*Gemah Ripah Repeh Rapih*". Platform ini menyajikan informasi lengkap tentang destinasi wisata di Jawa Barat. Seperti :</p>
- **Pantai** 🌊
- **Wisata Air** 💦
- **Wisata Alam** 🌳
- **Wisata Edukasi** 📚
- **Wisata Keagamaan** 🕌
- **Wisata Sejarah** 🏛️

Platfrom ini dikembangkan untuk membantu wisatawan menemukan dan mengeksplorasi keindahan alam serta budaya di seluruh wilayah Jawa Barat dan merupakan implementasi dari dashboard interaktif menggunakan RShiny untuk menampilkan dan menganalisis data pariwisata Jawa Barat. </p>

🚀 Selamat menjelajah Wisata Jawa Barat! 😊

## :clapper: Tampilan Menu Utama
Berikut tampilan dashboard RShiny:
<p align="center">
  <img width="700" height="450" src="assets/images/screenshot.png">
</p>

## :film_projector: Demo

Berikut link untuk shinnyapps atau dashboard dari project kami: linkkk

## :sparkles: Fitur Aplikasi

Website **Pariwisata Jawa Barat** dilengkapi dengan berbagai fitur yang mempermudah pengguna dalam menemukan dan menganalisis informasi wisata, antara lain:

- **Pencarian Destinasi Wisata** 🔍  
  Pengguna dapat mencari tempat wisata berdasarkan kategori, lokasi, atau kata kunci tertentu.  

- **Visualisasi Data Wisata** 📊  
  Dashboard interaktif menampilkan grafik dan statistik jumlah wisatawan, tren kunjungan, serta popularitas destinasi wisata.  

- **Peta Interaktif** 🗺️  
  Menggunakan **Leaflet**, pengguna dapat melihat lokasi destinasi wisata dalam bentuk peta interaktif dengan marker dan informasi detail.  

- **Detail Destinasi Wisata** 🏝️  
  Setiap destinasi dilengkapi dengan deskripsi lengkap, foto, rating, serta informasi fasilitas yang tersedia.  

- **Analisis Tren Wisata** 📈  
  Menyediakan analisis data berdasarkan kategori wisata, musim liburan, serta perbandingan kunjungan antar daerah di Jawa Barat.  

- **Rekomendasi Wisata** 🌟  
  Sistem memberikan rekomendasi destinasi wisata berdasarkan kategori yang paling banyak diminati oleh wisatawan.

### Software
- R Studio
- TablePlus untuk manajemen database
- Git & GitHub untuk version control

### Packages R
- `shiny` dan `shinydashboard` untuk pembuatan dashboard interaktif.
- `DT` untuk menampilkan data tables.
- `dplyr` untuk manipulasi data.
- `ggplot2` untuk visualisasi.
- `leaflet` untuk peta interaktif.

Pada pembuatan Data Base
- `RMySQL` untuk koneksi dan eksekusi query MySQL dari R.
- `BI` sebagai antarmuka standar untuk database di R.
- `glue` untuk menyusun query SQL secara dinamis.
- `readr`untuk membaca dan menulis file CSV/TSV dengan cepat.
- `tools` untuk manipulasi file dan path.

## :atom: Skema

Skema perancangan sistem kami:

## :books: ERD

ERD (Entity Relationship Diagram) menggambarkan hubungan antar entitas dalam sistem:

## :open_book: Deskripsi Data

Berikut adalah struktur tabel dalam database Wisata Jawa Barat:

**Create Database**
**Create Table Kab/Kot**
**Create Table Kecamatan**
**Create Table Kelurahan**
**Create Table Wisata**

## :file_folder: Struktur Project
```
.
├── app/
│   ├── server.R          # Logic server RShiny
│   ├── ui.R              # Interface RShiny
│   └── global.R          # Global variables dan functions
├── data/
│   ├── raw/              # Data mentah
│   └── processed/        # Data yang sudah diolah
├── www/
│   ├── images/           # Gambar-gambar yang digunakan
│   └── style.css         # Custom CSS
├── scripts/
│   ├── data_prep.R       # Script pengolahan data
│   └── functions.R       # Helper functions
└── README.md
```

  


## :owl: Tim Pengembang

**Kelompok 6**

**Front End Developer:**
- [Ngurah](https://github.com/ngurahsentana24)
  - Pengembangan ui.R
  - Desain interface dan komponen
  - Implementasi CSS 
  - User experience optimization

**Back End Developer:**
- [Sunan](https://github.com/mhmmd25)
  - Pengembangan server.R
  - Implementasi logika bisnis
  - API development
  - Data processing

**Database Manager:**
- [Desy](https://github.com/desyendriani)
  - Manajemen database
  - Data administration
  - Backup dan recovery
  - Performance monitoring

**Database Designer:**
- [Rara](https://github.com/zahralatifah)
  - Perancangan struktur database
  - Schema design
  - Query optimization
  - Database architecture

**Technical Writer:**
- [Fani](https://github.com/fanifahira)
  - Dokumentasi teknis
  - User guide
  - Testing dan QA
  - Knowledge base management

 **Lisensi**: Proyek ini dibuat untuk keperluan akademik dan bersifat open-source.

