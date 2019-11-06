clear all
close all
clc
%%Selecting the necessary folder for processing and running a batch operation
% Specify the folder where the files live.
myFolder = ('D:\Ents\NG Challenge\Sound_Files');
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
uiwait(warndlg(errorMessage));
return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.wav'); % Change to whatever pattern you need.
LS = dir(filePattern);

for k = 1 : length(LS);
  baseFileName = LS(k).name;
LungSounds = fullfile(myFolder, baseFileName);
fprintf(1, 'Now reading %s\n', LungSounds) 

[X, Fs] = audioread(LungSounds);


end