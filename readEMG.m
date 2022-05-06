function [EMGdata_Raw,EMGdata,EMGdata_Norm] = readEMG(subjectcode, taskname)
%Function to read the EMG data file and make the needed changes

%%% Reading the EMG file %%%
%Determining the file name
filename = strcat('P:\HMPL\Lower Extremity\Clark\MindInMotion\', subjectcode, '\EMG Data\', subjectcode, '_', taskname, '_EMGdata.txt');

% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 17);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["EMG_Sample_Rate", "Time", "Left_Gait_Cycle", "Right_Gait_Cycle", "TA_left", "TA_right", "SO_left", "SO_right", "MG_left", "MG_right", "VM_left", "VM_right", "RF_left", "RF_right", "BF_left", "BF_right", "Heel_lift_point"];
opts.VariableTypes = ["double", "double", "char", "char", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "char"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Left_Gait_Cycle", "Right_Gait_Cycle", "Heel_lift_point"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Left_Gait_Cycle", "Right_Gait_Cycle", "Heel_lift_point"], "EmptyFieldRule", "auto");

% Import the data
EMGdata_Raw = readtable(filename, opts);

% Convert to output type (cell)
EMGdata_Raw = table2cell(EMGdata_Raw);
numIdx = cellfun(@(x) ~isnan(str2double(x)), EMGdata_Raw);
EMGdata_Raw(numIdx) = cellfun(@(x) {str2double(x)}, EMGdata_Raw(numIdx));

% To make into EMGdata_Raw structure
f = {'EMG_Sample_Rate', 'Time', 'Left_Gait_Cycle', 'Right_Gait_Cycle', 'TA_left', 'TA_right', 'SO_left', 'SO_right', 'MG_left', 'MG_right', 'VM_left', 'VM_right', 'RF_left', 'RF_right', 'BF_left', 'BF_right', 'Heel_lift_point'};
EMGdata_Raw = cell2struct(EMGdata_Raw,f,2);

%%% Extracting only the complete gait cycles %%%
%Labels for use in for loops later
leg = ["left" "right" "Left_Gait_Cycle" "Right_Gait_Cycle"];
musc = ["TA" "SO" "MG" "VM" "RF" "BF" "TA_left" "SO_left" "MG_left" "VM_left" "RF_left" "BF_left" "TA_right" "SO_right" "MG_right" "VM_right" "RF_right" "BF_right"];

%Finding where left heel strike occurs
ind_left = strcmp({EMGdata_Raw.Left_Gait_Cycle}', 'left heel strike');
ind_left = find(ind_left); %We do use this ignore the warning

%Finding where right heel strike occurs
ind_right = strcmp({EMGdata_Raw.Right_Gait_Cycle}', 'right heel strike');
ind_right = find(ind_right); %We do use this ignore the warning

%Sorting the data into gait cycles
for N = 1:2 %Left vs right leg
   c = 1; %To keep track of gait cycle number
   b = min(eval(strcat('ind_',leg(N)))); %To find the first heel strike for each leg; where the ind_left and ind_right are used
   for i = min(eval(strcat('ind_',leg(N)))):(length(EMGdata_Raw)-1) %From first heel strike to end of data
       if strcmp(EMGdata_Raw(i).(leg{N+2}),'swing') == 1 && strcmp(EMGdata_Raw(i+1).(leg{N+2}),strcat(leg(N),' heel strike')) == 1 
        %Finds when last gait cycle ends and next gait cycle begins       
        B(c).(leg{N}).Time = [EMGdata_Raw(b:i).Time]'; %Creating temporary structure B
        B(c).(leg{N}).Gait_Cycle = {EMGdata_Raw(b:i).(leg{N+2})}';
        for M = 1:6 %For each muscle
            if N == 1
            B(c).(leg{N}).(musc{M}) = [EMGdata_Raw(b:i).(musc{M+6})]';
            else
            B(c).(leg{N}).(musc{M}) = [EMGdata_Raw(b:i).(musc{M+12})]';    
            end
        end
        
        c = c+1; %Keeping track of gait cycle number
        b = i+1; %Keeping track of starting position for next gait cycle
        
       else
       end
   end
end

%%% Demeaning, filtering, rectifying, and smoothing the data %%%
%Copying B into C so C has the time values; C will be used to hold the normalized data
C = B;

%Applying the filtering, rectifying, etc
for N = 1:2 %Left vs right leg
    for j = 1:length(B)
       if isempty(B(j).(leg{N})) == 0 %To make sure the gait cycle isn't empty
          for M = 1:6 %For each muscle
          B(j).(leg{N}).(musc{M}) = smooth(abs(Lowpass(Highpass(B(j).(leg{N}).(musc{M}) - mean(B(j).(leg{N}).(musc{M})),10),499)),100,'moving');
          end
       else
       end
    end
end

%%% Normalizing the data %%%
%For loop
for N = 1:2 %Left vs right leg
    for j = 1:length(B)
       if isempty(B(j).(leg{N})) == 0 %To make sure the gait cycle isn't empty
          %Normalizing the data for each muscle by the max of that muscle 
          for M = 1:6
          MAX = max(B(j).(leg{N}).(musc{M}));
          C(j).(leg{N}).(musc{M}) = B(j).(leg{N}).(musc{M})/MAX*100;
          end
       else
       end
    end
end

%%% Sorting the data into bins %%%
% Getting bins for the non-normalized data
for N = 1:2
    for j = 1:length(B)
        if isempty(B(j).(leg{N})) == 0
            %Bin 1(first double support)
            for k = find(strcmp(B(j).(leg{N}).Gait_Cycle,'double support, lead limb'),1):find(strcmp(B(j).(leg{N}).Gait_Cycle,'double support, lead limb'),1,'last')
                for M = 1:6
                EMGdata(j).(leg{N}).(musc{M}).bin1.data(k-find(strcmp(B(j).(leg{N}).Gait_Cycle,'double support, lead limb'),1)+1) = B(j).(leg{N}).(musc{M})(k);
                end
            end
            
            %Bin 2 (single support (first 50%))
            for k = find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1):(find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1,'last')-find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1)+1)/2+find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1)-1
                for M = 1:6
                EMGdata(j).(leg{N}).(musc{M}).bin2.data(k-find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1)+1) = B(j).(leg{N}).(musc{M})(k);
                end
            end
            
            %Bin 3 (single support (last 50%))
            for k = (find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1,'last')-find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1)+1)/2+find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1):find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1,'last')
                for M = 1:6
                EMGdata(j).(leg{N}).(musc{M}).bin3.data(k-((find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1,'last')-find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1)+1)/2+find(strcmp(B(j).(leg{N}).Gait_Cycle,'single support'),1))+1) = B(j).(leg{N}).(musc{M})(k);
                end
            end
            
            %Bin 4 (second double support)
            for k = find(strcmp(B(j).(leg{N}).Gait_Cycle,'double support, trail limb'),1):find(strcmp(B(j).(leg{N}).Gait_Cycle,'double support, trail limb'),1,'last')
                for M = 1:6
                EMGdata(j).(leg{N}).(musc{M}).bin4.data(k-find(strcmp(B(j).(leg{N}).Gait_Cycle,'double support, trail limb'),1)+1) = B(j).(leg{N}).(musc{M})(k); 
                end
            end
            
            %Bin 5 (swing (first 50%))
            for k = find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1):(find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1,'last')-find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1)+1)/2+find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1)-1
                for M = 1:6
                EMGdata(j).(leg{N}).(musc{M}).bin5.data(k-find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1)+1) = B(j).(leg{N}).(musc{M})(k);
                end
            end
            
            %Bin 6 (swing (last 50%))
            for k = (find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1,'last')-find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1)+1)/2+find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1):find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1,'last')
                for M = 1:6
                EMGdata(j).(leg{N}).(musc{M}).bin6.data(k-((find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1,'last')-find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1)+1)/2+find(strcmp(B(j).(leg{N}).Gait_Cycle,'swing'),1))+1) = B(j).(leg{N}).(musc{M})(k);
                end
            end

        else
        end
    end
end

% Getting bins for the normalized data
for N = 1:2
    for j = 1:length(C)
        if isempty(C(j).(leg{N})) == 0
            %Bin 1(first double support)
            for k = find(strcmp(C(j).(leg{N}).Gait_Cycle,'double support, lead limb'),1):find(strcmp(C(j).(leg{N}).Gait_Cycle,'double support, lead limb'),1,'last')
                for M = 1:6
                EMGdata_Norm(j).(leg{N}).(musc{M}).bin1.data(k-find(strcmp(C(j).(leg{N}).Gait_Cycle,'double support, lead limb'),1)+1) = C(j).(leg{N}).(musc{M})(k);
                end
            end
            
            %Bin 2 (single support (first 50%))
            for k = find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1):(find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1,'last')-find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1)+1)/2+find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1)-1
                for M = 1:6
                EMGdata_Norm(j).(leg{N}).(musc{M}).bin2.data(k-find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1)+1) = C(j).(leg{N}).(musc{M})(k);
                end
            end
            
            %Bin 3 (single support (last 50%))
            for k = (find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1,'last')-find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1)+1)/2+find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1):find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1,'last')
                for M = 1:6
                EMGdata_Norm(j).(leg{N}).(musc{M}).bin3.data(k-((find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1,'last')-find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1)+1)/2+find(strcmp(C(j).(leg{N}).Gait_Cycle,'single support'),1))+1) = C(j).(leg{N}).(musc{M})(k);
                end
            end
            
            %Bin 4 (second double support)
            for k = find(strcmp(C(j).(leg{N}).Gait_Cycle,'double support, trail limb'),1):find(strcmp(C(j).(leg{N}).Gait_Cycle,'double support, trail limb'),1,'last')
                for M = 1:6
                EMGdata_Norm(j).(leg{N}).(musc{M}).bin4.data(k-find(strcmp(C(j).(leg{N}).Gait_Cycle,'double support, trail limb'),1)+1) = C(j).(leg{N}).(musc{M})(k); 
                end
            end
            
            %Bin 5 (swing (first 50%))
            for k = find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1):(find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1,'last')-find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1)+1)/2+find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1)-1
                for M = 1:6
                EMGdata_Norm(j).(leg{N}).(musc{M}).bin5.data(k-find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1)+1) = C(j).(leg{N}).(musc{M})(k);
                end
            end
            
            %Bin 6 (swing (last 50%))
            for k = (find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1,'last')-find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1)+1)/2+find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1):find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1,'last')
                for M = 1:6
                EMGdata_Norm(j).(leg{N}).(musc{M}).bin6.data(k-((find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1,'last')-find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1)+1)/2+find(strcmp(C(j).(leg{N}).Gait_Cycle,'swing'),1))+1) = C(j).(leg{N}).(musc{M})(k);
                end
            end

        else
        end
    end
end

%%% Calculating the co-contraction indices %%%
%Labels for co-contraction for loops
bin = ["bin1" "bin2" "bin3" "bin4" "bin5" "bin6"];

%Calculating co-contraction for non-normalized EMG
for N = 1:2 %Left vs right leg
    for j = 1:length(EMGdata) %For each gait cycle
        if isempty(EMGdata(j).(leg{N})) == 0 %To make sure the gait cycle isn't empty
            for M1 = 1:6 %First muscle for comparison
                for M2 = 1:6 %Second muscle for comparison
                    for b = 1:6 %Bins
                       try
                           for i = 1:length(EMGdata(j).(leg{N}).(musc{M1}).(bin{b}).data) %For all data points in the bin
                               if EMGdata(j).(leg{N}).(musc{M1}).(bin{b}).data(i) < EMGdata(j).(leg{N}).(musc{M2}).(bin{b}).data(i)
                                   %If muscle 1 (M1) is smaller than muscle 2 (M2), calculate the "area under the curve" with muscle 1
                                   EMGdata(j).(leg{N}).(musc{M1}).(bin{b}).CCI.(musc{M2})(i) = EMGdata(j).(leg{N}).(musc{M1}).(bin{b}).data(i)*.0005;
                               else
                                   %If muscle 1 (M1) is larger than or equal to muscle 2 (M2), calculate the "area under the curve" with muscle 2
                                   EMGdata(j).(leg{N}).(musc{M1}).(bin{b}).CCI.(musc{M2})(i) = EMGdata(j).(leg{N}).(musc{M2}).(bin{b}).data(i)*.0005;
                               end
                           end
                       catch
                            warning('Missing events in raw data file.');
                            return
                       end
                    end
                end
            end
        else
        end
    end
end

%Calculating co-contraction for normalized EMG
for N = 1:2 %Left vs right leg
    for j = 1:length(EMGdata_Norm) %For each gait cycle
        if isempty(EMGdata_Norm(j).(leg{N})) == 0 %To make sure the gait cycle isn't empty
            for M1 = 1:6 %First muscle for comparison
                for M2 = 1:6 %Second muscle for comparison
                    for b = 1:6 %Bins
                       for i = 1:length(EMGdata_Norm(j).(leg{N}).(musc{M1}).(bin{b}).data) %For all data points in the bin
                           if EMGdata_Norm(j).(leg{N}).(musc{M1}).(bin{b}).data(i) < EMGdata_Norm(j).(leg{N}).(musc{M2}).(bin{b}).data(i)
                               %If muscle 1 (M1) is smaller than muscle 2 (M2), calculate the "area under the curve" with muscle 1
                               EMGdata_Norm(j).(leg{N}).(musc{M1}).(bin{b}).CCI.(musc{M2})(i) = EMGdata_Norm(j).(leg{N}).(musc{M1}).(bin{b}).data(i)*.0005;
                           else
                               %If muscle 1 (M1) is larger than or equal to muscle 2 (M2), calculate the "area under the curve" with muscle 2
                               EMGdata_Norm(j).(leg{N}).(musc{M1}).(bin{b}).CCI.(musc{M2})(i) = EMGdata_Norm(j).(leg{N}).(musc{M2}).(bin{b}).data(i)*.0005;
                           end
                       end
                       EMGdata_Norm(j).(leg{N}).(musc{M1}).(bin{b}).CCIsum.(musc{M2}) = sum(EMGdata_Norm(j).(leg{N}).(musc{M1}).(bin{b}).CCI.(musc{M2})(1:length(EMGdata_Norm(j).(leg{N}).(musc{M1}).(bin{b}).CCI.(musc{M2}))));
                    end
                end
            end
        else
        end
    end
end

end

