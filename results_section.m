%% Results Data
clear 
clc
close all

%inputing the data from the flight logs
Flight = [1; 2; 3; 4; 5];
Wind_Speed = [2; 1.85; 0; 1.9; 0]*0.44704; %convert to m/s from mph
Endurance = [NaN; 31; 37; 24; 35]; %Nan because the first flight was ended early
Course_Correction = [2; 2; 5; 3; 5];

% These are the experimental errors taken as the smallest increment of the
% measureing device 
err_wind_pos = .1*.44704*ones(1,5);
err_wind_neg = -err_wind_pos;
err_end_pos = ones(1,5);
err_end_neg = -err_end_pos;
err_cor_pos = ones(1,5);
err_cor_neg = -err_cor_pos;

results = table(Flight,Endurance,Course_Correction,Wind_Speed); % adding a results table to keep things organized 

%% Plotting

%plotting Endurance vs Wind
figure
p1=scatter(results,"Wind_Speed","Endurance","filled");
f1=lsline; %least squares linear regression line 
f1.Color = 'r';
hold on
errorbar(Wind_Speed,Endurance,err_end_neg,err_end_pos,err_wind_neg,err_wind_pos,'bo')
legend([p1 f1],'Test Flight','Linear Trendline')
title('Endurance vs Wind')
xlabel('Ground Wind Speed (m/s)')
ylabel('Endurance (mins)')
xlim([-.1 1])
ylim([22 39])

%plotting Course Correction vs Wind
figure
p2=scatter(results,"Wind_Speed","Course_Correction","filled");
f2=lsline; %least squares linear regression line 
f2.Color = 'r';
hold on
errorbar(Wind_Speed,Course_Correction,err_cor_neg,err_cor_pos,err_wind_neg,err_wind_pos,'bo')
legend([p2 f2],'Test Flight','Linear Trendline')
title('Course Correction vs Wind')
xlabel('Ground Wind Speed (m/s)')
ylabel('Course Correction (seconds)')
xlim([-.1 1])
ylim([.9 6.1])

%% Uncertainty calculations
[mean_end, uncert_end]=mean_uncertainty(Endurance,err_end_pos);
[mean_course, uncert_course]=mean_uncertainty(Course_Correction,err_cor_pos);
[mean_wind, uncert_wind]=mean_uncertainty(Wind_Speed,err_wind_pos);

% a function that propagates uncertainty 
function [avg, avg_err]=mean_uncertainty(values, errs)
    avg=nanmean(values);
    avg_err=errs(1)/sqrt(length(values));
end
    


