clear all; close all; clc;

%% params
fname = 'AH1024_datastruct';
% fname = 'AH1100_datastruct';
% fname = 'AH1107_datastruct';
% fname = 'AH1147_datastruct';
% fname = 'AH1149_datastruct';

% % fname = 'AH1110_datastruct';
% % fname = 'AH1148_datastruct';
% % fname = 'AH1151_datastruct';

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
           
% inputNames = {'poleOnsetVec'};
% windowSizes = [floor(5 * fs)]; % window sizes for design matrix

allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputNames, windowSizes);

%% plot summary
% deviance explained
devs = cellfun(@(x) x.fit.dev(end), allSessions);
cr = cellfun(@(x) x.sessionStruct.correctRate, allSessions);
figure; subplot(1,2,1); plot(devs); subplot(1,2,2); scatter(cr, devs);

% show reconstructed for best fit
[m, I] = max(devs);
figure; hold on;
plot(allSessions{I}.t, allSessions{I}.trueY, 'k');
plot(allSessions{I}.t, allSessions{I}.yHat, 'r');

figure;
plot(allSessions{I}.t, allSessions{I}.trueY -  allSessions{I}.yHat, 'k');

% mean response functions
nSessions = length(allSessions);
nInputs = length(inputNames);
stackResponseFunctions = cell(1, nInputs);
figure('Renderer', 'painters', 'Position', [500 500 1300 200])
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

%% trace subtraction, alignment
fullTraceLength = length(allSessions{I}.sessionStruct.dff);
subTrace = [nan(fullTraceLength - length(allSessions{I}.trueY), 1); allSessions{I}.trueY - allSessions{I}.yHat]';

trialAligned = splitToTrials(subTrace, allSessions{I}.sessionStruct.trialStart.*fs, allSessions{I}.sessionStruct.trialEnd.*fs);

trialOutcome = parseTrialMatrix(allSessions{I}.sessionStruct.trialMatrix);

% show responses for each trial type
hitTrials = trialAligned(trialOutcome==1, :);
missTrials = trialAligned(trialOutcome==2, :);
if size(missTrials, 1) < 2
   missTrials = [missTrials; missTrials]; 
end
crTrials = trialAligned(trialOutcome==4, :);
if size(crTrials, 1) < 2
   crTrials = [crTrials; crTrials]; 
end
faTrials = trialAligned(trialOutcome==3, :);

figure; hold on;
shadedErrorBar((1:size(hitTrials, 2))./fs, nanmean(hitTrials), nansem(hitTrials), 'lineprops', 'g', 'transparent', 1);
shadedErrorBar((1:size(crTrials, 2))./fs, nanmean(crTrials), nansem(crTrials), 'lineprops', 'b', 'transparent', 1);
shadedErrorBar((1:size(faTrials, 2))./fs, nanmean(faTrials), nansem(faTrials), 'lineprops', 'r', 'transparent', 1);
shadedErrorBar((1:size(missTrials, 2))./fs, nanmean(missTrials), nansem(missTrials), 'lineprops', 'm', 'transparent', 1);



