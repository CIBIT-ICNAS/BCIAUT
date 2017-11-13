function [ filtData ] = applyFilter( data, W )
%APPLYFILTER This function applies W'*data for every trial
%   data - EEG signal of size [nch, epochsize, ntrials]
%   W    - weight matrix (filter) to apply, of size [nch, nweights]
    
    filtData = nan(size(W, 2), size(data, 2), size(data, 3));

    for t = 1:size(data, 3)
        filtData(:,:,t) = W'*data(:,:,t);
    end
end

