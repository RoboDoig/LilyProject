function [sessionStruct] = extractSessionInformation(data, sessionIdx, fs, trialSkip, verbose)

    sessionStruct = struct();
    pfs = fs(1); % 2p fs
    wFs = fs(2); % whisker fs

    dff = dffFromTrace(data(sessionIdx).c2FOVraw);
    tAxis = (1:length(dff))./pfs;
    
    trialStart = data(sessionIdx).trialStart(trialSkip:end)./pfs;
    trialEnd = data(sessionIdx).trialEnd(trialSkip:end)./pfs;
    poleOnsetRelative = data(sessionIdx).poleOnset(trialSkip:end);
    poleDownRelative = data(sessionIdx).poleDown(trialSkip:end);
    
    nTrials = length(trialStart);
    trialMatrix = data(sessionIdx).trialMatrix(trialSkip:end, :);
    if ~isempty(data(sessionIdx).alignInfo)
        alignInfoX = data(sessionIdx).alignInfo(:, 1);
        alignInfoY = data(sessionIdx).alignInfo(:, 2);
    else
        alignInfoX = nan(1, length(dff));
        alignInfoY = nan(1, length(dff));
    end
    lickTimesRelative = data(sessionIdx).licks(trialSkip:end, :);
    waterTimesRelative = data(sessionIdx).waterTime(trialSkip: end);
    skipStartFrame = floor(trialStart(1)*pfs);
    
    thetaTrials = data(sessionIdx).theta(trialSkip:end);
    amplitudeTrials = data(sessionIdx).amplitude(trialSkip:end);
    setpointTrials = data(sessionIdx).setpoint(trialSkip:end);
    phaseTrials = data(sessionIdx).phase(trialSkip:end);
    
    % DEBUG
    if length(trialStart) > length(lickTimesRelative)
        trialStart = trialStart(1:end-1);
        trialEnd = trialEnd(1:end-1);
        nTrials = length(trialStart);
    end
    
    % get absolute times
    lickTimes = [];
    waterTimes = [];
    poleOnset = [];
    poleDown = [];
    wtAxis = [];
    theta = [];
    amplitude = [];
    setpoint = [];
    phase = [];
    for i = 1:length(trialStart)
        lickTimes = [lickTimes, lickTimesRelative{i}'+trialStart(i)];
        waterTimes = [waterTimes, waterTimesRelative{i}'+trialStart(i)];
        poleOnset = [poleOnset, poleOnsetRelative{i}+trialStart(i)];
        poleDown = [poleDown, poleDownRelative{i}+trialStart(i)];
        wtAxis = [wtAxis, ((1:length(thetaTrials{i}))./wFs)+trialStart(i)];
        theta = [theta, thetaTrials{i}];
        amplitude = [amplitude, amplitudeTrials{i}];
        setpoint = [setpoint setpointTrials{i}];
        phase = [phase phaseTrials{i}];
    end
    
    % split to first lick and other lick times
    firstLickTimes = [];
    otherLickTimes = [];
    for i = 1:length(trialStart)
        trialLicks = lickTimes(lickTimes >= trialStart(i) & lickTimes <= trialEnd(i));
        if ~isempty(trialLicks)
            firstLickTimes = [firstLickTimes, trialLicks(1)];
%             otherLickTimes = [otherLickTimes, trialLicks(2:end)];
        end
    end
    
    otherLickTimes = setdiff(lickTimes, firstLickTimes);

    % vectorize times
    lickTimesVec = zeros(1, length(dff));
    firstLickTimesVec = zeros(1, length(dff));
    otherLickTimesVec = zeros(1, length(dff));
    waterTimesVec = zeros(1, length(dff));
    for i = 1:length(lickTimes)
        vecPoint = find(tAxis>=lickTimes(i), 1);
        lickTimesVec(vecPoint) = 1;
    end
    
    for i = 1:length(waterTimes)
        vecPoint = find(tAxis>=waterTimes(i), 1);
        waterTimesVec(vecPoint) = 1;
    end
    
    for i = 1:length(firstLickTimes)
        vecPoint = find(tAxis>=firstLickTimes(i), 1);
        firstLickTimesVec(vecPoint) = 1;
    end
    
    for i = 1:length(otherLickTimes)
        vecPoint = find(tAxis>=otherLickTimes(i), 1);
        otherLickTimesVec(vecPoint) = 1;
    end
    
    poleOnsetVec = zeros(1, length(dff));
    poleDownVec  = zeros(1, length(dff));
    for i = 1:nTrials   
        vecPoint = find(tAxis>=poleOnset(i), 1);
        poleOnsetVec(vecPoint) = 1;
        
        vecPoint = find(tAxis>=poleDown(i), 1);
        poleDownVec(vecPoint) = 1;
    end
    
    % we're downsampling whisker data here to align to imaging, should be
    % the other way round! TODO
    thetaVec = zeros(1, length(dff));
    amplitudeVec = zeros(1, length(dff));
    setpointVec = zeros(1, length(dff));
    phaseVec = zeros(1, length(dff));
    for i = 1:length(dff)
        tPoint = find(tAxis(i)<=wtAxis, 1);
        if ~isempty(tPoint)
            thetaVec(i) = theta(tPoint);
            amplitudeVec(i) = amplitude(tPoint);
            setpointVec(i) = setpoint(tPoint);
            phaseVec(i) = phase(tPoint);
        end
    end
    
    % save to output struct
    sessionStruct.dff = dff';
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
    sessionStruct.firstLickTimes = firstLickTimes;
    sessionStruct.otherLickTimes = otherLickTimes;
    sessionStruct.waterTimes = waterTimes;
    sessionStruct.poleOnset = poleOnset;
    sessionStruct.poleDown = poleDown;
    
    sessionStruct.lickTimesVec = lickTimesVec;
    sessionStruct.firstLickTimesVec = firstLickTimesVec;
    sessionStruct.otherLickTimesVec = otherLickTimesVec;
    sessionStruct.waterTimesVec = waterTimesVec;
    sessionStruct.poleOnsetVec = poleOnsetVec;
    sessionStruct.poleDownVec = poleDownVec;
    
    sessionStruct.thetaVec = thetaVec;
    sessionStruct.amplitudeVec = amplitudeVec;
    sessionStruct.setpointVec = setpointVec;
    sessionStruct.phaseVec = phaseVec;
    
    sessionStruct.correctRate = data(sessionIdx).CorrectRate;
    
    if verbose
        % plot timings
        figure; hold on;
        plot(tAxis, dff, 'k');
        plot(tAxis, firstLickTimesVec, 'b');
        plot(tAxis, otherLickTimesVec, 'm');
        plot(tAxis, poleOnsetVec, 'g');
        plot(tAxis, waterTimesVec-1, 'y');
        plot(tAxis, thetaVec./100, 'm');
        plot([tAxis(skipStartFrame) tAxis(skipStartFrame)], [0, 1], 'g--')
        scatter(trialStart, ones(1,length(trialStart)), 'r.');
        scatter(trialEnd, ones(1,length(trialEnd)), 'ro');
        scatter(lickTimes, ones(1,length(lickTimes)), 'b.');
        scatter(poleOnset, ones(1,length(poleOnset)), 'g.');
    end
end

