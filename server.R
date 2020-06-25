# Define server logic required to draw a histogram
server <- function(input, output) {

  output$ref_map <- renderPlot({
    ggplot(us, aes(x = long, y = lat, group = group)) +
      geom_polygon(fill="lightgray", colour = "black")+
      geom_rect(aes(xmin=input$lon[1],
                    xmax=input$lon[2],
                    ymin=input$lat[1],
                    ymax=input$lat[2]),
                fill="darkorchid2",
                alpha=0.01
      )
    
  })
  
  # K8 I think
    output$sawtooth <- renderPlot({
      min_lat <- input$lat[1]
      max_lat <- input$lat[2]
      min_lon <- input$lon[1]%%360
      max_lon <- input$lon[2]%%360
      
      plot_sawtooths(min_lat,max_lat,min_lon,max_lon )
    })
    
    output$ref_map <- renderPlot({
      ggplot(us, aes(x = long, y = lat, group = group)) +
        geom_polygon(fill="lightgray", colour = "black")+
        geom_rect(aes(xmin=input$lon[1],
                      xmax=input$lon[2],
                      ymin=input$lat[1],
                      ymax=input$lat[2]),
                  fill="darkorchid2",
                  alpha=0.01
                  )
      
    })
    # smither8
    output$shp_map <- renderPlot({ #shapefile 
      plot(shp_file_s8$geometry)
    })
    
    output$hov_info <- renderTable({ #table for hover
      if (is.null(input$hov)){NULL}
      else{
        hov_df[1] <- input$hov$x
        hov_df[2] <- input$hov$y
      }
      hov_df
    })
    
    output$brus_info <- renderTable({     # display rectangle
      if (is.null(input$brus)){
        NULL
      }
      else{
        extent_df[1,1] <<- input$brus$xmin
        extent_df[2,1] <<- input$brus$xmax
        extent_df[2,2] <<- input$brus$ymin
        extent_df[1,2] <<- input$brus$ymax
      }
      extent_df
    }, rownames = TRUE)
    
    output$insert_any_plot <- renderPlot({ #just a placeholder plot
      ggplot(data=extent_df)+
        geom_point(aes(x=Longitude, y=Latitude))
    }
    )

}

