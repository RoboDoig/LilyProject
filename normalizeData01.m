function [updatedData] = normalizeData01(data, field)

    updatedData = data;
    nSessions = length(updatedData.summary);
    
    minVal = Inf;
    maxVal = -Inf;
    
    % find max and min vals
    for i = 1:nSessions
        thisSession = updatedData.summary(i).(field);
        if ~isempty(thisSession)
            for j = 1:length(thisSession)
                mi = min(thisSession{j});
                ma = max(thisSession{j});
                
                if mi < minVal
                    minVal = mi;
                end
                
                if ma > maxVal
                    maxVal = ma;
                end
            end
        end
    end
    
    % do normalization based on max and min vals
    for i = 1:nSessions
         thisSession = updatedData.summary(i).(field);
         if ~isempty(thisSession)
             for j = 1:length(thisSession)
                 updatedData.summary(i).(field){j} = (thisSession{j} - minVal) ./ (maxVal - minVal);
             end
         end
    end
end

