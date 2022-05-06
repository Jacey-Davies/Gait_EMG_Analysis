function posterEMG(EMGdata_Raw, subjectcode, taskname)
%To plot the raw EMG data and the envelopes into a poster

%So _ doesn't show up as subscript
set(0, 'DefaultTextInterpreter', 'none')

%Initializing the vectors
left = zeros(length(EMGdata_Raw),1);
right = zeros(length(EMGdata_Raw),1);

%The time vector
t = [EMGdata_Raw.Time];

%Determining if leg is in stance phase or not
for i = 1:length(EMGdata_Raw)
   if strcmp(EMGdata_Raw(i).Left_Gait_Cycle,'swing') == 1 || strcmp(EMGdata_Raw(i).Left_Gait_Cycle,'left toe off') == 1
        left(i) = NaN;
   elseif strcmp(EMGdata_Raw(i).Left_Gait_Cycle,'') == 1
       warning('Missing events in raw data file.');
       return
   else
        left(i) = 1;
   end
   
   if strcmp(EMGdata_Raw(i).Right_Gait_Cycle,'swing') == 1 || strcmp(EMGdata_Raw(i).Right_Gait_Cycle,'right toe off') == 1
        right(i) = NaN;
   else
        right(i) = .5;
   end
end

%Plotting stance phases; won't work in for loop
figure(1)
side = ["Left" "Right"];
for i = 1:2
    
    subplot(7,2,i)
    plot(t,left,'b','Linewidth',10)
    hold on
    plot(t,right,'r','Linewidth',10)
    hold off
    title(side(i))
    xlim([min(t) max(t)])
    ylim([0 1.5])

    color = 'none';
    set(gca,'XColor',color,'YColor',color,'TickDir','out') 

end

%The different muscles
musc = ["TA_left" "TA_right" "SO_left" "SO_right" "MG_left" "MG_right" "VM_left" "VM_right" "RF_left" "RF_right" "BF_left" "BF_right"];
musclab = ["TA (mV)" NaN "SO (mV)" NaN "MG (mV)" NaN "VM (mV)" NaN "RF (mV)" NaN "BF (mV)" NaN];
time = [NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN "Time (s)" "Time (s)"];
color = ["b" "r" "b" "r" "b" "r" "b" "r" "b" "r" "b" "r"];


for i = 3:14
    Raw = [EMGdata_Raw.(musc{i-2})];
    S = smooth(abs(Lowpass(Highpass(Raw - mean(Raw),10),499)),100,'moving');
    
    subplot(7,2,i)
    plot(t,Raw,color(i-2))
    hold on
    plot(t,S,'k','Linewidth',1.5)
    hold off
    xlim([min(t) max(t)])
    
    if max(S) == 0
       warning(strcat("Data missing in ", musc(i-2)));
       ylim([-.01 .01])
    else
       ylim([-2*max(S) 2*max(S)])
    end
    
    ylabel(musclab(i-2))
    xlabel(time(i-2))
end

%Title for entire figure
sgtitle(strcat(subjectcode, '_', taskname))

%To save figure in fullscreen
g = gcf;
g.WindowState = 'maximized';

saveas(figure(1), strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', subjectcode, '\', subjectcode, '_', taskname, '_Summary.fig'));
saveas(figure(1), strcat('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', subjectcode, '\', subjectcode, '_', taskname, '_Summary.png'));

clear color;
clear g;
clear i;
clear left;
clear musc;
clear musclab;
clear Raw;
clear right;
clear S;
clear side;
clear t;
clear time;

end

