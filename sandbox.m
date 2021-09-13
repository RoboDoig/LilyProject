clear all; close all; clc;

%% params
% fname = 'AH1024_datastruct';
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

inputNames = {'lickTimesVec', 'alignInfoX', 'alignInfoY'};
nInputs = length(inputNames);
windowSize = [30; 30; 30]; % window sizes for design matrix

allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputNames, windowSize);
nSessions = length(allSessions);

% response functions per session
figure;
for i = 1:nSessions
    for j = 1:nInputs
       subplot(1, nInputs, j); hold on;
       plot(allSessions{i}.responseFunctions{j}, 'Color', [i/nSessions, 0, 0]);
    end
end

% trial alignment
analysisWindow = 20:50;
allMeanTraceAligned = [];
allMeanTraceHit = [];
allMeanTraceFa = [];

allMeanLickAligned = [];
allMeanLickHit = [];
allMeanLickFa = [];
for i = 1:nSessions
    fullTraceLength = length(allSessions{i}.sessionStruct.dff);
    trueTrace = [nan(fullTraceLength - length(allSessions{i}.trueY), 1); allSessions{i}.trueY]';
    trueLicks = [nan(fullTraceLength - length(allSessions{i}.lickVec), 1); allSessions{i}.lickVec']';
    
    traceAligned = splitToTrials(trueTrace, floor(allSessions{i}.sessionStruct.trialStart.*fs), floor(allSessions{i}.sessionStruct.trialEnd.*fs));
    traceAligned = traceAligned(:, analysisWindow);
    lickAligned = splitToTrials(trueLicks, floor(allSessions{i}.sessionStruct.trialStart.*fs), floor(allSessions{i}.sessionStruct.trialEnd.*fs));
    lickAligned = lickAligned(:, analysisWindow);
    
    trialOutcome = parseTrialMatrix(allSessions{i}.sessionStruct.trialMatrix);
    hitIndex = find(trialOutcome==1);
    missIndex = find(trialOutcome==2);
    faIndex = find(trialOutcome==3);
    crIndex = find(trialOutcome==4);
    
    hitTraceAligned = traceAligned(hitIndex, :);
    faTraceAligned = traceAligned(faIndex, :);
    hitLickAligned = lickAligned(hitIndex, :);
    faLickAligned = lickAligned(faIndex, :);

    figure; hold on;
    scatter(mean(hitLickAligned, 2), mean(hitTraceAligned, 2), 'g');
    scatter(mean(faLickAligned, 2), mean(faTraceAligned, 2), 'r');
    [r, p] = corrcoef(mean(lickAligned, 2), mean(traceAligned, 2));
    title([num2str(r(1, 2)), ', ' num2str(p(1, 2))]);
    
    allMeanTraceAligned = [allMeanTraceAligned, mean(traceAligned, 2)'];
    allMeanTraceHit = [allMeanTraceHit, mean(hitTraceAligned, 2)'];
    allMeanTraceFa = [allMeanTraceFa, mean(faTraceAligned, 2)'];
    
    allMeanLickAligned = [allMeanLickAligned, mean(lickAligned, 2)'];
    allMeanLickHit = [allMeanLickHit, mean(hitLickAligned, 2)'];
    allMeanLickFa = [allMeanLickFa, mean(faLickAligned, 2)'];
end

figure; hold on;
scatter(allMeanLickHit+randn(1,length(allMeanLickHit))*0.005, allMeanTraceHit, 'g');
scatter(allMeanLickFa+randn(1,length(allMeanLickFa))*0.005, allMeanTraceFa, 'r');
[r, p] = corrcoef(allMeanLickAligned, allMeanTraceAligned);
title(['R^2: ' num2str(r(1, 2)) ' p: ' num2str(p(1, 2))]);
xlabel('Lick Rate / Frame');
ylabel('dF/F Integral')
% scatter(allMeanLickAligned+randn(1,length(allMeanLickAligned))*0.005, allMeanTraceAligned);