clear all; close all; clc;

%% params
fnames = {'AH1024_datastruct', 'AH1100_datastruct', 'AH1107_datastruct', 'AH1147_datastruct', 'AH1149_datastruct'};
fs = 15.44;
trialSkip = 30;

inputNames = {'lickTimesVec', 'poleOnsetVec', 'poleDownVec', 'alignInfoX', 'alignInfoY', 'waterTimesVec'};
windowSizes = [floor(5 * fs);...
               floor(1 * fs);...
               floor(1 * fs);...
               floor(1 * fs);...
               floor(1 * fs);...
               floor(5 * fs);];

%% leave one out
for i = 1:length(fnames)
   data = load([fnames{i}, '.mat']);
   
   % full model
   allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputNames, windowSizes);
   
   % drop model
   for j = 1:length(inputNames)
      allIdx = 1:length(inputNames); remainIdx = allIdx(allIdx~=j);
      inputs = inputNames(remainIdx);
      windows = windowSizes(remainIdx, :);
      
      allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputs, windows);
   end
end