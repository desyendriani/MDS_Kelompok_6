#---------------------- Library --------------------------
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(DT)
library(bs4Dash)
library(plotly)
library(slickR)
library(ggplot2)
library(dplyr)
library(readr)
library(leaflet)
library(writexl)
library(rmarkdown)
library(scales)
library(RMySQL)
library(DBI)
library(tm)
library(stringr)
library(tidytext)
library(wordcloud2)

# Konfigurasi database
db_config <- list(
  host = "127.0.0.1",
  port = 3306,          # Port MySQL di DBngin
  user = "root",
  password = "",
  dbname = "wisata_jabar"    # Nama database yang akan digunakan
)

# Membuat koneksi ke database
con_db <- dbConnect(
  MySQL(),
  host = db_config$host,
  port = db_config$port,
  user = db_config$user,
  password = db_config$password,
  dbname = db_config$dbname
)

query_gabungan <- "
SELECT 
    tw.*,  
    k.Nama_Kabkot, 
    k.Ibukota, 
    k.Jml_pddk, 
    kc.Nama_Kec, 
    kc.Jml_pddk_kec, 
    kel.Nama_Kel, 
    kel.Jml_pddk_kel, 
    dw.Jumlah_Ulasan, 
    dw.Latitude, 
    dw.Longitude, 
    dw.Image, 
    dk.Jumlah_Masjid, 
    dk.Jumlah_Restoran, 
    dk.Jumlah_Wisatawan, 
    dk.PDRB
FROM 
    tempat_wisata tw
LEFT JOIN 
    kelurahan kel ON tw.Kode_Kel = kel.Kode_Kel
LEFT JOIN 
    kecamatan kc ON tw.Kode_Kec = kc.Kode_Kec
LEFT JOIN 
    kabupaten_kota k ON tw.Kode_kabkot = k.Kode_kabkot
LEFT JOIN 
    detail_wisata dw ON tw.Kode_Wisata = dw.Kode_Wisata
LEFT JOIN 
    detail_kab dk ON k.Kode_kabkot = dk.Kode_kabkot
"

# Eksekusi query dan ambil hasilnya
wisata_data <- dbGetQuery(con_db, query_gabungan)
print(wisata_data)

wisata_data <- wisata_data %>% 
  mutate(
    Harga_Tiket_Bersih = str_remove(Harga_Tiket, "/orang"),
    Harga_Tiket_Bersih = str_remove(Harga_Tiket_Bersih, "/orang\""),
    Harga_Tiket_Bersih = str_remove(Harga_Tiket_Bersih, "/dewasa"),
    Harga_Tiket_Bersih = case_when(
      Harga_Tiket_Bersih == "Gratis" ~ "0",
      TRUE ~ Harga_Tiket_Bersih
    ),
    Harga_Tiket_Bersih = if_else(
      str_detect(Harga_Tiket_Bersih, "-"), 
      as.numeric(str_extract(Harga_Tiket_Bersih, "^[0-9]+")),  
      suppressWarnings(as.numeric(Harga_Tiket_Bersih))
    )
  ) %>% 
  arrange(desc(Rating))  # Urutkan berdasarkan rating terbesar ke terkecil


#-------------------- UI (Tampilan Front-End) ---------------
ui <- dashboardPage(
  ##------------------------ Header -----------------------------
  dashboardHeader(
    title = div(style = "text-align: center;", 
                img(src = "https://upload.wikimedia.org/wikipedia/commons/9/99/Coat_of_arms_of_West_Java.svg", height = 100, width = 100, style = "margin-bottom: 15px;"), 
                h1("Jawa Barat", style = "color: #00000; font-size: 38px; font-weight: bold; margin-top: -20px;"), 
                p(strong("Gemah Ripah Repeh Rapih"), style = "color: #00000; background-color: #f8e5b3; font-size: 14px; margin-top: -5px; font-family: 'Poplin', sans-serif;"), 
                textOutput("tanggal"),
                tags$hr(style = "border-top: 2px solid #007bff; margin: 10px 0;")  # Horizontal line
    ), 
    titleWidth = 400
  ),
  
  ##------------------------ SideBar -----------------------------
  dashboardSidebar(
    collapsed = FALSE,
    sidebarMenu(
      menuItem("Home", tabName = "beranda", icon = icon("home")),
      menuItem("Wisata", tabName = "wisata", icon = icon("mountain-sun")),
      menuItem("Kabupaten/Kota", tabName = "kota", icon = icon("building")),
      menuItem("Kecamatan", tabName = "kecamatan", icon = icon("map-marker-alt")),
      menuItem("Team", tabName = "info", icon = icon("users-line"))
    )
  ),
  
  ##------------------------  Body --------------------------------
  dashboardBody(
    tags$head(
      tags$style(HTML("
      .youtube-video {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: -1; /* Send it to the back */
      }
    "))
    ),
    tags$iframe(
      src = "https://www.youtube.com/embed/aKtb7Y3qOck?autoplay=1&loop=1&playlist=aKtb7Y3qOck",
      width = "100%",
      height = "100%",
      frameborder = "0",
      allow = "autoplay; encrypted-media",
      allowfullscreen = TRUE,
      class = "youtube-video"
    ),
    tabItems(
      ###----------------------------- Home ---------------------------------
      tabItem(
        tabName = "beranda",
        jumbotron(
          title = div(
            img(src = "https://upload.wikimedia.org/wikipedia/commons/9/99/Coat_of_arms_of_West_Java.svg", height = 300, width = 350, style = "align-items: center"),
            div(
              "Explore Pariwisata",
              style = "font-size: 54px; font-weight: bold; text-align: center;"
            ),
            div(
              "Jawa Barat",
              style = "font-size: 36px; font-weight: bold; text-align: center;"
            ),
            style = "text-align: center;"
          ),
          lead = div(
            span("Selamat Datang di Jawa Barat!", style = "font-size:20px; font-weight:bold; background-color: #f8e5b3; padding: 10px; border-radius: 40px; margin-bottom: 20px;"),
            p("Jelajahi keindahan alam, budaya, dan sejarah Jawa Barat dalam satu platform!", 
              style = "font-size: 18px; text-align: center; margin-top: 20px;"),
            style = "text-align: center;"
          ),
          href = "https://disparbud.jabarprov.go.id",
          status = "warning"
        ),
        fluidRow(
          box(title = "Keindahan Alam Jawa Barat", status = "primary", width = 12,
              slickROutput("slideshow", width = "100%", height = "400px"))
        ),
        
        # New FluidRow for Icons
        fluidRow(
          column(4, align = "center",
                 box(
                   title = "For Wisatawan",
                   icon = icon("user"),
                   status = "info",
                   solidHeader = TRUE,
                   width = NULL,
                   "Informasi dan layanan untuk wisatawan. Wisatawan dapat mencari destinasi berdasarkan kategori, lokasi, atau popularitas, sehingga lebih mudah menyusun itinerary perjalanan. Sistem dapat menyarankan tempat wisata yang sesuai dengan minat pengguna berdasarkan preferensi wisatawan lain serta membaca pengalaman dan rekomendasi dari pengguna lain sebelum mengunjungi suatu tempat."
                 )
          ),
          column(4, align = "center",
                 box(
                   title = "For Provincial Government",
                   icon = icon("building"),
                   status = "success",
                   solidHeader = TRUE,
                   width = NULL,
                   "Mendukung pengelolaan dan pengembangan sektor pariwisata. Dengan data dan analisis yang disajikan, pemerintah dapat mengambil keputusan yang lebih tepat sasaran, berbasis data, dan berorientasi pada pertumbuhan ekonomi daerah.
"
                 )
          ),
          column(4, align = "center",
                 box(
                   title = "For Regional Government",
                   icon = icon("city"),
                   status = "warning",
                   solidHeader = TRUE,
                   width = NULL,
                   "Informasi dan layanan strategis bagi pemerintah daerah dalam mengelola dan mengembangkan sektor pariwisata di wilayahnya. Pemerintah daerah dapat lebih mudah mengelola, mempromosikan, dan meningkatkan kualitas sektor pariwisata, menjadikannya sebagai salah satu motor penggerak ekonomi wilayah."
                 )
          )
        ),
        fluidRow(
          column(12, 
                 # Menampilkan gambar user manual
                 img(src = "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Dashboard/usermanual.jpeg", 
                     style = "width: 100%; height: auto;"),
                 div(style = "text-align: center; margin-top: 20px;",
                    downloadButton("downloadManual", "Download User Manual", class = "btn-primary", style = "font-size: 20px; padding: 15px 30px; margin-bottom: 20px")
                 )
          )
        ),
        fluidRow(
          box(title = "Video Pariwisata Jawa Barat", status = "primary", width = 12, 
              HTML('<iframe width="100%" height="400" src="https://www.youtube.com/embed/iM4Gf9XkfKY" frameborder="0" allowfullscreen></iframe>')
          )
        ),
        fluidRow(
          column(12, align = "center",
                 actionButton("chat_whatsapp_team", "Chat via WhatsApp", icon = icon("whatsapp"), 
                              style = "background-color: #25D366; color: white; font-weight: bold;")
          )
        )
      ),
      
      ###----------------------------- Wisata ---------------------------------
      tabItem(
        tabName = "wisata",
        fluidRow(
          valueBox(
            value = div(style = "font-size: 32px; font-weight: bold;", length(wisata_data$Kode_Wisata)),
            subtitle = div(style = "font-size: 20px; font-weight: bold;", "Total Wisata"),
            icon = icon("home", lib = "font-awesome"), 
            color = "primary", 
            width = 4
          ),
          valueBox( 
            value = div(style = "font-size: 32px; font-weight: bold;", 
                        prettyNum(sum(wisata_data$Jumlah_Ulasan), big.mark = ".", decimal.mark = ".", digits = 2)
            ),
            subtitle = div(style = "font-size: 20px; font-weight: bold;", "Total Ulasan"),
            icon = icon("users", lib = "font-awesome"), 
            color = "danger", 
            width = 4
          ),
          valueBox(
            value = div(style = "font-size: 32px; font-weight: bold;", round(mean(wisata_data$Rating, na.rm = TRUE), 2)),
            subtitle = div(style = "font-size: 20px; font-weight: bold;", "Rata Rata Rating"),
            icon = icon("star", lib = "font-awesome"), 
            color = "warning",
            width = 4
          )
        ),
        
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Peta Lokasi Wisata"), width = 12, 
              leafletOutput("wisata_map", height = 500),
              style = "border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);",
              solidHeader = TRUE,
              status = "primary"
          )
        ),
        
        fluidRow(
          box(
            title = div(
              style = "font-size: 20px; font-weight: bold; background-color: #007bff; color: white; padding: 10px; border-radius: 10px;", 
              "Filter Wisata"
            ),
            uiOutput("filter_wisata"), 
            width = 6,
            solidHeader = TRUE,
            status = "primary",
            style = "background-color: #e7f3ff;"
          ),
          box(
            title = div(
              style = "font-size: 20px; font-weight: bold; background-color: #007bff; color: white; padding: 10px; border-radius: 10px;", 
              "Minimum Rating"
            ),
            sliderInput("rating_filter", "Minimum Rating:", min = 0, max = 5, value = 0, step = 0.1),
            width = 6,
            solidHeader = TRUE,
            status = "primary",
            style = "background-color: #e7f3ff;"
          )
        ),
        
        # New Box for Tourist Attractions
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Wisata Berdasarkan Rating"), width = 6,
              dataTableOutput("top5_wisata_table"),
              style = "background-color: #ffffff; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);",
              solidHeader = TRUE,
              status = "primary"
          ),
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Detail Wisata yang Dipilih"), width = 6,
              uiOutput("selected_wisata_details"),
              style = "background-color: #ffffff; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);",
              solidHeader = TRUE,
              status = "primary"
          )
        ),
        
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Distribusi Tipe Wisata"), width = 6, 
              plotOutput("typePlotWisata"),
              style = "background-color: #ffffff; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);",
              solidHeader = TRUE,
              status = "primary"
          ),
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Distribusi Rating Wisata"), width = 6, 
              plotOutput("ratingPlot"),
              style = "background-color: #ffffff; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);",
              solidHeader = TRUE,
              status = "primary"
          )
        ),
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Rata-rata Harga Tiket Berdasarkan Tipe Wisata"), width = 6, 
              plotOutput("pricePlot"),
              style = "background-color: #ffffff; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);",
              solidHeader = TRUE,
              status = "primary"
          ),
          box(title = div(style = "font-size: 20px; font-weight: bold;",  "Jumlah Wisata Berdasarkan Kabupaten"), width = 6, 
              plotOutput("countyPlot"),
              style = "background-color: #ffffff; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);",
              solidHeader = TRUE,
              status = "primary"
          )
        ),
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;",  "Pilih Jumlah Cluster"), width = 6,
              sliderInput("num_clusters", "Jumlah Cluster:", min = 2, max = 10, value = 3),
              solidHeader = TRUE,
              status = "primary"
          )
        ),
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Visualisasi Clustering"), width = 12,
              plotOutput("clustering_plot"),
              solidHeader = TRUE,
              status = "primary"
          )
        ), 
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Hasil Clustering"), width = 12,
              tableOutput("clustering_results"),
              solidHeader = TRUE,
              status = "primary"
          )
        ),
        
        # Fluid row with the title "Interaktif Interaction"
        fluidRow(
          column(12, 
                 h2(class = "title", 
                    style = "font-size: 36px; color: #007BAC; text-align: center; background-color: #f0f8ff; padding: 15px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); transition: transform 0.2s;", 
                    strong("Interaktif"), " Interaction"),
                 p(class = "description", 
                   style = "font-size: 20px; color: #555; text-align: center; background-color: #f0f8ff; padding: 15px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); transition: transform 0.2s;", 
                   "Eksplorasi interaksi yang menarik!"),
                 style = "margin-top: 20px; margin-bottom: 20px;"  # Menambahkan margin atas dan bawah untuk spasi
          )
        ),
        
        fluidRow(
          box(
            title = div(style = "font-size: 20px; font-weight: bold;", "Pilih Wisata untuk Total Biaya"), 
            width = 6,
            selectInput("selected_wisata", "Pilih Wisata", 
                        choices = NULL, multiple = TRUE),
            actionButton("calculate_cost", "Hitung Total Biaya", 
                         style = "background-color: #007bff; color: white; font-weight: bold;"),
            solidHeader = TRUE,
            status = "primary"
          ),
          box(
            title = div(style = "font-size: 20px; font-weight: bold;", "Informasi Perjalanan Wisata"), 
            width = 6,
            div(style = "font-size: 20px; font-weight: normal;", textOutput("total_cost")),
            div(style = "font-size: 20px; font-weight: normal;", textOutput("total_distance")),
            div(style = "font-size: 20px; font-weight: normal;", textOutput("fuel_consumption")),
            div(style = "font-size: 20px; font-weight: normal;", textOutput("estimated_time")),
            div(style = "font-size: 20px; font-weight: normal;", textOutput("grand_total")),
            uiOutput("google_maps_link"),  # Link to Google Maps
            downloadButton("download_data", "Download Data as Excel", 
                           style = "background-color: #007bff; color: white; font-weight: bold;"),
            solidHeader = TRUE,
            status = "primary"
          ),
          box(
            title = div(style = "font-size: 24px; font-weight: bold;", "Detail Wisata yang Dipilih"), 
            width = 12,
            dataTableOutput("selected_wisata_table"),
            solidHeader = TRUE,
            status = "primary"
          )
        ),
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Rekomendasi Rute Wisata"), width = 12, solidHeader = TRUE, status = "primary",
              uiOutput("filter_kabupaten_rute"),  # Dropdown for selecting districts
              numericInput("budget", "Masukkan Budget (IDR):", value = 0, min = 0),  # Input for budget
              radioButtons("starting_point", "Pilih Titik Awal:",
                           choices = list("Pusat Kota Bandung" = "bandung_center",
                                          "Bandara" = "airport",
                                          "Pelabuhan" = "port",
                                          "Link Google Maps" = "custom"),
                           selected = "bandung_center"),  # Default selection
              conditionalPanel(
                condition = "input.starting_point == 'airport'",
                selectInput("selected_airport", "Pilih Bandara di Jawa Barat:",
                            choices = list(
                              "Husein Sastranegara International Airport" = "husein_sastranegara",
                              "Kertajati International Airport" = "kertajati",
                              "Cijulang Nusawiru Airport" = "cijulang",
                              "Sukabumi Airport" = "sukabumi"
                            ),
                            selected = "husein_sastranegara")  # Default selection
              ),
              conditionalPanel(
                condition = "input.starting_point == 'port'",
                selectInput("selected_port", "Pilih Pelabuhan di Jawa Barat:",
                            choices = list(
                              "Pelabuhan Patimban" = "patimban",
                              "Pelabuhan Cirebon" = "cirebon",
                              "Pelabuhan Muara Angke" = "muara_angke",
                              "Pelabuhan Tanjung Priok" = "tanjung_priok"
                            ),
                            selected = "patimban")  # Default selection
              ),
              conditionalPanel(
                condition = "input.starting_point == 'custom'",
                textInput("custom_gmaps", "Masukkan Link Google Maps:", placeholder = "https://www.google.com/maps/...")  # Input for custom link
              ),
              actionButton("recommend_route", "Rekomendasikan Wisata", style = "background-color: #007bff; color: white; font-weight: bold;")
          )
        ),
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Hasil Rekomendasi"), width = 12, solidHeader = TRUE, status = "primary",
              dataTableOutput("recommended_route_table")  # Table to display recommended routes
          )
        ),
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Peta Rute Wisata"), width = 12, solidHeader = TRUE, status = "primary",
              leafletOutput("recommended_route_map", height = 500)  # Map to display recommended routes
          )
        ),
        fluidRow(
          box(
            title = div(style = "font-size: 20px; font-weight: bold;", "Word Cloud dari Deskripsi Wisata"), 
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            img(src = "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Dashboard/wordcloud.png", 
                style = "max-width: 100%; height: auto;"),  # Responsive image
            textInput("keyword_filter", "Cari Kata Kunci:", placeholder = "Masukkan kata kunci..."),
            actionButton("filter_button", "Filter Wisata", style = "background-color: #007bff; color: white; font-weight: bold;"),
            dataTableOutput("filtered_wisata_table")
          )
        )
      ),
      
      
      ###----------------------------- Kabupaten/Kota ---------------------------------
      tabItem(
        tabName = "kota",
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Filter Kabupaten/Kota"), width = 12, solidHeader = TRUE,
              status = "primary",
              style = "background-color: #e7f3ff;", uiOutput("filter_kota")),
          solidHeader = TRUE,
          status = "primary"
        ),
        fluidRow(
          valueBoxOutput("jumlah_wisata_box", width = 4),
          valueBoxOutput("jumlah_restoran_box", width = 4),
          valueBoxOutput("jumlah_penduduk_box", width = 4)
        ),
        fluidRow(
          valueBoxOutput("jumlah_wisatawan_box", width = 4),
          valueBoxOutput("pdrb_box", width = 4),
          valueBoxOutput("jumlah_masjid_box", width = 4)
        ),
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Distribusi Tipe Wisata"), width =12, solidHeader = TRUE,
              status = "primary",plotOutput("typePlot")),
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Data Kabupaten"), width = 12, solidHeader = TRUE,
              status = "primary", dataTableOutput("kota_table"))
        ),
        
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Daya Tarik Wisata"), width = 12,
              p("Menurut Cooper dkk (1995: 81), terdapat 4 (empat) komponen yang harus dimiliki oleh sebuah objek wisata, yaitu:"),
              tags$ul(
                tags$li("Attraction: Daya tarik utama yang membuat wisatawan tertarik."),
                tags$li("Accessibility: Kemudahan akses menuju objek wisata."),
                tags$li("Amenity: Fasilitas yang mendukung kenyamanan wisatawan."),
                tags$li("Ancillary: Layanan tambahan yang meningkatkan pengalaman wisata.")
              ),
              dataTableOutput("kabupaten_table"),
              solidHeader = TRUE,
              status = "primary",
              style = "background-color: #f9f9f9; border-radius: 10px; padding: 15px; margin-bottom: 15px;"
          )
        ),
        
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: normal;","Perbandingan Kabupaten"), width = 12,
              solidHeader = TRUE,
              status = "primary",
              uiOutput("filter_kota_comparison"),
              tableOutput("comparison_results")
          ),
          box(title = div(style = "font-size: 20px; font-weight: normal;","Visualisasi Perbandingan"), width = 12,
              solidHeader = TRUE,
              status = "primary",
              fluidRow(
                column(6, plotOutput("jumlah_wisatawan_plot")),
                column(6, plotOutput("pdrb_plot")),
                column(6, plotOutput("jumlah_wisata_plot")),
                column(6, plotOutput("rata_rating_plot")),
                column(6, plotOutput("rata_ulasan_plot"))  
              )
          )
        ),
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: normal;","Pilih Variabel"), width = 4, 
              solidHeader = TRUE,
              status = "primary",
              uiOutput("filter_variabel_numeric")
              
          ),
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Evaluasi dan Interpretasi"), width = 8,
              solidHeader = TRUE,
              status = "primary",
              verbatimTextOutput("scatter_plot_evaluation"),
              style = "background-color: #ffffff; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);"
          )
        ),
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Scatter Plot"), width = 12,solidHeader = TRUE,
              status = "primary",
              plotOutput("scatter_plot"),
              style = "background-color: #ffffff; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);"
          )
        )
      ),
      
      ###----------------------------- Kecamatan ---------------------------------
      tabItem(
        tabName = "kecamatan",
        fluidRow(
          box(title = div(style = "font-size: 20px; font-weight: bold;","Filter Kecamatan"), width = 12, solidHeader = TRUE,
              status = "primary", style = "background-color: #e7f3ff;", uiOutput("filter_kecamatan")),
          box(title = div(style = "font-size: 20px; font-weight: bold;","Data Kecamatan"), width = 12, solidHeader = TRUE,
              status = "primary", dataTableOutput("kecamatan_table")),
          box(title = div(style = "font-size: 20px; font-weight: bold;", "Top 5 Wisata Terbaik"), width = 12,solidHeader = TRUE,
              status = "primary",dataTableOutput("top5_wisata_tableKec"),style = "background-color: #ffffff; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);"),
          box(title = div(style = "font-size: 20px; font-weight: bold;","Distribusi Wisata Berdasarkan Kelurahan"), width = 12,solidHeader = TRUE,
              status = "primary", plotOutput("kelurahanPlot")),
          box(title = div(style = "font-size: 20px; font-weight: bold;","Distribusi Rating Wisata Berdasarkan Kelurahan"), width = 12, solidHeader = TRUE,
              status = "primary",plotOutput("ratingKelurahanPlot")),
          box(title = div(style = "font-size: 20px; font-weight: bold;","Rata-rata Harga Tiket Berdasarkan Kelurahan"), width = 12, solidHeader = TRUE,
              status = "primary",plotOutput("hargaKelurahanPlot")),
          box(title = div(style = "font-size: 20px; font-weight: bold;","Jumlah Ulasan Berdasarkan Kelurahan"), width = 12, solidHeader = TRUE,
              status = "primary", plotOutput("ulasanKelurahanPlot"))
        )
      ),
      
      ###----------------------------- Team ---------------------------------
      tabItem(
        tabName = "info",
        fluidRow(
          column(12, align = "center",
                 div(
                   style = "font-size: 36px; font-weight: bold; color: #000; background-color: #f8e5b3; padding: 20px; border-radius: 10px; 
                    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); transition: background-color 0.3s, color 0.3s; display: inline-block; cursor: pointer;",
                   tags$span(icon("users"), style = "margin-right: 10px;"),  # Menambahkan ikon
                   "Our Amazing Team"
                 )
          )
        ),
        fluidRow(
          column(12, align = "center",
                 actionButton("chat_whatsapp_team", "Chat via WhatsApp", icon = icon("whatsapp"), 
                              style = "background-color: #25D366; color: white; font-weight: bold; margin bottom : 10px;")
          )
        ),
        fluidRow(
          column(12, align = "center",
                 img(src = "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Team/Full%20Squad.jpeg", 
                     width = "100%", style = "border-radius:10px; margin-bottom:15px;")
          )
        ),
        
        fluidRow(
          div(class = "d-flex justify-content-center flex-wrap", 
          box(
            title = div(style = "font-size: 20px; font-weight: bold;","Frontend Developer"),
            width = 4,
            img(src = "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Team/Ngurah.png", 
                width = "100%", style = "border-radius:10px; margin-bottom:15px;"),
            h3(class = "text-center", "Ngurah Sentana"),
            tags$a(href = "https://www.instagram.com/ngurahsentana24", class = "btn btn-primary btn-block", 
                   icon("instagram"), " Instagram"),
            tags$a(href = "https://github.com/ngurahsentana24", class = "btn btn-dark btn-block",
                   icon("github"), " GitHub")
          ),
          box(
            title = div(style = "font-size: 20px; font-weight: bold;","Technical Writer"),
            width = 4,
            img(src = "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Team/Fani.png", 
                width = "100%", style = "border-radius:10px; margin-bottom:15px;"),
            h3(class = "text-center", "Fani Fahira"),
            tags$a(href = "https://www.instagram.com/fanifahiraa/", class = "btn btn-primary btn-block", 
                   icon("instagram"), " Instagram"),
            tags$a(href = "https://github.com/fanifahira", class = "btn btn-dark btn-block",
                   icon("github"), " GitHub")
          ),
          box(
            title = div(style = "font-size: 20px; font-weight: bold;","Database Manager - Desy"),
            width = 4,
            img(src = "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Team/Desy.png", 
                width = "100%", style = "border-radius:10px; margin-bottom:15px;"),
            h3(class = "text-center", "Desy Endriani"),
            tags$a(href = "https://www.instagram.com/desy_endriani", class = "btn btn-primary btn-block", 
                   icon("instagram"), " Instagram"),
            tags$a(href = "https://github.com/desyendriani", class = "btn btn-dark btn-block",
                   icon("github"), " GitHub")
          ),
          box(
            title = div(style = "font-size: 20px; font-weight: bold;","Backend Developer"),
            width = 4,
            img(src = "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Team/SUNAN.png", 
                width = "100%", style = "border-radius:10px; margin-bottom:15px;"),
            h3(class = "text-center", "Muh Sunan"),
            tags$a(href = "https://www.instagram.com/m_sunan25?igsh=amxzZHFjanc4dXdv&utm_source=qr", class = "btn btn-primary btn-block", 
                   icon("instagram"), " Instagram"),
            tags$a(href = "https://github.com/mhmmd25", class = "btn btn-dark btn-block",
                   icon("github"), " GitHub")
          ),
          box(
            title = div(style = "font-size: 20px; font-weight: bold;","Designer DB"),
            width = 4,
            img(src = "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Team/Rara.png", 
                width = "100%", style = "border-radius:10px; margin-bottom:15px;"),
            h3(class = "text-center", "Latifah Zahra"),
            tags$a(href = "https://www.instagram.com/lzrara15/", class = "btn btn-primary btn-block", 
                   icon("instagram"), " Instagram"),
            tags$a(href = "https://github.com/zahralatifah", class = "btn btn-dark btn-block",
                   icon("github"), " GitHub")
          )
          )
        ),
        fluidRow(
          column(12, align = "center",  # Mengatur kolom agar berada di tengah
                 h3(
                   tags$span(icon("book-open"), style = "margin-right: 10px;"),  # Menambahkan ikon
                   "Dokumentasi Pengerjaan", 
                   style = "text-align: center; 
                    padding: 20px; 
                    background-color: #f8e5b3; 
                    color: #2c3e50; 
                    border-radius: 5px; 
                    font-weight: bold; 
                    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); 
                    transition: background-color 0.3s, color 0.3s; 
                    display: inline-block;  /* Agar padding berfungsi dengan baik */
                    cursor: pointer;  /* Menunjukkan bahwa ini interaktif */
                    "
                 ),
                 style = "margin-top: 20px; margin-bottom: 20px;"  # Menambahkan margin atas dan bawah untuk spasi
          )
        ),
        
        # Image grid
        fluidRow(
          column(4, div(class = "image-container", img(src = "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Team/Dokumen1.jpeg", class = "img-fluid"))),
          column(4, div(class = "image-container", img(src = "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Team/Dokumen2.jpeg", class = "img-fluid"))),
          column(4, div(class = "image-container", img(src = "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/main/Image/Team/Dokumen3.jpeg", class = "img-fluid")))
        )
      )
    )
  ),
  
  #-----------------FOOTER-----------------#
  footer = dashboardFooter(
    right = "© 2025 Kelompok 6. All rights reserved."
  )
)

#--------------------Server(Tampilan Back-End) ---------------
server <- function(input, output, session) {
  observeEvent(input$start_button, {
    # Hide the main content when the button is clicked
    shinyjs::hide("main_content")  # Hide the entire main content
    
    # Switch to the dashboard page (e.g., "beranda" tab)
    updateTabItems(session, "sidebar", selected = "beranda")  # Change "beranda" to the desired tab name
  })
  
  ##------------------------  Home ---------------------------------
  
  #======================= Slideshow Gambar =======================#
  output$slideshow <- renderSlickR({
    slickR(
      list(
        "https://d2s1u1uyrl4yfi.cloudfront.net/disparbud/slideshow/cc100156692eb022566b0739a5369349.webp", 
        "https://d2s1u1uyrl4yfi.cloudfront.net/disparbud/slideshow/062aa4b1ae5e52807ab7d57181caeafc.webp", 
        "https://d2s1u1uyrl4yfi.cloudfront.net/disparbud/slideshow/6ba3daa6b33667875dd1187e9c15893b.webp",
        "https://github.com/desyendriani/MDS_Kelompok_6/blob/main/Image/Curug%20Cigentis%20-%201.jpg?raw=true",
        "https://github.com/desyendriani/MDS_Kelompok_6/blob/main/Image/Curug%20Putri%20Palutungan%20-%201.jpeg?raw=true",
        "https://github.com/desyendriani/MDS_Kelompok_6/blob/main/Image/Curug%20Sidomba%20-%202.jpg?raw=true",
        "https://github.com/desyendriani/MDS_Kelompok_6/blob/main/Image/Gunung%20Papandayan%20-%201.jpg?raw=true",
        "https://github.com/desyendriani/MDS_Kelompok_6/blob/main/Image/Kampung%20Adat%20Ciptagelar%20-%202.png?raw=true",
        "https://github.com/desyendriani/MDS_Kelompok_6/blob/main/Image/Pantai%20Batu%20Hiu%20-%202.jpg?raw=true",
        "https://github.com/desyendriani/MDS_Kelompok_6/blob/main/Image/Taruma%20Leisure%20Waterpark%20-%202.jpg?raw=true",
        "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/refs/heads/main/Image/Curug%20Cikondang%20-%201.webp",
        "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/refs/heads/main/Image/Taman%20Safari%20-%202.webp",
        "https://raw.githubusercontent.com/desyendriani/MDS_Kelompok_6/refs/heads/main/Image/Waduk%20Darma%20-%201.webp"
      ), height = 400, width = "100%"
    ) + settings(autoplay = TRUE, autoplaySpeed = 3000, dots = TRUE)
  })
  
  ##------------------------  Wisata ---------------------------------
  
  #======================= Data Wisata =======================#
  wisata_data <- wisata_data
  
  #======================= Filter Wisata =======================#
  output$filter_wisata <- renderUI({
    unique_choices <- unique(wisata_data$Tipe_Wisata)
    choices <- c("Semua", unique_choices)
    
    selectInput("wisata_tipe", "Pilih Tipe Wisata", 
                choices = choices, 
                selected = "Semua")  # Ensure there's a default value
  })
  
  #======================= Data Wisata Sesuai Filter =======================#
  filtered_wisata <- reactive({
    req(input$wisata_tipe)  # Ensure input$wisata_tipe is not NULL
    req(input$rating_filter)  # Ensure input$rating_filter is not NULL
    
    filtered_data <- wisata_data
    
    # Filter by Tipe Wisata
    if (input$wisata_tipe != "Semua") {
      filtered_data <- filtered_data[filtered_data$Tipe_Wisata == input$wisata_tipe, ]
    }
    
    # Filter by Rating
    filtered_data <- filtered_data[filtered_data$Rating >= input$rating_filter, ]
    
    return(filtered_data)
  })
  
  #======================= Peta Interaktif dengan Filter =======================#
  output$wisata_map <- renderLeaflet({
    leaflet() %>%
      addTiles()
  })
  
  observe({
    filtered_data <- filtered_wisata()
    
    # Check for valid coordinates
    valid_data <- filtered_data %>%
      filter(!is.na(Latitude) & !is.na(Longitude) & is.finite(Latitude) & is.finite(Longitude))
    
    if (nrow(valid_data) > 0) {
      leafletProxy("wisata_map", data = valid_data) %>%
        clearMarkers() %>%
        addMarkers(
          lng = ~Longitude, lat = ~Latitude,
          popup = ~paste0(
            "<div style='font-family: Arial, sans-serif; width: 280px; padding: 10px; background: #f9f9f9; border-radius: 8px; box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1); text-align: center;'>
          <h4 style='margin: 5px 0; color: #333; font-size: 16px;'>", Nama_Wisata, "</h4>
          <img src='", Image, "' width='260px' height='150px' style='border-radius: 6px; margin-bottom: 8px;'>
          <p style='font-size: 13px; color: #666; margin-bottom: 5px;'><b>Nama_Kabkot:</b> ", Nama_Kabkot, "</p>
          <p style='font-size: 14px; font-weight: bold; color: #ff9800; margin-bottom: 5px;'>
            ⭐ ", Rating, " | ", Jumlah_Ulasan, " Ulasan</p>
          <p style='font-size: 12px; color: #444; text-align: justify;'>", Deskripsi, "</p>
        </div>"
          )
        ) %>%
        addCircleMarkers(
          lng = ~Longitude, lat = ~Latitude,
          radius = 8, color = "#ff5722", fill = TRUE, fillOpacity = 0.7
        ) %>%
        setView(lng = mean(valid_data$Longitude, na.rm = TRUE), 
                lat = mean(valid_data$Latitude, na.rm = TRUE), zoom = 10)
    } else {
      leafletProxy("wisata_map") %>%
        clearMarkers()  # Clear markers if no valid data
    }
  })
  
  #====================== Tabel Data Wisata ==========================#
  output$wisata_table <- renderDataTable({
    req(input$wisata_tipe)
    if (input$wisata_tipe == "Semua") {
      datatable(wisata_data[, c("Nama_Wisata", "Nama_Kabkot", "Nama_Kec","Nama_Kel","Tipe_Wisata", "Harga_Tiket", "Rating", "Jumlah_Ulasan")])
    } else {
      datatable(subset(wisata_data[, c("Nama_Wisata", "Nama_Kabkot", "Nama_Kec","Nama_Kel","Tipe_Wisata", "Harga_Tiket", "Rating", "Jumlah_Ulasan")], Tipe_Wisata == input$wisata_tipe))
    }
  })
  
  # Update the choices for the selectInput based on the available tourist attractions
  observe({
    updateSelectInput(session, "selected_wisata", 
                      choices = wisata_data$Nama_Wisata)
  })
  
  #======================= Wisata Berdasarkan Rating =======================#
  output$top5_wisata_table <- renderDataTable({
    req(input$wisata_tipe)  # Ensure the filter input is available
    
    # Filter the data based on the selected type of tourism
    filtered_data <- if (input$wisata_tipe == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Tipe_Wisata == input$wisata_tipe, ]
    }
    
    # Check if filtered_data is empty
    if (nrow(filtered_data) == 0) {
      return(datatable(data.frame(Nama_Wisata = character(0), Nama_Kabkot= character(0), Rating = numeric(0), Jumlah_Ulasan = numeric(0))))
    }
    
    # Get the top 5 based on rating
    top5_data <- filtered_data %>%
      arrange(desc(Rating)) %>%
      select(Nama_Wisata, Nama_Kabkot, Rating, Jumlah_Ulasan)  # Select relevant columns
    
    datatable(top5_data, selection = 'single',options = list(scrollX = TRUE))
  })
  
  # List of random invitations
  ajakan_kunjungan <- c(
    "Jangan lewatkan keindahan alamnya!",
    "Ayo kunjungi dan rasakan pengalaman yang tak terlupakan!",
    "Temukan keajaiban tersembunyi di sini!",
    "Bergabunglah dengan kami untuk petualangan yang seru!",
    "Rasakan budaya lokal yang kaya!",
    "Jelajahi keindahan yang menanti Anda!",
    "Buat kenangan indah bersama keluarga dan teman!",
    "Nikmati kelezatan kuliner khas daerah!",
    "Dapatkan pengalaman unik yang hanya ada di sini!",
    "Ayo, jadikan liburan Anda lebih berkesan!"
  )

  #======================= Menampilkan Detail Wisata yang Dipilih =======================#
  output$selected_wisata_details <- renderUI({
    selected_row <- input$top5_wisata_table_rows_selected  # Get selected row index
    
    # Check if selected_row is NULL or has length 0
    if (is.null(selected_row) || length(selected_row) == 0) {
      # If no row is selected, get the top rated tourist attraction
      top_rated_data <- filtered_wisata() %>%
        arrange(desc(Rating)) %>%
        slice(1)  # Get the top rated tourist attraction
      
      # Create UI output for the top rated tourist attraction details
      selected_data <- top_rated_data
    } else {
      # Get the selected data from filtered_wisata
      selected_data <- filtered_wisata()[selected_row, ]  # Use the filtered data
    }
    
    # Check if selected_data has valid latitude and longitude
    if (is.na(selected_data$Latitude) || is.na(selected_data$Longitude)) {
      return(h4("Data lokasi tidak tersedia."))
    }
    
    # Create Google Maps link
    gmaps_url <- paste0("https://www.google.com/maps/dir/?api=1&origin=Bandung&destination=", 
                        selected_data$Latitude, ",", selected_data$Longitude)
    
    # Create UI output for selected tourist attraction details
    tagList(
      h3(selected_data$Nama_Wisata),
      img(src = selected_data$Image, width = "100%", style = "border-radius: 10px;"),
      p(style = "font-size: 18px; font-weight: bold;", paste("Harga Tiket: IDR", formatC(selected_data$Harga_Tiket_Bersih, format = "f", big.mark = ".", decimal.mark = ",", digits = 0))),
      p(style = "font-size: 16px;", selected_data$Deskripsi),
      
      # Display stars based on rating
      uiOutput("rating_stars"),
      
      # Link to Google Maps
      tags$a(href = gmaps_url, target = "_blank", 
             style = "font-size: 20px; font-weight: bold; color: #007bff;", 
             "Lihat Rute di Google Maps"),
      
      # Random invitation
      h4(sample(ajakan_kunjungan, 1), style = "color: #ff5722; font-weight: bold;")
    )
  })
  
  #======================= Menampilkan Bintang Berdasarkan Rating =======================#
  output$rating_stars <- renderUI({
    selected_row <- input$top5_wisata_table_rows_selected  # Get selected row index
    
    # Filter the data based on the selected type of tourism
    filtered_data <- if (input$wisata_tipe == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Tipe_Wisata == input$wisata_tipe, ]
    }
    
    # If no row is selected, get the top rated tourist attraction
    if (length(selected_row) == 0) {
      top_rated_data <- filtered_data %>%
        arrange(desc(Rating)) %>%
        slice(1)  # Get the top rated tourist attraction
      
      rating_value <- top_rated_data$Rating
    } else {
      # Get the selected data
      selected_data <- filtered_wisata()[selected_row, ]  # Use the filtered data
      rating_value <- selected_data$Rating
    }
    
    # Create star rating based on the rating value
    stars <- lapply(1:5, function(i) {
      if (i <= rating_value) {
        tags$span(class = "fa fa-star", style = "color: gold;")
      } else {
        tags$span(class = "fa fa-star-o", style = "color: gold;")
      }
    })
    
    # Return the stars as UI output
    do.call(tagList, stars)
  })
  
  # Haversine function to calculate distance between two points on the Earth
  haversine <- function(lat1, lon1, lat2, lon2) {
    R <- 6371  # Radius of the Earth in kilometers
    dlat <- (lat2 - lat1) * pi / 180
    dlon <- (lon2 - lon1) * pi / 180
    a <- sin(dlat / 2) * sin(dlat / 2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
      sin(dlon / 2) * sin(dlon / 2)
    c <- 2 * atan2(sqrt(a), sqrt(1 - a))
    R * c  # Distance in kilometers
  }
  
  # Calculate total cost, distance, fuel consumption, and estimated time when the button is clicked
  observeEvent(input$calculate_cost, {
    req(input$selected_wisata)  # Ensure that at least one attraction is selected
    
    # Filter the selected attractions
    selected_data <- wisata_data[wisata_data$Nama_Wisata %in% input$selected_wisata, ]
    
    # Check if selected_data is not empty
    req(nrow(selected_data) > 0)
    
    # Calculate total cost
    total_cost <- sum(selected_data$Harga_Tiket_Bersih, na.rm = TRUE)
    total_cost_formatted <- formatC(total_cost, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)
    
    # Calculate total distance using Haversine formula
    total_distance <- 0
    if (nrow(selected_data) > 1) {
      for (i in 1:(nrow(selected_data) - 1)) {
        total_distance <- total_distance + haversine(
          selected_data$Latitude[i], selected_data$Longitude[i],
          selected_data$Latitude[i + 1], selected_data$Longitude[i + 1]
        )
      }
    }
    
    # Calculate fuel consumption (0.017 liters/km)
    fuel_consumption <- total_distance * 0.017
    
    # Estimate time (assuming an average speed of 60 km/h)
    estimated_time <- total_distance / 60  # in hours
    
    # Update the outputs
    output$total_cost <- renderText({
      paste("Total Tiket: IDR", total_cost_formatted)
    })
    
    output$total_distance <- renderText({
      paste("Total Jarak: ", round(total_distance, 2), "km")
    })
    
    output$fuel_consumption <- renderText({
      paste("Konsumsi Bahan Bakar: ", round(fuel_consumption, 2), "liter")
    })
    
    output$estimated_time <- renderText({
      paste("Estimasi Waktu Perjalanan: ", round(estimated_time, 2), "jam")
    })
    
    output$grand_total <- renderText({
      total_fuel_cost <- round(fuel_consumption, 2) * 12000  # Assuming fuel price is IDR 12,000 per liter
      grand_total <- total_cost + total_fuel_cost
      paste("Estimasi Biaya (Tiket & Bensin): IDR", formatC(grand_total, format = "f", big.mark = ".", decimal.mark = ",", digits = 0))
    })
    
    # Create Google Maps link
    map_url <- paste0("https://www.google.com/maps/dir/?api=1&origin=", 
                      selected_data$Latitude[1], ",", selected_data$Longitude[1],
                      "&destination=", selected_data$Latitude[nrow(selected_data)], ",", selected_data$Longitude[nrow(selected_data)],
                      "&waypoints=", paste(selected_data$Latitude[-1], selected_data$Longitude[-1], collapse = "|"),
                      "&travelmode=driving")
    
    output$google_maps_link <- renderUI({
      tags$a(href = map_url, target = "_blank", 
             style = "font-size: 20px; font-weight: bold; color: #007bff;", 
             "Lihat Rute di Google Maps")
    })
    
    # Display selected tourist attractions in a table
    output$selected_wisata_table <- renderDataTable({
      selected_data[, c("Nama_Wisata", "Nama_Kabkot", "Harga_Tiket", "Rating", "Deskripsi")]
    })
    
    #======================= Download Data as Excel =======================#
    output$download_data <- downloadHandler(
      filename = function() {
        paste("data_wisata_", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        # Get data from selected_data
        data_to_download <- selected_data[, c("Nama_Wisata", "Nama_Kabkot", "Harga_Tiket", "Rating", "Deskripsi")]
        
        # Write data to Excel file
        write_xlsx(data_to_download, path = file)
      }
    )
  })
  
  #======================= Visualisasi Wisata =======================#
  # Visualisasi Tipe Wisata
  output$typePlotWisata <- renderPlot({
    req(wisata_data)  # Ensure wisata_data is available
    
    ggplot(wisata_data, aes(x = Tipe_Wisata)) + 
      geom_bar(fill = "#69b3a2", color = "black", width = 0.6) +
      geom_text(stat = 'count', aes(label = ..count..), vjust = -0.5, size = 5) +  # Menambahkan label jumlah
      labs(
        title = "Distribusi Tipe Wisata",
        x = "Tipe Wisata",
        y = "Jumlah"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16, color = "#2c3e50"),
        axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1, size = 12),
        axis.text.y = element_text(size = 12),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank()
      )
  })
  
  # Visualisasi Rating Wisata
  output$ratingPlot <- renderPlot({
    # Create the histogram and store the counts
    hist_data <- ggplot(wisata_data, aes(x = Rating)) +
      geom_histogram(bins = 10, fill = "#1f77b4", color = "white", alpha = 0.8) +
      labs(
        title = "Distribusi Rating Wisata",
        x = "Rating",
        y = "Jumlah Wisata"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
        axis.text = element_text(size = 12),
        axis.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank()
      )
    
    # Get the maximum count from the histogram
    max_count <- ggplot_build(hist_data)$data[[1]]$count %>% max(na.rm = TRUE)
    
    # Add the mean line and text annotation
    hist_data +
      geom_vline(aes(xintercept = mean(Rating, na.rm = TRUE)), 
                 color = "red", linetype = "dashed", linewidth = 1) +
      geom_text(aes(x = mean(Rating, na.rm = TRUE), 
                    y = max_count * 0.9, 
                    label = "Mean"), 
                color = "red", fontface = "bold", vjust = -0.5)
  })
  
  #======================= Clustering =======================#
  output$clustering_results <- renderTable({
    req(input$num_clusters)  # Ensure input is available
    validate(need(input$num_clusters > 1, "Jumlah cluster harus lebih dari 1"))
    
    # Get necessary data
    data_clustering <- wisata_data %>%
      group_by(Nama_Kabkot) %>%
      summarise(
        Rata_Rata_Rating = mean(Rating, na.rm = TRUE),
        Rata_Rata_Ulasan = mean(Jumlah_Ulasan, na.rm = TRUE),
        Rata_Rata_Harga_Tiket = mean(Harga_Tiket_Bersih, na.rm = TRUE),
        Jumlah_Wisatawan = sum(Jumlah_Wisatawan, na.rm = TRUE),  # Sum of tourists
        Jumlah_Penduduk = sum(Jml_pddk, na.rm = TRUE),  # Sum of population
        PDRB = sum(PDRB, na.rm = TRUE)  # Sum of PDRB
      ) %>%
      na.omit()  # Remove NA
    
    # Perform clustering
    set.seed(1019)  # For consistent results
    kmeans_result <- kmeans(data_clustering[, -1], centers = input$num_clusters)
    
    # Add clustering results to data
    data_clustering$Cluster <- as.factor(kmeans_result$cluster)
    
    # Sort data_clustering by Cluster
    data_clustering <- data_clustering %>%
      arrange(Cluster)  # Sort by Cluster
    
    return(data_clustering)
  })
  
  #======================= Visualisasi Clustering =======================#
  output$clustering_plot <- renderPlot({
    req(input$num_clusters)
    validate(need(input$num_clusters > 1, "Jumlah cluster harus lebih dari 1"))
    
    # Get necessary data
    data_clustering <- wisata_data %>%
      group_by(Nama_Kabkot) %>%
      summarise(
        Rata_Rata_Rating = mean(Rating, na.rm = TRUE),
        Rata_Rata_Ulasan = mean(Jumlah_Ulasan, na.rm = TRUE),
        Rata_Rata_Harga_Tiket = mean(Harga_Tiket_Bersih, na.rm = TRUE),
        Jumlah_Wisatawan = sum(Jumlah_Wisatawan, na.rm = TRUE),  # Sum of tourists
        Jumlah_Penduduk = sum(Jml_pddk, na.rm = TRUE),  # Sum of population
        PDRB = sum(PDRB, na.rm = TRUE)  # Sum of PDRB
      ) %>%
      na.omit()
    
    # Perform clustering
    set.seed(1019)
    kmeans_result <- kmeans(data_clustering[, -1], centers = input$num_clusters)
    
    # Add clustering results to data
    data_clustering$Cluster <- as.factor(kmeans_result$cluster)
    
    # Visualize clustering
    ggplot(data_clustering, aes(x = Jumlah_Wisatawan, y = PDRB, color = Cluster, label = Nama_Kabkot)) +
      geom_point(size = 4, alpha = 0.7) +
      geom_text(hjust = 0.5, vjust = -0.8, size = 3, check_overlap = TRUE) +
      labs(title = "Clustering Kabupaten", x = "Jumlah Wisatawan", y = "PDRB") +
      theme_minimal() +
      scale_color_brewer(palette = "Set1")
  })
  
  # Visualisasi Harga Tiket
  output$pricePlot <- renderPlot({
    ggplot(wisata_data, aes(x = Tipe_Wisata, y = Harga_Tiket_Bersih)) +
      stat_summary(fun = mean, geom = "col", fill = "#2ca02c", color = "black", width = 0.6) +
      geom_errorbar(stat = "summary", fun.data = mean_se, width = 0.2, color = "black") +
      labs(
        title = "Rata-rata Harga Tiket Berdasarkan Tipe Wisata",
        x = "Tipe Wisata",
        y = "Harga Tiket (Rupiah)"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
        axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        axis.title = element_text(face = "bold"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank()
      )
  })
  
  # Visualisasi Jumlah Wisata Berdasarkan Kabupaten
  output$countyPlot <- renderPlot({
    # Count number of attractions per kabupaten
    county_data <- wisata_data %>%
      group_by(Nama_Kabkot) %>%
      summarise(Jumlah_Wisata = n()) %>%
      arrange(desc(Jumlah_Wisata))  # Sort from largest to smallest
    
    # Ensure Nama_Kabkot column is converted to factor with correct order
    county_data$Nama_Kabkot <- factor(county_data$Nama_Kabkot, levels = county_data$Nama_Kabkot)
    
    # Create plot
    ggplot(county_data, aes(x = reorder(Nama_Kabkot, Jumlah_Wisata), y = Jumlah_Wisata)) +
      geom_bar(stat = "identity", fill = "#ff7f0e", color = "black", width = 0.7) +
      coord_flip() +
      labs(
        title = "Jumlah Wisata Berdasarkan Kabupaten",
        x = "Kabupaten",
        y = "Jumlah Wisata"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
        axis.text = element_text(size = 12),
        axis.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(color = "grey", linewidth = 0.5)
      ) +
      geom_text(aes(label = Jumlah_Wisata), hjust = -0.2, size = 4, color = "black")  # Add label for number of attractions
  })

  ##------------------------  Kabupaten/Kota ---------------------------------
  
  #======================= Filter Kabupaten Kota =======================#  
  output$filter_kota <- renderUI({
    selectInput(
      inputId = "kota_pilihan",
      label = "Pilih Kabupaten/Kota",
      choices = c("Semua", unique(wisata_data$Nama_Kabkot)), 
      selected = "Semua"
    )
  })
  
  #======================= Tabel Kabupaten ============================#
  output$kota_table <- renderDataTable({
    req(input$kota_pilihan)
    if (input$kota_pilihan == "Semua") {
      datatable(wisata_data[, c("Nama_Wisata", "Nama_Kabkot", "Nama_Kec","Nama_Kel","Tipe_Wisata", "Harga_Tiket", "Rating", "Jumlah_Ulasan")])
    } else {
      datatable(subset(wisata_data[, c("Nama_Wisata", "Nama_Kabkot", "Nama_Kec","Nama_Kel","Tipe_Wisata", "Harga_Tiket", "Rating", "Jumlah_Ulasan")], Nama_Kabkot == input$kota_pilihan))
    }
  })
  
  #======================= Visualisasi Tipe Wisata Berdasarkan Kabupaten =====================#
  output$typePlot <- renderPlot({
    req(input$kota_pilihan)  # Ensure input is available
    req(length(input$kota_pilihan) > 0)  # Ensure at least one selection is made
    
    filtered_data <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan | input$kota_pilihan == "Semua", ]
    
    ggplot(filtered_data, aes(x = reorder(Tipe_Wisata, -table(Tipe_Wisata)[Tipe_Wisata]), fill = Tipe_Wisata)) +
      geom_bar(stat = "count", color = "black", width = 0.7, show.legend = FALSE) +
      geom_text(stat = "count", aes(label = ..count..), 
                vjust = -0.5, size = 5, fontface = "bold", color = "black") +
      scale_fill_brewer(palette = "Dark2") +  # Warna tetap konsisten
      labs(
        title = paste("Distribusi Tipe Wisata di", input$kota_pilihan),
        x = "Tipe Wisata",
        y = "Jumlah Wisata"
      ) +
      theme_minimal(base_size = 16) +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
        axis.title.x = element_text(size = 14, face = "bold"),
        axis.title.y = element_text(size = 14, face = "bold"),
        plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white", color = "black"),
        plot.background = element_rect(fill = "white")
      ) +
      scale_y_continuous(expand = expansion(mult = c(0, 0.1)), labels = scales::comma)
    # Add extra space above bars
  })
  
  #======================= Visualisasi Distribusi Kecamatan =======================#
  output$kecamatan_distribution_plot <- renderPlot({
    req(input$kota_pilihan)  # Ensure input is available
    
    # Filter data based on selected Kabupaten
    filtered_data <- if (input$kota_pilihan == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan, ]
    }
    
    # Count number of attractions per Kecamatan
    kecamatan_data <- filtered_data %>%
      group_by(Nama_Kec) %>%
      summarise(Jumlah_Wisata = n()) %>%
      arrange(desc(Jumlah_Wisata))  # Sort from largest to smallest
    
    # Create plot
    ggplot(kecamatan_data, aes(x = reorder(Nama_Kec, Jumlah_Wisata), y = Jumlah_Wisata)) +
      geom_bar(stat = "identity", fill = "#ff7f0e", color = "black") +
      coord_flip() +
      labs(
        title = paste("Jumlah Wisata Berdasarkan Kecamatan di", input$kota_pilihan),
        x = "Kecamatan",
        y = "Jumlah Wisata"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
        axis.text = element_text(size = 12),
        axis.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(color = "grey", linewidth = 0.5)
      ) +
      geom_text(aes(label = Jumlah_Wisata), hjust = -0.2, size = 4, color = "black")  # Add label for number of attractions
  })
  
  #======================= Visualisasi Rata-rata Rating Berdasarkan Kecamatan =======================#
  output$kecamatan_rating_plot <- renderPlot({
    req(input$kota_pilihan)  # Ensure input is available
    
    # Filter data based on selected Kabupaten
    filtered_data <- if (input$kota_pilihan == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan, ]
    }
    
    # Calculate average rating per Kecamatan
    rating_data <- filtered_data %>%
      group_by(Nama_Kec) %>%
      summarise(Rata_Rating = mean(Rating, na.rm = TRUE)) %>%
      arrange(desc(Rata_Rating))  # Sort from largest to smallest
    
    # Create plot
    ggplot(rating_data, aes(x = reorder(Nama_Kec, Rata_Rating), y = Rata_Rating)) +
      geom_bar(stat = "identity", fill = "#1f77b4", color = "black") +
      coord_flip() +
      labs(
        title = paste("Rata-rata Rating Berdasarkan Kecamatan di", input$kota_pilihan),
        x = "Kecamatan",
        y = "Rata-rata Rating"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
        axis.text = element_text(size = 12),
        axis.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(color = "grey", linewidth = 0.5)
      )
    })
  
  #======================= Visualisasi Total Ulasan Berdasarkan Kecamatan =======================#
  output$kecamatan_ulasan_plot <- renderPlot({
    req(input$kota_pilihan)  # Ensure input is available
    
    # Filter data based on selected Kabupaten
    filtered_data <- if (input$kota_pilihan == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan, ]
    }
    
    # Calculate total reviews per Kecamatan
    ulasan_data <- filtered_data %>%
      group_by(Nama_Kec) %>%
      summarise(Jumlah_Ulasan = sum(Jumlah_Ulasan, na.rm = TRUE)) %>%
      arrange(desc(Jumlah_Ulasan))  # Sort from largest to smallest
    
    # Create plot
    ggplot(ulasan_data, aes(x = reorder(Nama_Kec, Jumlah_Ulasan), y = Jumlah_Ulasan)) +
      geom_bar(stat = "identity", fill = "#ff7f0e", color = "black") +
      coord_flip() +
      labs(
        title = paste("Total Ulasan Berdasarkan Kecamatan di", input$kota_pilihan),
        x = "Kecamatan",
        y = "Jumlah Ulasan"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
        axis.text = element_text(size = 12),
        axis.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(color = "grey", linewidth = 0.5)
      ) +
      geom_text(aes(label = Jumlah_Ulasan), hjust = -0.2, size = 4, color = "black")  # Add label for total reviews
  })
  
  #======================= Value Box for Jumlah Wisata =======================#
  output$jumlah_wisata_box <- renderValueBox({
    req(input$kota_pilihan)  # Ensure input is available
    
    # Filter data based on selected Kabupaten
    filtered_data <- if (input$kota_pilihan == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan, ]
    }
    
    jumlah_wisata <- nrow(filtered_data)  # Count the number of tourist attractions
    
    valueBox(
      value = tags$div(style = "font-size: 40px; font-weight: bold;", formatC(jumlah_wisata, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)),
      subtitle = tags$div(style = "font-weight: bold; font-size: 16px;", "Jumlah Wisata"),
      icon = icon("home"),
      color = "primary"
    )
  })
  
  #======================= Value Box for Jumlah Restoran =======================#
  output$jumlah_restoran_box <- renderValueBox({
    req(input$kota_pilihan)  # Ensure input is available
    
    # Filter data based on selected Kabupaten
    filtered_data <- if (input$kota_pilihan == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan, ]
    }
    
    jumlah_restoran <- sum(filtered_data$Jumlah_Restoran, na.rm = TRUE)  # Assuming you have a column for restaurants
    
    valueBox(
      value = tags$div(style = "font-size: 40px; font-weight: bold;", formatC(jumlah_restoran, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)),
      subtitle = tags$div(style = "font-weight: bold; font-size: 16px;", "Jumlah Restoran"),
      icon = icon("utensils"),
      color = "success"
    )
  })
  
  #======================= Value Box for Jumlah Penduduk =======================#
  output$jumlah_penduduk_box <- renderValueBox({
    req(input$kota_pilihan)  # Ensure input is available
    
    # Filter data based on selected Kabupaten
    filtered_data <- if (input$kota_pilihan == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan, ]
    }
    
    jumlah_penduduk <- sum(filtered_data$Jml_pddk, na.rm = TRUE)  # Assuming you have a column for population
    
    valueBox(
      value = tags$div(style = "font-size: 40px; font-weight: bold;", formatC(jumlah_penduduk, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)),
      subtitle = tags$div(style = "font-weight: bold; font-size: 16px;", "Jumlah Penduduk"),
      icon = icon("users"),
      color = "info"
    )
  })
  
  #======================= Value Box for Jumlah Wisatawan =======================#
  output$jumlah_wisatawan_box <- renderValueBox({
    req(input$kota_pilihan)  # Ensure input is available
    
    # Filter data based on selected Kabupaten
    filtered_data <- if (input$kota_pilihan == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan, ]
    }
    
    jumlah_wisatawan <- sum(filtered_data$Jumlah_Wisatawan, na.rm = TRUE)  # Assuming you have a column for tourists
    
    valueBox(
      value = tags$div(style = "font-size: 40px; font-weight: bold;", formatC(jumlah_wisatawan, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)),
      subtitle = tags$div(style = "font-weight: bold; font-size: 16px;", "Jumlah Wisatawan"),
      icon = icon("plane"),
      color = "warning"
    )
  })
  
  #======================= Value Box for PDRB =======================#
  output$pdrb_box <- renderValueBox({
    req(input$kota_pilihan)  # Ensure input is available
    
    # Filter data based on selected Kabupaten
    filtered_data <- if (input$kota_pilihan == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan, ]
    }
    
    pdrb_value <- sum(filtered_data$PDRB, na.rm = TRUE)  # Assuming you have a column for PDRB
    
    valueBox(
      value = tags$div(style = "font-size: 40px; font-weight: bold;", formatC(pdrb_value, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)),
      subtitle = tags$div(style = "font-weight: bold; font-size: 16px;", "PDRB"),
      icon = icon("money-bill-wave"),
      color = "danger"
    )
  })
  
  #======================= Value Box for Jumlah Masjid =======================#
  output$jumlah_masjid_box <- renderValueBox({
    req(input$kota_pilihan)  # Ensure input is available
    
    # Filter data based on selected Kabupaten
    filtered_data <- if (input$kota_pilihan == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan, ]
    }
    
    jumlah_masjid <- sum(filtered_data$Jumlah_Masjid, na.rm = TRUE)  # Assuming you have a column for mosques
    
    valueBox(
      value = tags$div(style = "font-size: 40px; font-weight: bold;", formatC(jumlah_masjid, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)),
      subtitle = tags$div(style = "font-weight: bold; font-size: 16px;", "Jumlah Masjid"),
      icon = icon("mosque"),
      color = "purple"
    )
  })
  
  #======================= Filter untuk Perbandingan Kabupaten =======================#
  output$filter_kota_comparison <- renderUI({
    tagList(
      selectInput("kota_pilihan_1", "Pilih Kabupaten/Kota 1", choices = unique(wisata_data$Nama_Kabkot), selected = unique(wisata_data$Nama_Kabkot)[1]),
      selectInput("kota_pilihan_2", "Pilih Kabupaten/Kota 2", choices = unique(wisata_data$Nama_Kabkot), selected = unique(wisata_data$Nama_Kabkot)[2])
    )
  })
  
  #======================= Hasil Perbandingan =======================#
  output$comparison_results <- renderTable({
    req(input$kota_pilihan_1, input$kota_pilihan_2)
    
    # Filter data for both kabupaten
    data_kota_1 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_1, ]
    data_kota_2 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_2, ]
    
    # Calculate metrics
    comparison_data <- data.frame(
      Kabupaten = c(input$kota_pilihan_1, input$kota_pilihan_2),
      Jumlah_Wisata = c(nrow(data_kota_1), nrow(data_kota_2)),
      Jumlah_Wisatawan = c(sum(data_kota_1$Jumlah_Wisatawan, na.rm = TRUE), sum(data_kota_2$Jumlah_Wisatawan, na.rm = TRUE)),
      PDRB = c(sum(data_kota_1$PDRB, na.rm = TRUE), sum(data_kota_2$PDRB, na.rm = TRUE)),
      Rata_Rata_Rating = c(mean(as.numeric(data_kota_1$Rating), na.rm = TRUE), 
                           mean(as.numeric(data_kota_2$Rating), na.rm = TRUE)),
      Jumlah_Ulasan = c(sum(data_kota_1$Jumlah_Ulasan, na.rm = TRUE), sum(data_kota_2$Jumlah_Ulasan, na.rm = TRUE))
    )
    
    return(comparison_data)
  })
  
  #======================= Plot Rata-rata Rating =======================# 
  output$rata_rating_plot <- renderPlot({ 
    req(input$kota_pilihan_1, input$kota_pilihan_2)
    
    # Filter data for both kabupaten
    data_kota_1 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_1, ]
    data_kota_2 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_2, ]
    
    # Calculate average rating
    comparison_data <- data.frame(
      Kabupaten = c(input$kota_pilihan_1, input$kota_pilihan_2),
      Rata_Rata_Rating = c(mean(as.numeric(data_kota_1$Rating), na.rm = TRUE), 
                           mean(as.numeric(data_kota_2$Rating), na.rm = TRUE))
    )
    
    ggplot(comparison_data, aes(x = Kabupaten, y = Rata_Rata_Rating, fill = as.factor(Kabupaten))) +
      geom_bar(stat = "identity", color = "black") +  # Outline hitam agar lebih kontras
      geom_text(aes(label = round(Rata_Rata_Rating, 2)), vjust = -0.5, size = 5, color = "white", fontface = "bold") +
      scale_fill_manual(values = rep(c("#007bac", "#f39c12"), length.out = length(unique(comparison_data$Kabupaten)))) + 
      labs(title = "Rata-rata Rating", x = "Kabupaten", y = "Rata-rata Rating") +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16, color = "#2c3e50"),
        axis.text = element_text(size = 12, color = "#222222"),
        axis.title = element_text(face = "bold", color = "#2c3e50"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_line(color = "#bbbbbb", linewidth = 0.5)
      )
    
  })
  
  #======================= Plot Rata-rata Ulasan =======================# 
  output$rata_ulasan_plot <- renderPlot({ 
    req(input$kota_pilihan_1, input$kota_pilihan_2)
    
    # Filter data for both kabupaten
    data_kota_1 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_1, ]
    data_kota_2 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_2, ]
    
    # Calculate total reviews
    comparison_data <- data.frame(
      Kabupaten = c(input$kota_pilihan_1, input$kota_pilihan_2),
      Rata_Rata_Ulasan = c(sum(data_kota_1$Jumlah_Ulasan, na.rm = TRUE), 
                           sum(data_kota_2$Jumlah_Ulasan, na.rm = TRUE))
    )
    
    ggplot(comparison_data, aes(x = Kabupaten, y = Rata_Rata_Ulasan, fill = as.factor(Kabupaten))) +
      geom_bar(stat = "identity", color = "black") +  # Outline hitam untuk kontras
      geom_text(aes(label = round(Rata_Rata_Ulasan, 2)), vjust = -0.5, size = 5, color = "white", fontface = "bold") +
      scale_fill_manual(values = rep(c("#007bac", "#f39c12"), length.out = length(unique(comparison_data$Kabupaten)))) + 
      labs(title = "Rata-Rata Ulasan", x = "Kabupaten", y = "Rata-Rata Ulasan") +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16, color = "#2c3e50"),
        axis.text = element_text(size = 12, color = "#222222"),
        axis.title = element_text(face = "bold", color = "#2c3e50"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_line(color = "#bbbbbb", linewidth = 0.5)
      )
    
  })
  
  #======================= Plot Jumlah Wisata =======================# 
  output$jumlah_wisata_plot <- renderPlot({ 
    req(input$kota_pilihan_1, input$kota_pilihan_2)
    
    # Filter data for both kabupaten
    data_kota_1 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_1, ]
    data_kota_2 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_2, ]
    
    # Count number of attractions
    comparison_data <- data.frame(
      Kabupaten = c(input$kota_pilihan_1, input$kota_pilihan_2),
      Jumlah_Wisata = c(nrow(data_kota_1), nrow(data_kota_2))
    )
    
    ggplot(comparison_data, aes(x = Kabupaten, y = Jumlah_Wisata, fill = as.factor(Kabupaten))) +
      geom_bar(stat = "identity", color = "black") +  # Outline hitam agar lebih kontras
      geom_text(aes(label = Jumlah_Wisata), vjust = -0.5, size = 5, color = "white", fontface = "bold") +
      scale_fill_manual(values = rep(c("#007bac", "#f39c12"), length.out = length(unique(comparison_data$Kabupaten)))) + 
      labs(title = "Jumlah Wisata", x = "Kabupaten", y = "Jumlah Wisata") +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16, color = "#2c3e50"),
        axis.text = element_text(size = 12, color = "#222222"),
        axis.title = element_text(face = "bold", color = "#2c3e50"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_line(color = "#bbbbbb", linewidth = 0.5)
      )
    
  })
  
  #======================= Plot Jumlah Wisatawan =======================#
  output$jumlah_wisatawan_plot <- renderPlot({ 
    req(input$kota_pilihan_1, input$kota_pilihan_2)
    
    # Filter data for both kabupaten
    data_kota_1 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_1, ]
    data_kota_2 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_2, ]
    
    # Count number of attractions
    comparison_data <- data.frame(
      Kabupaten = c(input$kota_pilihan_1, input$kota_pilihan_2),
      Jumlah.Wisatawan = c(nrow(data_kota_1), nrow(data_kota_2))
    )
    
    ggplot(comparison_data, aes(x = Kabupaten, y = Jumlah.Wisatawan, fill = as.factor(Kabupaten))) +
      geom_bar(stat = "identity", color = "black") +
      geom_text(aes(label = Jumlah.Wisatawan), vjust = -0.5, size = 5, color = "white", fontface = "bold") +
      scale_fill_manual(values = rep(c("#007bac", "#f39c12"), length.out = length(unique(comparison_data$Kabupaten)))) + 
      labs(title = "Jumlah Wisatawan", x = "Kabupaten", y = "Jumlah Wisatawan") +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16, color = "#2c3e50"),
        axis.text = element_text(size = 12, color = "#222222"),
        axis.title = element_text(face = "bold", color = "#2c3e50"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_line(color = "#bbbbbb", linewidth = 0.5)
      )
    
  })
  
  #======================= Plot PDRB =======================#
  output$pdrb_plot <- renderPlot({ 
    req(input$kota_pilihan_1, input$kota_pilihan_2)
    
    # Filter data for both kabupaten
    data_kota_1 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_1, ]
    data_kota_2 <- wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan_2, ]
    
    # Count number of attractions
    comparison_data <- data.frame(
      Kabupaten = c(input$kota_pilihan_1, input$kota_pilihan_2),
      PDRB = c(nrow(data_kota_1), nrow(data_kota_2))
    )
    
    ggplot(comparison_data, aes(x = Kabupaten, y = PDRB, fill = as.factor(Kabupaten))) +
      geom_bar(stat = "identity", color = "black") +  # Outline hitam untuk kontras
      geom_text(aes(label = PDRB), vjust = -0.5, size = 5, color = "white", fontface = "bold") +
      scale_fill_manual(values = rep(c("#007bac", "#f39c12"), length.out = length(unique(comparison_data$Kabupaten)))) + 
      labs(title = "PDRB", x = "Kabupaten", y = "PDRB") +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16, color = "#2c3e50"),
        axis.text = element_text(size = 12, color = "#222222"),
        axis.title = element_text(face = "bold", color = "#2c3e50"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_line(color = "#bbbbbb", linewidth = 0.5)
      )
    
  })
  
  #======================= Tabel Kabupaten ============================#
  output$kabupaten_table <- renderDataTable({
    # Menghitung jumlah wisata, jumlah peta yang tidak null, jumlah restoran, jumlah masjid, dan rata-rata rating
    kabupaten_data <- wisata_data %>%
      group_by(Nama_Kabkot) %>%
      summarise(
        Jumlah_Wisata = n(),
        Jumlah_Map_Not_Null = sum(!is.na(Longitude) & !is.na(Latitude)),
        Jumlah_Restoran = sum(Jumlah_Restoran, na.rm = TRUE),  # Assuming you have a column for restaurants
        Jumlah_Masjid = sum(Jumlah_Masjid, na.rm = TRUE),  # Assuming you have a column for mosques
        Rata_Rata_Rating = round(mean(Rating, na.rm = TRUE), 2),  # Rata-rata rating with 2 decimal places
        Status = ifelse(Jumlah_Wisata == Jumlah_Map_Not_Null & Jumlah_Restoran > 0 & Jumlah_Masjid > 0, 
                        "Lengkap", 
                        "Tidak Lengkap")
      ) %>%
      arrange(desc(Jumlah_Wisata))  # Sort by Jumlah_Wisata descending
    
    # Menggunakan datatable dan menambahkan styling
    datatable(kabupaten_data, options = list(scrollX = TRUE), rownames = FALSE) %>%
      formatStyle(
        'Jumlah_Wisata', 
        backgroundColor = "#d9edf7"  # Light blue
      ) %>%
      formatStyle(
        'Jumlah_Map_Not_Null', 
        backgroundColor = "#dff0d8"  # Light green
      ) %>%
      formatStyle(
        'Jumlah_Restoran', 
        backgroundColor = "#fcf8e3"  # Light yellow
      ) %>%
      formatStyle(
        'Jumlah_Masjid', 
        backgroundColor = "#f2dede"  # Light red
      ) %>%
      formatStyle(
        'Rata_Rata_Rating', 
        backgroundColor = "#d9edf7"  # Light blue
      ) %>%
      formatStyle(
        'Status', 
        backgroundColor = styleEqual(c("Lengkap", "Tidak Lengkap"), c("green", "red")),
        color = styleEqual(c("Lengkap", "Tidak Lengkap"), c("white", "white"))  # Text color
      )
  })
  
  #========================= Pilih Variabel Numeric =========================#
  numeric_vars <- names(wisata_data)[sapply(wisata_data, is.numeric)]
  
  output$filter_variabel_numeric <- renderUI({
    tagList(
      selectInput("x_var", "Pilih Variabel X", choices = numeric_vars, selected = numeric_vars[1]),
      selectInput("y_var", "Pilih Variabel Y", choices = numeric_vars, selected = numeric_vars[2])
    )
  })
  
  ##------------------------ Rute Wisata ---------------------------------
  #======================= Filter Kabupaten for Route =======================#
  output$filter_kabupaten_rute <- renderUI({
    selectInput(
      inputId = "kabupaten_rute",
      label = "Pilih Kabupaten/Kota",
      choices = unique(wisata_data$Nama_Kabkot), 
      selected = NULL,
      multiple = TRUE  # Enable multiple selection
    )
  })
  #======================= Rekomendasi Rute Wisata =======================#
  observeEvent(input$recommend_route, {
    req(input$kabupaten_rute)  # Ensure at least one kabupaten is selected
    req(input$budget)  # Ensure budget is provided
    
    # Define coordinates for predefined starting points
    starting_points <- list(
      bandung_center = c(-6.9175, 107.6191),  # Center of Bandung
      husein_sastranegara = c(-6.9013, 107.6050),  # Husein Sastranegara International Airport
      kertajati = c(-6.3083, 108.5400),  # Kertajati International Airport
      cijulang = c(-7.4200, 105.7100),  # Cijulang Nusawiru Airport
      sukabumi = c(-6.9340, 106.9250),  # Sukabumi Airport
      patimban = c(-6.3920, 107.3600),  # Pelabuhan Patimban
      cirebon = c(-6.7060, 108.5500),  # Pelabuhan Cirebon
      muara_angke = c(-6.1260, 106.7540),  # Pelabuhan Muara Angke
      tanjung_priok = c(-6.1000, 106.8820)  # Pelabuhan Tanjung Priok
    )
    
    # Get the starting point coordinates based on user selection
    if (input$starting_point == "bandung_center") {
      starting_coords <- starting_points$bandung_center
    } else if (input$starting_point == "airport") {
      starting_coords <- starting_points[[input$selected_airport]]
    } else if (input$starting_point == "port") {
      starting_coords <- starting_points[[input$selected_port]]
    } else {
      starting_coords <- c(-6.9175, 107.6191)  # Default to center of Bandung
    }
    
    filtered_data <- wisata_data[wisata_data$Nama_Kabkot %in% input$kabupaten_rute, ]
    
    filtered_data <- filtered_data %>%
      mutate(Distance = haversine(starting_coords[1], starting_coords[2], Latitude, Longitude))
    
    filtered_data <- filtered_data %>%
      arrange(Distance)  
    
    cumulative_distance <- 0
    total_costs <- numeric(nrow(filtered_data))
    
    for (i in 1:nrow(filtered_data)) {
      if (i == 1) {
        cumulative_distance <- filtered_data$Distance[i]
      } else {
        previous_lat <- filtered_data$Latitude[i - 1]
        previous_lon <- filtered_data$Longitude[i - 1]
        distance_to_previous <- haversine(previous_lat, previous_lon, filtered_data$Latitude[i], filtered_data$Longitude[i])
        cumulative_distance <- cumulative_distance + distance_to_previous
      }
      
      total_costs[i] <- filtered_data$Harga_Tiket_Bersih[i] + (cumulative_distance * 0.017 * 12000)  
    }
    
    filtered_data <- filtered_data %>%
      mutate(Total_Cost = total_costs)  
    
    recommended_routes <- filtered_data %>%
      filter(Total_Cost <= input$budget) %>%
      select(Nama_Wisata, Nama_Kabkot, Harga_Tiket_Bersih, Distance, Total_Cost, Latitude, Longitude) %>%
      rename(
        `Nama Wisata` = Nama_Wisata,
        `Kabupaten` = Nama_Kabkot,
        `Harga Tiket (IDR)` = Harga_Tiket_Bersih,
        `Jarak dari Titik Awal (km)` = Distance,
        `Total Biaya (IDR)` = Total_Cost
      ) %>%
      mutate(
        `Harga Tiket (IDR)` = round(`Harga Tiket (IDR)`),  # Round ticket price
        `Jarak dari Titik Awal (km)` = round(`Jarak dari Titik Awal (km)`),  # Round distance
        `Total Biaya (IDR)` = round(`Total Biaya (IDR)`)  # Round total cost
      )
    
    output$recommended_route_table <- renderDataTable({
      datatable(recommended_routes, options = list(scrollX = TRUE))
    })
    
    output$recommended_route_map <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        setView(lng = starting_coords[2], lat = starting_coords[1], zoom = 10)
    })
    
    observe({
      leafletProxy("recommended_route_map", data = recommended_routes) %>%
        clearMarkers() %>%
        addMarkers(
          lng = ~Longitude, lat = ~Latitude,
          popup = ~paste0(
            "<strong>", `Nama Wisata`, "</strong><br>",
            "Kabupaten: ", Kabupaten, "<br>",
            "Harga Tiket: IDR ", formatC(`Harga Tiket (IDR)`, format = "f", big.mark = ".", decimal.mark = ",", digits = 0), "<br>",
            "Jarak dari Titik Awal: ", round(`Jarak dari Titik Awal (km)`, 2), " km<br>",
            "Total Biaya: IDR ", formatC(`Total Biaya (IDR)`, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)
          )
        )
    })
  })
  
  #======================= Scatter Plot =======================#
  output$scatter_plot <- renderPlot({
    req(input$x_var, input$y_var)  # Ensure both variables are selected
    
    # Filter data based on selected Kabupaten
    filtered_data <- if (input$kota_pilihan == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan, ]
    }
    
    # Check if there are enough data points to plot
    if (nrow(filtered_data) < 2) {
      return(NULL)  # Return NULL if not enough data
    }
    
    # Create scatter plot
    ggplot(filtered_data, aes_string(x = input$x_var, y = input$y_var)) +
      geom_point(color = "#007bff", size = 3, alpha = 0.7) +
      labs(title = paste("Scatter Plot of", input$x_var, "vs", input$y_var),
           x = input$x_var,
           y = input$y_var) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
        axis.text = element_text(size = 12),
        axis.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_line(color = "grey", linewidth = 0.5)
      )
  })
  
  #======================= Evaluasi Scatter Plot =======================#
  output$scatter_plot_evaluation <- renderText({
    req(input$kota_pilihan)  # Ensure input is available
    req(input$x_var, input$y_var)  # Ensure both variables are selected
    
    # Filter data based on selected Kabupaten
    filtered_data <- if (input$kota_pilihan == "Semua") {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kabkot == input$kota_pilihan, ]
    }
    
    # Calculate correlation
    correlation <- cor(filtered_data[[input$x_var]], filtered_data[[input$y_var]], use = "complete.obs")
    
    # Check if correlation is NA
    if (is.na(correlation)) {
      return("Tidak ada cukup data untuk menghitung korelasi.")
    }
    
    # Create interpretation based on correlation
    interpretation <- if (correlation > 0.7) {
      "Terdapat hubungan positif yang kuat antara variabel X dan Y."
    } else if (correlation > 0.3) {
      "Terdapat hubungan positif yang sedang antara variabel X dan Y."
    } else if (correlation < -0.7) {
      "Terdapat hubungan negatif yang kuat antara variabel X dan Y."
    } else if (correlation < -0.3) {
      "Terdapat hubungan negatif yang sedang antara variabel X dan Y."
    } else {
      "Tidak terdapat hubungan yang signifikan antara variabel X dan Y."
    }
    
    # Create a summary of the data
    summary_text <- paste("Evaluasi untuk scatter plot antara", input$x_var, "dan", input$y_var, ":",
                          "\n\n1. Nilai korelasi: ", round(correlation, 2),
                          "\n2. Interpretasi: ", interpretation)
    
    return(summary_text)
  })
  
  ##------------------------  Kecamatan ---------------------------------  
  
  #======================= Filter Kecamatan =======================#  
  output$filter_kecamatan <- renderUI({
    selectInput(
      inputId = "kecamatan_pilihan",
      label = "Pilih Kecamatan",
      choices = c("Semua", unique(wisata_data$Nama_Kec)), 
      selected = "Semua",
      multiple = TRUE  # Enable multiple selection
    )
  })
  
  #======================= Data Kelurahan =======================#
  kelurahan_data <- reactive({
    req(input$kecamatan_pilihan)  # Ensure input is not NULL
    
    if ("Semua" %in% input$kecamatan_pilihan) {
      wisata_data %>%
        group_by(Nama_Kel) %>%
        summarise(Jumlah_Wisata = n()) %>%
        arrange(desc(Jumlah_Wisata))
    } else {
      wisata_data %>%
        filter(Nama_Kec %in% input$kecamatan_pilihan) %>%
        group_by(Nama_Kel) %>%
        summarise(Jumlah_Wisata = n()) %>%
        arrange(desc(Jumlah_Wisata))
    }
  })
  
  #======================= Tabel Kecamatan =======================#
  output$kecamatan_table <- renderDataTable({
    req(input$kecamatan_pilihan)
    
    # If "Semua" is selected, display all data
    if ("Semua" %in% input$kecamatan_pilihan) {
      datatable(wisata_data[, c("Nama_Wisata", "Nama_Kabkot", "Nama_Kec", "Nama_Kel", "Tipe_Wisata", "Harga_Tiket", "Rating", "Jumlah_Ulasan")])
    } else {
      # Filter data based on selected Nama_Kec
      datatable(subset(wisata_data[, c("Nama_Wisata", "Nama_Kabkot", "Nama_Kec", "Nama_Kel", "Tipe_Wisata", "Harga_Tiket", "Rating", "Jumlah_Ulasan")], 
                       Nama_Kec %in% input$kecamatan_pilihan))
    }
  })
  
  #======================= Plot Jumlah Wisata Berdasarkan Kelurahan =======================#
  output$kelurahanPlot <- renderPlot({
    kelurahan_data_df <- kelurahan_data() %>%
      arrange(desc(Jumlah_Wisata)) %>%  # Sort from highest
      slice_max(Jumlah_Wisata, n = 20, with_ties = FALSE)  # Take top 20 without ties
    
    ggplot(kelurahan_data_df, aes(x = reorder(Nama_Kel, Jumlah_Wisata), y = Jumlah_Wisata)) +
      geom_bar(stat = "identity", fill = "#007bff", color = "#003366") +
      coord_flip() +
      labs(
        title = "Top Kelurahan dengan Jumlah Wisata Terbanyak",
        x = "Kelurahan",
        y = "Jumlah Wisata"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16, color = "#003366"),
        axis.text = element_text(size = 12, color = "#333333"),
        axis.title = element_text(face = "bold", color = "#003366"),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(color = "#cccccc", linewidth = 0.5)
      ) +
      geom_text(aes(label = Jumlah_Wisata), hjust = -0.2, size = 4, color = "#ffffff", fontface = "bold")
  })
  
  #======================= Plot Rating Berdasarkan Kelurahan =======================#
  output$ratingKelurahanPlot <- renderPlot({
    kelurahan_data_df <- kelurahan_data()
    
    # Calculate average rating per kelurahan and take top 20
    rating_data <- wisata_data %>%
      filter(Nama_Kel %in% kelurahan_data_df$Nama_Kel) %>%
      group_by(Nama_Kel) %>%
      summarise(Rata_Rating = mean(Rating, na.rm = TRUE)) %>%
      arrange(desc(Rata_Rating)) %>%
      slice_max(Rata_Rating, n = 20, with_ties = FALSE)
    
    # To display bars with highest ratings on top,
    # we reorder factors in ascending order (smallest value at bottom)
    rating_data <- rating_data %>% arrange(Rata_Rating)
    rating_data$Nama_Kel <- factor(rating_data$Nama_Kel, levels = rating_data$Nama_Kel)
    
    ggplot(rating_data, aes(x = Nama_Kel, y = Rata_Rating)) +
      geom_bar(stat = "identity", fill = "#1f77b4", color = "black") +
      coord_flip() +
      labs(
        title = "Top Kelurahan dengan Rata-rata Rating Wisata Tertinggi",
        x = "Kelurahan",
        y = "Rata-rata Rating"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
        axis.text = element_text(size = 12),
        axis.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(color = "grey", linewidth = 0.5)
      ) +
      geom_text(aes(label = round(Rata_Rating, 2)), hjust = -0.2, size = 4, color = "black")
  })
  
  #======================= Plot Rata-rata Harga Tiket Berdasarkan Kelurahan =======================#
  output$hargaKelurahanPlot <- renderPlot({
    harga_data <- wisata_data %>%
      filter(Nama_Kel %in% kelurahan_data()$Nama_Kel) %>%
      group_by(Nama_Kel) %>%
      summarise(Rata_Harga = mean(Harga_Tiket_Bersih, na.rm = TRUE)) %>%
      slice_max(order_by = Rata_Harga, n = 20, with_ties = FALSE)
    
    # Reorder factors so that kelurahan with highest prices appear on top
    harga_data <- harga_data %>% arrange(Rata_Harga)
    harga_data$Nama_Kel <- factor(harga_data$Nama_Kel, levels = harga_data$Nama_Kel)
    
    ggplot(harga_data, aes(x = Nama_Kel, y = Rata_Harga)) +
      geom_bar(stat = "identity", fill = "#2ca02c", color = "black") +
      coord_flip() +
      labs(
        title = "Top Kelurahan dengan Rata-rata Harga Tiket Tertinggi",
        x = "Kelurahan",
        y = "Rata-rata Harga Tiket (IDR)"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
        axis.text = element_text(size = 12),
        axis.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(color = "grey", linewidth = 0.5)
      ) +
      geom_text(aes(label = round(Rata_Harga, 0)), hjust = -0.2, size = 4, color = "black")
  })
  
  #======================= Plot Jumlah Ulasan Berdasarkan Kelurahan =======================#
  output$ulasanKelurahanPlot <- renderPlot({
    ulasan_data <- wisata_data %>%
      filter(Nama_Kel %in% kelurahan_data()$Nama_Kel) %>%
      group_by(Nama_Kel) %>%
      summarise(Jumlah_Ulasan = sum(Jumlah_Ulasan, na.rm = TRUE)) %>%
      slice_max(Jumlah_Ulasan, n = 20, with_ties = FALSE) %>%  # Only take top 20
      arrange(Jumlah_Ulasan)  # Sort ascending for correct factor order
    
    # Reorder factors so that kelurahan with most reviews appear on top
    ulasan_data$Nama_Kel <- factor(ulasan_data$Nama_Kel, levels = ulasan_data$Nama_Kel)
    
    ggplot(ulasan_data, aes(x = Nama_Kel, y = Jumlah_Ulasan)) +
      geom_bar(stat = "identity", fill = "#ff7f0e", color = "black") +
      coord_flip() +
      labs(
        title = "Top Kelurahan dengan Jumlah Ulasan Terbanyak",
        x = "Kelurahan",
        y = "Jumlah Ulasan"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
        axis.text = element_text(size = 12),
        axis.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(color = "grey", linewidth = 0.5)
      ) +
      geom_text(aes(label = Jumlah_Ulasan), hjust = -0.2, size = 4, color = "black")
  })
  
  #======================= Top 5 Wisata Terbaik =======================#
  output$top5_wisata_tableKec <- renderDataTable({
    # Get filtered tourist attractions based on selected kecamatan
    req(input$kecamatan_pilihan)  # Ensure at least one kecamatan is selected
    
    # Filter data based on selected kecamatan
    filtered_data <- if ("Semua" %in% input$kecamatan_pilihan) {
      wisata_data
    } else {
      wisata_data[wisata_data$Nama_Kec %in% input$kecamatan_pilihan, ]
    }
    
    # Get top 5 attractions based on rating
    top5_data <- filtered_data %>%
      arrange(desc(Rating)) %>%
      select(Nama_Wisata, Nama_Kabkot, Rating, Jumlah_Ulasan) %>%
      head(5)# Select relevant columns
    
    datatable(top5_data)
  })
  observeEvent(input$chat_whatsapp_team, {
    browseURL("https://wa.me/6287761435287?text=Halo, saya ingin bertanya tentang tim.")
  })
  
  # Assuming you have the following in your server function
  filtered_wisata <- reactive({
    req(input$wisata_tipe)  # Ensure input$wisata_tipe is not NULL
    req(input$rating_filter)  # Ensure input$rating_filter is not NULL
    
    filtered_data <- wisata_data
    
    # Filter by Tipe Wisata
    if (input$wisata_tipe != "Semua") {
      filtered_data <- filtered_data[filtered_data$Tipe_Wisata == input$wisata_tipe, ]
    }
    
    # Filter by Rating
    filtered_data <- filtered_data[filtered_data$Rating >= input$rating_filter, ]
    
    # Filter by Keyword
    if (input$keyword_filter != "") {
      # Tokenize the descriptions
      tokenized_data <- filtered_data %>%
        unnest_tokens(word, Deskripsi) %>%
        filter(!word %in% c(stopwords("en"), custom_stopwords))  # Remove stop words
      
      # Check if the keyword is present in the tokenized words
      keyword_present <- tokenized_data %>%
        filter(grepl(tolower(input$keyword_filter), word)) %>%
        distinct(Nama_Wisata)  # Get unique tourist attractions that match the keyword
      
      # Filter the original data based on the keyword presence
      filtered_data <- filtered_data %>%
        filter(Nama_Wisata %in% keyword_present$Nama_Wisata)
    }
    
    return(filtered_data)
  })
  
  # Daftar stop words kustom
  custom_stopwords <- c("dan", "atau", "yang", "di", "ke", "dari", "untuk", "adalah", "dengan","ini", "sebagai", "juga", "oleh",
                        "karena", "selain", "tidak", "kamu", "aku", "ada","sangat", "akan", "bagi", "perlu", "anda", "para", "situ")
  # Generate the word cloud
  output$wordcloud <- renderWordcloud2({
    # Check if there are any descriptions available
    if (all(is.na(wisata_data$Deskripsi)) || all(trimws(wisata_data$Deskripsi) == "")) {
      return(NULL)  # Return NULL if there are no descriptions
    }
    
    # Create a text corpus from the descriptions, filtering out empty descriptions
    corpus <- Corpus(VectorSource(wisata_data$Deskripsi[!is.na(wisata_data$Deskripsi) & trimws(wisata_data$Deskripsi) != ""]))
    
    # Preprocess the text
    corpus <- tm_map(corpus, content_transformer(tolower))  # Convert to lower case
    corpus <- tm_map(corpus, removePunctuation)  # Remove punctuation
    corpus <- tm_map(corpus, removeNumbers)  # Remove numbers
    corpus <- tm_map(corpus, removeWords, c(stopwords("en"), custom_stopwords))  # Remove stopwords
    corpus <- tm_map(corpus, stripWhitespace)  # Remove extra whitespace
    
    # Check if the corpus is empty after preprocessing
    if (length(corpus) == 0 || sum(sapply(corpus, nchar)) == 0) {
      return(NULL)  # Return NULL if the corpus is empty
    }
    
    # Create a term-document matrix
    tdm <- TermDocumentMatrix(corpus)
    m <- as.matrix(tdm)
    word_freqs <- sort(rowSums(m), decreasing = TRUE)
    word_freqs_df <- data.frame(word = names(word_freqs), freq = word_freqs)
    
    # Generate the word cloud
    wordcloud2(word_freqs_df, size = 2.5, color = "random-light")
  })
  
  output$filtered_wisata_table <- renderDataTable({
    req(filtered_wisata())  # Ensure data is available
    if (nrow(filtered_wisata()) == 0) {
      return(NULL)  # If no data, return NULL
    }
    
    datatable(filtered_wisata()[, c("Nama_Wisata", "Nama_Kabkot", "Nama_Kec", "Nama_Kel", "Tipe_Wisata", "Harga_Tiket", "Rating", "Jumlah_Ulasan")])
  })
  
  output$downloadManual <- downloadHandler(
    filename = function() {
      "Panduan_User_Web_Jabar.pdf"  # Name of the file to be downloaded
    },
    content = function(file) {
      # Directly redirect to the Google Docs link
      url <- "https://docs.google.com/document/d/1_41b_k-6Qeo5ULb2Zfd34H3Z_olurHYIcoDjD2Xi0Y4/export?format=pdf"
      download.file(url, destfile = file, mode = "wb")  # Download file from Google Docs
    }
  )
}



# Run the application 
shinyApp(ui, server)