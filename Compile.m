%Compiling the Excel sheets together
%File/trial names MUST follow normal naming guidelines (ex: FW 01 NOT FW 1)

clear
close all
clc

%Desired tasks
task = ["SS" "SS_C" "WWT_C"];

%Desired names for output Excel files
%Include ".xlsx"
%This will save to "P:\ClarkLab\Mind_in_Motion\Study Data\EMG" folder
fnameCCI = 'Compile_CCI.xlsx';
fnamePeak = 'Compile_PeakEMG.xlsx';

%Running the program
compileEMG(task, fnameCCI, fnamePeak)


