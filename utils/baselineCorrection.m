function [EEG] = baselineCorrection(EEG, xmin, xmax)
%BASELINECORRECTION Subtracts each epoch by the mean of the baseline
%   Recives the EEG structure and the minimum and maximum time of the baseline, in seconds


    baselineIdx = EEG.times >= xmin & EEG.times < xmax;
    
    baseline = mean(EEG.data(:, baselineIdx, :), 2);

    EEG.data = EEG.data - repmat(baseline, [1 size(EEG.data, 2) 1]);

end