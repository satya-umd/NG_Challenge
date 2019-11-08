clear all
close all
clc
%%Selecting the necessary folder for processing and running a batch operation
% Specify the folder where the files live.
myFolder = ('D:\Ents\NG Challenge\Sound_Files');
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
SAMPLE_RATE = 16000
errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
uiwait(warndlg(errorMessage));
return;
end
% ADS = audioDatastore(myFolder);
% ADSnew = transform(ADS,@(x)mean(x,2));
% maxn =0;

% while hasdata(ADSnew)
%     audio = read(ADSnew);
%     maxn = max(maxn,size(audio,1));
% end
filePattern = fullfile(myFolder, '*.wav'); % Change to whatever pattern you need.
LS = dir(filePattern);
maxR=2205696;
for k = 1 : length(LS);
    baseFileName = LS(k).name;
    LungSounds = fullfile(myFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', LungSounds) 
    [y,Fs] = returnMono(LungSounds);
%     maxR = max(maxR, size(y,1));
    y = [y', zeros(1, maxR - length(y))];
%     maxR = max(maxR, size(y,1));
    y = y';
    melSpect =  preProcess(y,Fs);
    size(melSpect)
end

function melSpect =  preProcess(data,fs)
    resampled_data = resample(data, fs, 16000);
    size(data)
    melSpect = mfcc(resampled_data,16000);
%     melSpect = melSpectrogram(resampled_data, 16000, ...
%            'WindowLength',2048,...
%            'OverlapLength',1024, ...
%            'FFTLength',4096, ...
%            'NumBands',64, ...
%            'FrequencyRange',[62.5,8e3]);

end
function [y,Fs] = returnMono(sound)
[x, Fs] = audioread(sound,'double');
    
    [m, n] = size(x); %gives dimensions of array where n is the number of stereo channels
    if n == 2
        y = x(:, 1) + x(:, 2); %sum(y, 2) also accomplishes this
        peakAmp = max(abs(y)); 
        y = y/peakAmp;
        %  check the L/R channels for orig. peak Amplitudes
        peakL = max(abs(x(:, 1)));
        peakR = max(abs(x(:, 2))); 
        maxPeak = max([peakL peakR]);
        %apply x's original peak amplitude to the normalized mono mixdown 
        y = y*maxPeak;

    else
        y = x; %it is stereo so we will return it as is (e.g., for additional processing)
    end
end
