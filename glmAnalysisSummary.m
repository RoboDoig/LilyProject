clear all; close all; clc;

%% params
% fname = 'AH1024_datastruct';
% fname = 'AH1100_datastruct';
% fname = 'AH1107_datastruct';
% fname = 'AH1147_datastruct';
fname = 'AH1149_datastruct';

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
lickRate = cellfun(@(x) sum(x.lickVec) / length(x.lickVec), allSessions);
sessionLength = cellfun(@(x) length(x.lickVec), allSessions);
sessionVariance = cellfun(@(x) var(x.trueY), allSessions);
alignVarianceX = cellfun(@(x) var(x.sessionStruct.alignInfoX), allSessions);
alignVarianceY = cellfun(@(x) var(x.sessionStruct.alignInfoY), allSessions);
figure('Renderer', 'painters', 'Position', [100 100 1200 200]); 
subplot(1,7,1); plot(devs, 'k'); xlabel('Sesssion'); ylabel('% Dev')
subplot(1,7,2); scatter(cr, devs, 'k'); [r, p] = corrcoef(cr, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('Correct Rate')
subplot(1,7,3); scatter(lickRate, devs, 'k'); [r, p] = corrcoef(lickRate, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('Lick Rate')
subplot(1,7,4); scatter(sessionLength, devs, 'k'); [r, p] = corrcoef(sessionLength, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('Session Length')
subplot(1,7,5); scatter(sessionVariance, devs, 'k'); [r, p] = corrcoef(sessionVariance, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('Session Var')
subplot(1,7,6); scatter(alignVarianceX, devs, 'k'); [r, p] = corrcoef(alignVarianceX, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('alignX Var')
subplot(1,7,7); scatter(alignVarianceY, devs, 'k'); [r, p] = corrcoef(alignVarianceY, devs); title([num2str(r(1, 2)), ',', num2str(p(1, 2))]); xlabel('alignY Var')

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
windowCutoff = floor(6*fs);
trueTrials = cell(1, 4);
subTrials = cell(1, 4);
for i = 1:nSessions
   
    fullTraceLength = length(allSessions{i}.sessionStruct.dff);
    trueTrace = [nan(fullTraceLength - length(allSessions{i}.trueY), 1); allSessions{i}.trueY]';
    subTrace = [nan(fullTraceLength - length(allSessions{i}.trueY), 1); allSessions{i}.trueY - allSessions{i}.yHat]';
    
    trueAligned = splitToTrials(trueTrace, floor(allSessions{i}.sessionStruct.trialStart.*fs), floor(allSessions{i}.sessionStruct.trialEnd.*fs));
    subAligned = splitToTrials(subTrace, floor(allSessions{i}.sessionStruct.trialStart.*fs), floor(allSessions{i}.sessionStruct.trialEnd.*fs));
    
    trialOutcome = parseTrialMatrix(allSessions{i}.sessionStruct.trialMatrix);
    hitIndex = find(trialOutcome==1);
    missIndex = find(trialOutcome==2);
    faIndex = find(trialOutcome==3);
    crIndex = find(trialOutcome==4);
    
    if length(missIndex) > 2 && length(faIndex) > 2
        trueHit = trueAligned(hitIndex, 1:windowCutoff); trueTrials{1, 1} = [trueTrials{1, 1}; nanmean(trueHit)];
        trueMiss = trueAligned(missIndex, 1:windowCutoff); trueTrials{1, 2} = [trueTrials{1, 2}; nanmean(trueMiss)];
        trueFA = trueAligned(faIndex, 1:windowCutoff); trueTrials{1, 3} = [trueTrials{1, 3}; nanmean(trueFA)];
        trueCR = trueAligned(crIndex, 1:windowCutoff); trueTrials{1, 4} = [trueTrials{1, 4}; nanmean(trueCR)];

        subHit = subAligned(hitIndex, 1:windowCutoff); subTrials{1, 1} = [subTrials{1, 1}; nanmean(subHit)];
        subMiss = subAligned(missIndex, 1:windowCutoff); subTrials{1, 2} = [subTrials{1, 2}; nanmean(subMiss)];
        subFA = subAligned(faIndex, 1:windowCutoff); subTrials{1, 3} = [subTrials{1, 3}; nanmean(subFA)];
        subCR = subAligned(crIndex, 1:windowCutoff); subTrials{1, 4} = [subTrials{1, 4}; nanmean(subCR)];
    end
end

%% plotting
figure('Renderer', 'painters', 'Position', [10 10 600 250]);
subplot(1,2,1); hold on;
shadedErrorBar((1:size(trueTrials{1, 1}, 2))./fs, nanmean(trueTrials{1, 1})-nanmean(trueTrials{1, 1}(:,1)), nansem(trueTrials{1, 1}), 'lineprops', 'b', 'transparent', 1);
shadedErrorBar((1:size(trueTrials{1, 2}, 2))./fs, nanmean(trueTrials{1, 2})-nanmean(trueTrials{1, 2}(:,1)), nansem(trueTrials{1, 2}), 'lineprops', 'b--', 'transparent', 1);
shadedErrorBar((1:size(trueTrials{1, 3}, 2))./fs, nanmean(trueTrials{1, 3})-nanmean(trueTrials{1, 3}(:,1)), nansem(trueTrials{1, 3}), 'lineprops', 'r--', 'transparent', 1);
shadedErrorBar((1:size(trueTrials{1, 4}, 2))./fs, nanmean(trueTrials{1, 4})-nanmean(trueTrials{1, 4}(:,1)), nansem(trueTrials{1, 4}), 'lineprops', 'r', 'transparent', 1);
ylim([-0.05 0.3])

subplot(1,2,2); hold on;
shadedErrorBar((1:size(subTrials{1, 1}, 2))./fs, nanmean(subTrials{1, 1})-nanmean(subTrials{1, 1}(:,1)), nansem(subTrials{1, 1}), 'lineprops', 'b', 'transparent', 1);
shadedErrorBar((1:size(subTrials{1, 2}, 2))./fs, nanmean(subTrials{1, 2})-nanmean(subTrials{1, 2}(:,1)), nansem(subTrials{1, 2}), 'lineprops', 'b--', 'transparent', 1);
shadedErrorBar((1:size(subTrials{1, 3}, 2))./fs, nanmean(subTrials{1, 3})-nanmean(subTrials{1, 3}(:,1)), nansem(subTrials{1, 3}), 'lineprops', 'r--', 'transparent', 1);
shadedErrorBar((1:size(subTrials{1, 4}, 2))./fs, nanmean(subTrials{1, 4})-nanmean(subTrials{1, 4}(:,1)), nansem(subTrials{1, 4}), 'lineprops', 'r', 'transparent', 1);
ylim([-0.05 0.2])



