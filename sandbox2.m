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
hasFA = arrayfun(@(x) sum(x.trialMatrix(:, 3)), data.summary);
goodSessionIndex = find([data.summary.hasWhisker] == 1 & [data.summary.hasScopolamine] == 0 & [data.summary.polePresent] == 1 & hasFA>0);
earlySessionIndex = goodSessionIndex(1:3);
lateSessionIndex = goodSessionIndex(end-2:end);
fs = 15.44;
trialSkip = 30;

inputNames = {'lickTimesVec', 'alignInfoX', 'alignInfoY', 'poleDownVec'};
nInputs = length(inputNames);
windowSize = [30; 30; 30; 30]; % window sizes for design matrix

allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputNames, windowSize);
nSessions = length(allSessions);

%% response functions per session
figure;
for i = 1:nSessions
    for j = 1:nInputs
       subplot(1, nInputs, j); hold on;
       plot(allSessions{i}.responseFunctions{j}, 'Color', [i/nSessions, 0, 0]);
       ylim([-0.05 0.16])
       xlabel('Frame'); ylabel('Beta'); title(inputNames{j});
    end
end

%% example trace
figure;
subplot(2,1,1)
plot(allSessions{lateSessionIndex(1)}.t, allSessions{lateSessionIndex(1)}.trueY, 'k');
ylabel('dF/F');
subplot(2,1,2)
plot(allSessions{lateSessionIndex(1)}.t(6000:6150), allSessions{lateSessionIndex(1)}.trueY(6000:6150), 'k');
xlabel('Time (s)'); ylabel('dF/F');

%% trial alignment
analysisWindow = 1:130;
hitResponses = []; faResponses = []; missResponses = []; crResponses = [];
hitPrediction = []; faPrediction = []; missPrediction = []; crPrediction = [];
hitLicks = []; faLicks = []; missLicks = []; crLicks = [];
hitDown = []; faDown = []; missDown = []; crDown = [];

for i = [earlySessionIndex lateSessionIndex]
    fullTraceLength = length(allSessions{i}.sessionStruct.dff);
    
    trueTrace = [nan(fullTraceLength - length(allSessions{i}.trueY), 1); allSessions{i}.trueY]';
    traceAligned = splitToTrials(trueTrace, floor(allSessions{i}.sessionStruct.trialStart.*fs), floor(allSessions{i}.sessionStruct.trialEnd.*fs));
    
    predTrace = [nan(fullTraceLength - length(allSessions{i}.yHat), 1); allSessions{i}.yHat]';
    predAligned = splitToTrials(predTrace, floor(allSessions{i}.sessionStruct.trialStart.*fs), floor(allSessions{i}.sessionStruct.trialEnd.*fs));
    
    trueLicks = [nan(fullTraceLength - length(allSessions{i}.lickVec), 1); allSessions{i}.lickVec']';
    lickAligned = splitToTrials(trueLicks, floor(allSessions{i}.sessionStruct.trialStart.*fs), floor(allSessions{i}.sessionStruct.trialEnd.*fs));
    
    truePoleOnset = [nan(fullTraceLength - length(allSessions{i}.poleOnsetVec), 1); allSessions{i}.poleOnsetVec']';
    poleOnsetAligned = splitToTrials(truePoleOnset, floor(allSessions{i}.sessionStruct.trialStart.*fs), floor(allSessions{i}.sessionStruct.trialEnd.*fs));
    
    truePoleDown = [nan(fullTraceLength - length(allSessions{i}.poleDownVec), 1); allSessions{i}.poleDownVec']';
    poleDownAligned = splitToTrials(truePoleDown, floor(allSessions{i}.sessionStruct.trialStart.*fs), floor(allSessions{i}.sessionStruct.trialEnd.*fs));
    
    trialOutcome = parseTrialMatrix(allSessions{i}.sessionStruct.trialMatrix);
    hitIndex = find(trialOutcome==1);
    missIndex = find(trialOutcome==2);
    faIndex = find(trialOutcome==3);
    crIndex = find(trialOutcome==4);
    
    if length(missIndex) < 2
        missIndex = [missIndex missIndex];
    end
    
    if length(crIndex) < 2
        crIndex = [crIndex crIndex];
    end
    
    hitResponses = [hitResponses; nanmean(traceAligned(hitIndex, analysisWindow))];
    faResponses = [faResponses; nanmean(traceAligned(faIndex, analysisWindow))];
    missResponses = [missResponses; nanmean(traceAligned(missIndex, analysisWindow))];
    crResponses = [crResponses; nanmean(traceAligned(crIndex, analysisWindow))];
    
    hitPrediction = [hitPrediction; nanmean(predAligned(hitIndex, analysisWindow))];
    faPrediction = [faPrediction; nanmean(predAligned(faIndex, analysisWindow))];
    missPrediction = [missPrediction; nanmean(predAligned(missIndex, analysisWindow))];
    crPrediction = [crPrediction; nanmean(predAligned(crIndex, analysisWindow))];
    
    hitLicks = [hitLicks; nanmean(lickAligned(hitIndex, analysisWindow))];
    faLicks = [faLicks; nanmean(lickAligned(faIndex, analysisWindow))];
    missLicks = [missLicks; nanmean(lickAligned(missIndex, analysisWindow))];
    crLicks = [crLicks; nanmean(lickAligned(crIndex, analysisWindow))];
    
    hitDown = [hitDown; nanmean(poleDownAligned(hitIndex, analysisWindow))];
    faDown = [faDown; nanmean(poleDownAligned(faIndex, analysisWindow))];
    missDown = [missDown; nanmean(poleDownAligned(missIndex, analysisWindow))];
    crDown = [crDown; nanmean(poleDownAligned(crIndex, analysisWindow))];
    
    % temp
    hitMap = traceAligned(hitIndex, analysisWindow);
    faMap = traceAligned(faIndex, analysisWindow);
    lickMapHit = lickAligned(hitIndex, analysisWindow);
    lickMapFa = lickAligned(faIndex, analysisWindow);
    upMapHit = poleOnsetAligned(hitIndex, analysisWindow);
    upMapFa = poleOnsetAligned(faIndex, analysisWindow);
    downMapHit = poleDownAligned(hitIndex, analysisWindow);
    downMapFa = poleDownAligned(faIndex, analysisWindow);
    
    figure;
    [s, I] = sort(nanmean(lickMapHit, 2));
    subplot(2,2,1);
    imagesc(hitMap(I, :));
    subplot(2,2,3);
    imagesc(lickMapHit(I, :) + upMapHit(I,:).*2 + downMapHit(I,:).*3);
    [s, I] = sort(nanmean(lickMapFa, 2));
    subplot(2,2,2);
    imagesc(faMap(I, :));
    subplot(2,2,4);
    imagesc(lickMapFa(I, :) + upMapFa(I,:).*2 + downMapFa(I,:).*3);
end

%% plotting
figure;
subplot(3,2,1); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(hitResponses(1:3, :)), nansem(hitResponses(1:3, :)), 'lineprops', 'b', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(faResponses(1:3, :)), nansem(faResponses(1:3, :)), 'lineprops', 'g', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(hitPrediction(1:3, :)), nansem(hitPrediction(1:3, :)), 'lineprops', 'b--', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(faPrediction(1:3, :)), nansem(faPrediction(1:3, :)), 'lineprops', 'g--', 'transparent', 1)
title('Early Sessions'); xlabel('Time (s)'); ylabel('dF/F');

subplot(3,2,2); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(hitResponses(4:6, :)), nansem(hitResponses(4:6, :)), 'lineprops', 'b', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(faResponses(4:6, :)), nansem(faResponses(4:6, :)), 'lineprops', 'g', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(hitPrediction(4:6, :)), nansem(hitPrediction(4:6, :)), 'lineprops', 'b--', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(faPrediction(4:6, :)), nansem(faPrediction(4:6, :)), 'lineprops', 'g--', 'transparent', 1)
title('Late Sessions'); xlabel('Time (s)'); ylabel('dF/F');

subplot(3,2,3); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(hitLicks(1:3, :)), nansem(hitLicks(1:3, :)), 'lineprops', 'b', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(faLicks(1:3, :)), nansem(faLicks(1:3, :)), 'lineprops', 'g', 'transparent', 1)
xlabel('Time (s)'); ylabel('Lick Rate');

subplot(3,2,4); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(hitLicks(4:6, :)), nansem(hitLicks(4:6, :)), 'lineprops', 'b', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(faLicks(4:6, :)), nansem(faLicks(4:6, :)), 'lineprops', 'g', 'transparent', 1)
xlabel('Time (s)'); ylabel('Lick Rate');

subplot(3,2,5); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(hitDown(1:3, :)), nansem(hitDown(1:3, :)), 'lineprops', 'b', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(faDown(1:3, :)), nansem(faDown(1:3, :)), 'lineprops', 'g', 'transparent', 1)
xlabel('Time (s)'); ylabel('Down Average');

subplot(3,2,6); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(hitDown(4:6, :)), nansem(hitDown(4:6, :)), 'lineprops', 'b', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(faDown(4:6, :)), nansem(faDown(4:6, :)), 'lineprops', 'g', 'transparent', 1)
xlabel('Time (s)'); ylabel('Down Average');

%
figure;
subplot(3,2,1); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(missResponses(1:3, :)), nansem(missResponses(1:3, :)), 'lineprops', 'k', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(crResponses(1:3, :)), nansem(crResponses(1:3, :)), 'lineprops', 'r', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(missPrediction(1:3, :)), nansem(missPrediction(1:3, :)), 'lineprops', 'k--', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(crPrediction(1:3, :)), nansem(crPrediction(1:3, :)), 'lineprops', 'r--', 'transparent', 1)
title('Early Sessions'); xlabel('Time (s)'); ylabel('dF/F');

subplot(3,2,2); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(missResponses(4:6, :)), nansem(missResponses(4:6, :)), 'lineprops', 'k', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(crResponses(4:6, :)), nansem(crResponses(4:6, :)), 'lineprops', 'r', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(missPrediction(4:6, :)), nansem(missPrediction(4:6, :)), 'lineprops', 'k--', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(crPrediction(4:6, :)), nansem(crPrediction(4:6, :)), 'lineprops', 'r--', 'transparent', 1)
title('Late Sessions'); xlabel('Time (s)'); ylabel('dF/F');

subplot(3,2,3); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(missLicks(1:3, :)), nansem(missLicks(1:3, :)), 'lineprops', 'k', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(crLicks(1:3, :)), nansem(crLicks(1:3, :)), 'lineprops', 'r', 'transparent', 1)
xlabel('Time (s)'); ylabel('Lick Rate');

subplot(3,2,4); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(missLicks(4:6, :)), nansem(missLicks(4:6, :)), 'lineprops', 'k', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(crLicks(4:6, :)), nansem(crLicks(4:6, :)), 'lineprops', 'r', 'transparent', 1)
xlabel('Time (s)'); ylabel('Lick Rate');

subplot(3,2,5); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(missDown(1:3, :)), nansem(missDown(1:3, :)), 'lineprops', 'k', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(crDown(1:3, :)), nansem(crDown(1:3, :)), 'lineprops', 'r', 'transparent', 1)
xlabel('Time (s)'); ylabel('Down Average');

subplot(3,2,6); hold on;
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(missDown(4:6, :)), nansem(missDown(4:6, :)), 'lineprops', 'k', 'transparent', 1)
shadedErrorBar((1:length(analysisWindow))./fs, nanmean(crDown(4:6, :)), nansem(crDown(4:6, :)), 'lineprops', 'r', 'transparent', 1)
xlabel('Time (s)'); ylabel('Down Average');