# Data_Dashboard_Template

## Overview

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
The Data Dashboard Template will dynamically generate plots, labels, tabs, and tab groups, based on the contents of the `Data/Data_Input.csv` and `Data/Data_Names.xlsx` files. 

### Data/Data_Names.xlsx ###
This file is used to determine what columns from the input data file get plotted, what the plot and tab labels are, and how the analytes get grouped together. The required columns, and their contents are as follows. Each row in this file references a single analyte in the input data.
Required Columns:
- DataColumn: This column contains the names of the data columns in the `Data/Data_Input.csv` file
- DisplayName: These values are the names displayed on analyte's tab in the UI.
- PlotLabel: These values will be used as y-axis labels for the plots.
- Category: This colum determines what analytes get grouped together within a tab, as well as the name of that tab. The default dashboard assumes four distinct categories, and no more than six analytes within a category. Those assumtions can be changed, see the modifying the UI section below for details. 


### Data/Data_Input.csv ###
This file contains the data that will be displayed on the dashboard. Details on the contets and formatting of the column are as follows.
Required Columns:
- Date: Expected format is mm/dd/yyyy
- Site: This column is used to separate the data into different sampling locations. 
- Data: Any number of columns that contain numeric values. The name of each column must be unique, and the names of the columns to plot must be included in the Data/Data_Names.xlsx file. 
Optional Column:
- Site Code: If provided, this column is used for x-axis labels when making boxplots. If not provided, the values from the Site column will be used as x-axis labels.


## Modifying the Dashboard ##
### Number of Categories ###
To update the number of category tabs that appear, modify [this](ui.R#L238) section of the `ui.R` file.

