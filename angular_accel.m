function angular_accel(filename)
    close all
    
    data_geodetic = readtable(filename); %importing the raw data 
   
    %set up the plot for the geodata by creating arrays for lat/lon/alt

    tlat = data_geodetic.GPSLatitude; 
    tlon = data_geodetic.GPSLongitude;
    talt = data_geodetic.GPSAltitude; 
    
    %calculating heading
    wgs84 = wgs84Ellipsoid;
    theading = azimuth(tlat(1:end-1),tlon(1:end-1),tlat(2:end),tlon(2:end),wgs84); %using the azimuth function to determine heading 
    theading = [theading(1);theading(:)];
    %angular velocity in rad/s, first derivative, 3s time interval 
    angvel = (deg2rad(theading)/3);
    %angular accel in rad/s^2, second derivative, 3s time interval 
    angaccel = abs(diff(angvel)/3); 
    angaccel = [angaccel(1);angaccel(:)];
    
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
    
    %plotting Path vs Yaw Angular Acceleration 
    subplot(1,2,1)
    scatter3(tlon,tlat,talt,50,angaccel, 'fill') % Make filled 3D scatter plot
    line(tlon,tlat,talt)
    xlabel('Longitude')
    ylabel('Latitude')
    zlabel('Altitude (m)')
    title('Path vs Yaw Angular Acceleration ')
    c = colorbar;
    c.Label.String = 'Angular Acceleration (rad/s^2)';

    %plotting Path vs Pitch Angular Acceleration
    subplot(1,2,2)
    scatter3(tlon,tlat,talt,50,pitchangaccel, 'fill') % Make filled 3D scatter plot
    line(tlon,tlat,talt)
    xlabel('Longitude')
    ylabel('Latitude')
    zlabel('Altitude (m)')
    title('Path vs Pitch Angular Acceleration ')
    c = colorbar;
    c.Label.String = 'Angular Acceleration (rad/s^2)';
    
    % Finding and comparing means 
    mean_pitch=mean(pitchangaccel);
    mean_yaw=mean(angaccel);
    fprintf("Average pitch angular acceleration is %f rad/s^2 .\n",mean_pitch)
    fprintf("Average pitch angular acceleration is %f rad/s^2 .\n",mean_yaw)
    fprintf("Yaw angular accleration is %f times greater than pitch angular acceleration.\n",mean_yaw/mean_pitch)
    
end