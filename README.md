## Explore Jabar 🏞️
📌 *Jelajahi keindahan alam, budaya, dan sejarah Jawa Barat dalam satu platform!*

<p align="center">
   <img width="900" height="500" src="https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Header.ReadMe.gif">
</p>

**Explore Jabar** adalah aplikasi berbasis RShiny yang bertujuan untuk menyediakan informasi terkini tentang pariwisata di wilayah Jawa Barat. Aplikasi ini menggunakan data dari berbagai sumber untuk menampilkan analisis dan visualisasi yang membantu pengguna dalam merencanakan perjalanan wisata mereka. </p>

*Satu Klik untuk Eksplorasi Tanpa Batas!* 🚀

## :classical_building: Menu

<table>
  <tr>
    <td style="vertical-align: top; width: 50%;">
      <ul>
        <li><a href="#basecampy-welcome">Welcome</a></li>
        <li><a href="#clapper-tampilan-menu-utama">Tampilan Menu Utama</a></li>
        <li><a href="#film_projector-demo">Demo</a></li>
        <li><a href="#sparkles-fitur-aplikasi">Fitur</a></li>
        <li><a href="#computer-software">Software</a></li>
        <li><a href="#package-packages-r">Packages R</a></li>
      </ul>
    </td>
    <td style="vertical-align: top; width: 50%;">
      <ul>
      </ul>
        <li><a href="#atom-skema">Skema</a></li>
        <li><a href="#books-erd">ERD</a></li>
        <li><a href="#open_book-deskripsi-data">Deskripsi Data</a></li>
        <li><a href="#file_folder-struktur-project">Folder Structure</a></li>
        <li><a href="#owl-tim-pengembang">Our Team</a></li>
      </ul>
    </td>
  </tr>
</table>

## :basecampy: Welcome

Selamat datang di **Explore Jabar**! </p>
Jawa Barat merupakan salah satu provinsi yang terletak di pulau Jawa dengan motto "*Gemah Ripah Repeh Rapih*". Platform ini menyajikan informasi lengkap tentang destinasi wisata di Jawa Barat. Seperti :</p>
- **Pantai** 🌊
- **Wisata Air** 💦
- **Wisata Alam** 🌳
- **Wisata Edukasi** 📚
- **Wisata Keagamaan** 🕌
- **Wisata Sejarah** 🏛️

Platfrom ini dikembangkan untuk membantu wisatawan menemukan dan mengeksplorasi keindahan alam serta budaya di seluruh wilayah Jawa Barat. </p>
🚀 Selamat menjelajah Wisata di Jawa Barat! 😊

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

## :computer: Software
- R Studio
- TablePlus untuk manajemen database
- Git & GitHub untuk version control

## :package: Packages R  
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

<p align="center">
   <img width="900" height="500" src="https://github.com/desyendriani/MDS_Kelompok_6/blob/main/doc/ERD.jpg">
</p>

## :open_book: Deskripsi Data

Berikut adalah struktur tabel dalam database Wisata Jawa Barat:

### :world_map: Pembuatan Database
Database *Wisata Jawa Barat* menyimpan informasi terkait lokasi wisata yang ada di berbagai wilayah di Jawa Barat, mencakup kabupaten/kota, kecamatan, kelurahan, tempat wisata, serta berbagai detail lainnya.

```sql
CREATE DATABASE wisata_jabar;
```

---

### :cityscape: Tabel `kabupaten_kota`
Tabel ini menyimpan data mengenai kabupaten/kota di Jawa Barat, termasuk kode wilayah, nama kabupaten/kota, ibu kota, dan jumlah penduduk.

| Atribut                  | Tipe Data             | Deskripsi                                 |
|--------------------------|----------------------|-------------------------------------------|
| kode_kabupaten_kota      | VARCHAR(100)        | Kode unik untuk kabupaten/kota           |
| nama_kabupaten_kota      | VARCHAR(100)        | Nama kabupaten/kota                      |
| ibukota                  | VARCHAR(100)        | Nama ibu kota dari kabupaten/kota        |
| jumlah_penduduk          | INT                 | Jumlah penduduk di kabupaten/kota        |

```sql
CREATE TABLE IF NOT EXISTS kabupaten_kota (
  kode_kabupaten_kota VARCHAR(100) PRIMARY KEY,
  nama_kabupaten_kota VARCHAR(100) NOT NULL,
  ibukota VARCHAR(100) NOT NULL,
  jumlah_penduduk INT
);
```

---

### :houses: Tabel `kecamatan`
Tabel ini menyimpan data kecamatan yang ada di setiap kabupaten/kota.

| Atribut                  | Tipe Data             | Deskripsi                                 |
|--------------------------|----------------------|-------------------------------------------|
| kode_kecamatan          | VARCHAR(100)        | Kode unik kecamatan                      |
| nama_kecamatan          | VARCHAR(100)        | Nama kecamatan                           |
| kode_kabupaten_kota      | VARCHAR(100)        | Kode kabupaten/kota yang menaungi kecamatan |
| jumlah_penduduk_kecamatan | INT                 | Jumlah penduduk di kecamatan             |

```sql
CREATE TABLE IF NOT EXISTS kecamatan (
  kode_kecamatan VARCHAR(100) PRIMARY KEY,
  nama_kecamatan VARCHAR(100) NOT NULL,
  kode_kabupaten_kota VARCHAR(100) NOT NULL,
  jumlah_penduduk_kecamatan INT,
  FOREIGN KEY (kode_kabupaten_kota) REFERENCES kabupaten_kota(kode_kabupaten_kota)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
```

---

### :house: Tabel `kelurahan`
Tabel ini menyimpan data kelurahan yang ada dalam setiap kecamatan.

| Atribut                  | Tipe Data             | Deskripsi                                 |
|--------------------------|----------------------|-------------------------------------------|
| kode_kelurahan          | VARCHAR(100)        | Kode unik kelurahan                      |
| nama_kelurahan          | VARCHAR(100)        | Nama kelurahan                           |
| kode_kecamatan          | VARCHAR(100)        | Kode kecamatan yang menaungi kelurahan   |
| jumlah_penduduk_kelurahan | INT                 | Jumlah penduduk di kelurahan             |

```sql
CREATE TABLE IF NOT EXISTS kelurahan (
  kode_kelurahan VARCHAR(100) PRIMARY KEY,
  nama_kelurahan VARCHAR(100) NOT NULL,
  kode_kecamatan VARCHAR(100) NOT NULL,
  jumlah_penduduk_kelurahan INT,
  FOREIGN KEY (kode_kecamatan) REFERENCES kecamatan(kode_kecamatan)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
```

---

### :national_park: Tabel `tempat_wisata`
Tabel ini menyimpan informasi tentang tempat wisata yang ada di setiap kabupaten/kota, kecamatan, dan kelurahan.

| Atribut       | Tipe Data      | Deskripsi                                 |
|--------------|--------------|-------------------------------------------|
| kode_wisata  | VARCHAR(100)  | Kode unik untuk setiap tempat wisata     |
| tipe_wisata  | VARCHAR(100)  | Jenis wisata (alam, budaya, kuliner, dll) |
| nama_wisata  | VARCHAR(100)  | Nama tempat wisata                       |
| kode_kabupaten_kota | VARCHAR(100) | Kode kabupaten/kota tempat wisata berada |
| kode_kecamatan | VARCHAR(100) | Kode kecamatan tempat wisata berada      |
| kode_kelurahan | VARCHAR(100) | Kode kelurahan tempat wisata berada      |
| deskripsi    | TEXT         | Deskripsi singkat tentang tempat wisata  |
| harga_tiket  | VARCHAR(100)  | Harga tiket masuk                        |
| rating       | DECIMAL(3,1) CHECK (rating BETWEEN 1.0 AND 5.0) | Rating wisata |
| alamat       | VARCHAR(255)  | Alamat lengkap tempat wisata             |
| created_at   | TIMESTAMP DEFAULT CURRENT_TIMESTAMP | Waktu data dibuat |

```sql
CREATE TABLE IF NOT EXISTS tempat_wisata (
  kode_wisata VARCHAR(100) PRIMARY KEY,
  tipe_wisata VARCHAR(100),
  nama_wisata VARCHAR(100) NOT NULL,
  kode_kabupaten_kota VARCHAR(100) NOT NULL,
  kode_kecamatan VARCHAR(100) NOT NULL,
  kode_kelurahan VARCHAR(100) NOT NULL,
  deskripsi TEXT,
  harga_tiket VARCHAR(100),
  rating DECIMAL(3,1) CHECK (rating BETWEEN 1.0 AND 5.0),
  alamat VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (kode_kabupaten_kota) REFERENCES kabupaten_kota(kode_kabupaten_kota)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (kode_kecamatan) REFERENCES kecamatan(kode_kecamatan)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (kode_kelurahan) REFERENCES kelurahan(kode_kelurahan)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
```

---

### :bar_chart: Tabel `detail_wisata`
Tabel ini menyimpan detail tambahan terkait tempat wisata, seperti jumlah ulasan, koordinat lokasi, dan gambar.

| Atribut       | Tipe Data      | Deskripsi                                 |
|--------------|--------------|-------------------------------------------|
| kode_wisata  | VARCHAR(100)  | Kode tempat wisata                       |
| jumlah_ulasan | INT          | Jumlah ulasan yang diberikan pengunjung  |
| latitude     | VARCHAR(100)  | Koordinat latitude tempat wisata         |
| longitude    | VARCHAR(100)  | Koordinat longitude tempat wisata        |
| image        | TEXT         | URL atau path gambar tempat wisata       |

```sql
CREATE TABLE IF NOT EXISTS detail_wisata (
  kode_wisata VARCHAR(100) PRIMARY KEY,
  jumlah_ulasan INT,
  latitude VARCHAR(100),
  longitude VARCHAR(100),
  image TEXT,
  FOREIGN KEY (kode_wisata) REFERENCES tempat_wisata(kode_wisata)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
```

## :file_folder: Struktur Project
.
├── app/  
│   ├── ui.r                 # Interface untuk aplikasi RShiny  
│  
├── data/  
│   ├── data                 # Folder utama penyimpanan data  
│   ├── detail_kab.csv       # Data detail kabupaten  
│   ├── detail_wisata.csv    # Data detail tempat wisata  
│   ├── kabupaten_kota.csv   # Data daftar kabupaten/kota  
│   ├── kecamatan.csv        # Data kecamatan  
│   ├── kelurahan.csv        # Data kelurahan  
│   ├── tempat_wisata.csv    # Data tempat wisata  
│  
├── doc/  
│   ├── ERD                 # Dokumentasi ERD (Entity Relationship Diagram)  
│  
├── src/  
│   ├── Wisata Jabar.Rmd     # Laporan atau dokumentasi dalam format RMarkdown  
│  
├── Image/                   # Folder untuk menyimpan gambar atau assets  


## :owl: Tim Pengembang

**Kelompok 6**

</p>
<img src="https://github.com/desyendriani/MDS_Kelompok_6/blob/main/Image/Alun-Alun%20Kota%20Banjar%20-%201.jpg?raw=true" width="500" align="left" style="margin-right: 50px;">  

   **🖥️ Front End Developer:** <br>
   [I Gusti Ngurah Sentana Putra (M0501241019)](https://github.com/ngurahsentana24) <br>
         - Pengembangan ui.R <br>
         - Desain interface dan komponen<br> 
         - Implementasi CSS <br>
         - User experience optimization<br>

         Github    : ngurahsentana24
         Instagram : @ngurahsentana24
<br>
<br>
<br>
<br>

**Back End Developer:** [Muh. Sunan (M0501241018)](https://github.com/mhmmd25)
  - Pengembangan server.R
  - Implementasi logika bisnis
  - API development
  - Data processing

**Database Manager:** [Desy Endriani (M0501241051)](https://github.com/desyendriani)
  - Manajemen database
  - Data administration
  - Backup dan recovery
  - Performance monitoring

**Database Designer:** [Latifah Zahra (M0501241075)](https://github.com/zahralatifah)
  - Perancangan struktur database
  - Schema design
  - Query optimization
  - Database architecture

**Technical Writer:** [Fani Fahira (M0501241052) ](https://github.com/fanifahira)
  - Dokumentasi teknis
  - User guide
  - Testing dan QA
  - Knowledge base management

 **Lisensi**: Proyek ini dibuat untuk keperluan akademik dan bersifat open-source.

 

