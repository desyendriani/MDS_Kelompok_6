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
