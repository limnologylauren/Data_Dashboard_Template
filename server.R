library(tidyverse)
library(readxl)
options(ggrepel.max.overlaps=Inf)

pltSize = 25
numSize = 25
shapes = c(16,15,17,18,25,3,8,4,9,11)
cbPalette =c("#999999","#009E73","#56B4E9", "#F0E442",
             "#E69F00","#0072B2","#D55E00", "#CC79A7",
             "#000000") # This color palette is colorblind friendly

alphas = c(
  rep(1,length(cbPalette)),
  #rep(.9,length(cbPalette)),
  #rep(.8,length(cbPalette)),
  rep(.7,length(cbPalette)),
  #rep(.6,length(cbPalette)),
  rep(.5,length(cbPalette)),
  #rep(.4,length(cbPalette)),
  rep(.3,length(cbPalette))
)
# Adding multiple alpha values in case there are more than 9 sites used in a
#  single boxplot

shapes = rep(shapes,length(cbPalette))
cbPalette = rep(cbPalette,length(shapes))
# Having a different number of distinct shapes and colors prevents pairs of 
#  colors and shapes from being reused.
dateFormat = "%b '%y"

bottomL = theme(text=element_text(size=pltSize),
      legend.position='bottom',
      panel.grid.major.y=element_line(color='grey'),
      panel.grid.minor=element_blank(),
      panel.background = element_blank(),
      axis.line=element_line(colour='black'),
      axis.text=element_text(size=numSize),
      legend.key=element_blank())

bottomSlant = bottomL +
  theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1))

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
  
  # Extract a color for each site.
  colrs = cbPalette[1:length(sites)]
  alphs = alphas[1:length(sites)]

  # If this data set doesn't have a "Site Code" column, then create one, and 
  #  make it identical to the Site column.
  if(!("Site Code" %in% names(data))){
    data = data %>%
      mutate('Site Code' = Site)
  }
  
  data_plot_sort = data %>%
    filter(between(Date, dateStrt, dateEnd)) %>%
    select(Site,`Site Code`,all_of(var)) %>%
    filter(!is.na(!!as.symbol(var)),
           Site %in% sites) %>%
    arrange(Site)
  
  # By setting the site and site code to factors, that keeps them in the 
  #  order specified by the levels(). The level order is determined by the 
  #  previous table, which is sorted by Site alphabetically. Doing this
  #  step ensures the x-axis order and legend order match.
  data_plot = data_plot_sort %>%
    mutate(Site = factor(Site, levels = data_plot_sort %>%
                           pull(Site) %>%
                           unique()),
           `Site Code` = factor(`Site Code`, levels = data_plot_sort %>%
                                  pull(`Site Code`) %>%
                                  unique()))
  
  yLab = name_conversion %>%
    filter(DataColumn == var) %>%
    pull(PlotLabel)
  
  plot_output = ggplot(data_plot) + 
    geom_boxplot(aes(x=`Site Code`,
                     y=get(var),
                     fill = Site,
                     alpha = Site)) +
    labs(y= yLab,
         x='',
         fill="",
         alpha = "") +
    scale_fill_manual(values = colrs, guide=guide_legend(ncol=2)) +
    scale_alpha_manual(values = alphs) +
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
    # Selects only the columns we care about, date, location, variable
    select(Site, all_of(var), Date) %>%
    # Remove any missing values, and plot only the selected sites.
    filter(!is.na(!!as.symbol(var)),
           Site %in% sites)
  
  n_sites = data_plot$Site %>%
    unique() %>%
    length()
  
  shps = shapes[1:n_sites]
  colrs= cbPalette[1:n_sites]

  # Calculate number of months of the plot. Used later to format x-axis.  
  n_mon = interval(
      first(data_plot$Date %>% sort()),
      last(data_plot$Date %>% sort())
    ) %/% months(1)
  
  # Extract the desired y-axis label from the data name values.
  yLab = name_conversion %>%
    filter(DataColumn == var) %>%
    pull(PlotLabel)
  
  plot_output = ggplot(data_plot) +
    geom_point(aes(x=Date,
                   y=get(var),
                   color = Site, shape = Site, fill = Site),
               size = 5) + 
    scale_shape_manual(values = shps,
                       guide = guide_legend(ncol=2))+
    scale_color_manual(values = colrs) +
    scale_fill_manual(values = colrs) +
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
  
  for(a1 in allAnalytes){
    local({
      a = a1
      plotName1 = paste0(a,"_Time")
      output[[plotName1]] <<- renderPlot({
        drTime = input[[paste0("DateRange",a)]]
        sitesTime = input[[paste0("SiteChoice",a)]]
        plt = make_overtime(data,a,sitesTime,drTime)
        if(input[[paste0("LogYes",a)]]){
          plt = plt + scale_y_log10()
        }
        plt
      })
    
      plotName2 = paste0(a,"_Box")
      output[[plotName2]] <<- renderPlot({
        drBox = input[[paste0("BoxDateRange",a)]]
        sitesBox = input[[paste0("BoxSiteChoice",a)]]
        plt = make_boxplot(data,a,sitesBox,drBox)
        if(input[[paste0("BoxLogYes",a)]]){
          plt = plt + scale_y_log10()
        }
        plt
      })
    })
    # This previous section needs to be run locally (with the local({}),
    #  function, and have the iteration variable (a1) saved to another
    #  variable (a) in order to function as expected. If not saved locally,
    #  only the final value of the iteration variable will be saved.
  }
  
  # Additional plots can be created here, and then added to the ui.R file.
  #
    output$PlotName = renderPlot({
      #userInput1 = input$InputFieldName1
      #userInput2 = input$InputFieldName2
      plot_data = data %>%
        filter(Site %in% c("Barnes Meadow Outflow",
                           "Barnes Meadow Reservoir"),
               between(Date,
                       as.Date('2022-04-20'),
                       as.Date('2023-01-15')))
        
      plot = ggplot(data = plot_data) +
        geom_point(aes(x=Date, y=SO4, color = Site, shape = Site),
                   size = 5) +
        bottomL +
        labs(x="", shape = "", color ="")
      plot
    })
  #
  #  After creating the plot, it can be drawn on the UI by calling "plotName".
}
