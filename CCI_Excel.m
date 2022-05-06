function CCI_Excel(subjectcode,taskname,EMGdata,EMGdata_Norm)
%Exports Excel sheet with CCI values

%Labels for Excel sheet
Label = ["Subject" "Task" "Side" "Step" "Bin" "Muscle Pair" "CCI" "Normalized CCI"];

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
            for M1 = 1:6 %First muscle for comparison
                for M2 = 1:6 %Second muscle for comparison
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
                            Cell(a+1,6) = {strcat(musc(M1), "-", musc(M2))}; %Muscle Pair
                            Cell(a+1,7) = {sum(EMGdata(j).(leg{N}).(musc{M1}).(bin{b}).CCI.(musc{M2})(1:length(EMGdata(j).(leg{N}).(musc{M1}).(bin{b}).CCI.(musc{M2}))))}; %CCI
                            Cell(a+1,8) = {sum(EMGdata_Norm(j).(leg{N}).(musc{M1}).(bin{b}).CCI.(musc{M2})(1:length(EMGdata_Norm(j).(leg{N}).(musc{M1}).(bin{b}).CCI.(musc{M2}))))}; %Normalized CCI
                            a = a + 1;
                        end
                    catch
                       warning('Missing events in raw data file.');
                       return
                    end
                end
            end
        else
        end
    end
end

filename = strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', subjectcode, '\', subjectcode, '_', taskname, '_', 'EMGdata_CCI.xlsx'); %Name for Excel file
writecell(Cell,filename); %Creating the Excel sheet

end

