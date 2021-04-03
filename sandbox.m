clear all; close all; clc;

data = load('AH1024_datastruct.mat');
data = data.summary;
fs = 15.44;

% find highest performance trial
correctRate = [data.CorrectRate];
[m, maxIdx] = max(correctRate);
session = maxIdx;

% for that session get useful variables
dff = dffFromTrace(data(session).c2FOVrigid);
trialStart = data(session).trialStart;
trialEnd = data(session).trialEnd;
nTrials = length(trialStart);
trialMatrix = data(session).trialMatrix;

figure; hold on;
plot(dff, 'k');
scatter(trialStart, ones(1,length(trialStart)), 'r.');

% split into trials
trialAligned = splitToTrials(dff', trialStart, trialEnd);

figure;
imagesc(trialAligned(30:end, :));

% parse trialMatrix (hit, miss, fa, cr)
trialOutcome = nan(1, nTrials);
for i = 1:nTrials
    trialOutcome(i) = find(trialMatrix(i, :)==1);
end

