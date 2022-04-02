%% import and process data
close all
clear
clc

dome_data = load('00000050.BIN-454297.mat','ATT_label','ATT'); %importing the raw data (de)
dome_time=(1e-6)*dome_data.ATT(:,2); %pull in time and convert to seconds
dome_time=dome_time-dome_time(1); %zero the time
dome_time=downsample(dome_time,63); %downsample frequency to one point every 3s
dome_heading=[dome_data.ATT(:,8)]; %pull in headings
dome_heading=downsample(dome_heading,63); %downsample frequency to one point every 3s
dome_heading_uncert=0.01  %Uncertainty in a Digital Measuring Device is equal to the smallest increment 

data_geodetic = readtable('flight_3_matlab.csv'); %importing the raw data (alaska)
lat_long_uncert=00.00000001; %Uncertainty in a Digital Measuring Device is equal to the smallest increment 
tlat = [data_geodetic.GPSLatitude]; 
tlon = [data_geodetic.GPSLongitude];

%calculating heading
wgs84 = wgs84Ellipsoid;
theading = azimuth(tlat(1:end-1),tlon(1:end-1),tlat(2:end),tlon(2:end),wgs84);
theading_uncert=abs(theading-azimuth(tlat(1:end-1),tlon(1:end-1)-lat_long_uncert,tlat(2:end),tlon(2:end)+lat_long_uncert,wgs84));%uncertainty in both lat and long is propigated through the heading calculation
theading = [theading(1);theading(:)];
alaska_time=[1:size(theading,1)]' * 3;


%% Statistical Analysis

subplot(2,1,2)
[dome_TF,dome_S1,dome_S2] = ischange(dome_heading,'variance','Threshold',20);
hold on
plot(dome_time,dome_heading(:,1),'o')
stairs(dome_time,dome_S1(:,1))
STD_dome=sqrt(dome_S2);
plot(dome_time,STD_dome(:,1))
legend('Heading','Segment Mean','Segment Standard Deviation','Location','NE')
title('Dome Flight')
xlabel('Time (seconds)')
ylabel('Heading (Degrees)')
xlim([300 500])
hold off

subplot(2,1,1)
[alaska_TF,alaska_S1,alaska_S2] = ischange(theading,'variance','Threshold',20);
hold on
plot(alaska_time,theading,'o')
stairs(alaska_time,alaska_S1)
STD_alaska=sqrt(alaska_S2);
plot(alaska_time,STD_alaska)
legend('Heading','Segment Mean','Segment Standard Deviation','Location','NE')
title('Alaska Flight')
xlabel('Time (seconds)')
ylabel('Heading (Degrees)')
xlim([400 800])
hold off

%Normal Test
lillietest(STD_alaska(:,1))
lillietest(STD_dome(:,1))

%Because samples are not normaly distributed (h=1), Wilcoxon rank sum test is used
%Null hypothesis: The median is the same 
%h=1 indicated rejection of the null hypothesis in favor of the alternative hypothesis 
%Left-tailed hypothesis test, where the alternative hypothesis states that the median of x is less than the median of y.
[p,h] = ranksum(STD_dome(:,1),STD_alaska,'alpha',0.01,'tail','left')

median_STD_alaska=median(STD_alaska(:,1));
median_STD_dome=median(STD_dome);
percent_difference = 100*(median_STD_dome-median_STD_alaska)./median_STD_alaska


