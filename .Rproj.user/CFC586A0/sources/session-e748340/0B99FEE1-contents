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
library(scales)


#----------------(Data)------------------

# Membaca file CSV dan TSV (pastikan file berada di lokasi yang sesuai)
library(readr)
library(dplyr)

# Membaca data dari URL
data_wisata <- read_csv("https://raw.githubusercontent.com/ngurahsentana24/ngurah/ngurahsentana24-patch-1/Entity%20Wisata_Clean.csv")
data_kelurahan <- read_tsv("https://raw.githubusercontent.com/ngurahsentana24/ngurah/ngurahsentana24-patch-1/Entity%20Kelurahan.csv")
data_kecamatan <- read_tsv("https://raw.githubusercontent.com/ngurahsentana24/ngurah/ngurahsentana24-patch-1/Entity%20Kecamatan.csv")
data_kab <- read_tsv("https://raw.githubusercontent.com/ngurahsentana24/ngurah/ngurahsentana24-patch-1/Entity%20Kab-Kota.csv")

# Pastikan URL untuk detail mengarah ke file CSV yang dapat diunduh
detail <- read_csv("https://raw.githubusercontent.com/ngurahsentana24/ngurah/ngurahsentana24-patch-1/Alamat_Wisata_Cleaned.csv")

# Menampilkan data dari masing-masing tabel
head(data_wisata)
head(data_kelurahan)
head(data_kecamatan)
head(data_kab)
head(detail)

# Melakukan join berdasarkan kolom yang sesuai
data_gabungan <- data_wisata %>%
  left_join(data_kelurahan, by = c("Kode_Kec" = "Kode_Kec", "Kode_Kel" = "Kode_Kel")) %>%
  left_join(data_kecamatan, by = c("Kode_Kabkot" = "Kode_Kabkot", "Kode_Kec" = "Kode_Kec")) %>%
  left_join(data_kab, by = "Kode_Kabkot") %>%
  left_join(detail, by = "Kode_Wisata")

# Menampilkan hasil gabungan
head(data_gabungan)

#-------------------- UI (Tampilan Front-End) ---------------
ui <- dashboardPage(
  
  ##------------------------ Header -----------------------------
  dashboardHeader(
    title = div(style = "text-align: center;",img(src = "https://upload.wikimedia.org/wikipedia/commons/9/99/Coat_of_arms_of_West_Java.svg", height = 50, width = 50, style = "margin-bottom: -5px;"), h1("Jawa Barat", style = "color: #00000; font-size: 38px; font-weight: bold; margin-top: -20px;"), p(strong("Gemah Ripah Repeh Rapih"), style = "color: #00000; background-color: #f8e5b3; font-size: 14px; margin-top: -5px; font-family: 'Poplin', sans-serif;"), textOutput("tanggal")), 
    titleWidth = 400),
  
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
    tabItems(
      ###----------------------------- Home ---------------------------------
      tabItem(
        tabName = "beranda",
        jumbotron(
          title = div(
            img(src = "https://upload.wikimedia.org/wikipedia/commons/9/99/Coat_of_arms_of_West_Java.svg", height = 300, width = 350, style = "font-size:90px;font-weight:bold;display: flex;align-items: center"),
            "Pariwisata Jawa Barat",
            style = "font-size:50px;font-weight:bold; display: flex; align-items: center;"
          ),
          lead = span("Selamat Datang di Jawa Barat!", style = "font-size:20px;font-weight:bold; background-color: #f8e5b3; padding: 10px; border-radius: 5px;"),
          href = "https://disparbud.jabarprov.go.id",
          status = "warning"
        ),
        fluidRow(
          box(title = "Keindahan Alam Jawa Barat", status = "primary", width = 12,
              slickROutput("slideshow", width = "100%", height = "400px"))
        ),
        fluidRow(
          box(title = "Video Pariwisata Jawa Barat", status = "primary", width = 12, 
              HTML('<iframe width="100%" height="400" src="https://www.youtube.com/embed/iM4Gf9XkfKY" frameborder="0" allowfullscreen></iframe>')
          )
        )
      ),
      
      
      ###----------------------------- Wisata ---------------------------------
      tabItem(
        tabName = "wisata",
        fluidRow(
          valueBox(
            value = HTML(paste0("<span style='font-size: 24px;'>", length(data_gabungan$Kode_Wisata))),
            subtitle = "Total Wisata", 
            icon = icon("home", lib = "font-awesome"), 
            color = "primary", 
            width = 4
          ),
          valueBox(
            value = HTML(paste0("<span style='font-size: 24px;'>", mean(as.numeric(data_gabungan$Rating), na.rm = TRUE))),
            subtitle = "Rata Rata Rating ", 
            icon = icon("star", lib = "font-awesome"), 
            color = "warning", 
            width = 4
          ),
          valueBox(
            value = HTML(paste0("<span style='font-size: 24px;'>", 
                                formatC(mean(data_gabungan$Harga_Tiket_Bersih, na.rm = TRUE), 
                                        format = "f", big.mark = ".", decimal.mark = ",", digits = 0), 
                                " IDR</span>")),
            subtitle = "Rata-rata Harga Tiket", 
            icon = icon("box", lib = "font-awesome"), 
            color = "danger",
            width = 4
          )
        ),
        fluidRow(
          box(title = "Peta Lokasi Wisata", width = 12, leafletOutput("wisata_map", height = 500))
        ),
        
        fluidRow(
          box(title = "Filter Wisata", width = 6, uiOutput("filter_wisata")),
          box(title = "Data Wisata", width = 12, dataTableOutput("wisata_table"))
        ),
        fluidRow(
          box(title = "Distribusi Tipe Wisata", width = 6, plotOutput("typePlot")),
          box(title = "Distribusi Rating Wisata", width = 6, plotOutput("ratingPlot"))
        ),
        fluidRow(
          box(title = "Rata-rata Harga Tiket Berdasarkan Tipe Wisata", width = 6, plotOutput("pricePlot")),
          box(title = "Jumlah Wisata Berdasarkan Kabupaten", width = 6, plotOutput("countyPlot"))
        ),
        fluidRow(
          box(title = "Pilih Wisata untuk Total Biaya", width = 10,
              selectInput("selected_wisata", "Pilih Wisata", 
                          choices = NULL, multiple = TRUE),
              actionButton("calculate_cost", "Hitung Total Biaya")
          ),
          box(title = "Total Biaya", width = 10,
              textOutput("total_cost")
          )
        ),
      ),
      
      
      
      ###----------------------------- Kabupaten/Kota ---------------------------------
      tabItem(
        tabName = "kota",
        fluidRow(
          box(title = "Filter Kabupaten/Kota", width = 6, uiOutput("filter_kota")),
          box(title = "Distribusi Tipe Wisata", width = 6, plotOutput("typePlot")),
          box(title = "Data Kabupaten", width = 12, dataTableOutput("kota_table"))
        )
      ),
      
      ###----------------------------- Kecamatan ---------------------------------
      tabItem(
        tabName = "kecamatan",
        fluidRow(
          box(title = "Filter Kecamatan", width = 6, uiOutput("filter_kecamatan")),
          box(title = "Data Kecamatan", width = 12, dataTableOutput("kecamatan_table"))
        )
      ),
      
      
      ###----------------------------- Team ---------------------------------
      tabItem(
        tabName = "info",
        h2("Our Amazing Team", align = "center", 
           style = "color: #00000; font-size: 36px; font-weight: bold ; background-color: #f8e5b3;"),
        fluidRow(
          column(12, align = "center",
                 p(HTML("Need Help? Contact Us!;"), style = "font-size:18px; color:#555; background-color: #f8e5b3")
          )
        ),
        
        fluidRow(
          img(src = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTlLaFt95PU641AOqkZTkjXAGgYLjK7zn5zWg&s", 
              width = "100%", style = "border-radius:10px; margin-bottom:15px;")
        ),
        
        fluidRow(
          box(
            title = "Frontend Developer- Ngurah Sentana",
            status = "warning",
            solidHeader = TRUE,
            width = 6,
            collapsible = TRUE,
            collapsed = TRUE,
            img(src = "https://media.licdn.com/dms/image/v2/C4E03AQGHxSavWR0yQg/profile-displayphoto-shrink_200_200/0/1623592048266", 
                width = "100%", style = "border-radius:10px; margin-bottom:15px;"),
            tags$a(href = "https://www.instagram.com/ngurahsentana24", class = "btn btn-primary btn-block", 
                   icon("instagram"), " Instagram"),
            tags$a(href = "https://github.com/ngurahsentana24", class = "btn btn-dark btn-block",
                   icon("github"), " GitHub")
          ),
          box(
            title = "Database Manager - Desy",
            status = "warning",
            solidHeader = TRUE,
            width = 6,
            collapsible = TRUE,
            collapsed = TRUE,
            img(src = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTlLaFt95PU641AOqkZTkjXAGgYLjK7zn5zWg&s", 
                width = "100%", style = "border-radius:10px; margin-bottom:15px;"),
            tags$a(href = "https://www.instagram.com/desy_endriani", class = "btn btn-primary btn-block", 
                   icon("instagram"), " Instagram"),
            tags$a(href = "https://github.com/desyendriani", class = "btn btn-dark btn-block",
                   icon("github"), " GitHub")
          )
        )
      )
    )
  )
)

#-------------------- Server (Tampilan Back-End) ---------------

server <- function(input, output, session) {
  
  ##------------------------  Home ---------------------------------
  
  #======================= Slideshow Gambar =======================#
  output$slideshow <- renderSlickR({
    slickR(
      list(
        "https://d2s1u1uyrl4yfi.cloudfront.net/disparbud/slideshow/cc100156692eb022566b0739a5369349.webp", 
        "https://d2s1u1uyrl4yfi.cloudfront.net/disparbud/slideshow/062aa4b1ae5e52807ab7d57181caeafc.webp", 
        "https://d2s1u1uyrl4yfi.cloudfront.net/disparbud/slideshow/6ba3daa6b33667875dd1187e9c15893b.webp"
      ), height = 400, width = "100%"
    ) + settings(autoplay = TRUE, autoplaySpeed = 3000, dots = TRUE)
  })
  
  
  ##------------------------  Wisata ---------------------------------
  
  #======================= Data Wisata =======================#
  wisata_data <- data.frame(
    Nama_Wisata = data_gabungan$Nama_Wisata,
    Lokasi = data_gabungan$Nama_Kabkot,
    Kecamatan = data_gabungan$Kode_Kec,
    Kelurahan = data_gabungan$Kode_Kel,
    Tipe = data_gabungan$Tipe_Wisata,
    Latitude = data_gabungan$Latitude,
    Longitude = data_gabungan$Longitude,
    Harga_Tiket = data_gabungan$Harga_Tiket_Bersih,
    Rating = data_gabungan$Rating,
    Jumlah_Ulasan = data_gabungan$Jumlah_Ulasan,
    Foto = sample(c(
      "https://upload.wikimedia.org/wikipedia/commons/8/83/Pantai_Pangandaran.jpg",
      "https://upload.wikimedia.org/wikipedia/commons/8/83/Pantai_Pangandaran.jpg",
      "https://upload.wikimedia.org/wikipedia/commons/a/a8/Mangrove.jpg",
      "https://upload.wikimedia.org/wikipedia/commons/a/a8/Mangrove.jpg",
      "https://upload.wikimedia.org/wikipedia/commons/a/a8/Mangrove.jpg"
    ), nrow(data_gabungan), replace = TRUE),
    Deskripsi = data_gabungan$Deskripsi
  )
  
  #======================= Filter Wisata =======================#
  output$filter_wisata <- renderUI({
    # Mengambil pilihan unik dari kolom tipe_wisata
    unique_choices <- unique(wisata_data$Tipe)
    
    # Menambahkan "Semua" sebagai pilihan pertama
    choices <- c("Semua", unique_choices)
    
    selectInput("wisata_tipe", "Pilih Tipe Wisata", 
                choices = choices, 
                selected = "Semua")  # Pastikan ada nilai default
  })
  
  #======================= Data Wisata Sesuai Filter =======================#
  filtered_wisata <- reactive({
    req(input$wisata_tipe)  # Memastikan input$wisata_tipe tidak NULL
    
    if (input$wisata_tipe == "Semua") {
      return(wisata_data)
    } else {
      return(wisata_data[wisata_data$Tipe == input$wisata_tipe, ])
    }
  })
  
  #======================= Peta Interaktif dengan Filter =======================#
  output$wisata_map <- renderLeaflet({
    leaflet() %>%
      addTiles()
  })
  
  observe({
    filtered_data <- filtered_wisata()
    
    if (!is.null(filtered_data) && nrow(filtered_data) > 0) {
      leafletProxy("wisata_map", data = filtered_data) %>%
        clearMarkers() %>%
        addMarkers(
          lng = ~Longitude, lat = ~Latitude,
          popup = ~paste0(
            "<div style='font-family: Arial, sans-serif; width: 280px; padding: 10px; background: #f9f9f9; border-radius: 8px; box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1); text-align: center;'>
            <h4 style='margin: 5px 0; color: #333; font-size: 16px;'>", Nama_Wisata, "</h4>
            <img src='", Foto, "' width='260px' height='150px' style='border-radius: 6px; margin-bottom: 8px;'>
            <p style='font-size: 13px; color: #666; margin-bottom: 5px;'><b>Lokasi:</b> ", Lokasi, "</p>
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
        setView(lng = mean(filtered_data$Longitude, na.rm = TRUE), 
                lat = mean(filtered_data$Latitude, na.rm = TRUE), zoom = 10)
    }
  })
  
  #====================== Tabel Data Wisata ==========================#
  output$wisata_table <- renderDataTable({
    req(input$wisata_tipe)
    if (input$wisata_tipe == "Semua") {
      datatable(wisata_data[, c("Nama_Wisata", "Lokasi", "Kecamatan","Kelurahan","Tipe", "Harga_Tiket", "Rating", "Jumlah_Ulasan")])
    } else {
      datatable(subset(wisata_data[, c("Nama_Wisata", "Lokasi", "Kecamatan","Kelurahan","Tipe", "Harga_Tiket", "Rating", "Jumlah_Ulasan")], Tipe == input$wisata_tipe))
    }
  })
  
  # Update the choices for the selectInput based on the available tourist attractions
  observe({
    updateSelectInput(session, "selected_wisata", 
                      choices = wisata_data$Nama_Wisata)
  })
  #======================= Hitung Biaya =======================#
  # Calculate total cost when the button is clicked
  observeEvent(input$calculate_cost, {
    req(input$selected_wisata)  # Ensure that at least one attraction is selected
    
    # Filter the selected attractions and sum their ticket prices
    total_cost <- sum(wisata_data$Harga_Tiket[wisata_data$Nama_Wisata %in% input$selected_wisata], na.rm = TRUE)
    
    # Format the total cost as Rupiah
    total_cost_formatted <- formatC(total_cost, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)
    
    # Update the output text
    output$total_cost <- renderText({
      paste("Total Biaya: IDR", total_cost_formatted)
    })
  })
  #======================= Visualisasi Wisata =======================#
  # Visualisasi Tipe Wisata
  output$typePlot <- renderPlot({
    ggplot(wisata_data, aes(x = Tipe)) +
      geom_bar(fill = "#69b3a2", color = "black", width = 0.6) +
      labs(
        title = "Distribusi Tipe Wisata",
        x = "Tipe Wisata",
        y = "Jumlah"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold"),
        axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank()
      )
    
  })
  
  # Visualisasi Rating Wisata
  output$ratingPlot <- renderPlot({
    ggplot(wisata_data, aes(x = Rating)) +
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
      ) +
      geom_vline(aes(xintercept = mean(Rating, na.rm = TRUE)), 
                 color = "red", linetype = "dashed", linewidth = 1) +
      annotate("text", x = mean(wisata_data$Rating, na.rm = TRUE), y = max(table(wisata_data$Rating)) * 0.9, 
               label = "Mean", color = "red", fontface = "bold", vjust = -0.5)
    
  })
  
  # Visualisasi Harga Tiket
  output$pricePlot <- renderPlot({
    ggplot(wisata_data, aes(x = Tipe, y = Harga_Tiket)) +
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
    ggplot(wisata_data, aes(x = reorder(Lokasi, -table(Lokasi)[Lokasi]))) +
      geom_bar(fill = "#ff7f0e", color = "black", width = 0.7) +
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
        panel.grid.major.y = element_blank()
      )
  })
  
  
  ##------------------------  Kabupaten/Kota ---------------------------------
  
  #======================= Filter Kabupaten Kota =======================#  
  output$filter_kota <- renderUI({
    selectInput(
      inputId = "kota_pilihan",
      label = "Pilih Kabupaten/Kota",
      choices = c("Semua", unique(data_gabungan$Nama_Kabkot)), 
      selected = "Semua"
    )
  })
  
  #======================= Tabel Kabupaten ============================#
  output$kota_table <- renderDataTable({
    req(input$kota_pilihan)
    if (input$kota_pilihan == "Semua") {
      datatable(wisata_data[, c("Nama_Wisata", "Lokasi", "Kecamatan","Kelurahan","Tipe", "Harga_Tiket", "Rating", "Jumlah_Ulasan")])
    } else {
      datatable(subset(wisata_data[, c("Nama_Wisata", "Lokasi", "Kecamatan","Kelurahan","Tipe", "Harga_Tiket", "Rating", "Jumlah_Ulasan")], Lokasi == input$kota_pilihan))
    }
  })
  
  #======================= Visualisasi Tipe Wisata Berdasarkan Kabupaten =====================#
  output$typePlot <- renderPlot({
    filtered_data <- wisata_data[wisata_data$Lokasi == input$kota_pilihan | input$kota_pilihan == "Semua", ]
    
    ggplot(filtered_data, aes(x = Tipe, fill = Tipe)) +
      geom_bar(stat = "count", color = "black", width = 0.7, show.legend = FALSE) +
      geom_text(
        stat = "count", aes(label = ..count..), 
        vjust = -0.3, size = 5, fontface = "bold", color = "black"
      ) +
      scale_fill_brewer(palette = "Pastel1") +  # Warna lebih soft dan profesional
      labs(
        title = paste("Distribusi Tipe Wisata di", input$kota_pilihan),
        x = "Tipe Wisata",
        y = "Jumlah Wisata"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
        axis.title.x = element_text(size = 14, face = "bold"),
        axis.title.y = element_text(size = 14, face = "bold"),
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
        panel.grid.major.x = element_blank(),  # Menghapus grid vertikal agar lebih bersih
        panel.grid.minor = element_blank()
      )
    
  })
  
  
  ##------------------------  Kecamatan ---------------------------------  
  
  #======================= Filter Kecamatan =======================#  
  output$filter_kecamatan <- renderUI({
    selectInput(
      inputId = "kecamatan_pilihan",
      label = "Pilih Kecamatan",
      choices = c("Semua", unique(wisata_data$nama_kec)), 
      selected = "Semua"
    )
  })
  #======================= Tabel Kecamatan =======================#
  output$kecamatan_table <- renderDataTable({
    req(input$kecamatan_pilihan)
    if (input$kecamatan_pilihan == "Semua") {
      datatable(wisata_data[, c("Nama_Wisata", "Lokasi", "Kecamatan","Kelurahan","Tipe", "Harga_Tiket", "Rating", "Jumlah_Ulasan")])
    } else {
      datatable(subset(wisata_data[, c("Nama_Wisata", "Lokasi", "Kecamatan","Kelurahan","Tipe", "Harga_Tiket", "Rating", "Jumlah_Ulasan")], Kecamatan == input$kecamatan_pilihan))
    }
  })
  
}

shinyApp(ui, server)