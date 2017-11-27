function [EEG] = normalizeTrials(EEG, method)
%NORMALIZETRIALS Normalizes EEG epochs
%   EEG epochs are normalized using the method provided
%   method - [mean, zscore] mean subtracts te average mean of the epoch, zscore subtracts the mean 
%               and divides by the standard deviation

    avgEEG = nanmean(EEG.data, 2);
    EEG.data = EEG.data - repmat(avgEEG, [1 size(EEG.data, 2) 1]);

    if strcmp(method, 'zscore')
        stdEEG = nanstd(EEG.data, [], 2) + 1E7;
        EEG.data = EEG.data ./ repmat(stdEEG, [1 size(EEG.data, 2) 1]);
    end
end