close all
clc
clear
% uncertainty analysis in accordance with ASME PTC 19.1, Measurement Uncertainty 

%import data

dome_time=csvread('dome_time.csv')*(1e-6);%pull in time and convert to second
dome_time=(dome_time-dome_time(1)); %zero the time
dome_time=downsample(dome_time,63); %downsample frequency to one point every 3s
dome_heading=csvread('dome_heading.csv'); %pull in headings
dome_heading=downsample(dome_heading,63); %downsample frequency to one point every 3s
dome_heading_uncert=0.01;  %Uncertainty in a Digital Measuring Device is equal to the smallest increment

data_geodetic = readtable('flight_3_matlab.csv'); %importing the raw data (alaska)
lat_long_uncert=00.00000001; %Uncertainty in a Digital Measuring Device is equal to the smallest increment
tlat = [data_geodetic.GPSLatitude]; %creating lattitude array
tlon = [data_geodetic.GPSLongitude]; %creating longitude array

elat=0.00000001; %same as bias
elon=0.00000001;
ealt=0.0001;

% uncertainty alaska

Slat=std(tlat);  % precision index of parameter
Slon=std(tlon);
athetalat=(akheading(tlat+elat,tlon)-akheading(tlat,tlon))/elat; %sensitivity factor
athetalon=(akheading(tlat,tlon+elon)-akheading(tlat,tlon))/elon;
aSr=sqrt((athetalat*Slat)^2+(athetalon*Slon)^2); %precision index of result
aBr=sqrt((athetalat*elat)^2+(athetalon*elon)^2); %bias limit of result
aUr=aBr+2*aSr %+/- at the 99% CI

diff_ak=100*((aUr)/akheading(tlat,tlon)) %+/- difference in heading median due to uncertainty

% uncertainty dome
eheading=0.01;
Shead=std(dome_heading); % precision index of parameter
dthetahead=(dheading(dome_heading+eheading)-dheading(dome_heading))/eheading; %sensitivity factor
dSr=sqrt((dthetahead*Shead)^2); %precision index of result
dBr=sqrt((dthetahead*eheading)^2); %bias limit of result
dUr=dBr+2*dSr %+/- at the 99% CI

diff_dome=100*((dUr)/dheading(dome_heading)) %+/- difference in heading median due to uncertainty


function median_STD_alaska=akheading(tlat,tlon)
 %calculating heading
        wgs84 = wgs84Ellipsoid;
        theading = azimuth(tlat(1:end-1),tlon(1:end-1),tlat(2:end),tlon(2:end),wgs84); %using the azimuth function to determine heading 
        theading = [theading(1);theading(:)];
        [alaska_TF,alaska_S1,alaska_S2] = ischange(theading,'variance','Threshold',20);
        STD_alaska=sqrt(alaska_S2);
        median_STD_alaska=median(STD_alaska(:,1));
end


function median_STD_dome=dheading(dome_heading)
 %calculating heading
        [dome_TF,dome_S1,dome_S2] = ischange(dome_heading,'variance','Threshold',20);
        STD_dome=sqrt(dome_S2);
        median_STD_dome=median(STD_dome(:,1));
end      