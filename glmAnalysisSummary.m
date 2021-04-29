clear all; close all; clc;

%% params
data = load('AH1024_datastruct.mat');
% data = load('AH1100_datastruct.mat');
% data = load('AH1107_datastruct.mat');
nSessions = size(data.summary, 2);
fs = 15.44;
trialSkip = 30;

%% fit models for each session
allSessions = cell(1, nSessions);
for sessionIdx = 1:nSessions
    fitData = struct();
    
    % extract session variables
    sessionStruct = extractSessionInformation(data.summary, sessionIdx, fs, trialSkip, 0);

    % GLM
    inputVectors = [sessionStruct.lickTimesVec;...
                    sessionStruct.poleOnsetVec;...
                    sessionStruct.poleDownVec;...
                    sessionStruct.alignInfoX';...
                    sessionStruct.alignInfoY'];

    windowSizes = [floor(20 * fs);...
                   floor(10 * fs);...
                   floor(10 * fs);...
                   floor(5 * fs);...
                   floor(5 * fs)]; % window sizes for design matrix

    responseVector = sessionStruct.dff; % response vector;
    startFrame = sessionStruct.skipStartFrame;
    endFrame = length(responseVector);

    [fit, fullDesignMatrix, y, yHat] = buildGLM(inputVectors, windowSizes, responseVector, startFrame, endFrame, 0);

    trueY = y(startFrame:endFrame);
    yHat = yHat(:, end);
    lickVec = sessionStruct.lickTimesVec(startFrame:endFrame);
    t = sessionStruct.tAxis(startFrame:endFrame);
    
    % extract response functions
    cT = [0 cumsum(windowSizes)'];
    responseFunctions = {};
    for i = 1:size(inputVectors, 1)
       rf = flipud(fit.beta((cT(i)+1):cT(i+1), end));
       responseFunctions{i} = rf;
    end
    
    % save to session struct
    fitData.sessionStruct = sessionStruct;
    fitData.windowSizes = windowSizes;
    fitData.responseVector = sessionStruct.dff;
    fitData.startFrame = startFrame;
    fitData.endFrame = endFrame;
    fitData.fit = fit;
    fitData.X = fullDesignMatrix;
    fitData.trueY = trueY;
    fitData.yHat = yHat;
    fitData.lickVec = lickVec;
    fitData.t = t;
    fitData.responseFunctions = responseFunctions;
    allSessions{sessionIdx} = fitData;
end

%% plot summary
% deviance explained
devs = cellfun(@(x) x.fit.dev(end), allSessions);
cr = cellfun(@(x) x.sessionStruct.correctRate, allSessions);
figure; subplot(1,2,1); plot(devs); subplot(1,2,2); scatter(cr, devs);

% true vs. predicted + response functions
for i = 1:nSessions
   figure;
   subplot(1,3,1:2); hold on;
   plot(allSessions{i}.t, allSessions{i}.trueY, 'k');
   plot(allSessions{i}.t, allSessions{i}.yHat, 'r');
   
   subplot(1,3,3);
   scatter(allSessions{i}.trueY, allSessions{i}.yHat, 'k.');
end
