function [allSessions] = mouseGLMAnalysis(data, fs, trialSkip, inputNames, windowSizes)
    
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

        responseVector = sessionStruct.dff; % response vector;
        startFrame = sessionStruct.skipStartFrame;
        endFrame = length(responseVector);

        [fit, fullDesignMatrix, y, yHat] = buildGLM(inputVectors, windowSizes, responseVector, startFrame, endFrame, 0);

        trueY = y(startFrame:endFrame);
        yHat = yHat(:, end);
        lickVec = sessionStruct.lickTimesVec(startFrame:endFrame);
        poleOnsetVec = sessionStruct.poleOnsetVec(startFrame:endFrame);
        poleDownVec = sessionStruct.poleDownVec(startFrame:endFrame);
        waterTimesVec = sessionStruct.waterTimesVec(startFrame:endFrame);
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
        fitData.poleOnsetVec = poleOnsetVec;
        fitData.poleDownVec = poleDownVec;
        fitData.waterTimesVec = waterTimesVec;
        fitData.t = t;
        fitData.responseFunctions = responseFunctions;
        allSessions{sessionIdx} = fitData;
        
    end

end

