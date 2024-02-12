
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Ruthu Prem Kumar  Nov 2019
%                  Basic Time Stretcher
%
%
% Program to accept an audio signal and time stretch/
% compress it using simple analysis and synthesis frames
%
% Program also plots a spectrogram using an external
% function stored in another file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;close all;

%read in our WAV file, and store sample rate in Fs
[x,Fs]=audioread('cath_short_clip.wav');

%in case of stereo, to mono
x = 0.5*sum(x,2);

%Frame length in seconds
Fr_len = 0.02;

%Time-stretch factor Q
Q = 1.0;

%Overlap factor Of
Of = 0.75;

%frame length in samples
N = round(Fs*Fr_len);

%Hop size HA
HA = round(N*(1-Of));

%Making sure N is a multiple of HA
N = HA/(1-Of);

%Synthesis Hop Size
HS = round(Q*HA);

%Hann window

t=[0:N-1];

win=0.5*(1-cos(2*pi*t/N));
win=win.';

%number of samples in input signal
L = length(x);

%Zero padding the start of the signal

x=x.';
x=[zeros(1,N) x];


%Finding the number of additional samples required to zero pad the end

%NF - Total number of frames
NF=floor((N+L)/HA);

%Total number of samples in final audio signal
tot_samples = (NF-1)*HA + N;

%number of additional samples required to zero pad
remainder = tot_samples-(L+N);

%Zero padding
x=[x zeros(1,remainder)];

%Returning x to a column vector
x=x.';

%Output vector y

y=zeros(N+((NF-1)*HS),1);

%Adding analysis frames to y

for m=0:NF-1

    nx=(HA*m)+1;
    ny=(HS*m)+1;
    y(ny:ny+(N-1)) = y(ny:ny+(N-1)) + (x(nx:nx+(N-1)).*win).*win;


end

%Normalizing y

y = (y/max(abs(y)))*max(abs(x));

%plots to compare
%Plot of input signal against time
figure(1);
subplot(3,1,1);
t1=[1:1/Fs:(length(x)/Fs)+1-(1/Fs)];
plot(t1,x);
xlabel('Time(s)');
ylabel('Amplitude');
title('Input');

%Plot of output signal against time
subplot (3,1,2);

t2=[1:1/Fs:(length(y)/Fs)+1-(1/Fs)];
plot(t2,y);
xlabel('Time(s)');
ylabel('Amplitude');
title('Output');

%For the special case Q=1, ensure perfect reconstruction.
if Q==1
    error = abs(x-y);
    subplot (3,1,3);

    plot(t1,error);
    xlabel('Time(s)');
    ylabel('Absolute difference');
    title('|x-y| vs. time');
end

%Play Output audio signal
soundsc(y,Fs);

%spectrogram for input signal
specto(x,N,Fs,Of);

%spectrogram for output signal
specto(y,N,Fs,Of);







