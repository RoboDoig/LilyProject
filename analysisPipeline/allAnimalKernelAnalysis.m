clear all; close all; clc;

%% data set and params
fnames = {'AH1100_datastruct', 'AH1107_datastruct', 'AH1147_datastruct', 'AH1149_datastruct', 'AH1151_datastruct'};
inputNames = {'firstLickTimesVec', 'otherLickTimesVec', 'poleOnsetVec', 'poleDownVec', 'waterTimesVec', 'amplitudeVec', 'dff'};
nInputs = length(inputNames);
windowSizes = [45; 45; 45; 45; 45; 45; 5]; % window sizes for design matrix
timeLags =  [0; 0; 0; 0; 0; 0; -10]; % time lags for each window
allResponseIntegrals = cell(length(fnames), nInputs);
allAnimalSessions = cell(1, length(fnames));

for f = 1:length(fnames)
    data = load([fnames{f}, '.mat']); 
   
    %% data preparation
    % normalize any fields that are particularly large
    data = normalizeData01(data, 'amplitude');
    data = normalizeData01(data, 'theta');
    data = normalizeData01(data, 'setpoint');
    data = normalizeData01(data, 'phase');

    % pick 'full data' sessions
    hasFA = arrayfun(@(x) sum(x.trialMatrix(:, 3)), data.summary); % where false alarm trials are present
    hasWhisker = arrayfun(@(x) length(x.theta) > 0, data.summary); % where whisker data is present
    % indices of full data sessions
    goodSessionIndex = find([data.summary.hasWhisker] == 1 & [data.summary.hasScopolamine] == 0 & [data.summary.polePresent] == 1 & hasFA>0 & hasWhisker>0);
    % which of these are early vs. late sessions
    earlySessionIndex = goodSessionIndex(1:3);
    lateSessionIndex = goodSessionIndex(end-2:end);
    % clip to only this data
    data.summary = data.summary([earlySessionIndex, lateSessionIndex]);
    fs = [15.44, 311]; % 2p fs, whisker fs
    trialSkip = 30; % skip initial fluorescence to avoid decay period

    %% GLM preparation and training
    allSessions = mouseGLMAnalysis(data, fs, trialSkip, inputNames, windowSizes, timeLags);
    allAnimalSessions{1, f} = allSessions;
    nSessions = length(allSessions);

    %% reset figures
    close all;
    earlySessionIndex = 1:3;
    lateSessionIndex = 4:6;
    fs = fs(1);

    %% Example traces and predictions
    sI = 3;
    figure;
    subplot(2,1,1); hold on;
    plot(allSessions{earlySessionIndex(sI)}.t, allSessions{earlySessionIndex(sI)}.trueY, 'k');
    plot(allSessions{earlySessionIndex(sI)}.t, allSessions{earlySessionIndex(sI)}.yHat, 'r');
    plot(allSessions{earlySessionIndex(sI)}.t, allSessions{earlySessionIndex(sI)}.lickVec, 'b');
    ylabel('dF/F');
    subplot(2,1,2); hold on;
    plot(allSessions{lateSessionIndex(sI)}.t, allSessions{lateSessionIndex(sI)}.trueY, 'k');
    plot(allSessions{lateSessionIndex(sI)}.t, allSessions{lateSessionIndex(sI)}.yHat, 'r');
    plot(allSessions{lateSessionIndex(sI)}.t, allSessions{lateSessionIndex(sI)}.lickVec, 'b');
    xlabel('Time (s)'); ylabel('dF/F');

    %% response functions per session
    figure;
    for i = 1:nSessions
        for j = 1:nInputs
           subplot(1, nInputs, j); hold on;
           plot(allSessions{i}.responseFunctions{j}, 'Color', [i/nSessions, 0, 0]);
           ylim([-0.05 0.16])
           xlabel('Frame'); ylabel('Beta'); axis square; title(inputNames{j});
        end
    end

    %% kernel importance analysis
    figure;
    for j = 1:nInputs
        responseIntegral = nan(1, nSessions);
        for i = 1:nSessions
            thisResponseFunction = allSessions{i}.responseFunctions{j};
            responseIntegral(i) = mean(abs(thisResponseFunction));
        end
        subplot(1, nInputs, j); hold on;
        scatter(ones(1,3), responseIntegral(1:3), 'k');
        errorbar(1, mean(responseIntegral(1:3)), std(responseIntegral(1:3)), 'k');
        scatter(ones(1,3)*2, responseIntegral(4:6), 'r');
        errorbar(2, mean(responseIntegral(4:6)), std(responseIntegral(4:6)), 'r');

        [h, p] = ttest2(responseIntegral(1:3), responseIntegral(4:6));

        xlim([0.5 2.5])
        ylim([-0.05 max(responseIntegral)*1.5])
        axis square
        title([inputNames{j} , ": ", num2str(p)]);
        
        allResponseIntegrals{f, j} = responseIntegral;
    end
end
nAnimals = size(allResponseIntegrals, 1);

%% across animal kernel average
figure;
for j = 1:nInputs
    meanRkEarly = [];
    meanRkLate = [];
    for i = 1:nAnimals
        rkEarly = [];
        rkLate = [];
        for s = 1:3
            rkEarly = [rkEarly; allAnimalSessions{i}{s}.responseFunctions{j}'];
        end
        meanRkEarly = [meanRkEarly; mean(rkEarly)];
        
        for s = 4:6
            rkLate = [rkLate; allAnimalSessions{i}{s}.responseFunctions{j}']; 
        end
        meanRkLate = [meanRkLate; mean(rkLate)];
    end
    
    subplot(1, nInputs, j); hold on;
    shadedErrorBar(1:size(meanRkEarly, 2), mean(meanRkEarly), nanstd(meanRkEarly), 'lineprops', 'k', 'transparent', 1);
    shadedErrorBar(1:size(meanRkLate, 2), mean(meanRkLate), nanstd(meanRkLate), 'lineprops', 'r', 'transparent', 1);
    axis square
    title(inputNames{j});
end

%% across animal analysis - kernel importance
figure;
for j = 1:nInputs
    responses = reshape([allResponseIntegrals{:, j}], 6, nAnimals)';
    earlyAvg = mean(responses(:, 1:3), 2);
    lateAvg = mean(responses(:, 4:6), 2);
    
    subplot(1, nInputs, j); hold on;
    for i = 1:nAnimals
        plot([1 2], [earlyAvg(i), lateAvg(i)], 'k'); 
    end
    
    [h, p] = ttest(earlyAvg, lateAvg);
    
    xlim([0.5 2.5])
    ylim([0 max(max(responses))*1.5]);
    axis square;
    title([inputNames{j} , ": ", num2str(p)]);
end