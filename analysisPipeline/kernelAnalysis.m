clear all; close all; clc;

%% load data, select animal, structure
% fname = 'AH1100_datastruct';
% fname = 'AH1107_datastruct';
% fname = 'AH1147_datastruct';
% fname = 'AH1149_datastruct';
% fname = 'AH1151_datastruct';
% fname = 'AH1110_datastruct';
% fname = 'AH1148_datastruct';

% fname = 'AH1024_datastruct';
% data = load([fname, '.mat']);

masterFile = ('MasterMouse.mat');
data = masterFile.M(2);

%% data preparation
% normalize any fields that are particularly large
data = normalizeData01(data, 'amplitude');
data = normalizeData01(data, 'theta');
data = normalizeData01(data, 'setpoint');
data = normalizeData01(data, 'phase');

% pick 'full data' sessions
hasFA = arrayfun(@(x) sum(x.trialMatrix(:, 3)), data.summary); % where false alarm trials are present
hasWhisker = arrayfun(@(x) length(x.theta) > 0, data.summary); % where whisker data is present
% indices of full data sessions
goodSessionIndex = find([data.summary.hasWhisker] == 1 & [data.summary.hasScopolamine] == 0 & [data.summary.polePresent] == 1 & hasFA>0 & hasWhisker>0);
% which of these are early vs. late sessions
earlySessionIndex = goodSessionIndex(1:3);
lateSessionIndex = goodSessionIndex(end-2:end);
% clip to only this data
data.summary = data.summary([earlySessionIndex, lateSessionIndex]);
fs = [15.44, 311]; % 2p fs, whisker fs
trialSkip = 30; % skip initial fluorescence to avoid decay period

%% GLM preparation and training
inputNames = {'firstLickTimesVec', 'otherLickTimesVec', 'poleOnsetVec', 'poleDownVec', 'waterTimesVec', 'amplitudeVec'};
nInputs = length(inputNames);
windowSizes = [45; 45; 45; 45; 45; 45; 5]; % window sizes for design matrix
timeLags =  [0; 0; 0; 0; 0; 0; -10]; % time lags for each window

allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputNames, windowSizes, timeLags);
nSessions = length(allSessions);

%% reset figures
close all;
earlySessionIndex = 1:3;
lateSessionIndex = 4:6;
fs = fs(1);

%% Example traces and predictions
sI = 3;
window = find(allSessions{earlySessionIndex(sI)}.t > 340, 1):find(allSessions{earlySessionIndex(sI)}.t > 650, 1);
figure;
subplot(2,1,1); hold on;
plot(allSessions{earlySessionIndex(sI)}.t(window), allSessions{earlySessionIndex(sI)}.lickVec(window), 'b');
plot(allSessions{earlySessionIndex(sI)}.t(window), allSessions{earlySessionIndex(sI)}.trueY(window), 'k');
plot(allSessions{earlySessionIndex(sI)}.t(window), allSessions{earlySessionIndex(sI)}.yHat(window), 'r');
xlim([340 600])
ylabel('dF/F');
subplot(2,1,2); hold on;
plot(allSessions{lateSessionIndex(sI)}.t(window), allSessions{lateSessionIndex(sI)}.lickVec(window), 'b');
plot(allSessions{lateSessionIndex(sI)}.t(window), allSessions{lateSessionIndex(sI)}.trueY(window), 'k');
plot(allSessions{lateSessionIndex(sI)}.t(window), allSessions{lateSessionIndex(sI)}.yHat(window), 'r');
xlabel('Time (s)'); ylabel('dF/F');
xlim([340 600])

%% response functions per session
figure;
maxVals = zeros(1, nInputs);
for i = 1:nSessions
    for j = 1:nInputs
       subplot(1, nInputs, j); hold on;
       plot((1:length(allSessions{i}.responseFunctions{j}))./fs, allSessions{i}.responseFunctions{j}, 'Color', [i/nSessions, 0, 0]);
       if max(allSessions{i}.responseFunctions{j}) > maxVals(j)
            maxVals(j) = max(allSessions{i}.responseFunctions{j});
       end
       ylim([-0.05 maxVals(j)*1.5])
       xlabel('Event Time (s)'); ylabel('Beta'); axis square; title(inputNames{j});
    end
end

%% kernel importance analysis
figure;
for j = 1:nInputs
    responseIntegral = nan(1, nSessions);
    for i = 1:nSessions
        thisResponseFunction = allSessions{i}.responseFunctions{j};
        responseIntegral(i) = mean(abs(thisResponseFunction));
    end
    subplot(1, nInputs, j); hold on;
    scatter(ones(1,3), responseIntegral(1:3), 'k');
    errorbar(1, mean(responseIntegral(1:3)), std(responseIntegral(1:3)), 'k');
    scatter(ones(1,3)*2, responseIntegral(4:6), 'r');
    errorbar(2, mean(responseIntegral(4:6)), std(responseIntegral(4:6)), 'r');
    
    [h, p] = ttest2(responseIntegral(1:3), responseIntegral(4:6));
    
    xlim([0.5 2.5])
    ylim([-0.01 max(responseIntegral)*1.5])
    axis square
    title([inputNames{j} , ": ", num2str(p)]);
end