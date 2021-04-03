function [trialAligned] = splitToTrials(trace, trialStart, trialEnd)
    % Given a data trace, and corresponding trial start/end times, reshape into a
    % matrix in which each row is a separate trial
    nTrials = length(trialStart);
    maxTrialLength = max(trialEnd - trialStart);
    trialAligned = nan(nTrials, maxTrialLength);
    
    for i = 1:length(trialStart)
       sT = trialStart(i);
       eT = trialEnd(i);
       thisTrial = trace(sT:eT);
       trialAligned(i, 1:length(thisTrial)) = thisTrial;
    end
end

