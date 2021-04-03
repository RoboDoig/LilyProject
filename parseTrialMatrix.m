function [trialOutcome] = parseTrialMatrix(trialMatrix)
    % for a trial matrix with 4 one-hot columns (hit, miss, fa, cr) - parse as
    % a single number per trial showing trial outcome (1 = hit, 2 = miss, 3 =
    % fa, 4 = cr)
    nTrials = size(trialMatrix, 1);
    trialOutcome = nan(1, nTrials);
    for i = 1:nTrials
        trialOutcome(i) = find(trialMatrix(i, :)==1);
    end
end

