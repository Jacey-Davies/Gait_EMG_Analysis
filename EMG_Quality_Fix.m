%Fixing the EMG errors in the Excel sheets

clear
close all
clc

%Input Excel sheet name for the quality checks
%Include ".xlsx"
qualityname = 'EMG_Quality_Fix.xlsx';

%Running the function
fixEMG(qualityname);