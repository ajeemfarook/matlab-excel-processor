function [Mean,SD,Med,Q1,Q3,IQR] = stat_functions(Data)
%STAT Compute basic statistics for a data vector
%   Returns: Mean, Standard Deviation, Median, Q1, Q3, IQR

    % Convert cell array to numeric if needed
    if iscell(Data)
        Data = str2double(Data);
    end
    
    % Remove NaN values
    Data = Data(~isnan(Data));
    
    % Compute statistics
    Mean = mean(Data);
    SD = std(Data, 0);  % Population std dev (STDEV.P equivalent)
    Q = quantile(Data, [0.25, 0.5, 0.75]);
    
    Q1 = Q(1);
    Med = Q(2);
    Q3 = Q(3);
    IQR = Q3 - Q1;
end
