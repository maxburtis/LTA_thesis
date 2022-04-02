function [pitch,N] = path_plot(filename)
    close all
    data_geodetic = readtable(filename); %importing the raw data 
   
    %set up the plot for the geodata

    tlat = data_geodetic.GPSLatitude;
    tlon = data_geodetic.GPSLongitude;
    talt = data_geodetic.GPSAltitude;
    
    %calculating heading
    wgs84 = wgs84Ellipsoid;
    theading = azimuth(tlat(1:end-1),tlon(1:end-1),tlat(2:end),tlon(2:end),wgs84);
    theading = [theading(1);theading(:)];
    %angular velocity in rad/s
    angvel = (deg2rad(theading)/3);
    %angular accel in rad/s^2
    angaccel = abs(diff(angvel)/3); 
    angaccel = [angaccel(1);angaccel(:)];
    %Calculating 3D distance flown
    N = egm96geoid(tlat,tlon);
    h = talt + N;
    
    
    lat1 = tlat(1:end-1);
    lat2 = tlat(2:end);
    lon1 = tlon(1:end-1);
    lon2 = tlon(2:end);
    h1 = h(1:end-1);
    h2 = h(2:end);
    [dx,dy,dz] = ecefOffset(wgs84,lat1,lon1,h1,lat2,lon2,h2);
    delta = [dx,dy,dz];
    
    distanceIncrementIn3D = hypot(hypot(dx, dy), dz);

    %pitch ang accel    
    pitches = asin(dz./distanceIncrementIn3D);
    pitches = [pitches(1);pitches(:)];

    %angular velocity in rad/s
    pitchangvel = (deg2rad(pitches)/3);
 
    %angular accel in rad/s^2
    pitchangaccel = abs(diff(pitchangvel)/3); 
    pitchangaccel = [pitchangaccel(1);pitchangaccel(:)];

    cumulativeDistanceIn3D = cumsum(distanceIncrementIn3D);
    totalDistanceIn3D = sum(distanceIncrementIn3D);
    fprintf("Total blimp track distance is %f meters.\n",totalDistanceIn3D)
    
    figpos = [200 200 800 400];
    uif = uifigure("Position",figpos);
    ug = uigridlayout(uif,[1,2]);
    p1 = uipanel(ug);
    p2 = uipanel(ug);
    %p3 = uipanel(ug);
    gx = geoaxes(p1,"Basemap","satellite"); 
    gg = geoglobe(p2); 
    %alt = axes(p3);
    gx.InnerPosition = gx.OuterPosition;
    gg.Position = [0 0 1 1];
    %alt.Position=[ 0 0 1 2];

    geoplot3(gg,tlat,tlon,talt,"c","LineWidth",2,"HeightReference","geoid")
    hold(gx,"on")
    ptrack = geoplot(gx,tlat,tlon,"c","LineWidth",2);
    [clat,clon,cheight] = campos(gg);
    gx.MapCenter = [clat,clon];
    %gx.ZoomLevel = heightToZoomLevel(cheight, clat);
      
    plot(data_geodetic.GPSAltitude(3:end,:)-data_geodetic.GPSAltitude(1));
    xlabel('Time (3s intervals)')
    ylabel('Height above ground (m)')
    title('Altitude vs Time')

    drawnow

%     tdist = [0 totalDistanceIn3D];
%     
%     campos(gg,tlat(1),tlon(1))
%     camheight(gg,talt(1) + 75)
%     campitch(gg,-90)
%     camheading(gg,theading(3))
%     marker = geoplot(gx,tlat(1),tlon(1),"ow","MarkerSize",10,"MarkerFaceColor","k");
%     mstart = geoplot(gx,tlat(1),tlon(1),"ow","MarkerSize",10,"MarkerFaceColor","magenta");
%     mend = geoplot(gx,tlat(end),tlon(end),"ow","MarkerSize",10,"MarkerFaceColor","blue");
%     
%     marker.DisplayName = "Current Location";
%     mstart.DisplayName = "Start Location";
%     mend.DisplayName = "End Location";
%     ptrack.DisplayName = "UAV Track";
%     legend(gx)
%     gx.Basemap = "topographic";
%     dt = datatip(ptrack,"DataIndex",1,"Location","southeast");
%     dtrow = dataTipTextRow("Distance",cumulativeDistanceIn3D);
%     dtrow(end+1) = dataTipTextRow("Altitude",talt);
%     dtrow(end+1) = dataTipTextRow("Heading",theading);
%     ptrack.DataTipTemplate.DataTipRows(end+1:end+3) = dtrow;
%     pitch = -2.7689;
%     campitch(gg,pitch)
%     
%     for k = 2:(length(tlat)-1)    
%         campos(gg,tlat(k),tlon(k))
%         camheight(gg,talt(k)+100)
%         camheading(gg,theading(k))
%         
%         set(marker,"LatitudeData",tlat(k),"LongitudeData",tlon(k));
%         dt.DataIndex = k;
%         
%         drawnow
%         %pause(.25)
%     end

    campos(gg,tlat(end),tlon(end),talt(end)+100)
    dt.DataIndex = length(tlat);

    subplot(1,2,1)
    scatter3(tlon,tlat,talt,50,angaccel, 'fill') % Make filled 3D scatter plot
    line(tlon,tlat,talt)
    xlabel('Longitude')
    ylabel('Latitude')
    zlabel('Altitude (m)')
    title('Path vs Yaw Angular Acceleration ')
    c = colorbar;
    c.Label.String = 'Angular Acceleration (rad/s^2)';

    subplot(1,2,2)
    scatter3(tlon,tlat,talt,50,pitchangaccel, 'fill') % Make filled 3D scatter plot
    line(tlon,tlat,talt)
    xlabel('Longitude')
    ylabel('Latitude')
    zlabel('Altitude (m)')
    title('Path vs Pitch Angular Acceleration ')
    c = colorbar;
    c.Label.String = 'Angular Acceleration (rad/s^2)';
    
    mean_pitch=mean(pitchangaccel);
    mean_yaw=mean(angaccel);
    fprintf("Average pitch angular acceleration is %f rad/s^2 .\n",mean_pitch)
    fprintf("Average pitch angular acceleration is %f rad/s^2 .\n",mean_yaw)
    fprintf("Yaw angular accleration is %f times greater than pitch angular acceleration.\n",mean_yaw/mean_pitch)

    
end