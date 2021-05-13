function [sessionStruct] = extractSessionInformation(data, sessionIdx, fs, trialSkip, verbose)

    sessionStruct = struct();

    dff = dffFromTrace(data(sessionIdx).c2FOVrigid);
    tAxis = (1:length(dff))./fs;
    
    trialStart = data(sessionIdx).trialStart(trialSkip:end)./fs;
    trialEnd = data(sessionIdx).trialEnd(trialSkip:end)./fs;
    poleOnsetRelative = data(sessionIdx).poleOnset(trialSkip:end);
    poleDownRelative = data(sessionIdx).poleDown(trialSkip:end);
    
    nTrials = length(trialStart);
    trialMatrix = data(sessionIdx).trialMatrix(trialSkip:end, :);
    alignInfoX = data(sessionIdx).alignInfo(:, 1);
    alignInfoY = data(sessionIdx).alignInfo(:, 2);
    lickTimesRelative = data(sessionIdx).licks(trialSkip:end, :);
    waterTimesRelative = data(sessionIdx).waterTime(trialSkip: end);
    skipStartFrame = floor(trialStart(1)*fs);
    
    % get absolute times
    lickTimes = [];
    waterTimes = [];
    poleOnset = [];
    poleDown = [];
    for i = 1:length(trialStart)
        lickTimes = [lickTimes, lickTimesRelative{i}'+trialStart(i)];
        waterTimes = [waterTimes, waterTimesRelative{i}'+trialStart(i)];
        poleOnset = [poleOnset, poleOnsetRelative{i}+trialStart(i)];
        poleDown = [poleDown, poleDownRelative{i}+trialStart(i)];
    end

    % vectorize times
    lickTimesVec = zeros(1, length(dff));
    waterTimesVec = zeros(1, length(dff));
    for i = 1:length(lickTimes)
        vecPoint = find(tAxis>=lickTimes(i), 1);
        lickTimesVec(vecPoint) = 1;
    end
    
    for i = 1:length(waterTimes)
        vecPoint = find(tAxis>=waterTimes(i), 1);
        waterTimesVec(vecPoint) = 1;
    end
    
    poleOnsetVec = zeros(1, length(dff));
    poleDownVec  = zeros(1, length(dff));
    for i = 1:nTrials   
        vecPoint = find(tAxis>=poleOnset(i), 1);
        poleOnsetVec(vecPoint) = 1;
        
        vecPoint = find(tAxis>=poleDown(i), 1);
        poleDownVec(vecPoint) = 1;
    end
    
    % save to output struct
    sessionStruct.dff = dff;
    sessionStruct.tAxis = tAxis;
    sessionStruct.trialStart = trialStart;
    sessionStruct.trialEnd = trialEnd;
    sessionStruct.nTrials = nTrials;
    sessionStruct.trialMatrix = trialMatrix;
    sessionStruct.alignInfoX = alignInfoX';
    sessionStruct.alignInfoY = alignInfoY';
    
    sessionStruct.lickTimesRelative = lickTimesRelative;
    sessionStruct.poleOnsetRelative = poleOnsetRelative;
    sessionStruct.poleDownRelative = poleDownRelative;
    
    sessionStruct.skipStartFrame = skipStartFrame;
    
    sessionStruct.lickTimes = lickTimes;
    sessionStruct.waterTimes = waterTimes;
    sessionStruct.poleOnset = poleOnset;
    sessionStruct.poleDown = poleDown;
    
    sessionStruct.lickTimesVec = lickTimesVec;
    sessionStruct.waterTimesVec = waterTimesVec;
    sessionStruct.poleOnsetVec = poleOnsetVec;
    sessionStruct.poleDownVec = poleDownVec;
    
    sessionStruct.correctRate = data(sessionIdx).CorrectRate;
    
    if verbose
        % plot timings
        figure; hold on;
        plot(tAxis, dff, 'k');
        plot(tAxis, lickTimesVec, 'b');
        plot(tAxis, poleOnsetVec, 'g');
        plot(tAxis, waterTimesVec-1, 'y');
        plot([tAxis(skipStartFrame) tAxis(skipStartFrame)], [0, 1], 'g--')
        scatter(trialStart, ones(1,length(trialStart)), 'r.');
        scatter(lickTimes, ones(1,length(lickTimes)), 'b.');
        scatter(poleOnset, ones(1,length(poleOnset)), 'g.');
    end
end

