# LTA_thesis
This repository contains the code and data that was used in my undergraduate thesis where I assessed the performance of a small blimp for remote sensing in test flights on glaciers in the Juneau Icefield, Alaska. 

My thesis was submitted to the University of Maine Honors College in April 2022. 

The following is the workflow and associated files used in the data processing and analysis for this project. The headings below contain the filenames in this repository and are annotated with instructions and/or explanations. 

Parts of the code in the following link was used in these calculations. 
https://www.mathworks.com/help/map/visualize-uav-flight-path-on-synchronized-maps.html

## "EXIFTOOL" 
Run this in the command line to strip the GPS points from the photos. This will have to be edited to your use case. 

## "blimp_1out.csv"
This is the raw data from Alaska. GPS points from all three flights were the camera was used. I seperated this code into the three flights by looking at the timestamps and comparing them to the times in my flight log. I then deleted extraneous points that were caused by errors in the GPS (0-6 points per flight). 

GPS Points for Each Flight:
## "flight_1_matlab.csv"
## "flight_2_matlab.csv"
## "flight_3_matlab.csv"

## "angular_accel.m"
Run this function in MATLAB to compare the angular excelerations in the pitch and yaw axis.
ex/. angular_accel('flight_1_matlab.csv')

## "compare_heading.m"
Run this function in MATLAB to compare the headings between flights.
ex/ [p,h, median_STD_alaska, median_STD_dome, percent_difference]=compare_heading('00000050.BIN-454297.mat','flight_3_matlab.csv')

## "results_section.m"
Run this function in MATLAB to plot endurance vs wind, course correction vs wind, find averages (endurance, wind, course correction, and their experimental errors) and thier associated uncertainties. Data from flight logs are inputed into arrays in the first section. 
