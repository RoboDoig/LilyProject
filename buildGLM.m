function [fit, fullDesignMatrix, y, yHat] = buildGLM(inputVectors, windowSizes, timeLags, responseVector, framePeriod, verbose)
    y = responseVector;

    % create design matrix
    fullDesignMatrix = [];
    for v = 1:size(inputVectors, 1)
        d = windowSizes(v); % get window size for this input
        designMatrix = nan(length(framePeriod), d); % make a new design matrix
        iV = inputVectors(v, :); % get the current input vector
        c = 1;
        for i = framePeriod
%            inputWindow = iV((i-d+1):i); % slice the input up to current time
           inputWindow = iV(((i-d+1):i)+timeLags(v)); % slice the input up to current time with time lag
           designMatrix(c, :) = inputWindow; % add to design matrix
           c = c+1;
        end
        fullDesignMatrix = [fullDesignMatrix, designMatrix];
    end
    
    % fit model
    options = glmnetSet;
    options.alpha = 0.5;
    options.standardize = 1;
    options.nlambda = 200;
%     options.intr = 0;
    fit = glmnet(fullDesignMatrix, y(framePeriod), 'gaussian', options);
    yHat = glmnetPredict(fit, fullDesignMatrix);
    
    if verbose
       glmnetPrint(fit);
    end
end

