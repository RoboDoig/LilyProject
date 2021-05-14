clear all; close all; clc;

data = load('AH1024_datastruct.mat');
% data = load('AH1107_datastruct.mat');
data = data.summary;
fs = 15.44;
trialSkip = 30;

% find highest performance trial
correctRate = [data.CorrectRate];
[m, maxIdx] = max(correctRate);
% session = maxIdx;
session = 7;

% for that session get useful variables
dff = dffFromTrace(data(session).c2FOVrigid);
trialStart = data(session).trialStart(trialSkip:end);
trialEnd = data(session).trialEnd(trialSkip:end);
nTrials = length(trialStart);
trialMatrix = data(session).trialMatrix(trialSkip:end, :);
lickTimes = data(session).licks(trialSkip:end, :);
waterTime = data(session).waterTime(trialSkip: end);

figure; hold on;
plot(dff, 'k');
scatter(trialStart, ones(1,length(trialStart)), 'r.');

% split into trials
trialAligned = splitToTrials(dff', trialStart, trialEnd);

% parse trialMatrix (hit, miss, fa, cr)
trialOutcome = parseTrialMatrix(trialMatrix);

% plot all trials with variable timings
figure;
imagesc(trialAligned(30:end, 1:100))

% show responses for each trial type
hitTrials = trialAligned(trialOutcome==1, :);
missTrials = trialAligned(trialOutcome==2, :);
crTrials = trialAligned(trialOutcome==4, :);
faTrials = trialAligned(trialOutcome==3, :);

figure;
subplot(2,2,1); imagesc(hitTrials); title('HIT');
subplot(2,2,2); imagesc(missTrials); title('MISS');
subplot(2,2,3); imagesc(crTrials); title('CR');
subplot(2,2,4); imagesc(faTrials); title('FA');

figure; hold on;
shadedErrorBar(1:size(hitTrials, 2), nanmean(hitTrials), nansem(hitTrials), 'lineprops', 'b', 'transparent', 1);
shadedErrorBar(1:size(missTrials, 2), nanmean(missTrials), nansem(missTrials), 'lineprops', 'k', 'transparent', 1);
shadedErrorBar(1:size(crTrials, 2), nanmean(crTrials), nansem(crTrials), 'lineprops', 'r', 'transparent', 1);
shadedErrorBar(1:size(faTrials, 2), nanmean(faTrials), nansem(faTrials), 'lineprops', 'g', 'transparent', 1);

%% GLM
% creat GLM Matrix
% nFrames = 100;
% startTrial = 30;
% 
% % glm input - nobs x nvars (trials x vars)
% % glm output - nobs
% trialOutcome = trialOutcome(startTrial:end)';
% trialOneHot = trialMatrix(startTrial:end, :);
% lickTimes = lickTimes(startTrial:end, :);
% nLicks = cellfun(@length, lickTimes);
% X = [trialOutcome nLicks];
% 
% meanResponse = nanmean(trialAligned(startTrial:end, 1:nFrames), 2);
% y = meanResponse;
% 
% fit = glmnet(X, y);
% glmnetPrint(fit);
 
% % show licks + response
% figure; hold on;
% imagesc(trialAligned);
% 
% for i = 1:size(lickTimes, 1)
%     lickFrames = lickTimes{i}*fs;
%     scatter(lickFrames, repmat(i, 1, length(lickFrames)), 'b.');
% end
% 
% % show responses for each trial type;
% figure;
% subplot(2,2,1); imagesc(trialAligned(trialOutcome==1, :)); title('HIT');
% subplot(2,2,2); imagesc(trialAligned(trialOutcome==2, :)); title('MISS');
% subplot(2,2,3); imagesc(trialAligned(trialOutcome==4, :)); title('CR');
% subplot(2,2,4); imagesc(trialAligned(trialOutcome==3, :)); title('FA');



