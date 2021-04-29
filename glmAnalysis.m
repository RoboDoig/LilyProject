clear all; close all; clc;

%% load animal data
data = load('AH1024_datastruct.mat');
data = data.summary;
fs = 15.44;
trialSkip = 30;

%% extract session variables
session = 5;
dff = dffFromTrace(data(session).c2FOVrigid);
tAxis = (1:length(dff))./fs;
trialStart = data(session).trialStart(trialSkip:end)./fs;
trialEnd = data(session).trialEnd(trialSkip:end)./fs;
nTrials = length(trialStart);
trialMatrix = data(session).trialMatrix(trialSkip:end, :);
lickTimesRelative = data(session).licks(trialSkip:end, :);
waterTime = data(session).waterTime(trialSkip: end);
skipStartFrame = floor(trialStart(1)*fs);

% get absolute lick times
lickTimes = [];
for i = 1:length(trialStart)
    thisTrialLicks = lickTimesRelative{i}';
    lickTimes = [lickTimes, thisTrialLicks+trialStart(i)];
end

% vectorize lick times
lickTimesVec = zeros(1, length(dff));
for i = 1:length(lickTimes)
    vecPoint = find(tAxis>=lickTimes(i), 1);
    lickTimesVec(vecPoint) = 1;
end

% plot timings
figure; hold on;
plot(tAxis, dff, 'k');
plot(tAxis, lickTimesVec, 'b');
plot([tAxis(skipStartFrame) tAxis(skipStartFrame)], [0, 1], 'g--')
scatter(trialStart, ones(1,length(trialStart)), 'r.');
scatter(lickTimes, ones(1,length(lickTimes)), 'b.');

%% GLM
d = floor(20 * fs); % window size for design matrix

y = dff;

% designMatrix
designMatrix = nan(length(skipStartFrame:length(y)), d);
c = 1;
for i = skipStartFrame:length(y)
    lickWindow = lickTimesVec((i-d+1):i);
    designMatrix(c, :) = lickWindow;
    
    c = c+1;
end

figure;
imagesc(designMatrix(1:1000, :));

fit = glmnet(designMatrix, y(skipStartFrame:end));
glmnetPrint(fit);
yHat = glmnetPredict(fit, designMatrix);

trueY = y(skipStartFrame:end);
yHat = yHat(:, end);
lickVec = lickTimesVec(skipStartFrame:end);
t = tAxis(skipStartFrame:end);

figure; hold on;
plot(t, trueY, 'k');
plot(t, yHat, 'r');

figure; hold on;
scatter(yHat(:, end), y(skipStartFrame:end), 'k.');
[h, p] = corrcoef(yHat(:, end), y(skipStartFrame:end));
title(['R^2 = ', num2str(h(1,2)), ' p = ', num2str(p(1,2))])

figure; hold on;
plot(flipud(fit.beta(:, end)), 'r');
