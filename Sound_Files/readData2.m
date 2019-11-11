clear all
close all
clc
%%Selecting the necessary folder for processing and running a batch operation
% Specify the folder where the files live.
myFolder = ('D:\Ents\NG Challenge\data_wav_single');
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
    'melSpectrum',true);

specsTall = cellfun(@(x)extract(aFE,returnMono(x)),adsTall,"UniformOutput",false);
specs = gather(specsTall);
fileNames = ads.Files;
labels = categorical(zeros(numel(fileNames)));
for n = 1:numel(fileNames)
    splitFiles =  split(fileNames(n),["classes_",",_"]);
%     labels(n, str2num(splitFiles{2}))=categorical(1);
%       if(size(str2num(splitFiles{2}),2)==1)
          labels(n)=categorical(str2num(splitFiles{2}));
%       end
      
end


Xt = cat(3, specs{:});
[segments, features, samples] = size(Xt);
X1 = reshape(Xt, [segments, features, 1, samples]);
cv = cvpartition(samples,'HoldOut',0.3);
idx = cv.test;
dataTrain = X1(:,:,:,~idx);
dataTest  = X1(:,:,:,idx);
YTrain = labels(~idx);
YTest = labels(idx);
layers = [ ...
    imageInputLayer([segments features])
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numel(categories(labels)))
    softmaxLayer
    classificationLayer
    ];
% options = trainingOptions('sgdm');
  options = trainingOptions("adam", ...
    "MaxEpochs",15, ...
    "InitialLearnRate",1e-5,...
    "MiniBatchSize",128, ...
    "Shuffle","every-epoch", ...
    "Plots","training-progress", ...
    "Verbose",false, ...
    "LearnRateSchedule","piecewise", ...
    "LearnRateDropFactor",0.5, ...
    "LearnRateDropPeriod",1);
net = trainNetwork(dataTrain,YTrain,layers,options);


function [y,Fs] = returnMono(x)
    [m, n] = size(x); %gives dimensions of array where n is the number of stereo channels
    maxR=8205696;
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
    y = [y', zeros(1, maxR - length(y))];
    y = y';
end