clear all
close all
clc
%%Selecting the necessary folder for processing and running a batch operation
% Specify the folder where the files live.
myFolder = ('D:\NG-Challenge\NG_Challenge-master_sounds\NG_Challenge-master\Sound_Files');
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
SAMPLE_RATE = 16000
errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
uiwait(warndlg(errorMessage));
return;
end

filePattern = fullfile(myFolder, '*.wav'); % Change to whatever pattern you need.
LS = dir(filePattern);
sizeMatrix = [0 0];
for k = 1 : length(LS);
    baseFileName = LS(k).name;
    LungSounds = fullfile(myFolder, baseFileName); 
    [y,Fs] = audioread(LungSounds);
    Fs2 = 96000;
    audiowrite(LungSounds,y,Fs2);
    [audioIn,myFs] = audioread(LungSounds);
    fprintf(1, 'Original Fs = %d, myFs = %d\n', Fs,myFs);
    [m, n] = size(audioIn); %gives dimensions of array where n is the number of stereo channels
    if n == 2
        y = audioIn(:, 1) + audioIn(:, 2); %sum(y, 2) also accomplishes this
        peakAmp = max(abs(y)); 
        y = y/peakAmp;
        %  check the L/R channels for orig. peak Amplitudes
        peakL = max(abs(audioIn(:, 1)));
        peakR = max(abs(audioIn(:, 2))); 
        maxPeak = max([peakL peakR]);
        %apply x's original peak amplitude to the normalized mono mixdown 
        y = y*maxPeak;

    else
        y = audioIn; %it is stereo so we will return it as is (e.g., for additional processing)
    end
    %x1 = size(y,2)
    %S = melSpectrogram(y,myFs);
    
    S = melSpectrogram(y,myFs, ...
               'WindowLength',2048,...
               'OverlapLength',1024, ...
               'NumBands',32);
    sizeMatrix = [sizeMatrix; size(S)]
    [numBands,numFrames] = size(S);
    aFE = audioFeatureExtractor("SampleRate",myFs, ...
    "melSpectrum",true);
    features = extract(aFE,y);
    idx = info(aFE);
    %features = (features - mean(features,1))./std(features,[],1);
    size(features);
    %melSpect =  preProcess(y,Fs);
    %size(melSpect);
end

% ADS = audioDatastore(myFolder);
%ads = audioDatastore(myFolder);
%info(ads)
%adsTall = tall(y);


 
cellData = num2cell(y);

specsTall = cellfun(@(feature) (extract(aFE,y)),cellData,"UniformOutput",false);
specs = gather(specsTall);
fileNames = ads.Files;
labels = zeros(numel(fileNames),3);
% 
% for n = 1:numel(fileNames)
%     [AudioIn,fs] = audioread(fileNames(n))
%     features = extract(aFE,AudioIn)
% end
% idx = info(aFE)
function [m,n] = returnMono(x)
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


function melSpect =  preProcess(data,fs)
    resampled_data = resample(data, fs, 16000);
    size(data);
    melSpect = mfcc(resampled_data,16000);
end
