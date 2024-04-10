library(tidyverse)
library(readxl)
library(lubridate)
library(ggrepel)
library(gridExtra)
library(ggpubr)
library(zoo)
options(ggrepel.max.overlaps=Inf)

# Values used in each plot for consistency. Colorblind friendly colors. 
pltSize = 25
numSize = 25
shapes = c(16,15,17,18,25,3,8,4,9,11)
shapes = rep(shapes,10)
shapesLong = c(shapes,rev(shapes),shapes)
dateFormat = "%b '%y"

bottomL = theme(text=element_text(size=pltSize),
      legend.position='bottom',
      panel.grid.major.y=element_line(color='grey'),
      panel.grid.minor=element_blank(),
      panel.background = element_blank(),
      axis.line=element_line(colour='black'),
      axis.text=element_text(size=numSize),
      legend.key=element_blank())

# blankTheme = theme(text=element_text(size=pltSize),
#       panel.grid.major.y=element_line(color='grey'),
#       panel.grid.minor=element_blank(),
#       panel.background = element_blank(),
#       axis.text=element_text(size=numSize),
#       axis.line=element_line(colour='black'),
#       legend.key=element_blank())
# 
# legendTwoRow = guides(fill=guide_legend(nrow=2,byrow=T))

bottomSlant = bottomL +
  #theme(axis.text.x = element_text(angle=45,hjust=0.5,vjust=0.5))
  theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1))
# 
# bottomUpDown = bottomL +
#   theme(axis.text.x = element_text(angle = 90,vjust=0.5,hjust=1))
  

dateX = scale_x_date(date_labels = dateFormat,
                     date_breaks = '1 month')

month_one = scale_x_date(date_labels = dateFormat,
                         date_breaks = '1 month')

month_two = scale_x_date(date_labels = dateFormat,
                         date_breaks = '2 month')

month_three = scale_x_date(date_labels = dateFormat,
                         date_breaks = '3 month')

month_six = scale_x_date(date_labels = dateFormat,
                         date_breaks = '6 month')


# grays = c("#EEEEEE",
#           '#CCCCCC',
#           '#999999',
#           '#666666')
# 
# conduc_lower_limit = 200
# 
# grays = rep(grays,3)

# cbbPalette <- c("#999999", # Hwy 93
#                 "#009E73",
#                 "#56B4E9",
#                 "#F0E442",
#                 "#E69F00", # Mulberry
#                 "#0072B2",
#                 "#D55E00",
#                 "#CC79A7",
#                 "#000000")
# cbbPaletteLong = c(cbbPalette,rev(cbbPalette),cbbPalette)

# Read in the data, and format the date column to date variable type
data = read_csv("Data/Data_Input.csv") %>%
  mutate(Date = as.Date(Date, format = "%m/%d/%Y"),
         Site = str_to_title(Site)) %>%
  arrange(Date)

analytes = names(data)[3:20]

# Transform the data from wide to long, which allows easier plot generation
data_long = data %>%
  pivot_longer(
    cols = all_of(analytes),
    names_to = "Analyte",
    values_to = "Value") %>%
  filter(!is.na(Value))

# The 'simple' column provides the column name in the data, and the
#  'combined' column has the variable with units, and will be used to 
#  make the y-label title of the plots.
name_conversion = read_xlsx("Data/Data_Names.xlsx")

allAnalytes = name_conversion %>%
  pull(DataColumn)

# Each boxplot and scatterplot are generated in the same way, so to save
#  space, these two functions are created here, and called when each plot
#  is generated. 
make_boxplot <- function(data, var, sites, dateRange){
  dateStrt = as.Date(dateRange[1])
  dateEnd = as.Date(dateRange[2])

  data_plot = data %>%
    filter(between(Date, dateStrt, dateEnd)) %>%
    select(Site,site_code,all_of(var)) %>%
    filter(!is.na(!!as.symbol(var)),
           Site %in% sites)
  
  yLab = name_conversion %>%
    filter(DataColumn == var) %>%
    pull(PlotLabel)
  
  plot_output = ggplot(data_plot) + 
    geom_boxplot(aes_string(x='site_code',
                            y=var,
                            fill='Site')) +
    labs(y= yLab,
         x='',
         fill="") +
    guides(fill = guide_legend(ncol=2))+
    bottomSlant
  
  plot_output
  
}

make_overtime <- function(data, var, sites, dateRange){
  # In case the date range isn't passed as a date, this turns it into the 
  # correct format. If already a date, it does nothing
  dateStrt = as.Date(dateRange[1])
  dateEnd = as.Date(dateRange[2])
  
  data_plot = data %>%
    # Filters to the right date range
    filter(between(Date, dateStrt, dateEnd)) %>%
    # Selects only the columns we care about, date, location, variable, color
    select(Site, all_of(var), Date) %>%
    filter(!is.na(!!as.symbol(var)),
           Site %in% sites)
  
  n_sites = data_plot$Site %>%
    unique() %>%
    length()
  
  shps = shapes[1:n_sites]

  # Calculate number of months of the plot. Used later to format x-axis.  
  n_mon = interval(
      first(data_plot$Date %>% sort()),
      last(data_plot$Date %>% sort())
    ) %/% months(1)
  
  yLab = name_conversion %>%
    filter(DataColumn == var) %>%
    pull(PlotLabel)
  
  plot_output = ggplot(data_plot) +
    geom_point(aes_string(x = 'Date',
                          y = var,
                          color = 'Site', shape = 'Site', fill = 'Site'),
               size=5) +
    scale_shape_manual(values = shps, guide = guide_legend(ncol=2))+
    labs(x='',color='',shape='',fill='',
         y = yLab)+
    bottomSlant

  if(n_mon>36){
    plot_output = plot_output + month_six
  } else if(n_mon>21){
    plot_output = plot_output + month_three
  } else if(n_mon>10){
    plot_output = plot_output + month_two
  } else {
    plot_output = plot_output + month_one
  }
  
  plot_output
  
}
#### First: Everything before the 'server' function is reading in and formatting the data
#### This is the function that will include all of the plot creation. Any information that is 
#### getting pulled from the UI file is input$objectName. Anything that gets passed to the UI
#### is an output$plotName. 
server <- function(input, output) {
  
  #allAnalytes = "ChlA"
  for(a1 in allAnalytes){
    local({
    a = a1
    plotName1 = paste0(a,"_Time")
    output[[plotName1]] <<- renderPlot({
      drTime = input[[paste0("DateRange",a)]]
      sitesTime = input[[paste0("SiteChoice",a)]]
      make_overtime(data,a,sitesTime,drTime)
    })
    
    plotName2 = paste0(a,"_Box")
    output[[plotName2]] <<- renderPlot({
      drBox = input[[paste0("BoxDateRange",a)]]
      sitesBox = input[[paste0("BoxSiteChoice",a)]]
      make_boxplot(data,a,sitesBox,drBox)
    })
    })
  }

}
