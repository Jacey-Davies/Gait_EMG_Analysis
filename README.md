# Gait_EMG_Analysis
This repository contains the code I developed to analyze EMG data for the "Mind in Motion" study by the UF Locomotor Neuroscience Lab. It also includes example input and output files. The code is very specific to the files on the lab drive.


The functions and what they do:

Highpass : Acts as a high-pass filter

Lowpass : Acts as a low-pass filter

readEMG : Finds and reads the EMG data text file for the given subject and puts it into a structure; outputs the raw data, linear envelope, and normalized linear envelope; calculates the co-contraction index (CCI) and peak EMG amplitude for each bin of each muscle of each leg for each gait cycle (see "EMGdata organization" and "Gait Cycle Bin")

posterEMG : Creates a "poster" showing the raw EMG signal and linear envelope for each leg and each muscle; exports this as a MATLAB figure and a png file (see "H1001_FW 01_Summary")

CCI_Excel : Exports the CCI values into an Excel sheet (see "H1001_FW 01_EMGdata_CCI")

peakEMG_Excel : Exports the peak EMG values into an Excel sheet (see "H1001_FW 01_EMGdata_PeakEMG")

fixEMG : Uses a given quality check file (see "EMG_Quality_Fix") and turns the CCI and peak EMG data for the given subjects, legs, and muscles into zeros

compileEMG : Compiles all of the CCI and peak EMG data for all of the subjects for all of the given tasks into a single Excel sheet; be warned that this can create massive files for even just a couple of tasks; the compiled Excel sheet for the CCI data is not given here because it was too big 


The scripts and what they do:

EMG_Analysis : Runs readEMG, posterEMG, CCI_Excel, and peakEMG_Excel for given subject

EMG_Quality_Fix : Runs fixEMG for given quality check file

Compile : Runs compileEMG for given tasks
