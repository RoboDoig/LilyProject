clear all; close all; clc;

%% params
data = load('AH1024_datastruct.mat');
sessionIdx = 7;
fs = 15.44;
trialSkip = 30;

%% extract session variables
sessionStruct = extractSessionInformation(data.summary, sessionIdx, fs, trialSkip, 1);

%% GLM
inputVectors = [sessionStruct.lickTimesVec; sessionStruct.poleOnsetVec; sessionStruct.alignInfoX'; sessionStruct.alignInfoY'];
windowSizes = [floor(20 * fs); floor(10 * fs); floor(10 * fs); floor(10 * fs)]; % window sizes for design matrix

responseVector = sessionStruct.dff; % response vector;
startFrame = sessionStruct.skipStartFrame;
endFrame = length(responseVector);

[fit, fullDesignMatrix, y, yHat] = buildGLM(inputVectors, windowSizes, responseVector, startFrame, endFrame, 1);

%% GLM - Plot
trueY = y(startFrame:endFrame);
yHat = yHat(:, end);
lickVec = sessionStruct.lickTimesVec(startFrame:endFrame);
t = sessionStruct.tAxis(startFrame:endFrame);

% plot true and predicted
figure; hold on;
plot(t, trueY, 'k');
plot(t, yHat, 'r');
% plot(t, -lickVec, 'b');

% plot RFs for each input
cT = [0 cumsum(windowSizes)'];
figure;
for i = 1:size(inputVectors, 1)
   subplot(1, size(inputVectors, 1), i);
   rf = flipud(fit.beta((cT(i)+1):cT(i+1), end));
   plot((1:length(rf))./fs, rf, 'k');
end