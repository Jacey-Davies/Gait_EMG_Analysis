%% Highpass filter---------------------------------------------------------
function y=Highpass(x,fc)

if nargin<3, fs=1000; end; % Assume sampling frequency is 1 kHz.
[b,a]=butter(3,fc/(fs/2),'high');
y=filtfilt(b,a,x);

