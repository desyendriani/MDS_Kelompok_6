# Pariwisata Jawa Barat

Sebuah platform digital yang menyajikan informasi lengkap tentang destinasi wisata di Jawa Barat. Website ini dikembangkan untuk membantu wisatawan menemukan dan mengeksplorasi keindahan alam serta budaya Jawa Barat.

<p align="center">
  <img width="900" height="500" src="assets/images/header.png">
</p>

## :classical_building: Menu

- [Welcome](#basecampy-welcome)
- [Deskripsi](#spiral_notepad-deskripsi)
- [Requirements](#page_with_curl-requirements)
- [Screenshot](#clapper-screenshot)
- [Demo](#film_projector-demo)
- [Struktur Project](#file_folder-struktur-project)
- [Tim Pengembang](#owl-tim-pengembang)

## :basecampy: Welcome

Selamat Datang di platform Wisata Jawa Barat. Platform ini menyajikan berbagai destinasi wisata yang indah, menarik, dan menambah khazanah pengetahuan anda. Terdapat 6 kategori wisata utama:

- Pantai
- Wisata Air
- Wisata Alam
- Wisata Edukasi
- Wisata Keagamaan
- Wisata Sejarah

## :spiral_notepad: Deskripsi

Jawa Barat merupakan salah satu provinsi yang terletak di pulau Jawa dengan motto "Gemah Ripah Repeh Rapih". Website ini dirancang untuk memudahkan wisatawan dalam menemukan destinasi wisata menarik di seluruh wilayah Jawa Barat. Project ini merupakan implementasi dari dashboard interaktif menggunakan RShiny untuk menampilkan dan menganalisis data pariwisata Jawa Barat.

## :page_with_curl: Requirements

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

## :clapper: Screenshot
Berikut tampilan dashboard RShiny:
<p align="center">
  <img width="700" height="450" src="assets/images/screenshot.png">
</p>

## :film_projector: Demo

Aplikasi dapat diakses melalui:
[https://your-username.shinyapps.io/wisata-jabar/](https://your-username.shinyapps.io/wisata-jabar/)

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

## :gear: Teknologi yang Digunakan
- **R dan RShiny**: Framework utama untuk pembuatan dashboard interaktif
- **TablePlus**: Tools untuk mengelola dan mengakses database
- **GitHub**: Version control dan kolaborasi project
- **ShinyApps.io**: Hosting untuk aplikasi RShiny

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
