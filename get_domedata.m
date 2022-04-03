function get_domedata(pixhawk_log)
    dome_data = load(pixhawk_log,'ATT_label','ATT'); % pull in labels and values
    dome_time=dome_data.ATT(:,2); % pull in time and convert to seconds
    dome_heading=dome_data.ATT(:,8) ; % pull in time 
    csvwrite('dome_time.csv',dome_time); % file will be created in the working directory
    csvwrite('dome_heading.csv',dome_heading); % file will be created in the working directory
end