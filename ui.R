library(tidyverse)
library(readxl)
library(lubridate)
library(bslib)

# Name that's listed on browser tab
tabTitle = "Monitoring the Coal Creek Ecosystem following the Marshall Fire"

# This section defines some messages that are disaplyed to users on different
#  analyte pages. These use HTML to format the messages.
moreInfo = "<br/>More info can be found here:"

condQ = "Conductivity is a measure of the ability of water to pass an electrical current. When water contains dissolved salts and other inorganic materials (salinity) that can pass an electrical current, the conductivity will be higher. Specific conductance is corrected for temperature."
condL = "https://pubs.usgs.gov/tm/09/a6.3/tm9-a6_3.pdf"
condUrl = a(condL,href=condL,target="_blank")
SC_Info = HTML(paste("<br/>",condQ,moreInfo,condUrl,"<br/>"))


chlaQ = "Chlorophyll-a is a measure of photosynthetic periphyton biomass in water."
chlaL = "https://www.epa.gov/national-aquatic-resource-surveys/indicators-chlorophyll"
chlaUrl = a(chlaL,href=chlaL,target="_blank")
ChlA_Info = HTML(paste("<br/>",chlaQ,"<br/> More info can be found here: ",
                      chlaUrl,"<br/>"))

morpQ = "Diatom taxa by morphology: These morphological categories can be used to classify diatoms."
morpL = "https://diatoms.org/morphology"
morpUrl = a(morpL,href=morpL,target="_blank")
morpInfo = HTML(paste("<br/>",morpQ," More info can be found here: ",
                      morpUrl,"<br/>"))

# FAQ stuff (chunk)
q1 = 'Where can I learn about my watershed and stormwater?'
a1 = "The Keep it Clean Partnership offers informational tools to learn about watersheds and stormwater basics:"
l1 = "https://www.keepitcleanpartnership.org/learn/"

url1 = a(l1,href=l1,target="_blank")


FAQ = HTML("<br/>",
           paste(
             strong(q1),a1,url1,"<br/>",
             sep="<br/>"))
# End FAQ

# Plot formatting
pltH ="600px"

# The data file only needs to be read in if information from it is used to 
#  set up the UI. In this case, the date ranges and site names are needed
#  to fill out the options for the user input sections.
data = read_csv("Data/CPF_reservoir_chemistry_up_to_20230907.csv") %>%
  mutate(Date = as.Date(Date, format = "%m/%d/%Y"),
         Site = str_to_title(Site)) %>%
  arrange(Date)

# Select the sites with the most data points as the default site values, and save
#  those values to be the default sites selected by the input.
start_sites = data %>% 
  select(Site,DOC) %>%
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
# Each analyte has its own panel, which appears as a tab along with other similar
#  analytes. Below is an example tab, which can be duplicated if other analytes
#  are added. Simply replace all instances of 'XYZ' with the column name of the
#  new analytes, and replace 'xyz tab name' with the display name of the analyte
#  to appear on the tab.
# 
# After each tab is created, they are grouped together into a page with similar
#  analytes.
#
# Finally the group pages are added to the main UI page.
###

XYZ_tab = tabPanel(
  "xyz tab name",
  #column(12,XYZ_Info), # Include this line to add a header line with information.
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeXYZ","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceXYZ","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("XYZ_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeXYZ","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceXYZ","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("XYZ_Box",height = pltH))))))


ANC_tab = tabPanel(
  "Acid Neutralizing Capacity",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeANC","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceANC","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("ANC_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
          "BoxDateRangeANC","Date Range",
          min = date_min, max = date_max,
          value = c(date_min_post, date_max)),
        selectInput(
          "BoxSiteChoiceANC","Site",
          choices = all_sites,
          selected = start_sites, multiple = T),width = 3),
      mainPanel(plotOutput("ANC_Box",height = pltH))))))

ChlA_tab = tabPanel(
  "Chlorophyll A",
  column(12,ChlA_Info),
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeChlA","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceChlA","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("ChlA_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
          "BoxDateRangeChlA","Date Range",
          min = date_min, max = date_max,
          value = c(date_min_post, date_max)),
        selectInput(
          "BoxSiteChoiceChlA","Site",
          choices = all_sites,
          selected = start_sites, multiple = T),width = 3),
      mainPanel(plotOutput("ChlA_Box",height = pltH))))))

SC_tab = tabPanel(
  "Conductivity",
  column(12,SC_Info),
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeSC","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceSC","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("SC_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
          "BoxDateRangeSC","Date Range",
          min = date_min, max = date_max,
          value = c(date_min_post, date_max)),
        selectInput(
          "BoxSiteChoiceSC","Site",
          choices = all_sites,
          selected = start_sites, multiple = T),width = 3),
      mainPanel(plotOutput("SC_Box",height = pltH))))))

pH_tab = tabPanel(
  "pH",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangepH","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoicepH","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("pH_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
          "BoxDateRangepH","Date Range",
          min = date_min, max = date_max,
          value = c(date_min_post, date_max)),
        selectInput(
          "BoxSiteChoicepH","Site",
          choices = all_sites,
          selected = start_sites, multiple = T),width = 3),
      mainPanel(plotOutput("pH_Box",height = pltH))))))

TSS_tab = tabPanel(
  "TSS",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeTSS","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceTSS","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("TSS_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
          "BoxDateRangeTSS","Date Range",
          min = date_min, max = date_max,
          value = c(date_min_post, date_max)),
        selectInput(
          "BoxSiteChoiceTSS","Site",
          choices = all_sites,
          selected = start_sites, multiple = T),width = 3),
      mainPanel(plotOutput("TSS_Box",height = pltH))))))

Turbidity_tab = tabPanel(
  "Turbidity",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeTurbidity","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceTurbidity","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("Turbidity_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
          "BoxDateRangeTurbidity","Date Range",
          min = date_min, max = date_max,
          value = c(date_min_post, date_max)),
        selectInput(
          "BoxSiteChoiceTurbidity","Site",
          choices = all_sites,
          selected = start_sites, multiple = T),width = 3),
      mainPanel(plotOutput("Turbidity_Box",height = pltH))))))

F_tab = tabPanel(
  "Fluorine",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeF","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceF","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("F_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeF","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceF","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("F_Box",height = pltH))))))

Cl_tab = tabPanel(
  "Chlorine",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeCl","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceCl","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("Cl_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeCl","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceCl","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("Cl_Box",height = pltH))))))

NO3_tab = tabPanel(
  "Nitrate",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeNO3","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceNO3","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("NO3_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeNO3","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceNO3","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("NO3_Box",height = pltH))))))

PO4_tab = tabPanel(
  "Phosphate",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangePO4","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoicePO4","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("PO4_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangePO4","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoicePO4","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("PO4_Box",height = pltH))))))

SO4_tab = tabPanel(
  "Sulfate",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeSO4","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceSO4","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("SO4_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeSO4","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceSO4","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("SO4_Box",height = pltH))))))

Na_tab = tabPanel(
  "Sodium",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeNa","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceNa","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("Na_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeNa","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceNa","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("Na_Box",height = pltH))))))

K_tab = tabPanel(
  "Potassium",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeK","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceK","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("K_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeK","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceK","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("K_Box",height = pltH))))))

NH4_tab = tabPanel(
  "Ammonium",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeNH4","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceNH4","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("NH4_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeNH4","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceNH4","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("NH4_Box",height = pltH))))))

Mg_tab = tabPanel(
  "Magnesium",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeMg","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceMg","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("Mg_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeMg","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceMg","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("Mg_Box",height = pltH))))))

Ca_tab = tabPanel(
  "Calcium",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeCa","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceCa","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("Ca_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeCa","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceCa","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("Ca_Box",height = pltH))))))

DOC_tab = tabPanel(
  "Carbon, Dissolved Organic",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeDOC","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceDOC","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("DOC_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeDOC","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceDOC","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("DOC_Box",height = pltH))))))

DTN_tab = tabPanel(
  "Nitrogen, Total Dissolved",
  tabsetPanel(
    tabPanel(
      "Over Time",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "DateRangeDTN","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "SiteChoiceDTN","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("DTN_Time", height = pltH)))),
    tabPanel(
      "Overall",
      sidebarLayout(
        sidebarPanel(
          sliderInput(
            "BoxDateRangeDTN","Date Range",
            min = date_min, max = date_max,
            value = c(date_min_post, date_max)),
          selectInput(
            "BoxSiteChoiceDTN","Site",
            choices = all_sites,
            selected = start_sites, multiple = T),width = 3),
        mainPanel(plotOutput("DTN_Box",height = pltH))))))

###
# End of the analyte tab sections
###


####
# Below the group pages are defined, as a tabsetPanel of multiple tabs
####

wq_page = fluidPage(
  tabsetPanel(
    ANC_tab,
    ChlA_tab,
    SC_tab,
    pH_tab,
    TSS_tab,
    Turbidity_tab
  )
)

anion_page = fluidPage(
  tabsetPanel(
    F_tab,
    Cl_tab,
    NO3_tab,
    PO4_tab,
    SO4_tab
  )
)

cation_page = fluidPage(
  tabsetPanel(
    NH4_tab,
    Ca_tab,
    Mg_tab,
    K_tab,
    Na_tab
  )
)

doc_tdn_page = fluidPage(
  tabsetPanel(
    DOC_tab,
    DTN_tab
  )
)

###
# This page is an example of only displaying an image instead of a plot.
#  The image needs to be saved in the 'www' folder to enable an easy lookup
#  from the img() function.
###
rmrs_page = fluidPage(
  fluidRow(
    column(10,img(src='rmrs_procedures.png',width="100%"))
  )
)

# Set up full page
#### The page overall is fluidPage, the title is displayed as the browser tab
# name if viewed on the web.
ui <- fluidPage(title=tabTitle,
                theme = bs_theme(version = 5, bootswatch = 'minty'),
  column(10, offset=1,titlePanel(
    img(src='HeaderImg.png',
        width="100%"))),#width=picW))),
  #### This is the list of each of the tabs. Each tabPanel has a name and the page that it is displayed
  fluidRow(column(10,
    tabsetPanel(
      type='tabs',
      tabPanel("Anions",anion_page),
      tabPanel("Basic Water Quality",wq_page),
      tabPanel("Cations",cation_page),
      tabPanel("Dissolved Nutrients",doc_tdn_page),
      tabPanel("Sampling Limits",rmrs_page),
      tabPanel("FAQ",FAQ)),
    offset=1)),
  #### This is just formatting stuff to have an some space around the bottom of the page
  br(),
  br(),
  tags$head(tags$style(HTML('* {font-family: "Arial";
                                font-size: 18px};')))
)