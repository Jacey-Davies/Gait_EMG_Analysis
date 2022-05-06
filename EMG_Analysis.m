%EMG Processing
%Coded by Jacey Davies
%Last updated 11/11/2021

%Close all windows and clear old variables
close all;
clear;
clc;

%Loading the given data
subjectcode = 'H1001'; %Enter subject code here ex: "H1001" from H1001_FW 01_EMGdata.txt 
taskname = 'FW 01'; %Enter task name here, ex: "FW 01" from H1001_FW 01_EMGdata.txt

[EMGdata_Raw,EMGdata,EMGdata_Norm] = readEMG(subjectcode,taskname);

mkdir('P:\ClarkLab\Mind_in_Motion\Study Data\EMG\', subjectcode);

CCI_Excel(subjectcode,taskname,EMGdata,EMGdata_Norm);

peakEMG_Excel(subjectcode,taskname,EMGdata,EMGdata_Norm);
%EMGdata_Raw is the data and labels straight from the txt document

%EMGdata is the non-normalized processed data sorted into bins
%EMGdata_Norm is the normalized processed data sorted into bins

%EMGdata and EMGdata_Norm are structured as follows:
%Gait Cycle > Left or right leg > Muscle > Bin > Data or Co-contraction
%values > What muscle it is being compared against

%Ex: EMGdata(1).left.TA.bin1.CCI.SO
%For the contraction values of the left TA muscle compared to the SO muscle 
%for the first bin of the first gait cycle for the non-normalized data

%Please see function files for more information

%Making the poster graphs
posterEMG(EMGdata_Raw,subjectcode,taskname);

