%% Lowpass filter----------------------------------------------------------

function y=Lowpass(x,fc)

if nargin<3, fs=1000; end; % Assume sampling frequency is 1 kHz.
[b,a]=butter(3,fc/(fs/2),'low');
y=filtfilt(b,a,x);