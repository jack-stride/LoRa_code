%%   
%        AUTHOR: Jack Stride 
%       CREATED: FEB 2022
%   
%   DESCRIPTION: *Script extracts SNR from LoRaWAN frames in JSON format.
%                *Calculates mean SNR by converting SNR back to ratio and
%                 averaging. Then converts back to dB
%                *Boxplot produced from SNR values in each JSON file.  
%
%%

clear variables 

file_names = ["5.1.json";"5.2.json";"5.3.json";"5.4.json";"5.5.json";"5.6.json";"5.7.json";"5.8.json";"5.9.json"];      % Insert file names of frames for data extraction

sensor_snr = zeros();                               % Creates SNR value array  

gatewayID = "qlVaAAAAAQI=";                         % Enter ID of gateway required 

posistion_locations = {'Position 5.1','Position 5.2','Position 5.3','Position 5.4','Position 5.5','Position 5.6','Position 5.7','Position 5.8','Position 5.9'};     % Position names of each file, used in plots.

for file_number = 1:length(file_names)              % Loop extracts data from JSON files

file_name = file_names(file_number);
fileID = fopen(file_name);                          % Open file
raw = fread(fileID);                                % Read data
str = char(raw');                                   % Convert to character array 
fclose(fileID);                                     % Close file
data = jsondecode(str);                             % Decode JSON-formatted text

                       
position_in_array = 1;                                                                          % Counter for index in sensor_snr  

for frame_number = 1:length(data)                                                               % Cycles through each frame  
                                                                            
    for rxInfo_number = 1:length(data(frame_number).uplinkMetaData.rxInfo)                      % Used when multiple SNR values in one frame
    
        if data(frame_number).uplinkMetaData.rxInfo(rxInfo_number).gatewayID == gatewayID       % Checks gateway ids match      
    
            snr = data(frame_number).uplinkMetaData.rxInfo(rxInfo_number).loRaSNR;              % Assigns SNR
    
            sensor_snr(file_number,position_in_array) = snr;                                    % Stores SNR in array 
    
            position_in_array = position_in_array+1;                                            % Moves on index coutner by 1
        else 
            
        end
    end 

end

end

sensor_snr(sensor_snr==0)=nan;                                          % Set all SNR error values to NaN      

%% Boxchart plot

means = zeros(1,length(file_names));                                    % Create array for mean values

snr_as_ratio = 10.^(sensor_snr/10);                                     % Convert SNR from dBs to ratio of signal to noise energy  

for position = 1:length(file_names)

    mean_position(position) = position;                                 % Position of mean for plotting                        

    means(position) = mean(snr_as_ratio(position,:),'omitnan');         % Calculate mean from ratio of signal energy to noise energy

end

means = 10*log10(means)                                                 % convert mean values back to dBs 

f=figure(2);
f.Position = [100 100 900 600];                                                     % set window size
boxchart(sensor_snr.',MarkerStyle="none")                                           % Boxplot
hold on 
plot(mean_position,means,Marker='_',LineStyle='none',MarkerSize=34,LineWidth=1.5)   % Add mean SNR values to plot
legend({'IQR','Mean'},FontSize=15)

xticklabels(posistion_locations)                                                    % Add position labels to x axis   
grid on 
ax = gca;                                                                           % Adjusting presentation of plot
ax.YMinorGrid = 'on';
ax.MinorGridAlpha = 1;                                                         
ax.GridAlpha = 0.7;
box on 
ax.FontSize = 17;
ax.XGrid='off';
ax.GridLineStyle='-.';
ax.YMinorTick='on';
ax.XAxis.FontSize = 15;
ax.YAxis.FontSize = 20;
ax.YLim = [2 12];

title('LoRa Sensor Along Whiteladies Rd Connecting to the MVB Gateway',FontSize=23,FontWeight='normal')
subtitle('19th April 2022 (Data Collection Day 2)', FontSize=15)
ylabel('SNR (dB)','FontSize',22)
xlabel('Location','FontSize',22)

ax.XColor=[0 0 0];  
ax.YColor=[0 0 0];                  

hold off 
