function [allSessions] = mouseGLMAnalysis(data, fs, trialSkip, inputNames, windowSizes, timeLags)
    
    nSessions = size(data.summary, 2);
    % fit models for each session
    allSessions = cell(1, nSessions);
    for sessionIdx = 1:nSessions
        
        fitData = struct();

        % extract session variables
        sessionStruct = extractSessionInformation(data.summary, sessionIdx, fs, trialSkip, 1);

        % GLM
        inputVectors = [];
        for i = 1:length(inputNames)
           inputVectors = [inputVectors; sessionStruct.(inputNames{i})]; 
        end

        responseVector = sessionStruct.dff'; % response vector;
        % continuous frame period
        startFrame = sessionStruct.skipStartFrame;
        endFrame = length(responseVector) - max(timeLags);
        framePeriod = startFrame : endFrame;
        
%         % trial frame period
%         trialFrames = [];
%         for i = 1:length(sessionStruct.trialStart)
%             trialStart = sessionStruct.trialStart(i);
%             startFrame = find(sessionStruct.tAxis > trialStart, 1);
%             trialFrames = [trialFrames startFrame:(startFrame+90)];
%         end
%         framePeriod = trialFrames;

        [fit, fullDesignMatrix, y, yHat] = buildGLM(inputVectors, windowSizes, timeLags, responseVector, framePeriod, 1);

        trueY = y(framePeriod);
        yHat = yHat(:, end);
        lickVec = sessionStruct.lickTimesVec(framePeriod);
        poleOnsetVec = sessionStruct.poleOnsetVec(framePeriod);
        poleDownVec = sessionStruct.poleDownVec(framePeriod);
        waterTimesVec = sessionStruct.waterTimesVec(framePeriod);
        t = sessionStruct.tAxis(framePeriod);

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
        fitData.framePeriod = framePeriod;
        fitData.fit = fit;
        fitData.X = fullDesignMatrix;
        fitData.trueY = trueY;
        fitData.yHat = yHat;
        fitData.lickVec = lickVec;
        fitData.poleOnsetVec = poleOnsetVec;
        fitData.poleDownVec = poleDownVec;
        fitData.waterTimesVec = waterTimesVec;
        fitData.t = t;
        fitData.responseFunctions = responseFunctions;
        allSessions{sessionIdx} = fitData;
        
    end

end

