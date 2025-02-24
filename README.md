# Pariwisata Jawa Barat

<p align="center">
  <img width="900" height="500" src="assets/images/header.png">
</p>

## :classical_building: Menu

- [Welcome](#basecampy-welcome)
- [Deskripsi](#spiral_notepad-deskripsi)
- [Tampilan Menu Utama](#clapper-tampilan-menu-utama)
- [Demo](#film_projector-demo)
- [Features](#sparkles-fitur-aplikasi)
- [Skema](#atom-skema)
- [ERD](#books-erd)
- [Data Description](#open_book-deskripsi-data)
- [Folder Structure](#file_folder-struktur-project)
- [Our Team](#owl-tim-pengembang)

## :basecampy: Welcome

Selamat datang di **Pariwisata Jawa Barat**! 
Platform ini menyajikan informasi lengkap tentang destinasi wisata di Jawa Barat. Website ini dikembangkan untuk membantu wisatawan menemukan dan mengeksplorasi keindahan alam serta budaya Jawa Barat.
- **Pantai** 🌊
- **Wisata Air** 💦
- **Wisata Alam** 🌳
- **Wisata Edukasi** 📚
- **Wisata Keagamaan** 🕌
- **Wisata Sejarah** 🏛️

## :spiral_notepad: Deskripsi

Jawa Barat merupakan salah satu provinsi yang terletak di pulau Jawa dengan motto "Gemah Ripah Repeh Rapih". Website ini dirancang untuk memudahkan wisatawan dalam menemukan destinasi wisata menarik di seluruh wilayah Jawa Barat. Project ini merupakan implementasi dari dashboard interaktif menggunakan RShiny untuk menampilkan dan menganalisis data pariwisata Jawa Barat. 

🚀 Selamat menjelajah Wisata Jawa Barat! 😊

### Packages R
- `shiny` dan `shinydashboard` untuk pembuatan dashboard interaktif
- `DT` untuk menampilkan data tables
- `dplyr` untuk manipulasi data
- `ggplot2` untuk visualisasi
- `leaflet` untuk peta interaktif

### Software
- R Studio
- TablePlus untuk manajemen database
- Git & GitHub untuk version control

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

