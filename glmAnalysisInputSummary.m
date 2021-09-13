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
fs = 15.44;
trialSkip = 30;

% inputNames = {'lickTimesVec', 'poleOnsetVec', 'poleDownVec', 'alignInfoX', 'alignInfoY', 'waterTimesVec'};
inputNames = {'lickTimesVec'};
windowSizes = 1:5:45; % window sizes for design matrix

devs = [];
c = 1;
figure('Renderer', 'painters', 'Position', [100 100 700 500]);
concResponseFunctions = [];
for window = windowSizes
    allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputNames, window);
    devs = [devs; cellfun(@(x) x.fit.dev(end), allSessions)];
    
    responseFunctions = nan(window, length(allSessions));
    for i = 1:length(allSessions)
       responseFunctions(:, i) = allSessions{i}.responseFunctions{1};
    end
    concResponseFunctions = [concResponseFunctions, nan(length(allSessions), 1), responseFunctions'];
    subplot(2,2,3); hold on; plot(devs(c,:), 'Color', [window/max(windowSizes), 0, 0]); xlabel('Session'); ylabel('Dev');
    subplot(2,2,4); hold on; plot((1:size(responseFunctions, 1))./fs, nanmean(responseFunctions, 2), 'Color', [window/max(windowSizes), 0, 0]); xlabel('Time (s)'); ylabel('Beta')
    c = c+1;
end
subplot(2,2,1); hold on;
for i = 1:size(responseFunctions, 2)
   plot(responseFunctions(:, i), 'Color', [i/size(responseFunctions, 2), 0, 0]);  
end
xlabel('Frames'); ylabel('Beta');
subplot(2,2,2); imagesc(corrcov(cov(responseFunctions))); set(gca,'YDir','normal'); colorbar; title('Kernel R^2'); xlabel('Session'); ylabel('Session');


% %% plot summary
% % deviance explained
% devs = cellfun(@(x) x.fit.dev(end), allSessions);
% cr = cellfun(@(x) x.sessionStruct.correctRate, allSessions);
% figure; subplot(1,2,1); plot(devs); subplot(1,2,2); scatter(cr, devs);
% 
% % show reconstructed for best fit
% [m, I] = max(devs);
% figure; hold on;
% plot(allSessions{I}.t, allSessions{I}.trueY, 'k');
% plot(allSessions{I}.t, allSessions{I}.yHat, 'r');
% 
% figure;
% plot(allSessions{I}.t, allSessions{I}.trueY -  allSessions{I}.yHat, 'k');
% 
% % mean response functions
% nSessions = length(allSessions);
% nInputs = length(inputNames);
% stackResponseFunctions = cell(1, nInputs);
% figure('Renderer', 'painters', 'Position', [500 500 1300 200])
% for i = 1:nSessions
%     for j = 1:nInputs
%         subplot(1, nInputs, j); hold on;
%         plot((1:length(allSessions{i}.responseFunctions{j}))./fs, allSessions{i}.responseFunctions{j}, 'k');
%         stackResponseFunctions{j} = [stackResponseFunctions{j}; allSessions{i}.responseFunctions{j}'];
%     end
% end
% for j = 1:nInputs
%    subplot(1, nInputs, j);
%    plot((1:length(allSessions{i}.responseFunctions{j}))./fs, mean(stackResponseFunctions{j}), 'r', 'LineWidth', 1.5);
%    ylim([-0.1, 0.15])
%    title(inputNames{j});
% end
% 
% %% trace subtraction, alignment
% windowCutoff = floor(6*fs);
% trueTrials = cell(1, 4);
% subTrials = cell(1, 4);
% for i = 1:nSessions
%    
%     fullTraceLength = length(allSessions{i}.sessionStruct.dff);
%     trueTrace = [nan(fullTraceLength - length(allSessions{i}.trueY), 1); allSessions{i}.trueY]';
%     subTrace = [nan(fullTraceLength - length(allSessions{i}.trueY), 1); allSessions{i}.trueY - allSessions{i}.yHat]';
%     
%     trueAligned = splitToTrials(trueTrace, floor(allSessions{i}.sessionStruct.trialStart.*fs), floor(allSessions{i}.sessionStruct.trialEnd.*fs));
%     subAligned = splitToTrials(subTrace, floor(allSessions{i}.sessionStruct.trialStart.*fs), floor(allSessions{i}.sessionStruct.trialEnd.*fs));
%     
%     trialOutcome = parseTrialMatrix(allSessions{i}.sessionStruct.trialMatrix);
%     hitIndex = find(trialOutcome==1);
%     missIndex = find(trialOutcome==2);
%     faIndex = find(trialOutcome==3);
%     crIndex = find(trialOutcome==4);
%     
%     if length(missIndex) > 2 && length(faIndex) > 2
%         trueHit = trueAligned(hitIndex, 1:windowCutoff); trueTrials{1, 1} = [trueTrials{1, 1}; nanmean(trueHit)];
%         trueMiss = trueAligned(missIndex, 1:windowCutoff); trueTrials{1, 2} = [trueTrials{1, 2}; nanmean(trueMiss)];
%         trueFA = trueAligned(faIndex, 1:windowCutoff); trueTrials{1, 3} = [trueTrials{1, 3}; nanmean(trueFA)];
%         trueCR = trueAligned(crIndex, 1:windowCutoff); trueTrials{1, 4} = [trueTrials{1, 4}; nanmean(trueCR)];
% 
%         subHit = subAligned(hitIndex, 1:windowCutoff); subTrials{1, 1} = [subTrials{1, 1}; nanmean(subHit)];
%         subMiss = subAligned(missIndex, 1:windowCutoff); subTrials{1, 2} = [subTrials{1, 2}; nanmean(subMiss)];
%         subFA = subAligned(faIndex, 1:windowCutoff); subTrials{1, 3} = [subTrials{1, 3}; nanmean(subFA)];
%         subCR = subAligned(crIndex, 1:windowCutoff); subTrials{1, 4} = [subTrials{1, 4}; nanmean(subCR)];
%     end
% end
% 
% %% plotting
% figure('Renderer', 'painters', 'Position', [10 10 600 250]);
% subplot(1,2,1); hold on;
% shadedErrorBar((1:size(trueTrials{1, 1}, 2))./fs, nanmean(trueTrials{1, 1})-nanmean(trueTrials{1, 1}(:,1)), nansem(trueTrials{1, 1}), 'lineprops', 'b', 'transparent', 1);
% shadedErrorBar((1:size(trueTrials{1, 2}, 2))./fs, nanmean(trueTrials{1, 2})-nanmean(trueTrials{1, 2}(:,1)), nansem(trueTrials{1, 2}), 'lineprops', 'b--', 'transparent', 1);
% shadedErrorBar((1:size(trueTrials{1, 3}, 2))./fs, nanmean(trueTrials{1, 3})-nanmean(trueTrials{1, 3}(:,1)), nansem(trueTrials{1, 3}), 'lineprops', 'r--', 'transparent', 1);
% shadedErrorBar((1:size(trueTrials{1, 4}, 2))./fs, nanmean(trueTrials{1, 4})-nanmean(trueTrials{1, 4}(:,1)), nansem(trueTrials{1, 4}), 'lineprops', 'r', 'transparent', 1);
% ylim([-0.05 0.3])
% 
% subplot(1,2,2); hold on;
% shadedErrorBar((1:size(subTrials{1, 1}, 2))./fs, nanmean(subTrials{1, 1})-nanmean(subTrials{1, 1}(:,1)), nansem(subTrials{1, 1}), 'lineprops', 'b', 'transparent', 1);
% shadedErrorBar((1:size(subTrials{1, 2}, 2))./fs, nanmean(subTrials{1, 2})-nanmean(subTrials{1, 2}(:,1)), nansem(subTrials{1, 2}), 'lineprops', 'b--', 'transparent', 1);
% shadedErrorBar((1:size(subTrials{1, 3}, 2))./fs, nanmean(subTrials{1, 3})-nanmean(subTrials{1, 3}(:,1)), nansem(subTrials{1, 3}), 'lineprops', 'r--', 'transparent', 1);
% shadedErrorBar((1:size(subTrials{1, 4}, 2))./fs, nanmean(subTrials{1, 4})-nanmean(subTrials{1, 4}(:,1)), nansem(subTrials{1, 4}), 'lineprops', 'r', 'transparent', 1);
% ylim([-0.05 0.2])



