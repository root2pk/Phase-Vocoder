%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Ruthu Prem Kumar  Nov 2019
%                  Phase Vocoder
%
%
% Program to accept an audio signal and time stretch/
% compress it using a phase vocoder.
% Program also plots a spectrogram using an external
% function stored in another file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;close all;

%read in our WAV file, and store sample rate in Fs
[x,Fs]=audioread('Cath_short_clip.wav');

%in case of stereo, to mono
x = 0.5*sum(x,2);

%Frame length in seconds
Fr_len = 0.02;

%Time-stretch factor Q
Q = 1.2;

%Overlap factor Of
Of = 0.75;

%Frame length in samples
N = round(Fs*Fr_len);

%Hop size HA
HA = round(N*(1-Of));

%Making N a multiple of HA
N = HA/(1-Of);

%Synthesis Hop Size
HS = round(Q*HA);

%Hann window

t=[0:N-1];
win=0.5*(1-cos(2*pi*t/(N-1)));
win=win.';

%number of samples in input signal
L = length(x);

%Finding NFFT frame length (Nearest power of 2)

n=0;

while true
    if power(2,n)>=N
        NFFT = power(2,n);
        break;
    else
        n=n+1;
    end
end

%Creating zero vectors

phi_m=zeros(NFFT,1);
phi_m1=zeros(NFFT,1);
theta_m=zeros(NFFT,1);
theta_m1=zeros(NFFT,1);
omega_m=zeros(NFFT,1);
omega_m1=zeros(NFFT,1);

%Frequency bin

k=[0:NFFT-1];
omega_k(k+1)=2*pi*k/NFFT;

omega_k=omega_k.';

%Zero padding the start of the signal

x=x.';
x=[zeros(1,N) x];


% NF - total number of frames required
NF=floor((N+L)/HA);

%tot_samples = Total number of samples in final audio signal
tot_samples = (NF-1)*HA + N;

%number of additional samples required to zero pad
rem = tot_samples-(L+N);

%Zero padding
x=[x zeros(1,rem)];

%Making x a column vector
x=x.';

%Output vector y

y=zeros(N+((NF-1)*HS),1);

%Adding analysis frames to y

for m=0:NF-1

    %Start points for each frame
    nx=(HA*m)+1;
    ny=(HS*m)+1;


    %DFT of frame

    X=fft(x(nx:nx+N-1).*win,NFFT);
    Xmag = abs(X); Xang = angle(X);
    phi_m1 = Xang;

    %Calculating vector values
    omega_m1 = omega_k + ppa(phi_m1-phi_m-omega_k*HA)/HA;
    theta_m1 = theta_m + HS*omega_m1;
    Y = Xmag.*exp(1i*theta_m1);

    %Calculating ifft
    Y_inv = ifft(Y);

    %Truncating the ifft
    Y_inv = Y_inv(1:N);

    %Ensuring only real components pass
    Y_inv = real(Y_inv);

    %Synthesis
    y(ny:ny+N-1) = y(ny:ny+N-1) + Y_inv.*win;

    %Updating values for next loop
    phi_m = phi_m1;
    theta_m = theta_m1;
    omega_m = omega_m1;


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

subplot (3,1,2);


%Plot of output signal against time
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

%Playing output audio
soundsc(y,Fs);


%spectrogram for input signal
specto(x,N,Fs,Of);

%spectrogram for output signal
specto(y,N,Fs,Of);



