function [tValues] = thermometerize(values, nLevels)
%THERMOMETERIZE Descretizes values using the thermometer method
%   Receives the values to descretize
    if nargin < 2
        nLevels = 5;
    end

    dValues = discretize(values, nLevels+1);
    dValues(isnan(dValues)) = 0;
    
    tValues = zeros(length(values), nLevels);
    for i=1:length(dValues)
        tValues(i, 1:dValues(i)-1) = 1;
    end

end
