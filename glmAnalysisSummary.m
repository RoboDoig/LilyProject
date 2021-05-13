clear all; close all; clc;

%% params
fname = 'AH1024_datastruct';
% fname = 'AH1100_datastruct';
% fname = 'AH1107_datastruct';
% fname = 'AH1110_datastruct';
% fname = 'AH1147_datastruct';
% fname = 'AH1148_datastruct';
% fname = 'AH1149_datastruct';
% fname = 'AH1151_datastruct';

data = load([fname, '.mat']);
fs = 15.44;
trialSkip = 30;

inputNames = {'lickTimesVec', 'poleOnsetVec', 'poleDownVec', 'alignInfoX', 'alignInfoY', 'waterTimesVec'};
windowSizes = [floor(5 * fs);...
               floor(1 * fs);...
               floor(1 * fs);...
               floor(1 * fs);...
               floor(1 * fs);...
               floor(5 * fs);]; % window sizes for design matrix

allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputNames, windowSizes);

%% plot summary
% deviance explained
devs = cellfun(@(x) x.fit.dev(end), allSessions);
cr = cellfun(@(x) x.sessionStruct.correctRate, allSessions);
figure; subplot(1,2,1); plot(devs); subplot(1,2,2); scatter(cr, devs);

% mean response functions
nSessions = length(allSessions);
nInputs = length(inputNames);
stackResponseFunctions = cell(1, nInputs);
figure;
for i = 1:nSessions
    for j = 1:nInputs
        subplot(1, nInputs, j); hold on;
        plot((1:length(allSessions{i}.responseFunctions{j}))./fs, allSessions{i}.responseFunctions{j}, 'k');
        stackResponseFunctions{j} = [stackResponseFunctions{j}; allSessions{i}.responseFunctions{j}'];
    end
end
for j = 1:nInputs
   subplot(1, nInputs, j);
   plot((1:length(allSessions{i}.responseFunctions{j}))./fs, mean(stackResponseFunctions{j}), 'r', 'LineWidth', 1.5);
   ylim([-0.1, 0.15])
   title(inputNames{j});
end
