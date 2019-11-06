clear all
close all
clc
%%Selecting the necessary folder for processing and running a batch operation
% Specify the folder where the files live.
myFolder = ('D:\Ents\NG Challenge\data_wav');
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
uiwait(warndlg(errorMessage));
return;
end
ADS = audioDatastore(myFolder);
ADSnew = transform(ADS,@(x)mean(x,2));