function [dff] = dffFromTrace(trace)
    % Given a raw fluorescence trace, detrend and calculate dff
    [eUp, eLow] = envelope(trace, 500, 'peaks');
    trace = (trace-eLow)+1000; % add 1000 to avoid negative F0 values after detrending
    f0 = prctile(trace, 8);
    dff = (trace-f0)./f0;
    
%     trace = detrend(trace) + 1000; % add 1000 to avoid negative F0 values after detrending
%     f0 = prctile(trace, 8);
%     dff = (trace-f0)./f0;
end

