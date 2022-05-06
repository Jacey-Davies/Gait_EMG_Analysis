function peakEMG_Excel(subjectcode,taskname,EMGdata,EMGdata_Norm)
%Exports Excel sheet with peak values

%Labels for Excel sheet
Label = ["Subject" "Task" "Side" "Step" "Bin" "Muscle" "Peak EMG Activity" "Normalized Peak EMG Activity"];

%Cell to hold values for Excel sheet
Cell = {Label(1),Label(2),Label(3),Label(4),Label(5),Label(6),Label(7), Label(8)};

%Structure names to use in for loop
leg = ["left" "right"];
musc = ["TA" "SO" "MG" "VM" "RF" "BF"];
bin = ["bin1" "bin2" "bin3" "bin4" "bin5" "bin6"];
a = 1; %Variable for tracking

%For loop to fill cell
for N = 1:2 %Left vs right leg
    for j = 1:length(EMGdata) %For each gait cycle
        if isempty(EMGdata(j).(leg{N})) == 0 %To make sure the gait cycle isn't empty
            for M = 1:6 %First muscle for comparison
                try
                    for b = 1:6 %Bins
                        Cell(a+1,1) = {subjectcode}; %Subject
                        Cell(a+1,2) = {taskname}; %Task
                            if N == 1 %Side
                               Cell(a+1,3) = {'left'}; 
                            else
                               Cell(a+1,3) = {'right'}; 
                            end
                        Cell(a+1,4) = {j}; %Step
                        Cell(a+1,5) = {b}; %Bin
                        Cell(a+1,6) = {musc(M)}; %Muscle
                        Cell(a+1,7) = {max(EMGdata(j).(leg{N}).(musc{M}).(bin{b}).data)}; %Peak EMG Activity
                        Cell(a+1,8) = {max(EMGdata_Norm(j).(leg{N}).(musc{M}).(bin{b}).data)}; %Normalized Peak EMG Activity
                        a = a + 1;
                    end
                catch
                    warning('Missing events in raw data file.');
                    return
                end
            end
        else
        end
    end
end

filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', subjectcode, '\', subjectcode, '_', taskname, '_', 'EMGdata_PeakEMG.xlsx'); %Name for Excel file
writecell(Cell,filename); %Creating the Excel sheet

end

