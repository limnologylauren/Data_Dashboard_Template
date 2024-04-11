# Data_Dashboard_Template

## Overivew

This tool can be used to visualize post-fire water quality data. The template provides both a scatterplot and boxplot for each analyte, separated by sampling site. The analytes are grouped by categories that appear as unique tabs in the dashboard UI.

## Using the Default Template ##
- Clone or download this repo to a local folder.

If you're using RStudio:
- Open the app.R file.
- Select 'Run App' in the upper right corner.

If you're using the R Console:
```
> install.packages('shiny')
> library(shiny)
> runApp("Path/To/The/Downloaded/Repo")
```

- The Data Dashboard will appear either as a popup if you're using RStudio, or in your default web browser if you're using the R Console.

## Using your own data ##
The Data Dashboard Template will dynamically generate plots, labels, tabs, and tab groups, based on the contents of the Data/Data_Input.csv and Data/Data_Names.xlsx files. 

### Data/Data_Names.xlsx ###
This file is used to determine what columns from the `Data/Data_Input.csv` file get plotted, what the plot and tab labels are, and what the category tabs are. The required columns, and their contents are as follows:
DataColumn:
DisplayName:
PlotLabel:
Category:

### Data/Data_Input.csv ###
This file contains the data that will be displayed on the dashboard, and must include a Date column, a Site column, and any number of Data columns. An optional Site Code column can be included if desired. Details on the contets and formatting of the column are as follows.

Date: Expected format is mm/dd/yyyy
Site: This column is used to separate the data into different sampling locations. 
Data: Any number of columns that contain numeric values. The name of each column must be unique, and the names of the columns to plot must be included in the Data/Data_Names.xlsx file.
