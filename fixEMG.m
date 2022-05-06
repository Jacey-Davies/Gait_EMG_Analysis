function fixEMG(qualityname)
%Turns all problem EMG data into zeros according to quality check in Excel
%file determined by "qualityname"


%Reading the quality check file
qualityname = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', qualityname);
qlty = readtable(qualityname);

for i = 1:height(qlty) %Going through the quality check file line by line
    
    %Getting the Trials
    trial = split(qlty.Trial(i))';

    %Remove first bracket
    trial{1} = trial{1}(2:length(trial{1}));

    %Remove last bracket
    trial{length(trial)} = trial{length(trial)}(1:(length(trial{length(trial)})-1));
    %trial = (str2double(hold(:)))';

%Getting the Sides
    if length(qlty.Side{i}) > 1
        side = split(qlty.Side(i))';
    else
        side = qlty.Side(i);
    end

%Getting the Muscles
    if length(qlty.Muscle{i}) > 1
        muscle = split(qlty.Muscle(i))';
    else
        muscle = qlty.Muscle(i);
    end

%Going through each trial in the line
    for j = 1:length(trial)
        
        %try/catch is to show a warning if the Excel sheets do not exist
        try
            %Name of file changes once the trial goes above 09
            if str2double(trial{j}) < 10
                filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', qlty.Subject(i), '\', qlty.Subject(i), '_', qlty.Task(i), ' 0', trial{j}, '_EMGdata_CCI.xlsx');
                dataCCI = readtable(char(filename), 'PreserveVariableNames', 1);
                filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', qlty.Subject(i), '\', qlty.Subject(i), '_', qlty.Task(i), ' 0', trial{j}, '_EMGdata_PeakEMG.xlsx');
                dataPeak = readtable(char(filename), 'PreserveVariableNames', 1);
            else
                filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', qlty.Subject(i), '\', qlty.Subject(i), '_', qlty.Task(i), {' '}, trial{j}, '_EMGdata_CCI.xlsx');
                dataCCI = readtable(char(filename), 'PreserveVariableNames', 1);
                filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', qlty.Subject(i), '\', qlty.Subject(i), '_', qlty.Task(i), {' '}, trial{j}, '_EMGdata_PeakEMG.xlsx');
                dataPeak = readtable(char(filename), 'PreserveVariableNames', 1);
            end
            
        catch
            if str2double(trial{j}) < 10
                warning(char(strcat({'No CCI/PeakEMG Excel files for '}, qlty.Subject{i}, '_', qlty.Task(i), ' 0', trial{j})))
            else
                warning(char(strcat({'No CCI/PeakEMG Excel files for '}, qlty.Subject{i}, '_', qlty.Task(i), {' '}, trial{j})))
            end
            
            continue
        end
  
        %Going through each side + muscle pair
        for k = 1:length(side)
            
                %CCI
                for a = 1:height(dataCCI) %Cycle through entire Excel sheet
                    %If the side matches
                    if strcmp(side{k},dataCCI.Side{a}) == 1 
                       %If the muscle pair involves the problem muscle
                       if strcmp(muscle{k},dataCCI.("Muscle Pair"){a}(1:2)) == 1 || strcmp(muscle{k},dataCCI.("Muscle Pair"){a}(4:5)) == 1
                          dataCCI.CCI(a) = 0;
                          dataCCI.("Normalized CCI")(a) = 0;
                       else
                       end
                    else
                    end
                end

            %Peak EMG
                for a = 1:height(dataPeak) %Cycle through entire Excel sheet
                    %If the side matches
                    if strcmp(side{k},dataPeak.Side{a}) == 1 
                       %If the muscle matches
                       if strcmp(muscle{k},dataPeak.Muscle(a)) == 1
                          dataPeak.("Peak EMG Activity")(a) = 0;
                          dataPeak.("Normalized Peak EMG Activity")(a) = 0;
                       else
                       end
                    else
                    end
                end
            
        end
        
        %Rewriting the Excel files
        
        if str2double(trial{j}) < 10
            filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', qlty.Subject(i), '\', qlty.Subject(i), '_', qlty.Task(i), ' 0', trial{j}, '_EMGdata_CCI.xlsx');
            writetable(dataCCI, char(filename));

            filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', qlty.Subject(i), '\', qlty.Subject(i), '_', qlty.Task(i), ' 0', trial{j}, '_EMGdata_PeakEMG.xlsx');
            writetable(dataPeak, char(filename));
        else
            filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', qlty.Subject(i), '\', qlty.Subject(i), '_', qlty.Task(i), {' '}, trial{j}, '_EMGdata_CCI.xlsx');
            writetable(dataCCI, char(filename));

            filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', qlty.Subject(i), '\', qlty.Subject(i), '_', qlty.Task(i), {' '}, trial{j}, '_EMGdata_PeakEMG.xlsx');
            writetable(dataPeak, char(filename));
        end
        
        
    end   
end




end

