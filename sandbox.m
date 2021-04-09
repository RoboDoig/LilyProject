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
lickTimes = data(session).licks;
waterTime = data(session).waterTime;

figure; hold on;
plot(dff, 'k');
scatter(trialStart, ones(1,length(trialStart)), 'r.');

% split into trials
trialAligned = splitToTrials(dff', trialStart, trialEnd);

% parse trialMatrix (hit, miss, fa, cr)
trialOutcome = parseTrialMatrix(trialMatrix);

% cut out initial trials
trialAligned = trialAligned(30:end, :);
trialOutcome = trialOutcome(30:end);
lickTimes = lickTimes(30:end);

% show licks + response
figure; hold on;
imagesc(trialAligned);

for i = 1:size(lickTimes, 1)
    lickFrames = lickTimes{i}*fs;
    scatter(lickFrames, repmat(i, 1, length(lickFrames)), 'b.');
end

% show responses for each trial type;
figure;
subplot(2,2,1); imagesc(trialAligned(trialOutcome==1, :)); title('HIT');
subplot(2,2,2); imagesc(trialAligned(trialOutcome==2, :)); title('MISS');
subplot(2,2,3); imagesc(trialAligned(trialOutcome==4, :)); title('CR');
subplot(2,2,4); imagesc(trialAligned(trialOutcome==3, :)); title('FA');



