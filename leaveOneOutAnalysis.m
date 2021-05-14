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
devExplained = nan(length(fnames), length(inputNames)+1);
for i = 1:length(fnames)
   data = load([fnames{i}, '.mat']);
   
   % full model
   allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputNames, windowSizes);
   meanDevs = max(cellfun(@(x) x.fit.dev(end), allSessions));
   devExplained(i, end) = meanDevs;
   
   % drop model
   for j = 1:length(inputNames)
      allIdx = 1:length(inputNames); remainIdx = allIdx(allIdx~=j);
      inputs = inputNames(remainIdx);
      windows = windowSizes(remainIdx, :);
      
      allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputs, windows);
      meanDevs = max(cellfun(@(x) x.fit.dev(end), allSessions));
      devExplained(i, j) = meanDevs;
   end
end

%% plotting
figure; hold on;
bar(nanmean(devExplained), 'k')
errorbar(1:length(inputNames)+1, nanmean(devExplained), nanstd(devExplained)./sqrt(length(fnames)), 'k.');
modelNames = inputNames; modelNames{end+1} = 'fullModel';
xticks(1:7)
xticklabels(modelNames); xtickangle(45)