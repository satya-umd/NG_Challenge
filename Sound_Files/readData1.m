clear all
close all
clc
%%Selecting the necessary folder for processing and running a batch operation
% Specify the folder where the files live.
myFolder = ('D:\Ents\NG Challenge\data_wav');
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
SAMPLE_RATE = 16000
errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
uiwait(warndlg(errorMessage));
return;
end
% ADS = audioDatastore(myFolder);
ads = audioDatastore(myFolder);
adsTall = tall(ads)
aFE = audioFeatureExtractor('SampleRate',44.1e3, ...
    'melSpectrum',true, ...
    'barkSpectrum',true, ...
    'erbSpectrum',true, ...
    'linearSpectrum',true);

specsTall = cellfun(@(x)extract(aFE,returnMono(x)),adsTall,"UniformOutput",false);
specs = gather(specsTall);
fileNames = ads.Files;
labels = zeros(numel(fileNames),3);
for n = 1:numel(fileNames)
    
end
function [y,Fs] = returnMono(x)
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