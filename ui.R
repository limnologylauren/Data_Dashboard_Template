library(tidyverse)
library(readxl)
library(bslib)

# Name that's listed on browser tab
tabTitle = "Sample Data Dashboard for Post Fire Water Quality"

# This section defines some messages that are displayed to users on different
#  analyte pages. These use HTML to format the messages. In order for the info
#  messages to be displayed, add the analyte name to the 'added_info' list below
moreInfo = "<br/>More info can be found here:"

condQ = "Conductivity is a measure of the ability of water to pass an electrical current. When water contains dissolved salts and other inorganic materials (salinity) that can pass an electrical current, the conductivity will be higher. Specific conductance is corrected for temperature."
condL = "https://pubs.usgs.gov/tm/09/a6.3/tm9-a6_3.pdf"
condUrl = a(condL,href=condL,target="_blank")
SC_Info = paste("<br/>",condQ,moreInfo,condUrl,"<br/>")

chlaQ = "Chlorophyll-a is a measure of photosynthetic periphyton biomass in water."
chlaL = "https://www.epa.gov/national-aquatic-resource-surveys/indicators-chlorophyll"
chlaUrl = a(chlaL,href=chlaL,target="_blank")
ChlA_Info = paste("<br/>",chlaQ,"<br/> More info can be found here: ",chlaUrl,"<br/>")

# A list of what analytes have added info. When that analyte's tab is being built,
#  the 'analyte'_Info variable will be added to the top of the page
added_info = c("ChlA","SC")

# Set a specific height for each plot that is made
pltH ="600px"

# The CSV file containing the data. Expected date format is mm/dd/YYYY. Other
#  see the README for expectations on contents.
data = read_csv("Data/Data_Input.csv")
yearDigits = str_length(sub(".*/","",data$Date[1]))
if(yearDigits == 2){
  data = data %>%
    mutate(Date = as.Date(Date, format = "%m/%d/%y"),
           Site = str_to_title(Site)) %>%
    arrange(Date)
} else {
  data = data %>%
  mutate(Date = as.Date(Date, format = "%m/%d/%Y"),
         Site = str_to_title(Site)) %>%
  arrange(Date)
}

name_conversion = read_xlsx("Data/Data_Names.xlsx")

allAnalytes = name_conversion %>%
  pull(DataColumn)

# Select the sites with the most data points as the default site values, and save
#  those values to be the default sites selected by the input.
start_sites = data %>% 
  select(Site,allAnalytes[1]) %>%
  group_by(Site) %>%
  summarise(n = n()) %>%
  arrange(-n) %>%
  slice(1:4) %>%
  pull(Site)

# Could also explicitly define the pre-selected sites
# start_sites = c("Poudre Below Rustic", "Barnes Meadow Outflow",
#                 "Chambers Inlet", "Chambers Outflow")

# Extract every site name, to include in the site selector input.
all_sites = data$Site %>% unique()

# Extract the minimum and maximum date values, to use in the date slider input.
date_min = data$Date %>% min()
date_max = data$Date %>% max()

# Find the earliest post-fire date, to be used as the default minimum date value
date_min_post = data %>%
  filter(Date > "2020-01-01") %>%
  pull(Date) %>% min()

###
# Each analyte has its own panel, which appears as a tab along with other 
#  analytes in the same categor.
# 
# After each tab is created, they are grouped together with all other
#  analytes that share a category.
#
# Finally the grouped tabs are combined to a tabset, and added to the main ui
###

# This section builds two tabs for each analyte, one tab for the boxplot
#  and one tab for the scatterplot. The variable names all use the same pattern,
#  based on the column name in the data file, that allows the ui to build 
#  all of the pages at once here.
for(a in allAnalytes){
  if(a %in% added_info){ # If the analye has extra info, it gets read in here.
    info_line = get(paste0(a,"_Info"))
  } else {
    info_line = "<br/>"
  }
  
  tabNameVar = paste0(a,"_tab")
  
  # Read in the display name for this analye, and save it to display on the UI
  tabLabel = name_conversion %>%
    filter(DataColumn == a) %>%
    pull(DisplayName)
  
  assign(tabNameVar,
   tabPanel(
    tabLabel, # Display name for the analyte
    column(12,HTML(info_line)), # any extra info added here. If none, add an empty line.
    tabsetPanel(
      tabPanel(
        "Over Time",
        sidebarLayout(
          sidebarPanel(
            sliderInput(
              paste0("DateRange",a), # Create a date input for this analyte
              "Date Range",
              min = date_min, max = date_max,
              value = c(date_min_post, date_max)),
            selectInput(
              paste0("SiteChoice",a), # Create a site input for this analyte
              "Site",
              choices = all_sites,
              selected = start_sites, multiple = T),
            checkboxInput(
              paste0("LogYes",a),
              "Log Scale",
              value = F),
            width = 3),
          # Access the analyte_Time plot from the server.R file
          mainPanel(plotOutput(paste0(a,"_Time"), height = pltH)))),
      tabPanel(
        "Overall",
        sidebarLayout(
          sidebarPanel(
            sliderInput(
              paste0("BoxDateRange",a), # Creates a date input for the boxplot
              "Date Range",
              min = date_min, max = date_max,
              value = c(date_min_post, date_max)),
            selectInput(
              paste0("BoxSiteChoice",a), # Creates a site input for the boxplot
              "Site",
              choices = all_sites,
              selected = start_sites, multiple = T),
            checkboxInput(
              paste0("BoxLogYes",a),
              "Log Scale",
              value = F),
            width = 3),
          # Access the analyte_Box plot from the server.R file
          mainPanel(plotOutput(paste0(a,"_Box"),height = pltH)))))))
}

# Make a list of all analyte categories
allCategories = name_conversion %>% pull(Category) %>% unique()

# For each category, build a tabset that contains all tabs for analytes
#  that are part of the category.
for(c in allCategories){
  pageNameVar = gsub(" ","",paste0(c,"_page"))
  
  # This gets a list of which analytes are in this category.
  analytes_in_category = name_conversion %>%
    filter(Category == c) %>%
    arrange(DisplayName) %>%
    pull(DataColumn) 
  
  analyte_tabs = paste0(analytes_in_category,"_tab")
  # This section needs to be done based on how many tabs are being included
  #  in the tabsetPanel. There isn't an easy way to combine multiple tabPanels
  #  that contain tabs withing themselves. 
  if(length(analyte_tabs)==1){
    assign(pageNameVar,fluidPage(
      tabsetPanel(get(analyte_tabs[1]))
    ))
  } else if(length(analyte_tabs)==2){
    assign(pageNameVar,fluidPage(
      tabsetPanel(get(analyte_tabs[1]),
                  get(analyte_tabs[2]))
    ))
  } else if(length(analyte_tabs)==3){
    assign(pageNameVar,fluidPage(
      tabsetPanel(get(analyte_tabs[1]),
                  get(analyte_tabs[2]),
                  get(analyte_tabs[3])
                  )))
  } else if(length(analyte_tabs)==4){
    assign(pageNameVar,fluidPage(
      tabsetPanel(get(analyte_tabs[1]),
                  get(analyte_tabs[2]),
                  get(analyte_tabs[3]),
                  get(analyte_tabs[4])
      )))
  } else if(length(analyte_tabs)==5){
    assign(pageNameVar,fluidPage(
      tabsetPanel(get(analyte_tabs[1]),
                  get(analyte_tabs[2]),
                  get(analyte_tabs[3]),
                  get(analyte_tabs[4]),
                  get(analyte_tabs[5])
      )))
  } else if(length(analyte_tabs)==6){
    assign(pageNameVar,fluidPage(
      tabsetPanel(get(analyte_tabs[1]),
                  get(analyte_tabs[2]),
                  get(analyte_tabs[3]),
                  get(analyte_tabs[4]),
                  get(analyte_tabs[5]),
                  get(analyte_tabs[6])
      )))
    } # #else if(length(analyte_tabs)==X){
  # # assign(pageNameVar,fluidPage(
  # #   tabsetPanel(get(analyte_tabs[1]),
  # #               get(analyte_tabs[2]),
  # #               get(analyte_tabs[3]),
  # #               get(analyte_tabs[4]),
  # #               get(analyte_tabs[5]),
  # #               get(analyte_tabs[6]),
  # #                                ...,
  # #               get(analyte_tabs[X])
  # #   )))
  # # }
}

###
# This page is an example of only displaying an image instead of a plot.
#  The image needs to be saved in the 'www' folder for R to find the file.
###
rmrs_page = fluidPage(
  fluidRow(
    column(10,img(src='rmrs_procedures.png',width="100%"))
  )
)

category_ordered = allCategories %>% sort()
category_pages = paste0(gsub(" ","",category_ordered),"_page")

# This combines the categories into one tabset that will go on the final UI page.
#  Again there isn't a dynamic way to combine the tabsets, so they are individually
#  called here. If more than four are needed, they can be added based on the 
#  commented out example.

# Other tabs can be added here, like the 'rmrs_page'. The first argument in the
#  tabPanel function is the name that is displayed on the tab.
mainRow = tabsetPanel(
  fluidRow(
    column(10,
    tabsetPanel(
      #tabPanel("Static Plot",fluidPage(
      #  fluidRow(column(10,plotOutput("PlotName",height = '700px')))
      #)),
      tabPanel(category_ordered[1],get(category_pages[1])),
      tabPanel(category_ordered[2],get(category_pages[2])),
      tabPanel(category_ordered[3],get(category_pages[3])),
      tabPanel(category_ordered[4],get(category_pages[4])),
      # # tabPanel(category_ordered[5],get(category_pages[5])),
      # # tabPanel(category_ordered[6],get(category_pages[6])),
      
      tabPanel("Sampling Methods",rmrs_page)

    ),
    offset = 1)
  )
)

# The ui variable is what gets displayed to the user.
ui <- fluidPage(
  title=tabTitle, # This title is what the tab displayes if viewed on the web.
  theme = bs_theme(version = 5, bootswatch = 'minty'),
  # Anything saved outside of the 'mainRow' is always present, regardless of which
  #  tab the user has selected. Below is an example of how to add an image to
  #  the top of the page that would always be present.
  #
  #  column(10, offset=1,titlePanel(img(src='HeaderImg.png', width="100%"))),
  #
  mainRow,
  #### This is just to have an some space around the bottom of the page
  br(),
  br(),
  # Below are the HTML formating options, can be customized as desired.
  tags$head(tags$style(HTML('* {font-family: "Arial";
                                font-size: 18px};')))
)
