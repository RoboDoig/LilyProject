function [fit, fullDesignMatrix, y, yHat] = buildGLM(inputVectors, windowSizes, responseVector, startFrame, endFrame, verbose)
    y = responseVector;

    % create design matrix
    fullDesignMatrix = [];
    for v = 1:size(inputVectors, 1)
        d = windowSizes(v); % get window size for this input
        designMatrix = nan(length(startFrame:endFrame), d); % make a new design matrix
        iV = inputVectors(v, :); % get the current input vector
        c = 1;
        for i = startFrame:endFrame
           inputWindow = iV((i-d+1):i); % slice the input up to current time
           designMatrix(c, :) = inputWindow; % add to design matrix
           c = c+1;
        end
        fullDesignMatrix = [fullDesignMatrix, designMatrix];
    end
    
    % fit model
    fit = glmnet(fullDesignMatrix, y(startFrame:endFrame));
    yHat = glmnetPredict(fit, fullDesignMatrix);
    
    if verbose
       glmnetPrint(fit);
    end
end

