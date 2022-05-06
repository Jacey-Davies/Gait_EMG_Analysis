function compileEMG(task, fnameCCI, fnamePeak)
%Compiles all of the tasks provided of all subjects for all trials into one
%big Excel sheet. Does CCI and peakEMG separately. "task" must be string
%vector of the desired task names (ex: FW, SS)

%To keep track of top of Excel sheet
first = 0;

%The columns for the table
Subject = " ";
Task = " ";
Trial = " ";
Side = " ";
Step = 0;
Bin = 0;
Muscle = " ";

%The CCI table
dataCCI = table(Subject, Task, Trial, Side, Step, Bin);
dataCCI.("Muscle Pair") = " ";
dataCCI.CCI = " ";
dataCCI.("Normalized CCI") = " ";

%The peakEMG table
dataPeak = table(Subject, Task, Trial, Side, Step, Bin, Muscle);
dataPeak.("Peak EMG Activity") = " ";
dataPeak.("Normalized Peak EMG Activity") = " ";

%For loop for all possible subject numbers
for i = 1000:3999
    
    %For loop for all tasks
    for j = 1:length(task)
        
        %For loop for all trials
        for k = 1:25 %Change if number of trials exceeds 25
            
            %See if file exists
            try
                %File names change after 09
                if k < 10
                    
                    %'P:\ClarkLab\Mind_in_Motion\Study Data\EMG\H1001\H1001_SS 01_EMGdata_CCI.xlsx'
                    filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\H', num2str(i), '\H', num2str(i), '_', task(j), ' 0', num2str(k), '_EMGdata_CCI.xlsx');
                    dataCCI_hold = readtable(char(filename), 'PreserveVariableNames', 1);
                    
                    filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\H', num2str(i), '\H', num2str(i), '_', task(j), ' 0', num2str(k), '_EMGdata_PeakEMG.xlsx');
                    dataPeak_hold = readtable(char(filename), 'PreserveVariableNames', 1);
                    
                else
                    
                    filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\H', num2str(i), '\H', num2str(i), '_', task(j), {' '}, num2str(k), '_EMGdata_CCI.xlsx');
                    dataCCI_hold = readtable(char(filename), 'PreserveVariableNames', 1);
                    
                    filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\H', num2str(i), '\H', num2str(i), '_', task(j), {' '}, num2str(k), '_EMGdata_PeakEMG.xlsx');
                    dataPeak_hold = readtable(char(filename), 'PreserveVariableNames', 1);
                    
                end
                                
            catch
                continue
            end
                     
            %helpme = dataCCI_hold.Task{:}((length(dataCCI_hold.Task{1})-1):length(dataCCI_hold.Task{1}));
            
            %Separating the Task and Trial number
            %Remove if this is fixed in CCI_Excel.m and peakEMG_Excel.m code
            taskcol_CCI = cell(height(dataCCI_hold),1);
            taskcol_CCI(:) = {task(j)};
            
            taskcol_peak = cell(height(dataPeak_hold),1);
            taskcol_peak(:) = {task(j)};
            
            trialcol_CCI = cell(height(dataCCI_hold),1);
            trialcol_peak = cell(height(dataPeak_hold),1);
            
            if k < 10
                
                trialcol_CCI(:) = {strcat('0', num2str(k))};
                trialcol_peak(:) = {strcat('0', num2str(k))};
                
            else
                
                trialcol_CCI(:) = {num2str(k)};
                trialcol_peak(:) = {num2str(k)};
                
            end
            
            %Adding these and the other data to dataCCI and dataPeak
            dataCCI_2 = [dataCCI_hold.Subject, taskcol_CCI, trialcol_CCI, dataCCI_hold.Side, num2cell(dataCCI_hold.Step), num2cell(dataCCI_hold.Bin), dataCCI_hold.("Muscle Pair"), num2cell(dataCCI_hold.CCI), num2cell(dataCCI_hold.("Normalized CCI"))];
            dataPeak_2 = [dataPeak_hold.Subject, taskcol_peak, trialcol_peak, dataPeak_hold.Side, num2cell(dataPeak_hold.Step), num2cell(dataPeak_hold.Bin), dataPeak_hold.Muscle, num2cell(dataPeak_hold.("Peak EMG Activity")), num2cell(dataPeak_hold.("Normalized Peak EMG Activity"))];
            dataCCI = [dataCCI; dataCCI_2];
            dataPeak = [dataPeak; dataPeak_2];
            
            if first == 0
                %Remove empty row from setting up table
                dataCCI(1,:) = [];
                dataPeak(1,:) = [];
            else
            end
            
            first = 1;
            
        end
        
    end
    
end

filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', fnameCCI);
writetable(dataCCI, char(filename));

filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', fnamePeak);
writetable(dataPeak, char(filename));

end

