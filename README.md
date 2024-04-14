# Data Dashboard Template

## Overview

This dashboard template uses R to visualize post-fire water quality data. The template provides both a scatterplot and boxplot for each analyte measured, separated by sampling site. The analytes are grouped by categories that appear as unique tabs in the dashboard UI. This template easily allows for additional plots, figures, and customizations to be added.  

> **_Note:_** This dashboard requires R to operate. R and RStudio (the integrated development environment for R) can be downloaded by following steps one and two [here](https://posit.co/download/rstudio-desktop/). If needed, older versions of RStudio can be found [here](https://global.rstudio.com/products/rstudio/older-versions/)

## Using the Default Template ##

- Clone or download this repo to a local folder.

If you're using RStudio:
- Open the app.R file.
- If this is the first time running the dashboard, type the following command in the R Console: `install.packages(c("tidyverse","shiny","readxl","bslib"))`
- Select 'Run App' in the upper right corner.

If you're using the R Console:
```
> install.packages(c("tidyverse","shiny","readxl","bslib"))
> library(shiny)
> runApp("Path/To/The/Downloaded/Repo")
```

- The Data Dashboard will appear either as a popup if you're using RStudio, or in your default web browser if you're using the R Console.

## File Overview ##
### app.R ###
This R file is the file that manages the whole data dashboard application. This file ensures that all the needed libraries are installed, and then starts the dashboard. There is very little content in this file.

### ui.R ###
This file generates the UI that is presented to the user. This file uses the information provided in `Data/Data_Names.xlsx` to generate category tabs and analyte tabs. For each analyte, this file creates fields for users to input options that are used to generate the plots.

### server.R ###
This file builds the plots based on input values from the UI. Once this file builds the plots, it returns the plot image to `ui.R`, to be presented to the user on the dashboard.

### Data/Data_Names.xlsx ###
This file contains one row for each analyte, and provides `ui.R` with the information on how to group analytes, and what to label analytes as. It also provides information to `server.R` that is necessary to label the y-axis of the plots.

### Data/Data_Info.csv ###
This file contains the actual data to be plotted, along with the date and site that each measurement was made at.

## Using your own data ##
The Data Dashboard Template will dynamically generate plots, labels, tabs, and tab groups, based on the contents of the `Data/Data_Input.csv` and `Data/Data_Names.xlsx` files. 

### Data/Data_Names.xlsx ###
This file is used to determine what columns from the input data file get plotted, what the plot and tab labels are, and how the analytes get grouped together. Each row in this file references a single analyte in the input data. The required columns, and their contents are as follows. 
Required Columns:
- DataColumn: This column contains the names of the data columns in the `Data/Data_Input.csv` file
- DisplayName: These values are the names displayed on analyte's tab in the UI.
- PlotLabel: These values will be used as y-axis labels for the plots.
- Category: This column determines what analytes get grouped together within a tab, as well as the name of that tab. The default dashboard assumes four distinct categories, and no more than six analytes within a category. Those assumptions can be changed, see the [modifying the dashboard](#modifying-the-dashboard) section below for details.  

### Data/Data_Input.csv ###
This file contains the data that will be displayed on the dashboard. Details on the contents and formatting of the column are as follows.
Required Columns:
- Date: Expected format is mm/dd/yyyy
- Site: This column is used to separate the data into different sampling locations. 
- Data: Any number of columns that contain numeric values. The name of each column must be unique, and the names of the columns to plot must be included in the Data/Data_Names.xlsx file. 
Optional Column:
- Site Code: If provided, this column is used for x-axis labels when making boxplots. If not provided, the values from the Site column will be used as x-axis labels.  

This file is assumed to be a `csv` file. If your data needs to be saved as an Excel file, the lines read in the data need to be updated. These updates can be done by changing the `read_csv("Data/Data_Input.csv")` function to `read_xlsx("Data/Data_Input.xlsx")` in the [server.R](server.R#L59) and [ui.R](ui.R#L32) files.


## Modifying the Dashboard ##
### Number of Categories ###
The default dashboard has four categories of analytes. The section of the dashboard that builds the category tabs isn't dynamic, and must be updated to create a different number of category tabs. To update the number of category tabs that appear, modify [this](ui.R#L247-L248) section of the `ui.R` file. Add or remove lines to match the desired number of category tabs. The category_ordered and category_pages list lengths are dynamically updated.

### Number of Analytes within a Category ###
The default dashboard has logic to allow between one and six analytes in each category. If more analytes within a category are needed, [this](ui.R#L202-L213) section of `ui.R` can be updated to handle the desired number of analytes.

### Adding tabs for images ###
The default dashboard has one tab, Sampling Methods, that displays an image rather than a plot. To add similar tabs, this can be done by modifying `ui.R`. First a fluidPage needs to be created, as seen [here](ui.R#L220-L224). Then that created fluidPage needs to be included in the list of main tabs, as seen [here](ui.R#L247).

### Adding Plots ###
Any kind of plot that R can make can be added to the dashboard. In the `server.R` file, simply add the code needed to generate your plot inside the `server` function. The plot can reference input values from the UI, or can use static values if you'd like to display a specific plot to the user. An example static plot is already built [here](server.R#L238-L254) in the `server.R` file, but that plot is never displayed because it isn't referenced in `ui.R` anywhere. To see the plot, and an example of how to create new plot displays, remove the `#` form [these](ui.R#240-L242) lines to show the static plot.

## References ##
This dashboard template uses the following data set.  
Struthers, S., Fegel, T., Willi, K., Rhoades, C., Ross, M. R. V., & Steele, B. G. (2023). ROSSyndicate Cameron Peak Fire (CPF) reservoir water quality data: Latest Release: 2021- 11/2023 Dataset (v12.13.23b) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.10372690

## Acknowledgements ##
Thank you to the CU Boulder Coal Creek sampling team, the Coal Creek Monitoring project stakeholders, and to Adam King for technical support.
