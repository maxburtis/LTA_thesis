    close all
    clear 
    clc
    data_geodetic = readtable('flight_3_matlab.csv'); %importing the raw data 
   
    %set up the plot for the geodata by creating arrays for lat/lon/alt
    
    lat_long_uncert=00.00000001
    tlat = data_geodetic.GPSLatitude; 
    tlon = data_geodetic.GPSLongitude;
    talt = data_geodetic.GPSAltitude; 
    
    
    % uncertainty analysis in accordance with ASME PTC 19.1, Measurement Uncertainty 
    %yaw    
    elat=0.00000001; %same as bias
    elon=0.00000001;
    ealt=0.0001;
   
    Slat=std(tlat);  % precision index of parameter
    Slon=std(tlon); 
    ythetalat=(mean(YAA(tlat+elat,tlon))-(mean(YAA(tlat,tlon))))/elat; %sensitivity factor
    ythetalon=(mean(YAA(tlat,tlon+elon))-(mean(YAA(tlat,tlon))))/elon; 
    ySr=sqrt((ythetalat*Slat)^2+(ythetalon*Slon)^2); %precision index of result
    yBr=sqrt((ythetalat*elat)^2+(ythetalon*elon)^2); %bias limit of result
    yUr=yBr+2*ySr %+/- at the 99% CI 
   
    % uncertainty pitch 
    Salt=std(talt);
    pthetalat=(mean(PAA(tlat+elat,tlon,talt))-(mean(PAA(tlat,tlon,talt))))/elat; %sensitivity factor
    pthetalon=(mean(PAA(tlat,tlon+elon,talt))-(mean(PAA(tlat,tlon,talt))))/elon; 
    pthetaalt=(mean(PAA(tlat,tlon,talt+ealt))-(mean(PAA(tlat,tlon,talt))))/ealt;
    pSr=sqrt((pthetalat*Slat)^2+(pthetalon*Slon)^2+(pthetaalt*Salt)^2); %precision index of result
    pBr=sqrt((pthetalat*elat)^2+(pthetalon*elon)^2+(pthetaalt*ealt)^2);
    pUr=pBr+2*pSr %+/- at the 99% CI 
    % Finding and comparing means 
    mean_pitch=mean(PAA(tlat,tlon,talt));
    mean_yaw=mean(YAA(tlat,tlon));
    diff_pitch=100*((pUr)/mean_pitch) %+/- difference in pitch mean due to uncertainty 
    diff_yaw=100*((yUr)/mean_yaw) %+/- difference in yaw mean due to uncertainty 
    fprintf("Average pitch angular acceleration is %f rad/s^2 .\n",mean_pitch)
    fprintf("Average yaw angular acceleration is %f rad/s^2 .\n",mean_yaw)
    fprintf("Yaw angular accleration is %f times greater than pitch angular acceleration.\n",mean_yaw/mean_pitch)
    
    function angaccel=YAA(tlat,tlon)
        %calculating heading
        wgs84 = wgs84Ellipsoid;
        theading = azimuth(tlat(1:end-1),tlon(1:end-1),tlat(2:end),tlon(2:end),wgs84); %using the azimuth function to determine heading 
        theading = [theading(1);theading(:)];
        %angular velocity in rad/s, first derivative, 3s time interval 
        angvel = (deg2rad(theading)/3);
        %angular accel in rad/s^2, second derivative, 3s time interval 
        angaccel = abs(diff(angvel)/3); 
        angaccel = [angaccel(1);angaccel(:)];
    end

    function pitchangaccel=PAA(tlat,tlon,talt)
        wgs84 = wgs84Ellipsoid;

        N = egm96geoid(tlat,tlon); % the geoid height of Earth 
        h = talt + N; %finding actual elipsoid height
        
        %making tables of GPS data so differences between points can be found
        lat1 = tlat(1:end-1);
        lat2 = tlat(2:end);
        lon1 = tlon(1:end-1);
        lon2 = tlon(2:end);
        h1 = h(1:end-1);
        h2 = h(2:end);
        [dx,dy,dz] = ecefOffset(wgs84,lat1,lon1,h1,lat2,lon2,h2); %converting from degrees to meters
        
        distanceIncrementIn3D = hypot(hypot(dx, dy), dz); %double hypotenuse function to find 3D distance
    
        %pitch ang accel    
        pitches = asin(dz./distanceIncrementIn3D);
        pitches = [pitches(1);pitches(:)];
    
        %angular velocity in rad/s
        pitchangvel = (deg2rad(pitches)/3);
     
        %angular accel in rad/s^2
        pitchangaccel = abs(diff(pitchangvel)/3); 
        pitchangaccel = [pitchangaccel(1);pitchangaccel(:)];
    end