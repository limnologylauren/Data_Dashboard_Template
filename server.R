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

blankTheme = theme(text=element_text(size=pltSize),
      panel.grid.major.y=element_line(color='grey'),
      panel.grid.minor=element_blank(),
      panel.background = element_blank(),
      axis.text=element_text(size=numSize),
      axis.line=element_line(colour='black'),
      legend.key=element_blank())

legendTwoRow = guides(fill=guide_legend(nrow=2,byrow=T))

bottomSlant = bottomL +
  #theme(axis.text.x = element_text(angle=45,hjust=0.5,vjust=0.5))
  theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1))

bottomUpDown = bottomL +
  theme(axis.text.x = element_text(angle = 90,vjust=0.5,hjust=1))
  

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


grays = c("#EEEEEE",
          '#CCCCCC',
          '#999999',
          '#666666')

conduc_lower_limit = 200

grays = rep(grays,3)

cbbPalette <- c("#999999", # Hwy 93
                "#009E73",
                "#56B4E9",
                "#F0E442",
                "#E69F00", # Mulberry
                "#0072B2",
                "#D55E00",
                "#CC79A7",
                "#000000")
cbbPaletteLong = c(cbbPalette,rev(cbbPalette),cbbPalette)

# Read in the data, and format the date column to date variable type
data = read_csv("Data/CPF_reservoir_chemistry_up_to_20230907.csv") %>%
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
units_list = read_xlsx("Data/Units_Cam_Peak.xlsx")

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
  
  yLab = units_list %>%
    filter(simple == var) %>%
    pull(combined)
  
  plot_output = ggplot(data_plot) + 
    geom_boxplot(aes_string(x='site_code',
                            y=var,
                            fill='Site')) +
    labs(y= yLab,
         x='',
         fill="") +
    guides(fill = guide_legend(ncol=2))+
#    scale_fill_manual(guide=guide_legend(ncol=2)) +
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
  
  yLab = units_list %>%
    filter(simple == var) %>%
    pull(combined)
  
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
  

  output$TSS_Time <- renderPlot({
    dr = input$DateRangeTSS
    sites = input$SiteChoiceTSS
    plot = make_overtime(data,varName,sites,dr)
    plot
  })
  output$TSS_Box <- renderPlot({
    dr = input$BoxDateRangeTSS
    sites = input$BoxSiteChoiceTSS
    plot = make_boxplot(data,'TSS',sites,dr)
    plot
  })  

  output$pH_Time <- renderPlot({
    dr = input$DateRangepH
    sites = input$SiteChoicepH
    plot = make_overtime(data,'pH',sites,dr)
    plot
  })
  output$pH_Box <- renderPlot({
    dr = input$BoxDateRangepH
    sites = input$BoxSiteChoicepH
    plot = make_boxplot(data,'pH',sites,dr)
    plot
  })
  
  output$Turbidity_Time <- renderPlot({
    dr = input$DateRangeTurbidity
    sites = input$SiteChoiceTurbidity
    plot = make_overtime(data,'Turbidity',sites,dr)
    plot
  })
  output$Turbidity_Box <- renderPlot({
    dr = input$BoxDateRangeTurbidity
    sites = input$BoxSiteChoiceTurbidity
    plot = make_boxplot(data,'Turbidity',sites,dr)
    plot
  })
  
  output$ChlA_Time <- renderPlot({
    dr = input$DateRangeChlA
    sites = input$SiteChoiceChlA
    plot = make_overtime(data,'ChlA',sites,dr)
    plot
  })
  output$ChlA_Box <- renderPlot({
    dr = input$BoxDateRangeChlA
    sites = input$BoxSiteChoiceChlA
    plot = make_boxplot(data,'ChlA',sites,dr)
    plot
  })
  
  output$DOC_Time <- renderPlot({
    dr = input$DateRangeDOC
    sites = input$SiteChoiceDOC
    plot = make_overtime(data,'DOC',sites,dr)
    plot
  })
  output$DOC_Box <- renderPlot({
    dr = input$BoxDateRangeDOC
    sites = input$BoxSiteChoiceDOC
    plot = make_boxplot(data,'DOC',sites,dr)
    plot
  })
  
  output$DTN_Time <- renderPlot({
    dr = input$DateRangeDTN
    sites = input$SiteChoiceDTN
    plot = make_overtime(data,'DTN',sites,dr)
    plot
  })
  output$DTN_Box <- renderPlot({
    dr = input$BoxDateRangeDTN
    sites = input$BoxSiteChoiceDTN
    plot = make_boxplot(data,'DTN',sites,dr)
    plot
  })
  
  output$ANC_Time <- renderPlot({
    dr = input$DateRangeANC
    sites = input$SiteChoiceANC
    plot = make_overtime(data,'ANC',sites,dr)
    plot
  })
  output$ANC_Box <- renderPlot({
    dr = input$BoxDateRangeANC
    sites = input$BoxSiteChoiceANC
    plot = make_boxplot(data,'ANC',sites,dr)
    plot
  })
  
  output$SC_Time <- renderPlot({
    dr = input$DateRangeSC
    sites = input$SiteChoiceSC
    plot = make_overtime(data,'SC',sites,dr)
    plot
  })
  output$SC_Box <- renderPlot({
    dr = input$BoxDateRangeSC
    sites = input$BoxSiteChoiceSC
    plot = make_boxplot(data,'SC',sites,dr)
    plot
  })
  
  output$Na_Time <- renderPlot({
    dr = input$DateRangeNa
    sites = input$SiteChoiceNa
    plot = make_overtime(data,'Na',sites,dr)
    plot
  })
  output$Na_Box <- renderPlot({
    dr = input$BoxDateRangeNa
    sites = input$BoxSiteChoiceNa
    plot = make_boxplot(data,'Na',sites,dr)
    plot
  })
  
  output$NH4_Time <- renderPlot({
    dr = input$DateRangeNH4
    sites = input$SiteChoiceNH4
    plot = make_overtime(data,'NH4',sites,dr)
    plot
  })
  output$NH4_Box <- renderPlot({
    dr = input$BoxDateRangeNH4
    sites = input$BoxSiteChoiceNH4
    plot = make_boxplot(data,'NH4',sites,dr)
    plot
  })
  
  output$K_Time <- renderPlot({
    dr = input$DateRangeK
    sites = input$SiteChoiceK
    plot = make_overtime(data,'K',sites,dr)
    plot
  })
  output$K_Box <- renderPlot({
    dr = input$BoxDateRangeK
    sites = input$BoxSiteChoiceK
    plot = make_boxplot(data,'K',sites,dr)
    plot
  })
  
  output$Mg_Time <- renderPlot({
    dr = input$DateRangeMg
    sites = input$SiteChoiceMg
    plot = make_overtime(data,'Mg',sites,dr)
    plot
  })
  output$Mg_Box <- renderPlot({
    dr = input$BoxDateRangeMg
    sites = input$BoxSiteChoiceMg
    plot = make_boxplot(data,'Mg',sites,dr)
    plot
  })
  
  output$Ca_Time <- renderPlot({
    dr = input$DateRangeCa
    sites = input$SiteChoiceCa
    plot = make_overtime(data,'Ca',sites,dr)
    plot
  })
  output$Ca_Box <- renderPlot({
    dr = input$BoxDateRangeCa
    sites = input$BoxSiteChoiceCa
    plot = make_boxplot(data,'Ca',sites,dr)
    plot
  })
  
  output$F_Time <- renderPlot({
    dr = input$DateRangeF
    sites = input$SiteChoiceF
    plot = make_overtime(data,'F',sites,dr)
    plot
  })
  output$F_Box <- renderPlot({
    dr = input$BoxDateRangeF
    sites = input$BoxSiteChoiceF
    plot = make_boxplot(data,'F',sites,dr)
    plot
  })
  
  output$Cl_Time <- renderPlot({
    dr = input$DateRangeCl
    sites = input$SiteChoiceCl
    plot = make_overtime(data,'Cl',sites,dr)
    plot
  })
  output$Cl_Box <- renderPlot({
    dr = input$BoxDateRangeCl
    sites = input$BoxSiteChoiceCl
    plot = make_boxplot(data,'Cl',sites,dr)
    plot
  })
  
  output$NO3_Time <- renderPlot({
    dr = input$DateRangeNO3
    sites = input$SiteChoiceNO3
    plot = make_overtime(data,'NO3',sites,dr)
    plot
  })
  output$NO3_Box <- renderPlot({
    dr = input$BoxDateRangeNO3
    sites = input$BoxSiteChoiceNO3
    plot = make_boxplot(data,'NO3',sites,dr)
    plot
  })
  
  output$PO4_Time <- renderPlot({
    dr = input$DateRangePO4
    sites = input$SiteChoicePO4
    plot = make_overtime(data,'PO4',sites,dr)
    plot
  })
  output$PO4_Box <- renderPlot({
    dr = input$BoxDateRangePO4
    sites = input$BoxSiteChoicePO4
    plot = make_boxplot(data,'PO4',sites,dr)
    plot
  })
  
  output$SO4_Time <- renderPlot({
    dr = input$DateRangeSO4
    sites = input$SiteChoiceSO4
    plot = make_overtime(data,'SO4',sites,dr)
    plot
  })
  output$SO4_Box <- renderPlot({
    dr = input$BoxDateRangeSO4
    sites = input$BoxSiteChoiceSO4
    plot = make_boxplot(data,'SO4',sites,dr)
    plot
  })
  
}
