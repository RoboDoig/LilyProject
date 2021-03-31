clear all; close all; clc;

data = load('AH1024_datastruct.mat');
data = data.summary;
fs = 15.44;

% find highest performance trial
correctRate = [data.CorrectRate];
[m, maxIdx] = max(correctRate);
session = maxIdx;

% for that session plot fov, trial starts, trial ends
figure; hold on;
plot(data(session).c2FOVrigid, 'k');
trialStart = data(session).trialStart; scatter(trialStart, ones(1,length(trialStart)), 'r.');

% session = 1;
% 
% plot(data.summary(1).wholeFOVrigid-3000); hold on;
% plot(data.summary(1).c2FOVrigid-3000);
% nTrialStart = length(data.summary(1).trialStart);
% nWaterTime = length(data.summary(1).waterTime);
% 
% figure;
% scatter(data.summary(1).wholeFOVrigid-3000, data.summary(1).c2FOVrigid-3000);
