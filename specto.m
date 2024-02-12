%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Ruthu Prem Kumar  Nov 2019
%              Spectrogram Function
%
%
% Function to accept an mono signal, frame length in
% samples, sample rate and overlap factor and plot its
% corresponding spectrogram.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = specto(x,N,Fs,Of)


    %Total no. of samples in x

    tot_samples = length(x);

    %Hann window
    n=[1:N];
    win(n) = 0.5*(1-cos(2*pi*(n-1)/N));
    win=win.';

    %Hop size HA
    HA = round(N*(1-Of));

    %Ensuring N is a multiple of HA
    N = HA/(1-Of);

    %Finding the nearest power of 2 to calculate NFFT
    n=0;

    while true
        if power(2,n)>=N
            NFFT = power(2,n);
            break;
        else
            n=n+1;
        end
    end

    %Total no. of frames

    NF = floor(((length(x)-N)/HA)+1);

    %Defining the array for frames to be written into
    comp_array = zeros(NFFT,NF);

    %Analysing each frame and adding to the array
    for m=0:NF-1

        nx=(m*HA)+1;
        comp_array(:,m+1) = fft(x(nx:nx+N-1).*win,NFFT);

    end

    %length of signal in seconds
    xlen = tot_samples/Fs;

    % calculation of the time vector and frequency vector(Upto Nyquist point)
    points = [0:NF-1];
    time_vector = xlen*points/(NF-1);
    points = [0:NFFT-1];
    frequency_vector = (Fs/2)*points/(NFFT-1);

    %Scaling to dB

    S = 20*log10(abs(comp_array));

    %Spectogram

    figure;   %To create a new figure

    im = image(time_vector,frequency_vector, S,'CDataMapping','scaled');
    set(gca,'YDir','normal');   %So that frequency is ascending upwards
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title({'Spectrogram',['Frame length = ' num2str(N/Fs) 's'],['Overlap Percentage = ' num2str(Of*100) '%']});

    hcol = colorbar;
    ylabel(hcol, 'Magnitude (dB)');
    caxis([max(S(:))-60 max(S(:))]);


end




