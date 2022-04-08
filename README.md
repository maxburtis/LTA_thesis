# LTA_thesis
This repository contains the MATLAB code and data that was used in my undergraduate thesis where I assessed the performance of a small blimp for remote sensing in flights on glaciers in the Juneau Icefield, Alaska. 

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
ex/ angular_accel('flight_1_matlab.csv')

## "dome_heading.csv"
## "dome_time.csv"
These files came from the Pixhawk flight controller after the dome test flight. To get these files use the convert log to matlab function in the ground control software Mission Planner, and then run the following script. 

## "get_domedata.m"
Run this function in MATLAB to create the two files that are above. The input to this function is the MATLAB file from Mission Planner. ex/ get_domedata('00000050.BIN-454297.mat')

## "compare_heading.m"
Run this function in MATLAB to compare the headings between flights. The 
ex/ [p,h, median_STD_alaska, median_STD_dome, percent_difference]=compare_heading('dome_heading.csv','dome_time.csv','flight_3_matlab.csv')

## "results_section.m"
Run this script in MATLAB to plot endurance vs wind, course correction vs wind, find averages (endurance, wind, course correction, and their experimental errors). Data from flight logs are inputed into arrays in the first section. 

## "heading_uncertainty.m"
## "accel_uncertainty.m"
These MATLAB scripts show the uncertainty calculations used to calculate heading uncertainty and acceleration uncertainty in my thesis. They are performed in accordance with ASME measurement uncertainty standards shown here: https://doi.org/10.1115/1.3242450

# Additional Functions
These functions were not used in my thesis calculations but they were useful in conceptualizing the data.

## "path_plot"
This function displays the flight path in 2D and 3D and calculates the total distance traveled in the flight. ex/ path_plot('flight_3_matlab.csv')

## "blimp_simulator
This function is similar to "path plot", but it shows position on top of the 2D map and the 3D map changes to the camera view of the blimp which varies with the position. ex/ blimp_simulator('flight_3_matlab.csv')
